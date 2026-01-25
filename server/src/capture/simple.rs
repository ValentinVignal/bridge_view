use core_foundation::base::{CFRelease, CFTypeRef};
use core_graphics::display::CGDirectDisplayID;
use core_graphics::image::CGImage;
use std::slice;
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::thread;
use std::time::{Duration, Instant};

/// Simple screen capture using CGDisplayCreateImage
pub struct SimpleCapture {
    display_id: CGDirectDisplayID,
}

impl SimpleCapture {
    pub fn new(display_id: CGDirectDisplayID) -> Self {
        Self { display_id }
    }

    /// Capture a single frame from the display with pixel data
    pub fn capture_frame(&self) -> Result<CapturedImage, String> {
        let image_ref = unsafe { CGDisplayCreateImage(self.display_id) };

        if image_ref.is_null() {
            return Err("Failed to capture display image. You may need to grant Screen Recording permission in System Settings > Privacy & Security".to_string());
        }

        // Get image properties
        let width = unsafe { CGImageGetWidth(image_ref) };
        let height = unsafe { CGImageGetHeight(image_ref) };
        let bits_per_component = unsafe { CGImageGetBitsPerComponent(image_ref) };
        let bits_per_pixel = unsafe { CGImageGetBitsPerPixel(image_ref) };
        let bytes_per_row = unsafe { CGImageGetBytesPerRow(image_ref) };

        // Get the pixel data
        let data_provider = unsafe { CGImageGetDataProvider(image_ref) };
        if data_provider.is_null() {
            unsafe { CFRelease(image_ref as CFTypeRef) };
            return Err("Failed to get data provider from image".to_string());
        }

        let cf_data = unsafe { CGDataProviderCopyData(data_provider) };
        if cf_data.is_null() {
            unsafe { CFRelease(image_ref as CFTypeRef) };
            return Err("Failed to copy data from data provider".to_string());
        }

        // Get pointer to the raw bytes
        let data_ptr = unsafe { CFDataGetBytePtr(cf_data) };
        let data_length = unsafe { CFDataGetLength(cf_data) };

        // Copy the pixel data into a Vec
        let pixel_data = unsafe { slice::from_raw_parts(data_ptr, data_length as usize).to_vec() };

        // Release resources
        unsafe {
            CFRelease(cf_data as CFTypeRef);
            CFRelease(image_ref as CFTypeRef);
        }

        Ok(CapturedImage {
            width,
            height,
            bits_per_component,
            bits_per_pixel,
            bytes_per_row,
            pixel_data,
        })
    }

    /// Capture frames continuously at a specified frame rate
    ///
    /// Returns a handle that can be used to stop the capture
    pub fn capture_continuous<F>(&self, target_fps: f64, mut callback: F) -> ContinuousCaptureHandle
    where
        F: FnMut(CapturedImage, CaptureStats) + Send + 'static,
    {
        let display_id = self.display_id;
        let running = Arc::new(AtomicBool::new(true));
        let running_clone = running.clone();

        let handle = thread::spawn(move || {
            let frame_duration = Duration::from_secs_f64(1.0 / target_fps);
            let mut frame_count = 0u64;
            let start_time = Instant::now();
            let mut last_stats_time = Instant::now();
            let mut stats_frame_count = 0u64;

            while running_clone.load(Ordering::Relaxed) {
                let frame_start = Instant::now();

                // Capture frame
                let capture = SimpleCapture::new(display_id);
                match capture.capture_frame() {
                    Ok(image) => {
                        frame_count += 1;
                        stats_frame_count += 1;

                        let capture_time = frame_start.elapsed();
                        let total_elapsed = start_time.elapsed();

                        let stats = CaptureStats {
                            frame_number: frame_count,
                            capture_duration: capture_time,
                            total_elapsed,
                            average_fps: frame_count as f64 / total_elapsed.as_secs_f64(),
                        };

                        callback(image, stats);
                    }
                    Err(e) => {
                        eprintln!("Frame capture error: {}", e);
                        break;
                    }
                }

                // Calculate sleep duration to maintain target frame rate
                let elapsed = frame_start.elapsed();
                if elapsed < frame_duration {
                    thread::sleep(frame_duration - elapsed);
                }

                // Log stats every second
                let now = Instant::now();
                if now.duration_since(last_stats_time).as_secs() >= 1 {
                    let period_duration = now.duration_since(last_stats_time).as_secs_f64();
                    let period_fps = stats_frame_count as f64 / period_duration;
                    let total_elapsed = start_time.elapsed().as_secs_f64();
                    let average_fps = frame_count as f64 / total_elapsed;

                    println!(
                        "Capture: {} frames total, avg {:.1} fps, last second {:.1} fps",
                        frame_count, average_fps, period_fps
                    );

                    last_stats_time = now;
                    stats_frame_count = 0;
                }
            }

            println!("Continuous capture stopped after {} frames", frame_count);
        });

        ContinuousCaptureHandle {
            running,
            thread_handle: Some(handle),
        }
    }
}

/// Statistics about a captured frame
#[derive(Debug, Clone)]
pub struct CaptureStats {
    pub frame_number: u64,
    pub capture_duration: Duration,
    pub total_elapsed: Duration,
    pub average_fps: f64,
}

/// Handle for controlling continuous capture
pub struct ContinuousCaptureHandle {
    running: Arc<AtomicBool>,
    thread_handle: Option<thread::JoinHandle<()>>,
}

impl ContinuousCaptureHandle {
    /// Stop the continuous capture
    pub fn stop(&mut self) {
        self.running.store(false, Ordering::Relaxed);
        if let Some(handle) = self.thread_handle.take() {
            let _ = handle.join();
        }
    }

    /// Check if capture is still running
    pub fn is_running(&self) -> bool {
        self.running.load(Ordering::Relaxed)
    }
}

impl Drop for ContinuousCaptureHandle {
    fn drop(&mut self) {
        self.stop();
    }
}

/// Information about a captured image
#[derive(Debug)]
pub struct CapturedImage {
    pub width: usize,
    pub height: usize,
    pub bits_per_component: usize,
    pub bits_per_pixel: usize,
    pub bytes_per_row: usize,
    pub pixel_data: Vec<u8>,
}

impl CapturedImage {
    /// Get the format description of the image
    pub fn format(&self) -> String {
        format!(
            "{}x{} @ {} bpc, {} bpp ({} bytes/row)",
            self.width,
            self.height,
            self.bits_per_component,
            self.bits_per_pixel,
            self.bytes_per_row
        )
    }

    /// Get the total size of the image data in bytes
    pub fn data_size(&self) -> usize {
        self.pixel_data.len()
    }

    /// Convert BGRA to RGB format
    /// macOS typically captures in BGRA format (32 bits per pixel)
    pub fn to_rgb(&self) -> Result<Vec<u8>, String> {
        if self.bits_per_pixel != 32 {
            return Err(format!(
                "Expected 32 bits per pixel for BGRA format, got {}",
                self.bits_per_pixel
            ));
        }

        let mut rgb_data = Vec::with_capacity(self.width * self.height * 3);

        // Convert BGRA to RGB
        for chunk in self.pixel_data.chunks_exact(4) {
            rgb_data.push(chunk[2]); // R (from B)
            rgb_data.push(chunk[1]); // G
            rgb_data.push(chunk[0]); // B (from R)
            // Skip alpha channel (chunk[3])
        }

        Ok(rgb_data)
    }

    /// Convert BGRA to I420 (YUV 4:2:0 planar) format
    /// This is a common format for video encoding
    /// Optimized version using integer arithmetic and iterators
    pub fn to_i420(&self) -> Result<Vec<u8>, String> {
        if self.bits_per_pixel != 32 {
            return Err(format!(
                "Expected 32 bits per pixel for BGRA format, got {}",
                self.bits_per_pixel
            ));
        }

        let width = self.width;
        let height = self.height;

        // I420 format: Y plane (full size) + U plane (quarter size) + V plane (quarter size)
        let y_size = width * height;
        let uv_size = (width / 2) * (height / 2);
        let mut i420_data = vec![0u8; y_size + uv_size * 2];

        // Split the buffer into mutable planes
        let (y_plane, uv_planes) = i420_data.split_at_mut(y_size);
        let (u_plane, v_plane) = uv_planes.split_at_mut(uv_size);

        // Process Y plane - convert all pixels
        for (i, bgra) in self.pixel_data.chunks_exact(4).enumerate() {
            let b = bgra[0] as i32;
            let g = bgra[1] as i32;
            let r = bgra[2] as i32;

            // Y = (77*R + 150*G + 29*B) >> 8
            y_plane[i] = ((77 * r + 150 * g + 29 * b) >> 8).clamp(0, 255) as u8;
        }

        // Process UV planes - subsample every 2x2 block
        for y in (0..height).step_by(2) {
            for x in (0..width).step_by(2) {
                let pixel_index = y * width + x;
                let bgra_index = pixel_index * 4;

                let b = self.pixel_data[bgra_index] as i32;
                let g = self.pixel_data[bgra_index + 1] as i32;
                let r = self.pixel_data[bgra_index + 2] as i32;

                // U = ((-43*R - 85*G + 128*B) >> 8) + 128
                let u_value = (((-43 * r - 85 * g + 128 * b) >> 8) + 128).clamp(0, 255) as u8;

                // V = ((128*R - 107*G - 21*B) >> 8) + 128
                let v_value = (((128 * r - 107 * g - 21 * b) >> 8) + 128).clamp(0, 255) as u8;

                let uv_index = (y / 2) * (width / 2) + (x / 2);
                u_plane[uv_index] = u_value;
                v_plane[uv_index] = v_value;
            }
        }

        Ok(i420_data)
    }
}

// External C functions
#[repr(C)]
struct CGDataProvider {
    _private: [u8; 0],
}

#[repr(C)]
struct CFData {
    _private: [u8; 0],
}

unsafe extern "C" {
    fn CGDisplayCreateImage(display: CGDirectDisplayID) -> *mut CGImage;
    fn CGImageGetWidth(image: *mut CGImage) -> usize;
    fn CGImageGetHeight(image: *mut CGImage) -> usize;
    fn CGImageGetBitsPerComponent(image: *mut CGImage) -> usize;
    fn CGImageGetBitsPerPixel(image: *mut CGImage) -> usize;
    fn CGImageGetBytesPerRow(image: *mut CGImage) -> usize;
    fn CGImageGetDataProvider(image: *mut CGImage) -> *mut CGDataProvider;
    fn CGDataProviderCopyData(provider: *mut CGDataProvider) -> *mut CFData;
    fn CFDataGetBytePtr(data: *mut CFData) -> *const u8;
    fn CFDataGetLength(data: *mut CFData) -> isize;
}
