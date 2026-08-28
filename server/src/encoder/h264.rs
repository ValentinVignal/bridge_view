use openh264::OpenH264API;
use openh264::encoder::{
    Encoder, EncoderConfig as OpenH264Config, RateControlMode, SpsPpsStrategy, UsageType,
};
use openh264::formats::YUVBuffer;
use std::time::{Duration, Instant};

/// Quality presets for H.264 encoding
#[derive(Debug, Clone, Copy)]
pub enum EncoderQuality {
    /// Low quality, high compression - suitable for low bandwidth
    Low,
    /// Balanced quality and compression
    Medium,
    /// High quality, lower compression - suitable for high bandwidth
    High,
    /// Maximum quality, minimal compression
    Ultra,
}

impl EncoderQuality {
    /// Get the target bitrate in bits per second for a given resolution
    pub fn target_bitrate(&self, width: usize, height: usize) -> u32 {
        let pixels = (width * height) as u32;
        // Bits per pixel varies by quality level
        let bits_per_pixel = match self {
            EncoderQuality::Low => 0.1,
            EncoderQuality::Medium => 0.2,
            EncoderQuality::High => 0.4,
            EncoderQuality::Ultra => 0.8,
        };

        // Target 30 fps as baseline
        (pixels as f64 * bits_per_pixel * 30.0) as u32
    }

    /// Get the maximum bitrate in bits per second
    pub fn max_bitrate(&self, width: usize, height: usize) -> u32 {
        self.target_bitrate(width, height) * 2
    }
}

/// Configuration for the H.264 encoder
#[derive(Debug, Clone)]
pub struct EncoderConfig {
    /// Width of the video frames
    pub width: usize,
    /// Height of the video frames
    pub height: usize,
    /// Target frame rate
    pub fps: f64,
    /// Quality preset
    pub quality: EncoderQuality,
    /// Enable low latency mode
    pub low_latency: bool,
}

impl Default for EncoderConfig {
    fn default() -> Self {
        Self {
            width: 1920,
            height: 1080,
            fps: 30.0,
            quality: EncoderQuality::Medium,
            low_latency: true,
        }
    }
}

impl EncoderConfig {
    pub fn new(width: usize, height: usize) -> Self {
        Self {
            width,
            height,
            ..Default::default()
        }
    }

    pub fn with_fps(mut self, fps: f64) -> Self {
        self.fps = fps;
        self
    }

    pub fn with_quality(mut self, quality: EncoderQuality) -> Self {
        self.quality = quality;
        self
    }

    pub fn with_low_latency(mut self, low_latency: bool) -> Self {
        self.low_latency = low_latency;
        self
    }
}

/// Encoded frame data with metadata
#[derive(Debug, Clone)]
pub struct EncodedFrame {
    /// Encoded frame data
    pub data: Vec<u8>,
    /// Frame sequence number
    pub sequence: u64,
    /// Timestamp when the frame was captured
    pub timestamp: Instant,
    /// Whether this is a keyframe (I-frame)
    pub is_keyframe: bool,
    /// Time taken to encode this frame
    pub encode_duration: Duration,
}

/// Trait for frame encoding
pub trait FrameEncoder {
    /// Encode an RGB frame
    fn encode_rgb(&mut self, rgb_data: &[u8], timestamp: Instant) -> Result<EncodedFrame, String>;

    /// Encode a YUV frame
    fn encode_yuv(
        &mut self,
        yuv_data: &YUVBuffer,
        timestamp: Instant,
    ) -> Result<EncodedFrame, String>;

    /// Get the encoder configuration
    fn config(&self) -> &EncoderConfig;

    /// Get encoding statistics
    fn stats(&self) -> EncoderStats;
}

/// Statistics for encoder performance
#[derive(Debug, Clone, Default)]
pub struct EncoderStats {
    pub total_frames: u64,
    pub keyframes: u64,
    pub total_bytes: u64,
    pub total_encode_time: Duration,
    pub average_encode_time: Duration,
    pub average_bitrate: f64,
}

/// H.264 encoder implementation using OpenH264
pub struct H264Encoder {
    encoder: Encoder,
    config: EncoderConfig,
    sequence: u64,
    /// Number of frames between keyframes, derived from the configured fps
    gop_size: u64,
    stats: EncoderStats,
}

impl H264Encoder {
    /// Create a new H.264 encoder
    pub fn new(config: EncoderConfig) -> Result<Self, String> {
        // Create encoder first with default config
        let api = OpenH264API::from_source();
        let mut h264_config = OpenH264Config::new()
            .set_bitrate_bps(config.quality.target_bitrate(config.width, config.height))
            .max_frame_rate(config.fps as f32);

        if config.low_latency {
            h264_config = h264_config
                // Screen content (sharp edges, text) rather than camera video
                .usage_type(UsageType::ScreenContentRealTime)
                // Keep output size close to target bitrate instead of prioritizing quality
                .rate_control_mode(RateControlMode::Bitrate)
                .sps_pps_strategy(SpsPpsStrategy::ConstantId)
                .enable_skip_frame(true)
                // Disable frame-level threading, which trades latency for throughput
                .set_multiple_thread_idc(1);
        }

        let encoder = Encoder::with_api_config(api, h264_config)
            .map_err(|e| format!("Failed to create encoder: {:?}", e))?;

        // One keyframe per second by default, minimum every 2 frames
        let gop_size = (config.fps.round() as u64).max(2);

        Ok(Self {
            encoder,
            config,
            sequence: 0,
            gop_size,
            stats: EncoderStats::default(),
        })
    }

    /// Convert RGB to YUV420 (I420) format
    fn rgb_to_yuv420(&self, rgb_data: &[u8]) -> Result<YUVBuffer, String> {
        let width = self.config.width;
        let height = self.config.height;
        let rgb_stride = width * 3;

        if rgb_data.len() < height * rgb_stride {
            return Err(format!(
                "RGB data too small: expected {} bytes, got {}",
                height * rgb_stride,
                rgb_data.len()
            ));
        }

        // Create YUV buffer (I420 format: Y plane + U plane + V plane)
        let y_size = width * height;
        let uv_size = (width / 2) * (height / 2);
        let mut y_plane = vec![0u8; y_size];
        let mut u_plane = vec![0u8; uv_size];
        let mut v_plane = vec![0u8; uv_size];

        // RGB to YUV conversion (ITU-R BT.601)
        for y in 0..height {
            for x in 0..width {
                let rgb_idx = y * rgb_stride + x * 3;
                let r = rgb_data[rgb_idx] as f32;
                let g = rgb_data[rgb_idx + 1] as f32;
                let b = rgb_data[rgb_idx + 2] as f32;

                // Y component
                let y_val = (0.299 * r + 0.587 * g + 0.114 * b) as u8;
                y_plane[y * width + x] = y_val;

                // U and V components (subsample 2x2)
                if x % 2 == 0 && y % 2 == 0 {
                    let uv_idx = (y / 2) * (width / 2) + (x / 2);
                    let u_val = ((-0.169 * r - 0.331 * g + 0.500 * b) + 128.0) as u8;
                    let v_val = ((0.500 * r - 0.419 * g - 0.081 * b) + 128.0) as u8;
                    u_plane[uv_idx] = u_val;
                    v_plane[uv_idx] = v_val;
                }
            }
        }

        // Combine Y, U, V planes into single buffer for I420 format
        let mut yuv_data = Vec::with_capacity(y_size + uv_size * 2);
        yuv_data.extend_from_slice(&y_plane);
        yuv_data.extend_from_slice(&u_plane);
        yuv_data.extend_from_slice(&v_plane);

        Ok(YUVBuffer::from_vec(yuv_data, width, height))
    }
}

impl FrameEncoder for H264Encoder {
    fn encode_rgb(&mut self, rgb_data: &[u8], timestamp: Instant) -> Result<EncodedFrame, String> {
        let encode_start = Instant::now();

        // Convert RGB to YUV420
        let yuv = self.rgb_to_yuv420(rgb_data)?;

        // Encode the frame
        let bitstream = self
            .encoder
            .encode(&yuv)
            .map_err(|e| format!("Encoding failed: {:?}", e))?;

        let encode_duration = encode_start.elapsed();
        self.sequence += 1;

        // Convert bitstream to vec
        let data = bitstream.to_vec();

        // Check if this is a keyframe (first frame or every gop_size frames)
        let is_keyframe = self.sequence == 1 || self.sequence % self.gop_size == 0;

        // Update statistics
        self.stats.total_frames += 1;
        if is_keyframe {
            self.stats.keyframes += 1;
        }
        self.stats.total_bytes += data.len() as u64;
        self.stats.total_encode_time += encode_duration;
        self.stats.average_encode_time =
            self.stats.total_encode_time / self.stats.total_frames as u32;

        let encoded_frame = EncodedFrame {
            data,
            sequence: self.sequence,
            timestamp,
            is_keyframe,
            encode_duration,
        };

        Ok(encoded_frame)
    }

    fn encode_yuv(
        &mut self,
        yuv_data: &YUVBuffer,
        timestamp: Instant,
    ) -> Result<EncodedFrame, String> {
        let encode_start = Instant::now();

        // Encode the frame
        let bitstream = self
            .encoder
            .encode(yuv_data)
            .map_err(|e| format!("Encoding failed: {:?}", e))?;

        let encode_duration = encode_start.elapsed();
        self.sequence += 1;

        // Convert bitstream to vec
        let data = bitstream.to_vec();

        // Check if this is a keyframe (first frame or every gop_size frames)
        let is_keyframe = self.sequence == 1 || self.sequence % self.gop_size == 0;

        // Update statistics
        self.stats.total_frames += 1;
        if is_keyframe {
            self.stats.keyframes += 1;
        }
        self.stats.total_bytes += data.len() as u64;
        self.stats.total_encode_time += encode_duration;
        self.stats.average_encode_time =
            self.stats.total_encode_time / self.stats.total_frames as u32;

        let encoded_frame = EncodedFrame {
            data,
            sequence: self.sequence,
            timestamp,
            is_keyframe,
            encode_duration,
        };

        Ok(encoded_frame)
    }

    fn config(&self) -> &EncoderConfig {
        &self.config
    }

    fn stats(&self) -> EncoderStats {
        let mut stats = self.stats.clone();

        // Calculate average bitrate
        if self.stats.total_frames > 0 {
            let total_seconds = self.stats.total_encode_time.as_secs_f64();
            if total_seconds > 0.0 {
                stats.average_bitrate = (self.stats.total_bytes as f64 * 8.0) / total_seconds;
            }
        }

        stats
    }
}

impl Drop for H264Encoder {
    fn drop(&mut self) {
        println!("\nEncoder Statistics:");
        println!("  Total frames: {}", self.stats.total_frames);
        println!("  Keyframes: {}", self.stats.keyframes);
        println!(
            "  Total bytes: {} ({:.2} MB)",
            self.stats.total_bytes,
            self.stats.total_bytes as f64 / 1_000_000.0
        );

        if self.stats.total_frames > 0 {
            let avg_frame_size = self.stats.total_bytes as f64 / self.stats.total_frames as f64;
            println!("  Average frame size: {:.2} KB", avg_frame_size / 1000.0);
            println!(
                "  Average encode time: {:.2} ms",
                self.stats.average_encode_time.as_secs_f64() * 1000.0
            );

            let stats = self.stats();
            if stats.average_bitrate > 0.0 {
                println!(
                    "  Average bitrate: {:.2} Mbps",
                    stats.average_bitrate / 1_000_000.0
                );
            }
        }
    }
}
