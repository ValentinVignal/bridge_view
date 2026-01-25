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

    // Test continuous capture with frame rate limiting
    println!("\n=== Testing Continuous Capture with Frame Rate Limiting ===\n");
    test_continuous_capture();

    // Test capture performance and optimizations
    println!("\n=== Testing Capture Performance ===\n");
    test_capture_performance();

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

    // Capture a few frames and test format conversions
    for i in 1..=3 {
        match capture.capture_frame() {
            Ok(image) => {
                println!("\nFrame #{}: {}", i, image.format());
                println!("  Raw data size: {} bytes", image.data_size());

                // Test RGB conversion
                match image.to_rgb() {
                    Ok(rgb_data) => {
                        println!("  RGB conversion: {} bytes", rgb_data.len());
                        // Print first pixel
                        if rgb_data.len() >= 3 {
                            println!(
                                "  First pixel RGB: [{}, {}, {}]",
                                rgb_data[0], rgb_data[1], rgb_data[2]
                            );
                        }
                    }
                    Err(e) => eprintln!("  RGB conversion error: {}", e),
                }

                // Test I420 conversion
                match image.to_i420() {
                    Ok(i420_data) => {
                        println!("  I420 conversion: {} bytes", i420_data.len());
                        let y_size = image.width * image.height;
                        let uv_size = (image.width / 2) * (image.height / 2);
                        println!(
                            "  I420 planes: Y={} bytes, U={} bytes, V={} bytes",
                            y_size, uv_size, uv_size
                        );
                        // Print first Y, U, V values
                        if i420_data.len() >= y_size + uv_size * 2 {
                            println!(
                                "  First pixel YUV: Y={}, U={}, V={}",
                                i420_data[0],
                                i420_data[y_size],
                                i420_data[y_size + uv_size]
                            );
                        }
                    }
                    Err(e) => eprintln!("  I420 conversion error: {}", e),
                }
            }
            Err(e) => {
                eprintln!("Error capturing frame: {}", e);
                return;
            }
        }

        if i < 3 {
            thread::sleep(Duration::from_millis(500));
        }
    }

    println!("\nSimple capture test completed successfully!");
}

fn test_continuous_capture() {
    let main_display = CGDisplay::main();
    let display_id = main_display.id;

    println!(
        "Testing continuous capture at 30 fps on display {}",
        display_id
    );

    let capture = SimpleCapture::new(display_id);

    // Track frame statistics
    let frame_count = std::sync::Arc::new(std::sync::atomic::AtomicU64::new(0));
    let frame_count_clone = frame_count.clone();

    // Start continuous capture at 30 fps
    let mut handle = capture.capture_continuous(30.0, move |image, stats| {
        let count = frame_count_clone.fetch_add(1, std::sync::atomic::Ordering::Relaxed) + 1;

        // Print details for first frame only
        if count == 1 {
            println!("  First frame: {}", image.format());
            println!("  Data size: {} bytes", image.data_size());
            println!(
                "  Capture took: {:.1}ms\n",
                stats.capture_duration.as_secs_f64() * 1000.0
            );
        }
    });

    // Run for 3 seconds
    println!("Capturing at 30 fps target for 3 seconds...\n");
    thread::sleep(Duration::from_secs(3));

    // Stop capture
    handle.stop();

    let total_frames = frame_count.load(std::sync::atomic::Ordering::Relaxed);
    let actual_fps = total_frames as f64 / 3.0;

    println!(
        "\n✓ Continuous capture test completed: {} frames captured ({:.1} fps average)",
        total_frames, actual_fps
    );

    // Note about performance
    if actual_fps < 25.0 {
        println!("  Note: Actual FPS is limited by CGDisplayCreateImage performance");
        println!("        on high-resolution Retina displays (~70ms per frame).");
        println!("        This will improve with hardware encoding in Phase 2.3.");
    }
}

fn test_capture_performance() {
    let main_display = CGDisplay::main();
    let display_id = main_display.id;

    println!("Running performance benchmark on display {}", display_id);

    let capture = SimpleCapture::new(display_id);

    // Benchmark: Frame capture only
    println!("\n1. Frame Capture Performance:");
    let mut capture_times = Vec::new();
    for i in 1..=10 {
        let start = std::time::Instant::now();
        match capture.capture_frame() {
            Ok(image) => {
                let duration = start.elapsed();
                capture_times.push(duration.as_secs_f64() * 1000.0);

                if i == 1 {
                    println!("   Frame size: {}x{}", image.width, image.height);
                    println!(
                        "   Raw data: {:.2} MB",
                        image.data_size() as f64 / 1_048_576.0
                    );
                }
            }
            Err(e) => {
                eprintln!("   Capture error: {}", e);
                return;
            }
        }
    }

    let avg_capture = capture_times.iter().sum::<f64>() / capture_times.len() as f64;
    let min_capture = capture_times.iter().cloned().fold(f64::INFINITY, f64::min);
    let max_capture = capture_times
        .iter()
        .cloned()
        .fold(f64::NEG_INFINITY, f64::max);
    println!(
        "   Capture time: avg {:.1}ms, min {:.1}ms, max {:.1}ms",
        avg_capture, min_capture, max_capture
    );
    println!("   Max theoretical FPS: {:.1}", 1000.0 / avg_capture);

    // Benchmark: RGB conversion
    println!("\n2. RGB Conversion Performance:");
    let image = capture.capture_frame().unwrap();
    let mut rgb_times = Vec::new();
    for _ in 1..=10 {
        let start = std::time::Instant::now();
        let rgb_data = image.to_rgb().unwrap();
        let duration = start.elapsed();
        rgb_times.push(duration.as_secs_f64() * 1000.0);

        if rgb_times.len() == 1 {
            println!("   RGB data: {:.2} MB", rgb_data.len() as f64 / 1_048_576.0);
        }
    }

    let avg_rgb = rgb_times.iter().sum::<f64>() / rgb_times.len() as f64;
    println!("   RGB conversion: avg {:.1}ms", avg_rgb);

    // Benchmark: I420 conversion
    println!("\n3. I420 (YUV) Conversion Performance:");
    let mut i420_times = Vec::new();
    for _ in 1..=10 {
        let start = std::time::Instant::now();
        let i420_data = image.to_i420().unwrap();
        let duration = start.elapsed();
        i420_times.push(duration.as_secs_f64() * 1000.0);

        if i420_times.len() == 1 {
            println!(
                "   I420 data: {:.2} MB",
                i420_data.len() as f64 / 1_048_576.0
            );
            let compression_ratio = image.data_size() as f64 / i420_data.len() as f64;
            println!("   Compression: {:.1}x smaller than raw", compression_ratio);
        }
    }

    let avg_i420 = i420_times.iter().sum::<f64>() / i420_times.len() as f64;
    println!("   I420 conversion: avg {:.1}ms", avg_i420);

    // Overall pipeline performance
    println!("\n4. Complete Pipeline (Capture + Convert to I420):");
    let total_time = avg_capture + avg_i420;
    let pipeline_fps = 1000.0 / total_time;
    println!("   Total time: {:.1}ms", total_time);
    println!("   Pipeline FPS: {:.1}", pipeline_fps);

    // Memory bandwidth analysis
    println!("\n5. Memory Bandwidth:");
    let bytes_per_frame = image.data_size();
    let bandwidth_mbps = (bytes_per_frame as f64 / 1_048_576.0) / (avg_capture / 1000.0);
    println!("   Read bandwidth: {:.1} MB/s", bandwidth_mbps);

    // Optimization recommendations
    println!("\n6. Optimization Summary:");
    if avg_capture > 50.0 {
        println!("   ⚠ Capture is the main bottleneck ({:.1}ms)", avg_capture);
        println!("   → Consider switching to CGDisplayStream for better performance");
        println!("   → Or reduce capture resolution");
    }
    if avg_i420 > 20.0 {
        println!("   ⚠ I420 conversion is slow ({:.1}ms)", avg_i420);
        println!("   → Consider using SIMD optimizations or GPU acceleration");
    }
    if pipeline_fps >= 30.0 {
        println!("   ✓ Pipeline can sustain 30 fps target");
    } else if pipeline_fps >= 24.0 {
        println!("   ⚠ Pipeline can sustain 24 fps (cinematic)");
    } else {
        println!(
            "   ⚠ Pipeline too slow for real-time video ({:.1} fps)",
            pipeline_fps
        );
    }

    println!("\nPerformance testing completed!");
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
