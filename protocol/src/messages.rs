use crate::types::*;
use bincode::{Decode, Encode};
use serde::{Deserialize, Serialize};

/// Messages sent from client to server
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone)]
pub enum ClientMessage {
    Connect {
        device_id: DeviceId,
        display: DisplayMetadata,
        preferred_encoding: EncodingFormat,
    },
    UpdateSettings {
        quality: QualitySettings,
    },
    Ping,
    Disconnect,
}

/// Messages sent from server to client
#[derive(Serialize, Deserialize, Encode, Decode, Debug, Clone)]
pub enum ServerMessage {
    Connected {
        session_id: String,
        display: DisplayMetadata,
        encoding: EncodingFormat,
    },
    Rejected {
        reason: String,
    },
    Frame {
        sequence: u64,
        timestamp: u64,
        data: Vec<u8>,
        encoding: EncodingFormat,
    },
    DisplayChanged {
        display: DisplayMetadata,
    },
    Pong,
    Error {
        message: String,
    },
}
