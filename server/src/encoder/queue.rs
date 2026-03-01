use crossbeam_channel::{Receiver, Sender, TryRecvError, bounded, unbounded};
use std::sync::Arc;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::thread::{self, JoinHandle};
use std::time::{Duration, Instant};

use super::h264::{EncodedFrame, EncoderConfig, FrameEncoder, H264Encoder};
use crate::capture::CapturedImage;

/// Configuration for the frame queue
#[derive(Debug, Clone)]
pub struct QueueConfig {
    /// Maximum number of frames in the queue before dropping oldest
    pub max_queue_size: usize,
    /// Whether to drop frames when queue is full (vs blocking)
    pub drop_on_full: bool,
}

impl Default for QueueConfig {
    fn default() -> Self {
        Self {
            max_queue_size: 30, // ~1 second at 30fps
            drop_on_full: true,
        }
    }
}

/// Frame with metadata for encoding queue
#[derive(Clone)]
pub struct QueuedFrame {
    pub rgb_data: Vec<u8>,
    pub width: usize,
    pub height: usize,
    pub timestamp: Instant,
    pub sequence: u64,
}

impl QueuedFrame {
    pub fn from_captured(image: CapturedImage, sequence: u64) -> Result<Self, String> {
        let rgb_data = image.to_rgb()?;
        Ok(Self {
            rgb_data,
            width: image.width,
            height: image.height,
            timestamp: Instant::now(),
            sequence,
        })
    }
}

/// Statistics for the encoding queue
#[derive(Debug, Clone, Default)]
pub struct QueueStats {
    pub frames_queued: u64,
    pub frames_encoded: u64,
    pub frames_dropped: u64,
    pub current_queue_size: usize,
    pub max_queue_size_reached: usize,
}

/// Encoding queue that processes frames in a background thread
pub struct EncodingQueue {
    frame_sender: Sender<QueuedFrame>,
    encoded_receiver: Receiver<EncodedFrame>,
    config: QueueConfig,
    running: Arc<AtomicBool>,
    stats: Arc<AtomicQueueStats>,
    worker_handle: Option<JoinHandle<()>>,
}

/// Thread-safe statistics using atomics
struct AtomicQueueStats {
    frames_queued: AtomicU64,
    frames_encoded: AtomicU64,
    frames_dropped: AtomicU64,
}

impl AtomicQueueStats {
    fn new() -> Self {
        Self {
            frames_queued: AtomicU64::new(0),
            frames_encoded: AtomicU64::new(0),
            frames_dropped: AtomicU64::new(0),
        }
    }

    fn to_stats(&self, current_queue_size: usize, max_queue_size_reached: usize) -> QueueStats {
        QueueStats {
            frames_queued: self.frames_queued.load(Ordering::Relaxed),
            frames_encoded: self.frames_encoded.load(Ordering::Relaxed),
            frames_dropped: self.frames_dropped.load(Ordering::Relaxed),
            current_queue_size,
            max_queue_size_reached,
        }
    }
}

impl EncodingQueue {
    /// Create a new encoding queue with the specified encoder configuration
    pub fn new(encoder_config: EncoderConfig, queue_config: QueueConfig) -> Result<Self, String> {
        let (frame_sender, frame_receiver) = if queue_config.drop_on_full {
            bounded::<QueuedFrame>(queue_config.max_queue_size)
        } else {
            unbounded::<QueuedFrame>()
        };

        let (encoded_sender, encoded_receiver) = unbounded();

        let running = Arc::new(AtomicBool::new(true));
        let running_clone = running.clone();

        let stats = Arc::new(AtomicQueueStats::new());
        let stats_clone = stats.clone();

        let max_queue_size = queue_config.max_queue_size;
        let drop_on_full = queue_config.drop_on_full;

        // Spawn encoding worker thread
        let worker_handle = thread::spawn(move || {
            // Create encoder
            let mut encoder = match H264Encoder::new(encoder_config) {
                Ok(enc) => enc,
                Err(e) => {
                    eprintln!("Failed to create encoder: {}", e);
                    return;
                }
            };

            let mut max_queue_reached = 0;
            let mut last_stats_time = Instant::now();

            while running_clone.load(Ordering::Relaxed) {
                // Try to receive a frame from the queue
                match frame_receiver.try_recv() {
                    Ok(queued_frame) => {
                        // Track queue size
                        let current_queue_size = frame_receiver.len();
                        if current_queue_size > max_queue_reached {
                            max_queue_reached = current_queue_size;
                        }

                        // Encode the frame
                        match encoder.encode_rgb(&queued_frame.rgb_data, queued_frame.timestamp) {
                            Ok(encoded_frame) => {
                                stats_clone.frames_encoded.fetch_add(1, Ordering::Relaxed);

                                // Send encoded frame
                                if let Err(e) = encoded_sender.send(encoded_frame) {
                                    eprintln!("Failed to send encoded frame: {}", e);
                                    break;
                                }
                            }
                            Err(e) => {
                                eprintln!("Encoding error: {}", e);
                                // Continue processing other frames
                            }
                        }
                    }
                    Err(TryRecvError::Empty) => {
                        // No frames available, sleep briefly
                        thread::sleep(Duration::from_millis(1));
                    }
                    Err(TryRecvError::Disconnected) => {
                        // Channel closed, exit
                        break;
                    }
                }

                // Log stats periodically
                let now = Instant::now();
                if now.duration_since(last_stats_time).as_secs() >= 5 {
                    let queued = stats_clone.frames_queued.load(Ordering::Relaxed);
                    let encoded = stats_clone.frames_encoded.load(Ordering::Relaxed);
                    let dropped = stats_clone.frames_dropped.load(Ordering::Relaxed);
                    let encoder_stats = encoder.stats();

                    println!(
                        "Encoding Queue: {} queued, {} encoded, {} dropped, max queue: {}, avg encode: {:.2}ms",
                        queued,
                        encoded,
                        dropped,
                        max_queue_reached,
                        encoder_stats.average_encode_time.as_secs_f64() * 1000.0
                    );

                    last_stats_time = now;
                }
            }

            println!("Encoding worker thread stopped");
        });

        Ok(Self {
            frame_sender,
            encoded_receiver,
            config: queue_config,
            running,
            stats,
            worker_handle: Some(worker_handle),
        })
    }

    /// Queue a frame for encoding
    pub fn queue_frame(&self, frame: QueuedFrame) -> Result<(), String> {
        self.stats.frames_queued.fetch_add(1, Ordering::Relaxed);

        if self.config.drop_on_full {
            // Try send - will fail if queue is full
            match self.frame_sender.try_send(frame) {
                Ok(_) => Ok(()),
                Err(e) => {
                    self.stats.frames_dropped.fetch_add(1, Ordering::Relaxed);
                    Err(format!("Frame dropped - queue full: {}", e))
                }
            }
        } else {
            // Blocking send
            self.frame_sender
                .send(frame)
                .map_err(|e| format!("Failed to queue frame: {}", e))
        }
    }

    /// Try to receive an encoded frame (non-blocking)
    pub fn try_recv_encoded(&self) -> Result<EncodedFrame, TryRecvError> {
        self.encoded_receiver.try_recv()
    }

    /// Get a receiver for encoded frames (for use in other threads)
    pub fn encoded_receiver(&self) -> Receiver<EncodedFrame> {
        self.encoded_receiver.clone()
    }

    /// Get current queue statistics
    pub fn stats(&self) -> QueueStats {
        let current_queue_size = self.frame_sender.len();
        let max_queue_size_reached = current_queue_size; // Simplified, could track max
        self.stats
            .to_stats(current_queue_size, max_queue_size_reached)
    }

    /// Stop the encoding queue
    pub fn stop(&mut self) {
        self.running.store(false, Ordering::Relaxed);

        // Wait for worker thread to finish
        if let Some(handle) = self.worker_handle.take() {
            let _ = handle.join();
        }
    }
}

impl Drop for EncodingQueue {
    fn drop(&mut self) {
        self.stop();
    }
}
