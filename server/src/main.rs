use core_graphics::display::CGDisplay;
use std::sync::Arc;
use std::thread;
use std::time::Duration;

mod capture;
mod connection;
mod encoder;
mod proto;

use capture::{CaptureConfig, DisplayCapture, SimpleCapture};
use connection::{ConnectionManager, ServerConfig, WebSocketServer};
use encoder::{
    EncoderConfig, EncoderQuality, EncodingQueue, FrameEncoder, QueueConfig, QueuedFrame,
};

fn main() {
    // Initialize logger
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .format_timestamp_millis()
        .init();

    let args: Vec<String> = std::env::args().collect();

    if args.len() > 1 && args[1] == "--server" {
        // Run in server mode - start WebSocket server
        run_server();
    } else {
        // Run legacy tests
        run_tests();
    }
}

fn run_server() {
    println!("Bridge View Server - Starting WebSocket Server\n");

    let config = ServerConfig::default();
    println!("Server configuration:");
    println!("  Bind address: {}", config.listen_addr());
    println!("  Max clients: {}", config.max_clients);
    println!(
        "  Heartbeat interval: {}s",
        config.heartbeat_interval_secs
    );
    println!("  Heartbeat timeout: {}s", config.heartbeat_timeout_secs);
    println!();

    let manager = Arc::new(ConnectionManager::new(config));
    let server = WebSocketServer::new(manager.clone());

    // Run the async server
    let rt = tokio::runtime::Runtime::new().expect("Failed to create Tokio runtime");
    rt.block_on(async {
        // Spawn a task to periodically print connection status
        let manager_status = manager.clone();
        tokio::spawn(async move {
            loop {
                tokio::time::sleep(tokio::time::Duration::from_secs(10)).await;
                let count = manager_status.client_count().await;
                let summary = manager_status.client_summary().await;
                log::info!("Connected clients: {}", count);
                for (session_id, desc, state) in &summary {
                    log::info!("  [{}] {} - {}", session_id, desc, state);
                }
            }
        });

        if let Err(e) = server.run().await {
            log::error!("Server error: {}", e);
        }
    });
}

fn run_tests() {
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

    // Test encoding with frame queue
    println!("\n=== Testing H.264 Encoding with Frame Queue ===\n");
    test_encoding_with_queue();

    // Benchmark encoding performance
    println!("\n=== Benchmarking Encoding Performance ===\n");
    test_encoding_performance();
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

    println!("\nStream capture test completed!");
}

fn test_encoding_with_queue() {
    let main_display = CGDisplay::main();
    let display_id = main_display.id;
    let bounds = main_display.bounds();

    println!(
        "Testing encoding with queue on display {} ({}x{})",
        display_id, bounds.size.width as usize, bounds.size.height as usize
    );

    // Configure encoder for medium quality
    let encoder_config =
        EncoderConfig::new(bounds.size.width as usize, bounds.size.height as usize)
            .with_fps(30.0)
            .with_quality(EncoderQuality::Medium)
            .with_low_latency(true);

    // Create encoding queue
    let queue_config = QueueConfig::default();
    let encoding_queue = match EncodingQueue::new(encoder_config, queue_config) {
        Ok(queue) => queue,
        Err(e) => {
            eprintln!("Failed to create encoding queue: {}", e);
            return;
        }
    };

    println!("\nCapturing and encoding for 10 seconds...");
    println!("Quality: Medium | Target FPS: 30");

    // Start capture thread
    let capture = SimpleCapture::new(display_id);
    let running = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(true));
    let running_clone = running.clone();

    let capture_thread = thread::spawn(move || {
        let mut sequence = 0u64;
        let mut frame_count = 0;

        while running_clone.load(std::sync::atomic::Ordering::Relaxed) {
            match capture.capture_frame() {
                Ok(image) => {
                    frame_count += 1;
                    // Just count frames - actual encoding would happen separately
                    if frame_count % 30 == 0 {
                        println!("Captured {} frames", frame_count);
                    }
                    thread::sleep(Duration::from_millis(33)); // ~30fps
                }
                Err(e) => {
                    eprintln!("Capture error: {}", e);
                    break;
                }
            }
        }
        frame_count
    });

    // Monitor encoded frames
    let encoded_receiver = encoding_queue.encoded_receiver();
    let stats_thread = thread::spawn(move || {
        let mut encoded_count = 0;
        let mut total_bytes = 0u64;
        let start = std::time::Instant::now();

        loop {
            match encoded_receiver.try_recv() {
                Ok(encoded_frame) => {
                    encoded_count += 1;
                    total_bytes += encoded_frame.data.len() as u64;

                    if encoded_count % 30 == 0 {
                        let elapsed = start.elapsed().as_secs_f64();
                        let fps = encoded_count as f64 / elapsed;
                        let avg_size = total_bytes as f64 / encoded_count as f64;
                        let bitrate = (total_bytes as f64 * 8.0) / elapsed / 1_000_000.0;

                        println!(
                            "Encoded {} frames | {:.1} fps | avg {:.1} KB/frame | {:.2} Mbps",
                            encoded_count,
                            fps,
                            avg_size / 1000.0,
                            bitrate
                        );
                    }
                }
                Err(_) => {
                    thread::sleep(Duration::from_millis(10));
                }
            }

            if start.elapsed().as_secs() >= 11 {
                break;
            }
        }

        (encoded_count, total_bytes)
    });

    // Wait for test duration
    thread::sleep(Duration::from_secs(10));
    running.store(false, std::sync::atomic::Ordering::Relaxed);

    // Wait for threads
    let captured_frames = capture_thread.join().unwrap();
    thread::sleep(Duration::from_millis(500));
    let (encoded_count, total_bytes) = stats_thread.join().unwrap();

    // Print final statistics
    println!("\n=== Encoding Test Results ===");
    println!("Total frames captured: {}", captured_frames);
    println!("Total frames encoded: {}", encoded_count);
    println!("Total data: {:.2} MB", total_bytes as f64 / 1_000_000.0);

    if encoded_count > 0 {
        let avg_frame_size = total_bytes as f64 / encoded_count as f64;
        println!("Average frame size: {:.2} KB", avg_frame_size / 1000.0);
    }

    let queue_stats = encoding_queue.stats();
    println!("\nQueue Statistics:");
    println!("  Frames queued: {}", queue_stats.frames_queued);
    println!("  Frames encoded: {}", queue_stats.frames_encoded);
    println!("  Frames dropped: {}", queue_stats.frames_dropped);

    if queue_stats.frames_queued > 0 {
        let drop_rate =
            queue_stats.frames_dropped as f64 / queue_stats.frames_queued as f64 * 100.0;
        println!("  Drop rate: {:.2}%", drop_rate);
    }

    println!("\nNote: This test demonstrates the queue infrastructure.");
    println!("In production, capture and encode would be fully connected.");
    println!("\nEncoding test completed!");
}

fn test_encoding_performance() {
    let main_display = CGDisplay::main();
    let display_id = main_display.id;
    let bounds = main_display.bounds();
    let width = bounds.size.width as usize;
    let height = bounds.size.height as usize;

    println!("Benchmarking encoding performance at {}x{}", width, height);

    // Capture a sample frame
    let capture = SimpleCapture::new(display_id);
    let image = match capture.capture_frame() {
        Ok(img) => img,
        Err(e) => {
            eprintln!("Failed to capture frame: {}", e);
            return;
        }
    };

    let rgb_data = match image.to_rgb() {
        Ok(data) => data,
        Err(e) => {
            eprintln!("Failed to convert to RGB: {}", e);
            return;
        }
    };

    // Test different quality levels
    let qualities = vec![
        ("Low", EncoderQuality::Low),
        ("Medium", EncoderQuality::Medium),
        ("High", EncoderQuality::High),
        ("Ultra", EncoderQuality::Ultra),
    ];

    println!(
        "\n{:<10} | {:>10} | {:>12} | {:>12} | {:>10}",
        "Quality", "Encode (ms)", "Size (KB)", "Bitrate", "Target FPS"
    );
    println!("{}", "-".repeat(70));

    for (name, quality) in qualities {
        let config = EncoderConfig::new(width, height)
            .with_fps(30.0)
            .with_quality(quality)
            .with_low_latency(true);

        let mut encoder = match encoder::H264Encoder::new(config) {
            Ok(enc) => enc,
            Err(e) => {
                eprintln!("Failed to create encoder: {}", e);
                continue;
            }
        };

        // Encode 10 frames
        let mut encode_times = Vec::new();
        let mut frame_sizes = Vec::new();

        for i in 0..10 {
            let timestamp = std::time::Instant::now();
            match encoder.encode_rgb(&rgb_data, timestamp) {
                Ok(encoded) => {
                    encode_times.push(encoded.encode_duration.as_secs_f64() * 1000.0);
                    frame_sizes.push(encoded.data.len());

                    if i == 0 {
                        println!(
                            "  First frame: {} bytes (keyframe: {})",
                            encoded.data.len(),
                            encoded.is_keyframe
                        );
                    }
                }
                Err(e) => {
                    eprintln!("Encoding error: {}", e);
                    break;
                }
            }
        }

        if !encode_times.is_empty() {
            let avg_encode_time = encode_times.iter().sum::<f64>() / encode_times.len() as f64;
            let avg_frame_size =
                frame_sizes.iter().sum::<usize>() as f64 / frame_sizes.len() as f64;
            let bitrate_mbps = (avg_frame_size * 8.0 * 30.0) / 1_000_000.0; // At 30 fps
            let max_fps = 1000.0 / avg_encode_time;

            println!(
                "{:<10} | {:>10.2} | {:>12.2} | {:>9.2} Mbps | {:>10.1}",
                name,
                avg_encode_time,
                avg_frame_size / 1000.0,
                bitrate_mbps,
                max_fps
            );
        }
    }

    println!("\nBenchmark completed!");
}
