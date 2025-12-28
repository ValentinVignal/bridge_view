use block::ConcreteBlock;
use core_foundation::base::{CFRelease, CFTypeRef, TCFType};
use core_foundation::dictionary::CFDictionaryRef;
use core_foundation::number::CFNumber;
use core_foundation::string::CFString;
use core_graphics::display::{CGDirectDisplayID, CGDisplay};
use std::os::raw::c_void;
use std::sync::{Arc, Mutex};

/// Configuration for display capture
#[derive(Debug, Clone)]
pub struct CaptureConfig {
    /// Target frame rate (frames per second)
    pub frame_rate: f64,
    /// Display ID to capture
    pub display_id: CGDirectDisplayID,
    /// Width of the capture (None = full display width)
    pub width: Option<usize>,
    /// Height of the capture (None = full display height)
    pub height: Option<usize>,
}

impl CaptureConfig {
    pub fn new(display_id: CGDirectDisplayID) -> Self {
        Self {
            frame_rate: 30.0,
            display_id,
            width: None,
            height: None,
        }
    }

    pub fn with_frame_rate(mut self, frame_rate: f64) -> Self {
        self.frame_rate = frame_rate;
        self
    }
}

/// Frame data captured from the display
#[derive(Debug)]
pub struct CapturedFrame {
    pub width: usize,
    pub height: usize,
    pub bytes_per_row: usize,
    pub timestamp: f64,
    pub data: Vec<u8>,
}

/// Callback type for captured frames
pub type FrameCallback = Box<dyn FnMut(CapturedFrame) + Send + 'static>;

/// Display capture using CGDisplayStream
pub struct DisplayCapture {
    stream: Option<CGDisplayStreamRef>,
    config: CaptureConfig,
    _callback: Arc<Mutex<Option<FrameCallback>>>, // Keep reference alive but unused for now
}

// Opaque type for CGDisplayStream
#[repr(C)]
pub struct __CGDisplayStream {
    _private: [u8; 0],
}
pub type CGDisplayStreamRef = *mut __CGDisplayStream;

// Opaque type for IOSurface
#[repr(C)]
pub struct __IOSurface {
    _private: [u8; 0],
}
pub type IOSurfaceRef = *mut __IOSurface;

// Frame status enum
#[repr(C)]
pub enum CGDisplayStreamFrameStatus {
    FrameComplete = 0,
    FrameIdle = 1,
    FrameBlank = 2,
    Stopped = 3,
}

// External C functions from CoreGraphics/CoreMedia
#[link(name = "CoreGraphics", kind = "framework")]
#[link(name = "IOSurface", kind = "framework")]
unsafe extern "C" {
    fn CGDisplayStreamCreateWithDispatchQueue(
        display: CGDirectDisplayID,
        output_width: usize,
        output_height: usize,
        pixel_format: u32,
        properties: CFDictionaryRef,
        queue: *mut c_void,
        handler: *const c_void,
    ) -> CGDisplayStreamRef;

    fn CGDisplayStreamStart(stream: CGDisplayStreamRef) -> i32;
    fn CGDisplayStreamStop(stream: CGDisplayStreamRef) -> i32;

    fn IOSurfaceGetWidth(surface: IOSurfaceRef) -> usize;
    fn IOSurfaceGetHeight(surface: IOSurfaceRef) -> usize;
    fn IOSurfaceGetBytesPerRow(surface: IOSurfaceRef) -> usize;
    fn IOSurfaceGetBaseAddress(surface: IOSurfaceRef) -> *const u8;
    fn IOSurfaceLock(surface: IOSurfaceRef, options: u32, seed: *mut u32) -> i32;
    fn IOSurfaceUnlock(surface: IOSurfaceRef, options: u32, seed: *mut u32) -> i32;

    fn dispatch_get_global_queue(priority: isize, flags: usize) -> *mut c_void;
}

// Pixel format constant for 32-bit BGRA
const K_CV_PIXEL_FORMAT_TYPE_32_BGRA: u32 = 0x42475241; // 'BGRA'
const DISPATCH_QUEUE_PRIORITY_DEFAULT: isize = 0;

impl DisplayCapture {
    /// Create a new display capture instance
    pub fn new(config: CaptureConfig) -> Result<Self, String> {
        Ok(Self {
            stream: None,
            config,
            _callback: Arc::new(Mutex::new(None)),
        })
    }

    /// Set the callback for captured frames
    pub fn set_callback<F>(&mut self, callback: F)
    where
        F: FnMut(CapturedFrame) + Send + 'static,
    {
        *self._callback.lock().unwrap() = Some(Box::new(callback));
    }

    /// Start capturing frames from the display
    pub fn start(&mut self) -> Result<(), String> {
        if self.stream.is_some() {
            return Err("Capture already started".to_string());
        }

        let display = CGDisplay::new(self.config.display_id);
        let bounds = display.bounds();

        let width = self.config.width.unwrap_or(bounds.size.width as usize);
        let height = self.config.height.unwrap_or(bounds.size.height as usize);

        println!(
            "Starting capture for display {} ({}x{})",
            self.config.display_id, width, height
        );

        // Create properties dictionary for the stream
        let properties = create_stream_properties(self.config.frame_rate);

        // Get the global dispatch queue
        let queue = unsafe { dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) };

        if queue.is_null() {
            return Err("Failed to get dispatch queue".to_string());
        }

        // For now, use a simple callback that just logs frame info
        // This avoids the complexity of closures until we get the basic capture working
        let block = ConcreteBlock::new(
            |status: CGDisplayStreamFrameStatus,
             display_time: f64,
             surface: IOSurfaceRef,
             _update_ref: *mut c_void| {
                match status {
                    CGDisplayStreamFrameStatus::FrameComplete => {
                        if !surface.is_null() {
                            let width = unsafe { IOSurfaceGetWidth(surface) };
                            let height = unsafe { IOSurfaceGetHeight(surface) };
                            let bytes_per_row = unsafe { IOSurfaceGetBytesPerRow(surface) };
                            println!(
                                "Frame: {}x{} ({} bytes/row) @ {:.3}s",
                                width, height, bytes_per_row, display_time
                            );
                        }
                    }
                    CGDisplayStreamFrameStatus::FrameIdle => {}
                    CGDisplayStreamFrameStatus::FrameBlank => {}
                    CGDisplayStreamFrameStatus::Stopped => {
                        println!("Stream stopped callback");
                    }
                }
            },
        );
        let block = block.copy();

        // Create the display stream
        let stream = unsafe {
            CGDisplayStreamCreateWithDispatchQueue(
                self.config.display_id,
                width,
                height,
                K_CV_PIXEL_FORMAT_TYPE_32_BGRA,
                properties,
                queue,
                &*block as *const _ as *const c_void,
            )
        };

        if stream.is_null() {
            return Err("Failed to create display stream".to_string());
        }

        // Start the stream
        let result = unsafe { CGDisplayStreamStart(stream) };
        if result != 0 {
            unsafe {
                CFRelease(stream as CFTypeRef);
            }
            return Err(format!("Failed to start display stream: {}", result));
        }

        self.stream = Some(stream);
        println!("Display stream started successfully");

        Ok(())
    }

    /// Stop capturing frames
    pub fn stop(&mut self) {
        if let Some(stream) = self.stream.take() {
            unsafe {
                CGDisplayStreamStop(stream);
                CFRelease(stream as CFTypeRef);
            }
            println!("Display stream stopped");
        }
    }
}

impl Drop for DisplayCapture {
    fn drop(&mut self) {
        self.stop();
    }
}

// Create properties dictionary for the stream
fn create_stream_properties(min_frame_time: f64) -> CFDictionaryRef {
    use core_foundation::dictionary::CFMutableDictionary;

    let key = unsafe {
        CFString::wrap_under_get_rule("kCGDisplayStreamMinimumFrameTime\0".as_ptr() as *const _)
    };

    let value = CFNumber::from(1.0 / min_frame_time);

    let mut dict = CFMutableDictionary::new();
    dict.set(key, value);

    dict.as_concrete_TypeRef()
}
