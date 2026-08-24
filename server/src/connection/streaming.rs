use std::sync::Arc;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::time::{Duration, Instant};

use log::{debug, error, info, warn};

use crate::capture::SimpleCapture;
use crate::encoder::{EncoderConfig, EncoderQuality, EncodingQueue, QueueConfig, QueuedFrame};

use super::manager::ConnectionManager;

/// Configuration for the frame streaming pipeline.
///
/// Controls how frames are captured from the display, encoded, and delivered
/// to connected clients.
#[derive(Debug, Clone)]
pub struct StreamingConfig {
    /// Target frame rate (in frames per second) for screen capture.
    /// The streaming loop sleeps between iterations to maintain this rate.
    /// Typical values: 30.0 for smooth video, 15.0 for lower CPU usage.
    pub target_fps: f64,
    /// macOS `CGDirectDisplayID` of the display to capture.
    /// Defaults to `CGDisplay::main().id` (the primary display).
    /// Each connected client could theoretically be assigned a different display.
    pub display_id: u32,
    /// H.264 encoder quality preset that controls bitrate and compression.
    /// Higher quality increases bandwidth usage but produces sharper frames.
    /// See `EncoderQuality` for available presets (Low, Medium, High, Ultra).
    pub encoder_quality: EncoderQuality,
    /// Maximum number of captured frames that can be buffered in the encoding
    /// queue before back-pressure is applied. When the queue reaches this size,
    /// new frames are either dropped or block depending on `drop_on_full`.
    /// A value of 30 represents ~1 second of buffer at 30 fps.
    pub max_queue_size: usize,
    /// When `true`, new frames are silently dropped if the encoding queue is full
    /// (non-blocking). When `false`, the capture thread blocks until queue space
    /// is available. Dropping is preferred for real-time streaming to avoid
    /// introducing latency from stale frames.
    pub drop_on_full: bool,
}

impl Default for StreamingConfig {
    fn default() -> Self {
        Self {
            target_fps: 30.0,
            display_id: core_graphics::display::CGDisplay::main().id,
            encoder_quality: EncoderQuality::Medium,
            max_queue_size: 30,
            drop_on_full: true,
        }
    }
}

/// Runtime statistics for the frame streaming pipeline.
///
/// Provides a snapshot of counters and timing info for monitoring
/// the health and throughput of the capture → encode → broadcast loop.
#[derive(Debug, Clone, Default)]
pub struct StreamingStats {
    /// Total number of frames successfully captured from the display
    /// via `CGDisplayCreateImage` since the streamer started.
    pub frames_captured: u64,
    /// Total number of frames that completed H.264 encoding and were
    /// dequeued from the encoding worker thread.
    pub frames_encoded: u64,
    /// Cumulative count of per-client frame sends. If a single encoded
    /// frame is sent to 3 clients, this counter increases by 3.
    pub frames_broadcast: u64,
    /// Number of captured frames that were dropped because the encoding
    /// queue was full (only counted when `drop_on_full` is `true`).
    pub frames_dropped: u64,
    /// Number of times `SimpleCapture::capture_frame()` returned an error
    /// (e.g. missing Screen Recording permission).
    pub capture_errors: u64,
    /// Average time in milliseconds to capture a single display frame.
    /// Currently reserved for future use (populated as 0.0).
    pub avg_capture_ms: f64,
    /// Average time in milliseconds to H.264-encode a single frame.
    /// Currently reserved for future use (populated as 0.0).
    pub avg_encode_ms: f64,
    /// Average time in milliseconds to broadcast an encoded frame to
    /// all connected clients. Currently reserved for future use (populated as 0.0).
    pub avg_broadcast_ms: f64,
    /// Total elapsed wall-clock time in seconds since the streamer started.
    /// Currently reserved for future use (populated as 0.0).
    pub uptime_secs: f64,
}

/// Orchestrates the capture → encode → broadcast frame streaming pipeline.
///
/// Runs asynchronously and captures display frames, encodes them with H.264,
/// and broadcasts them to all active clients via the ConnectionManager.
pub struct FrameStreamer {
    /// Streaming configuration (FPS, display, quality, queue settings).
    /// Cloned into the background thread when `start()` is called.
    config: StreamingConfig,
    /// Shared reference to the `ConnectionManager` used to broadcast
    /// encoded frames to all active WebSocket clients.
    manager: Arc<ConnectionManager>,
    /// Atomic flag shared with the background streaming thread.
    /// Set to `true` when the streamer starts; set to `false` to
    /// signal the loop to exit gracefully.
    running: Arc<AtomicBool>,
    /// Thread-safe atomic counters for streaming statistics.
    /// Updated by the background thread and read via `stats()`.
    stats: Arc<StreamingStatsAtomic>,
}

/// Internal thread-safe version of `StreamingStats` using atomics.
///
/// Lives on the heap behind an `Arc` and is shared between the main
/// thread (for reading via `FrameStreamer::stats()`) and the background
/// streaming thread (for incrementing counters).
struct StreamingStatsAtomic {
    /// Atomically incremented each time a display frame is captured.
    frames_captured: AtomicU64,
    /// Atomically incremented each time an H.264 encoded frame is
    /// dequeued from the encoding worker.
    frames_encoded: AtomicU64,
    /// Atomically incremented by the number of clients a frame was
    /// successfully sent to (can increase by >1 per frame).
    frames_broadcast: AtomicU64,
    /// Atomically incremented when a frame is dropped due to a full
    /// encoding queue.
    frames_dropped: AtomicU64,
    /// Atomically incremented on each capture error (e.g. permission
    /// denied, display unavailable).
    capture_errors: AtomicU64,
}

impl StreamingStatsAtomic {
    fn new() -> Self {
        Self {
            frames_captured: AtomicU64::new(0),
            frames_encoded: AtomicU64::new(0),
            frames_broadcast: AtomicU64::new(0),
            frames_dropped: AtomicU64::new(0),
            capture_errors: AtomicU64::new(0),
        }
    }
}

impl FrameStreamer {
    /// Create a new frame streamer
    pub fn new(config: StreamingConfig, manager: Arc<ConnectionManager>) -> Self {
        Self {
            config,
            manager,
            running: Arc::new(AtomicBool::new(false)),
            stats: Arc::new(StreamingStatsAtomic::new()),
        }
    }

    /// Start the frame streaming pipeline.
    ///
    /// This spawns a blocking background thread that:
    /// 1. Captures frames from the display at the target frame rate
    /// 2. Queues them for H.264 encoding
    /// 3. Reads encoded frames and broadcasts them to all connected clients
    ///
    /// Returns a handle to stop the streamer.
    pub fn start(&self) -> StreamerHandle {
        let running = self.running.clone();
        running.store(true, Ordering::SeqCst);

        let config = self.config.clone();
        let manager = self.manager.clone();
        let stats = self.stats.clone();

        // We need a separate tokio runtime handle to broadcast frames from
        // the background thread. The manager methods are async.
        let rt_handle = tokio::runtime::Handle::current();

        let join_handle = std::thread::spawn(move || {
            Self::streaming_loop(config, manager, running, stats, rt_handle);
        });

        info!(
            "Frame streamer started ({}fps, display {})",
            self.config.target_fps, self.config.display_id
        );

        StreamerHandle {
            running: self.running.clone(),
            join_handle: Some(join_handle),
        }
    }

    /// The main streaming loop (runs on a background thread)
    fn streaming_loop(
        config: StreamingConfig,
        manager: Arc<ConnectionManager>,
        running: Arc<AtomicBool>,
        stats: Arc<StreamingStatsAtomic>,
        rt_handle: tokio::runtime::Handle,
    ) {
        // Get display dimensions for the capture
        let display = core_graphics::display::CGDisplay::new(config.display_id);
        let bounds = display.bounds();
        let capture_width = bounds.size.width as usize;
        let capture_height = bounds.size.height as usize;

        info!(
            "Capture dimensions: {}x{} from display {}",
            capture_width, capture_height, config.display_id
        );

        // Initialize encoder
        let encoder_config = EncoderConfig::new(capture_width, capture_height)
            .with_fps(config.target_fps)
            .with_quality(config.encoder_quality)
            .with_low_latency(true);

        let queue_config = QueueConfig {
            max_queue_size: config.max_queue_size,
            drop_on_full: config.drop_on_full,
        };

        let mut encoding_queue = match EncodingQueue::new(encoder_config, queue_config) {
            Ok(q) => q,
            Err(e) => {
                error!("Failed to create encoding queue: {}", e);
                return;
            }
        };

        let capture = SimpleCapture::new(config.display_id);
        let frame_duration = Duration::from_secs_f64(1.0 / config.target_fps);
        let mut sequence: u64 = 0;
        let start_time = Instant::now();
        let mut last_log_time = Instant::now();

        info!(
            "Streaming loop started, target {:.0} fps",
            config.target_fps
        );

        while running.load(Ordering::SeqCst) {
            let loop_start = Instant::now();

            // --- 1. Capture a frame ---
            match capture.capture_frame() {
                Ok(image) => {
                    sequence += 1;
                    stats.frames_captured.fetch_add(1, Ordering::Relaxed);

                    // Queue for encoding
                    match QueuedFrame::from_captured(image, sequence) {
                        Ok(queued) => {
                            if let Err(e) = encoding_queue.queue_frame(queued) {
                                stats.frames_dropped.fetch_add(1, Ordering::Relaxed);
                                if sequence % 100 == 0 {
                                    warn!("Frame {} dropped: {}", sequence, e);
                                }
                            }
                        }
                        Err(e) => {
                            stats.capture_errors.fetch_add(1, Ordering::Relaxed);
                            warn!("Failed to prepare frame {}: {}", sequence, e);
                        }
                    }
                }
                Err(e) => {
                    stats.capture_errors.fetch_add(1, Ordering::Relaxed);
                    if stats.capture_errors.load(Ordering::Relaxed) % 10 == 1 {
                        error!("Capture error: {}", e);
                    }
                }
            }

            // --- 2. Drain encoded frames and broadcast ---
            loop {
                match encoding_queue.try_recv_encoded() {
                    Ok(encoded_frame) => {
                        stats.frames_encoded.fetch_add(1, Ordering::Relaxed);

                        let width = capture_width as u32;
                        let height = capture_height as u32;
                        let manager_ref = manager.clone();

                        // Broadcast via the tokio runtime
                        let sent = rt_handle.block_on(async {
                            manager_ref
                                .broadcast_frame(&encoded_frame, width, height)
                                .await
                        });

                        if sent > 0 {
                            stats
                                .frames_broadcast
                                .fetch_add(sent as u64, Ordering::Relaxed);
                        }
                    }
                    Err(crossbeam_channel::TryRecvError::Empty) => break,
                    Err(crossbeam_channel::TryRecvError::Disconnected) => {
                        error!("Encoding queue disconnected, stopping streamer");
                        running.store(false, Ordering::SeqCst);
                        break;
                    }
                }
            }

            // --- 3. Log periodic stats ---
            if last_log_time.elapsed() >= Duration::from_secs(5) {
                let captured = stats.frames_captured.load(Ordering::Relaxed);
                let encoded = stats.frames_encoded.load(Ordering::Relaxed);
                let broadcast = stats.frames_broadcast.load(Ordering::Relaxed);
                let dropped = stats.frames_dropped.load(Ordering::Relaxed);
                let errors = stats.capture_errors.load(Ordering::Relaxed);
                let uptime = start_time.elapsed().as_secs_f64();
                let active_clients = rt_handle.block_on(async { manager.client_count().await });

                debug!(
                    "Streaming: {:.1}s uptime | {} captured, {} encoded, {} broadcast, {} dropped, {} errors | {} clients",
                    uptime, captured, encoded, broadcast, dropped, errors, active_clients
                );
                last_log_time = Instant::now();
            }

            // --- 4. Sleep to maintain target frame rate ---
            let elapsed = loop_start.elapsed();
            if elapsed < frame_duration {
                std::thread::sleep(frame_duration - elapsed);
            }
        }

        // Shut down the encoding queue
        encoding_queue.stop();
        info!("Streaming loop stopped");
    }

    /// Get current streaming statistics
    pub fn stats(&self) -> StreamingStats {
        StreamingStats {
            frames_captured: self.stats.frames_captured.load(Ordering::Relaxed),
            frames_encoded: self.stats.frames_encoded.load(Ordering::Relaxed),
            frames_broadcast: self.stats.frames_broadcast.load(Ordering::Relaxed),
            frames_dropped: self.stats.frames_dropped.load(Ordering::Relaxed),
            capture_errors: self.stats.capture_errors.load(Ordering::Relaxed),
            ..Default::default()
        }
    }
}

/// Handle to control and stop the frame streamer.
///
/// Returned by `FrameStreamer::start()`. Dropping this handle
/// automatically stops the background streaming thread.
pub struct StreamerHandle {
    /// Shared atomic flag — setting this to `false` tells the
    /// background streaming loop to exit after the current iteration.
    running: Arc<AtomicBool>,
    /// Join handle for the background thread running `streaming_loop()`.
    /// Taken (consumed) by `stop()` to join the thread. Wrapped in
    /// `Option` so it can only be joined once.
    join_handle: Option<std::thread::JoinHandle<()>>,
}

impl StreamerHandle {
    /// Stop the frame streamer
    pub fn stop(&mut self) {
        info!("Stopping frame streamer...");
        self.running.store(false, Ordering::SeqCst);
        if let Some(handle) = self.join_handle.take() {
            let _ = handle.join();
        }
        info!("Frame streamer stopped");
    }

    /// Check if the streamer is still running
    pub fn is_running(&self) -> bool {
        self.running.load(Ordering::SeqCst)
    }
}

impl Drop for StreamerHandle {
    fn drop(&mut self) {
        self.stop();
    }
}
