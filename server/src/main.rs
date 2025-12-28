use core_graphics::display::CGDisplay;
use std::thread;
use std::time::Duration;

mod capture;
use capture::{CaptureConfig, DisplayCapture, SimpleCapture};

fn main() {
    println!("Bridge View Server - Display Capture Test\n");

    // Detect all connected displays
    detect_displays();

    // Test simple screen capture first
    println!("\n=== Testing Simple Screen Capture ===\n");
    test_simple_capture();

    // Test streaming screen capture
    println!("\n=== Testing Streaming Screen Capture ===\n");
    test_screen_capture();
}

fn detect_displays() {
    // Get the main display
    let main_display = CGDisplay::main();
    println!("Main Display:");
    print_display_info(&main_display, true);

    // Get all active displays
    match CGDisplay::active_displays() {
        Ok(displays) => {
            println!("\nTotal Active Displays: {}\n", displays.len());

            for (index, display_id) in displays.iter().enumerate() {
                let display = CGDisplay::new(*display_id);
                let is_main = display.id == main_display.id;
                println!("Display #{} (ID: {}):", index + 1, display_id);
                print_display_info(&display, is_main);
                println!();
            }
        }
        Err(e) => {
            eprintln!("Error getting active displays: {:?}", e);
        }
    }
}

fn print_display_info(display: &CGDisplay, is_main: bool) {
    let bounds = display.bounds();
    let mode = display.display_mode();

    println!("  Type: {}", if is_main { "Main" } else { "Extended" });
    println!("  ID: {}", display.id);
    println!("  Position: ({}, {})", bounds.origin.x, bounds.origin.y);
    println!("  Size: {}x{}", bounds.size.width, bounds.size.height);

    if let Some(mode) = mode {
        println!("  Resolution: {}x{}", mode.width(), mode.height());
        println!("  Refresh Rate: {} Hz", mode.refresh_rate());
        println!("  Pixel Encoding: {}", mode.pixel_encoding());
    }

    println!("  Built-in: {}", display.is_builtin());
    println!("  Active: {}", display.is_active());
    println!("  Online: {}", display.is_online());
    println!(
        "  Hardware Accelerated: {}",
        display.uses_open_gl_acceleration()
    );
}

fn test_simple_capture() {
    let main_display = CGDisplay::main();
    let display_id = main_display.id;

    println!("Testing simple capture on display {}", display_id);

    let capture = SimpleCapture::new(display_id);

    // Capture a few frames
    for i in 1..=5 {
        match capture.capture_frame() {
            Ok(image) => {
                println!(
                    "Frame #{}: {}x{} pixels, {} bits/pixel, {} bytes/row",
                    i, image.width, image.height, image.bits_per_pixel, image.bytes_per_row
                );
            }
            Err(e) => {
                eprintln!("Error capturing frame: {}", e);
                return;
            }
        }
        thread::sleep(Duration::from_millis(500));
    }

    println!("Simple capture test completed successfully!");
}

fn test_screen_capture() {
    // Get the main display
    let main_display = CGDisplay::main();
    let display_id = main_display.id;

    println!("Testing capture on main display (ID: {})", display_id);

    // Create capture configuration
    let config = CaptureConfig::new(display_id).with_frame_rate(30.0);

    // Create capture instance
    let mut capture = match DisplayCapture::new(config) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to create capture: {}", e);
            return;
        }
    };

    // Set up frame callback
    let mut frame_count = 0;
    capture.set_callback(move |frame| {
        frame_count += 1;
        println!(
            "Frame #{}: {}x{} pixels, {} bytes, timestamp: {:.3}s",
            frame_count,
            frame.width,
            frame.height,
            frame.data.len(),
            frame.timestamp
        );

        // Print first few bytes as a sanity check
        if frame_count == 1 && frame.data.len() >= 4 {
            println!(
                "  First pixel BGRA: [{}, {}, {}, {}]",
                frame.data[0], frame.data[1], frame.data[2], frame.data[3]
            );
        }
    });

    // Start capture
    if let Err(e) = capture.start() {
        eprintln!("Failed to start capture: {}", e);
        return;
    }

    // Capture for 5 seconds
    println!("Capturing frames for 5 seconds...");
    thread::sleep(Duration::from_secs(5));

    // Stop capture
    capture.stop();
    println!("Capture test completed");
}
