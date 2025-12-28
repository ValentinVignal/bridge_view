use core_foundation::base::{CFRelease, CFTypeRef};
use core_graphics::display::CGDirectDisplayID;
use core_graphics::image::CGImage;

/// Simple screen capture using CGDisplayCreateImage
pub struct SimpleCapture {
    display_id: CGDirectDisplayID,
}

impl SimpleCapture {
    pub fn new(display_id: CGDirectDisplayID) -> Self {
        Self { display_id }
    }

    /// Capture a single frame from the display
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

        // Release the image
        unsafe { CFRelease(image_ref as CFTypeRef) };

        Ok(CapturedImage {
            width,
            height,
            bits_per_component,
            bits_per_pixel,
            bytes_per_row,
        })
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
}

// External C functions
unsafe extern "C" {
    fn CGDisplayCreateImage(display: CGDirectDisplayID) -> *mut CGImage;
    fn CGImageGetWidth(image: *mut CGImage) -> usize;
    fn CGImageGetHeight(image: *mut CGImage) -> usize;
    fn CGImageGetBitsPerComponent(image: *mut CGImage) -> usize;
    fn CGImageGetBitsPerPixel(image: *mut CGImage) -> usize;
    fn CGImageGetBytesPerRow(image: *mut CGImage) -> usize;
}
