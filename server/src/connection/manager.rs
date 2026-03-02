use std::collections::HashMap;
use std::sync::Arc;

use log::{info, warn};
use tokio::sync::{Mutex, broadcast};

use crate::proto::{ClientRegistration, ControlMessageType, DisplayConfig};

use super::types::{ClientConnection, ClientState, ConnectionEvent, ServerConfig};

/// Manages all client connections and their state
pub struct ConnectionManager {
    /// Connected clients keyed by session_id
    clients: Arc<Mutex<HashMap<String, ClientConnection>>>,
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
}
