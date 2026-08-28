use std::time::Instant;

use crate::proto::{
    ClientCapabilities, ClientRegistration, CompressionSettings, DeviceType, DisplayConfig,
    DisplayPosition, VideoCodec,
};

/// Configuration for the WebSocket server
#[derive(Debug, Clone)]
pub struct ServerConfig {
    /// Address to bind the server to
    pub bind_address: String,
    /// Port to listen on
    pub port: u16,
    /// Maximum number of simultaneous client connections
    pub max_clients: usize,
    /// Heartbeat interval in seconds
    pub heartbeat_interval_secs: u64,
    /// Heartbeat timeout in seconds (disconnect if no heartbeat received)
    pub heartbeat_timeout_secs: u64,
}

impl Default for ServerConfig {
    fn default() -> Self {
        Self {
            bind_address: "0.0.0.0".to_string(),
            port: 9876,
            max_clients: 3,
            heartbeat_interval_secs: 5,
            heartbeat_timeout_secs: 15,
        }
    }
}

impl ServerConfig {
    pub fn listen_addr(&self) -> String {
        format!("{}:{}", self.bind_address, self.port)
    }
}

/// State of a client connection
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ClientState {
    /// Client connected but not yet registered
    Connected,
    /// Client sent registration, awaiting display assignment
    Registered,
    /// Client is actively receiving frames
    Active,
    /// Client is paused (not receiving frames)
    Paused,
    /// Client is disconnecting
    Disconnecting,
}

impl std::fmt::Display for ClientState {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ClientState::Connected => write!(f, "Connected"),
            ClientState::Registered => write!(f, "Registered"),
            ClientState::Active => write!(f, "Active"),
            ClientState::Paused => write!(f, "Paused"),
            ClientState::Disconnecting => write!(f, "Disconnecting"),
        }
    }
}

/// Represents a connected client with its metadata
#[derive(Debug, Clone)]
pub struct ClientConnection {
    /// Unique session identifier assigned by the server
    pub session_id: String,
    /// Client's self-reported registration info
    pub registration: ClientRegistration,
    /// Current connection state
    pub state: ClientState,
    /// Display configuration assigned to this client
    pub display_config: Option<DisplayConfig>,
    /// macOS `CGDirectDisplayID` of the physical/dummy display captured for
    /// this client. Assigned by `ConnectionManager::register_client` from the
    /// pool of active displays not already assigned to another client.
    pub assigned_display_id: u32,
    /// Time the client connected
    pub connected_at: Instant,
    /// Time of last heartbeat received
    pub last_heartbeat: Instant,
    /// Number of frames sent to this client
    pub frames_sent: u64,
}

impl ClientConnection {
    /// Create a new client connection from a registration message
    pub fn new(session_id: String, registration: ClientRegistration) -> Self {
        let now = Instant::now();
        Self {
            session_id,
            registration,
            state: ClientState::Registered,
            display_config: None,
            // Placeholder — overwritten by `register_client` once a display is assigned.
            assigned_display_id: 0,
            connected_at: now,
            last_heartbeat: now,
            frames_sent: 0,
        }
    }

    /// Get a human-readable description of the client
    pub fn description(&self) -> String {
        let device_type = match DeviceType::try_from(self.registration.device_type) {
            Ok(dt) => dt.as_str_name().to_string(),
            Err(_) => "Unknown".to_string(),
        };
        format!(
            "{} ({}) [{}]",
            self.registration.device_name, device_type, self.state
        )
    }

    /// Check if the heartbeat has timed out
    pub fn is_heartbeat_expired(&self, timeout_secs: u64) -> bool {
        self.last_heartbeat.elapsed().as_secs() > timeout_secs
    }

    /// Update the last heartbeat time
    pub fn touch_heartbeat(&mut self) {
        self.last_heartbeat = Instant::now();
    }

    /// Build a display config for this client from the real geometry of its
    /// assigned macOS display (`assigned_display_id`), capped to the client's
    /// reported capabilities where provided.
    pub fn create_display_config(
        &self,
        x_offset: i32,
        y_offset: i32,
        phys_width: u32,
        phys_height: u32,
    ) -> DisplayConfig {
        let (width, height) = self
            .registration
            .capabilities
            .as_ref()
            .map(|caps| {
                let w = if caps.max_width > 0 {
                    caps.max_width.min(phys_width)
                } else {
                    phys_width
                };
                let h = if caps.max_height > 0 {
                    caps.max_height.min(phys_height)
                } else {
                    phys_height
                };
                (w, h)
            })
            .unwrap_or((phys_width, phys_height));

        let framerate = self
            .registration
            .capabilities
            .as_ref()
            .map(|caps| {
                if caps.max_framerate > 0 {
                    caps.max_framerate
                } else {
                    30
                }
            })
            .unwrap_or(30);

        DisplayConfig {
            session_id: self.session_id.clone(),
            display_width: width,
            display_height: height,
            framerate,
            codec: VideoCodec::H264 as i32,
            position: Some(DisplayPosition {
                x_offset,
                y_offset,
                width,
                height,
            }),
            compression: Some(CompressionSettings {
                bitrate_kbps: 5000,
                quality: 75,
                adaptive_bitrate: true,
            }),
        }
    }
}

/// Events emitted by the connection manager
#[derive(Debug)]
pub enum ConnectionEvent {
    /// A new client has connected and registered
    ClientRegistered {
        session_id: String,
        registration: ClientRegistration,
    },
    /// A client has disconnected
    ClientDisconnected { session_id: String, reason: String },
    /// A client's heartbeat has timed out
    ClientTimeout { session_id: String },
    /// A client requested a configuration change
    ClientReconfigure { session_id: String, payload: String },
}
