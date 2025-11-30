use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};

/// Unique identifier for a client device
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone, PartialEq, Eq, Hash)]
pub struct DeviceId(pub String);

/// Display resolution and position information
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone, Copy)]
pub struct DisplayMetadata {
    pub width: u32,
    pub height: u32,
    pub x: i32,
    pub y: i32,
    pub scale_factor: f32,
}

/// Video encoding format
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone, Copy, PartialEq, Eq)]
pub enum EncodingFormat {
    Jpeg,
    H264,
    Raw,
}

/// Quality settings for encoding
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone, Copy)]
pub struct QualitySettings {
    pub quality: u8, // JPEG quality (1-100) or H.264 CRF (0-51)
    pub fps: u8,
}

impl Default for QualitySettings {
    fn default() -> Self {
        Self {
            quality: 80,
            fps: 30,
        }
    }
}
