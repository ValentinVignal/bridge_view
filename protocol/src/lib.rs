pub mod messages;
pub mod types;

pub use messages::*;
pub use types::*;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_client_message_json() {
        let msg = ClientMessage::Connect {
            device_id: DeviceId("test-device".to_string()),
            display: DisplayMetadata {
                width: 1920,
                height: 1080,
                x: 0,
                y: 0,
                scale_factor: 1.0,
            },
            preferred_encoding: EncodingFormat::Jpeg,
        };

        let json = serde_json::to_string(&msg).unwrap();
        let deserialized: ClientMessage = serde_json::from_str(&json).unwrap();

        assert!(matches!(deserialized, ClientMessage::Connect { .. }));
    }

    #[test]
    fn test_frame_message_bincode() {
        let frame = ServerMessage::Frame {
            sequence: 42,
            timestamp: 1234567890,
            data: vec![0xFF; 1024],
            encoding: EncodingFormat::Jpeg,
        };

        let config = bincode::config::standard();
        let binary = bincode::encode_to_vec(&frame, config).unwrap();
        let (deserialized, _): (ServerMessage, usize) =
            bincode::decode_from_slice(&binary, config).unwrap();

        match deserialized {
            ServerMessage::Frame { sequence, .. } => assert_eq!(sequence, 42),
            _ => panic!("Wrong message type"),
        }
    }
}
