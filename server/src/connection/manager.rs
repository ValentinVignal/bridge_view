use std::collections::HashMap;
use std::sync::Arc;

use log::{error, info, warn};
use prost::Message;
use tokio::sync::{Mutex, broadcast, mpsc};

use crate::encoder::EncodedFrame;
use crate::proto::{ClientRegistration, ControlMessageType, DisplayConfig, FrameType, VideoFrame};

use super::types::{ClientConnection, ClientState, ServerConfig};

/// Manages all client connections and their state
pub struct ConnectionManager {
    /// Connected clients keyed by session_id
    clients: Arc<Mutex<HashMap<String, ClientConnection>>>,
    /// Per-client frame senders for streaming encoded frames
    frame_senders: Arc<Mutex<HashMap<String, mpsc::UnboundedSender<Vec<u8>>>>>,
    /// Server configuration
    config: ServerConfig,
    /// Channel for broadcasting connection events
    event_sender: broadcast::Sender<String>,
}

impl ConnectionManager {
    /// Create a new connection manager
    pub fn new(config: ServerConfig) -> Self {
        let (event_sender, _) = broadcast::channel(64);
        Self {
            clients: Arc::new(Mutex::new(HashMap::new())),
            frame_senders: Arc::new(Mutex::new(HashMap::new())),
            config,
            event_sender,
        }
    }

    /// Register a new client. Returns the session_id and display config, or an error.
    pub async fn register_client(
        &self,
        registration: ClientRegistration,
    ) -> Result<(String, DisplayConfig), String> {
        let mut clients = self.clients.lock().await;

        // Check if max clients reached
        let active_count = clients
            .values()
            .filter(|c| c.state != ClientState::Disconnecting)
            .count();

        if active_count >= self.config.max_clients {
            return Err(format!(
                "Maximum number of clients ({}) reached",
                self.config.max_clients
            ));
        }

        // Check if client with same ID is already connected
        let existing = clients
            .values()
            .find(|c| c.registration.client_id == registration.client_id);
        if let Some(existing) = existing {
            return Err(format!(
                "Client '{}' is already connected with session '{}'",
                registration.client_id, existing.session_id
            ));
        }

        // Generate session ID
        let session_id = uuid::Uuid::new_v4().to_string();

        // Determine display index (position in the lineup)
        let display_index = clients.len();

        // Create the client connection
        let mut client = ClientConnection::new(session_id.clone(), registration.clone());

        // Generate display configuration
        let display_config = client.create_default_display_config(display_index);
        client.display_config = Some(display_config.clone());
        client.state = ClientState::Active;

        info!(
            "Client registered: {} (session: {})",
            client.description(),
            session_id
        );

        clients.insert(session_id.clone(), client);

        // Notify listeners
        let _ = self.event_sender.send(format!("registered:{}", session_id));

        Ok((session_id, display_config))
    }

    /// Handle a heartbeat from a client
    pub async fn handle_heartbeat(&self, session_id: &str) -> Result<(), String> {
        let mut clients = self.clients.lock().await;
        match clients.get_mut(session_id) {
            Some(client) => {
                client.touch_heartbeat();
                Ok(())
            }
            None => Err(format!("Unknown session: {}", session_id)),
        }
    }

    /// Handle a control message from a client
    pub async fn handle_control_message(
        &self,
        session_id: &str,
        msg_type: i32,
        payload: &str,
    ) -> Result<String, String> {
        let control_type = ControlMessageType::try_from(msg_type)
            .map_err(|_| format!("Unknown control message type: {}", msg_type))?;

        match control_type {
            ControlMessageType::Heartbeat => {
                self.handle_heartbeat(session_id).await?;
                Ok("heartbeat ok".to_string())
            }
            ControlMessageType::Disconnect => {
                self.disconnect_client(session_id, "Client requested disconnect")
                    .await?;
                Ok("disconnected".to_string())
            }
            ControlMessageType::Reconfigure => {
                info!(
                    "Client {} requested reconfiguration: {}",
                    session_id, payload
                );
                let _ = self
                    .event_sender
                    .send(format!("reconfigure:{}:{}", session_id, payload));
                Ok("reconfiguration acknowledged".to_string())
            }
            ControlMessageType::Error => {
                warn!("Client {} reported error: {}", session_id, payload);
                Ok("error acknowledged".to_string())
            }
            ControlMessageType::Unspecified => Err("Unspecified control message type".to_string()),
        }
    }

    /// Disconnect a client gracefully
    pub async fn disconnect_client(&self, session_id: &str, reason: &str) -> Result<(), String> {
        let mut clients = self.clients.lock().await;
        match clients.get_mut(session_id) {
            Some(client) => {
                info!(
                    "Disconnecting client: {} - reason: {}",
                    client.description(),
                    reason
                );
                client.state = ClientState::Disconnecting;
                // Remove the client
                clients.remove(session_id);
                let _ = self
                    .event_sender
                    .send(format!("disconnected:{}", session_id));
                Ok(())
            }
            None => Err(format!("Unknown session: {}", session_id)),
        }
    }

    /// Get the display config for a specific client
    pub async fn get_display_config(&self, session_id: &str) -> Option<DisplayConfig> {
        let clients = self.clients.lock().await;
        clients
            .get(session_id)
            .and_then(|c| c.display_config.clone())
    }

    /// Get all active session IDs
    pub async fn active_sessions(&self) -> Vec<String> {
        let clients = self.clients.lock().await;
        clients
            .values()
            .filter(|c| c.state == ClientState::Active)
            .map(|c| c.session_id.clone())
            .collect()
    }

    /// Get a summary of all connected clients
    pub async fn client_summary(&self) -> Vec<(String, String, ClientState)> {
        let clients = self.clients.lock().await;
        clients
            .values()
            .map(|c| (c.session_id.clone(), c.description(), c.state.clone()))
            .collect()
    }

    /// Get the number of connected clients
    pub async fn client_count(&self) -> usize {
        let clients = self.clients.lock().await;
        clients
            .values()
            .filter(|c| c.state != ClientState::Disconnecting)
            .count()
    }

    /// Check for timed-out clients and remove them
    pub async fn check_heartbeats(&self) -> Vec<String> {
        let mut clients = self.clients.lock().await;
        let timeout = self.config.heartbeat_timeout_secs;

        let timed_out: Vec<String> = clients
            .values()
            .filter(|c| c.state == ClientState::Active && c.is_heartbeat_expired(timeout))
            .map(|c| c.session_id.clone())
            .collect();

        for session_id in &timed_out {
            if let Some(client) = clients.get(session_id) {
                warn!(
                    "Client heartbeat timeout: {} (session: {})",
                    client.description(),
                    session_id
                );
            }
            clients.remove(session_id);
            let _ = self.event_sender.send(format!("timeout:{}", session_id));
        }

        timed_out
    }

    /// Get a reference to the internal clients map (for use by the WebSocket server)
    pub fn clients(&self) -> Arc<Mutex<HashMap<String, ClientConnection>>> {
        self.clients.clone()
    }

    /// Subscribe to connection events
    pub fn subscribe_events(&self) -> broadcast::Receiver<String> {
        self.event_sender.subscribe()
    }

    /// Get the server config
    pub fn config(&self) -> &ServerConfig {
        &self.config
    }

    /// Increment the frames_sent counter for a client
    pub async fn record_frame_sent(&self, session_id: &str) {
        let mut clients = self.clients.lock().await;
        if let Some(client) = clients.get_mut(session_id) {
            client.frames_sent += 1;
        }
    }

    /// Register a per-client frame sender channel.
    /// Returns the receiving end for the connection handler to consume.
    pub async fn register_frame_sender(
        &self,
        session_id: &str,
    ) -> mpsc::UnboundedReceiver<Vec<u8>> {
        let (tx, rx) = mpsc::unbounded_channel();
        let mut senders = self.frame_senders.lock().await;
        senders.insert(session_id.to_string(), tx);
        info!("Frame sender registered for session {}", session_id);
        rx
    }

    /// Remove a per-client frame sender (called on disconnect).
    pub async fn remove_frame_sender(&self, session_id: &str) {
        let mut senders = self.frame_senders.lock().await;
        senders.remove(session_id);
        info!("Frame sender removed for session {}", session_id);
    }

    /// Broadcast an encoded frame to all active clients.
    /// Converts the EncodedFrame into a protobuf VideoFrame and sends to each client.
    /// Returns the number of clients the frame was successfully sent to.
    pub async fn broadcast_frame(
        &self,
        encoded_frame: &EncodedFrame,
        width: u32,
        height: u32,
    ) -> usize {
        // Build the protobuf VideoFrame
        let video_frame = VideoFrame {
            sequence_number: encoded_frame.sequence,
            timestamp_us: encoded_frame.timestamp.elapsed().as_micros() as u64, // relative timestamp
            frame_data: encoded_frame.data.clone(),
            frame_type: if encoded_frame.is_keyframe {
                FrameType::Keyframe as i32
            } else {
                FrameType::Delta as i32
            },
            width,
            height,
        };

        let frame_bytes = video_frame.encode_to_vec();

        let active_sessions = self.active_sessions().await;
        let senders = self.frame_senders.lock().await;

        let mut sent_count = 0;
        let mut failed_sessions = Vec::new();

        for session_id in &active_sessions {
            if let Some(sender) = senders.get(session_id) {
                match sender.send(frame_bytes.clone()) {
                    Ok(_) => {
                        sent_count += 1;
                    }
                    Err(_) => {
                        // Channel closed — client disconnected
                        warn!(
                            "Failed to send frame to session {} (channel closed)",
                            session_id
                        );
                        failed_sessions.push(session_id.clone());
                    }
                }
            }
        }

        // Update frame counters for successfully sent frames
        if sent_count > 0 {
            let mut clients = self.clients.lock().await;
            for session_id in &active_sessions {
                if let Some(client) = clients.get_mut(session_id) {
                    if !failed_sessions.contains(session_id) {
                        client.frames_sent += 1;
                    }
                }
            }
        }

        // Schedule cleanup of failed sessions (don't hold lock)
        drop(senders);
        for session_id in failed_sessions {
            error!(
                "Auto-disconnecting session {} due to send failure",
                session_id
            );
            self.disconnect_client(&session_id, "Frame send failed — channel closed")
                .await
                .ok();
            self.remove_frame_sender(&session_id).await;
        }

        sent_count
    }
}
