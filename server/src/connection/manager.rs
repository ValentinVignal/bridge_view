use std::collections::HashMap;
use std::sync::Arc;

use core_graphics::display::CGDisplay;
use log::{info, warn};
use prost::Message;
use tokio::sync::{Mutex, broadcast, mpsc};

use crate::encoder::EncodedFrame;
use crate::proto::{
    ClientRegistration, ControlMessageType, DisplayConfig, FrameType, ServerPush, VideoFrame,
    server_push,
};

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

        // Pick a physical/dummy macOS display not already captured for another
        // client (see doc/virtual-display-research.md — true virtual displays
        // aren't feasible for the MVP, so we capture real connected displays).
        let display_id = Self::pick_available_display(&clients);
        let bounds = CGDisplay::new(display_id).bounds();

        // Create the client connection
        let mut client = ClientConnection::new(session_id.clone(), registration.clone());
        client.assigned_display_id = display_id;

        // Generate display configuration from the assigned display's real geometry
        let display_config = client.create_display_config(
            bounds.origin.x as i32,
            bounds.origin.y as i32,
            bounds.size.width as u32,
            bounds.size.height as u32,
        );
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

    /// Pick a `CGDirectDisplayID` for a newly registered client: prefer an
    /// active display not already assigned to another connected client,
    /// falling back to the main display when no spare display is connected
    /// (e.g. during local development with a single Mac).
    fn pick_available_display(clients: &HashMap<String, ClientConnection>) -> u32 {
        let used: std::collections::HashSet<u32> =
            clients.values().map(|c| c.assigned_display_id).collect();
        let main_id = CGDisplay::main().id;

        if let Ok(active) = CGDisplay::active_displays() {
            if let Some(&id) = active
                .iter()
                .find(|&&id| id != main_id && !used.contains(&id))
            {
                return id;
            }
        }

        main_id
    }

    /// Get the `CGDirectDisplayID` assigned to a specific client session
    pub async fn assigned_display(&self, session_id: &str) -> Option<u32> {
        let clients = self.clients.lock().await;
        clients.get(session_id).map(|c| c.assigned_display_id)
    }

    /// Reassign the macOS display captured for an already-connected client.
    ///
    /// Validates that `display_id` is currently active and not already
    /// captured for a *different* client, then updates the client's
    /// `assigned_display_id`/`display_config` and returns the new config.
    /// Callers are responsible for pushing the config to the client (see
    /// `push_display_config`) and restarting its `FrameStreamer` (see
    /// `notify_display_changed`) — this only updates the manager's bookkeeping.
    pub async fn reassign_display(
        &self,
        session_id: &str,
        display_id: u32,
    ) -> Result<DisplayConfig, String> {
        let active = CGDisplay::active_displays()
            .map_err(|e| format!("Failed to enumerate displays: {:?}", e))?;
        if !active.contains(&display_id) {
            return Err(format!("Display {} is not currently active", display_id));
        }

        let mut clients = self.clients.lock().await;

        if let Some((other_session, _)) = clients
            .iter()
            .find(|(id, c)| id.as_str() != session_id && c.assigned_display_id == display_id)
        {
            return Err(format!(
                "Display {} is already assigned to session {}",
                display_id, other_session
            ));
        }

        let client = clients
            .get_mut(session_id)
            .ok_or_else(|| format!("Unknown session: {}", session_id))?;

        let bounds = CGDisplay::new(display_id).bounds();
        let display_config = client.create_display_config(
            bounds.origin.x as i32,
            bounds.origin.y as i32,
            bounds.size.width as u32,
            bounds.size.height as u32,
        );
        client.assigned_display_id = display_id;
        client.display_config = Some(display_config.clone());

        info!(
            "Reassigned session {} to display {}",
            session_id, display_id
        );

        Ok(display_config)
    }

    /// Push a `DisplayConfig` to a connected client outside of the initial
    /// registration handshake (e.g. after `reassign_display`). Returns
    /// `true` if the config was successfully queued for delivery.
    pub async fn push_display_config(&self, session_id: &str, config: &DisplayConfig) -> bool {
        let push = ServerPush {
            payload: Some(server_push::Payload::DisplayConfig(config.clone())),
        };
        let bytes = push.encode_to_vec();

        let senders = self.frame_senders.lock().await;
        match senders.get(session_id) {
            Some(sender) => sender.send(bytes).is_ok(),
            None => false,
        }
    }

    /// Broadcast a `display_changed` event so the `StreamerPool` restarts
    /// the streamer for this session against its newly assigned display.
    pub fn notify_display_changed(&self, session_id: &str) {
        let _ = self
            .event_sender
            .send(format!("display_changed:{}", session_id));
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

    /// Get a summary of all connected clients (session id, description,
    /// state, and the `CGDirectDisplayID` captured for them)
    pub async fn client_summary(&self) -> Vec<(String, String, ClientState, u32)> {
        let clients = self.clients.lock().await;
        clients
            .values()
            .map(|c| {
                (
                    c.session_id.clone(),
                    c.description(),
                    c.state.clone(),
                    c.assigned_display_id,
                )
            })
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

    /// Send an encoded frame to a single client (each client has its own
    /// dedicated capture/encode pipeline targeting its assigned display).
    /// Converts the `EncodedFrame` into a protobuf `VideoFrame`.
    /// Returns `true` if the frame was successfully delivered.
    pub async fn send_frame(
        &self,
        session_id: &str,
        encoded_frame: &EncodedFrame,
        width: u32,
        height: u32,
    ) -> bool {
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

        let push = ServerPush {
            payload: Some(server_push::Payload::VideoFrame(video_frame)),
        };
        let frame_bytes = push.encode_to_vec();

        let sent = {
            let senders = self.frame_senders.lock().await;
            match senders.get(session_id) {
                Some(sender) => sender.send(frame_bytes).is_ok(),
                None => false,
            }
        };

        if sent {
            self.record_frame_sent(session_id).await;
        } else {
            warn!(
                "Failed to send frame to session {} (no sender or channel closed)",
                session_id
            );
            self.disconnect_client(session_id, "Frame send failed — channel closed")
                .await
                .ok();
            self.remove_frame_sender(session_id).await;
        }

        sent
    }
}
