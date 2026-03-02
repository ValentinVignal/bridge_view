use std::sync::Arc;

use futures_util::{SinkExt, StreamExt};
use log::{error, info, warn};
use prost::Message;
use tokio::net::TcpListener;
use tokio::sync::Mutex;
use tokio_tungstenite::accept_async;
use tokio_tungstenite::tungstenite::protocol::Message as WsMessage;

use crate::proto::{
    ClientRegistration, ControlMessage, ControlResponse, DisplayConfig, VideoFrame,
};

use super::manager::ConnectionManager;

/// WebSocket server that handles client connections
pub struct WebSocketServer {
    manager: Arc<ConnectionManager>,
}

impl WebSocketServer {
    /// Create a new WebSocket server
    pub fn new(manager: Arc<ConnectionManager>) -> Self {
        Self { manager }
    }

    /// Start the WebSocket server and listen for connections
    pub async fn run(&self) -> Result<(), Box<dyn std::error::Error>> {
        let addr = self.manager.config().listen_addr();
        let listener = TcpListener::bind(&addr).await?;
        info!("WebSocket server listening on ws://{}", addr);

        // Spawn heartbeat checker
        let manager_hb = self.manager.clone();
        let heartbeat_interval = self.manager.config().heartbeat_interval_secs;
        tokio::spawn(async move {
            loop {
                tokio::time::sleep(tokio::time::Duration::from_secs(heartbeat_interval)).await;
                let timed_out = manager_hb.check_heartbeats().await;
                for session_id in timed_out {
                    warn!("Session {} timed out and was removed", session_id);
                }
            }
        });

        // Accept connections
        loop {
            match listener.accept().await {
                Ok((stream, addr)) => {
                    info!("New TCP connection from: {}", addr);

                    let manager = self.manager.clone();
                    tokio::spawn(async move {
                        match accept_async(stream).await {
                            Ok(ws_stream) => {
                                info!("WebSocket handshake completed with: {}", addr);
                                if let Err(e) =
                                    Self::handle_connection(manager, ws_stream, addr.to_string())
                                        .await
                                {
                                    error!("Connection error with {}: {}", addr, e);
                                }
                            }
                            Err(e) => {
                                error!("WebSocket handshake failed with {}: {}", addr, e);
                            }
                        }
                    });
                }
                Err(e) => {
                    error!("Failed to accept connection: {}", e);
                }
            }
        }
    }

    /// Handle a single WebSocket connection
    async fn handle_connection(
        manager: Arc<ConnectionManager>,
        ws_stream: tokio_tungstenite::WebSocketStream<tokio::net::TcpStream>,
        addr: String,
    ) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
        let (write, mut read) = ws_stream.split();
        let write = Arc::new(Mutex::new(write));

        // Phase 1: Wait for client registration
        let session_id = loop {
            match read.next().await {
                Some(Ok(msg)) => {
                    if let WsMessage::Binary(data) = msg {
                        // Try to decode as ClientRegistration
                        match ClientRegistration::decode(data.as_ref()) {
                            Ok(registration) => {
                                info!(
                                    "Received registration from '{}' ({})",
                                    registration.device_name, addr
                                );

                                match manager.register_client(registration).await {
                                    Ok((session_id, display_config)) => {
                                        // Send display config back to client
                                        let config_bytes = display_config.encode_to_vec();
                                        let mut w = write.lock().await;
                                        w.send(WsMessage::Binary(config_bytes.into()))
                                            .await
                                            .map_err(|e| {
                                                format!("Failed to send display config: {}", e)
                                            })?;
                                        info!(
                                            "Sent display config to client (session: {})",
                                            session_id
                                        );
                                        break session_id;
                                    }
                                    Err(e) => {
                                        error!("Registration failed: {}", e);
                                        // Send error response
                                        let response = ControlResponse {
                                            success: false,
                                            message: e.clone(),
                                            timestamp_us: 0,
                                        };
                                        let mut w = write.lock().await;
                                        w.send(WsMessage::Binary(
                                            response.encode_to_vec().into(),
                                        ))
                                        .await
                                        .ok();
                                        return Err(e.into());
                                    }
                                }
                            }
                            Err(e) => {
                                warn!(
                                    "Failed to decode registration from {}: {}. Waiting for valid registration.",
                                    addr, e
                                );
                            }
                        }
                    } else if let WsMessage::Ping(data) = msg {
                        let mut w = write.lock().await;
                        w.send(WsMessage::Pong(data)).await.ok();
                    } else if let WsMessage::Close(_) = msg {
                        info!("Client {} closed connection before registering", addr);
                        return Ok(());
                    }
                }
                Some(Err(e)) => {
                    error!("WebSocket error from {} during registration: {}", addr, e);
                    return Err(e.into());
                }
                None => {
                    info!("Client {} disconnected before registering", addr);
                    return Ok(());
                }
            }
        };

        info!(
            "Client {} registered with session {}. Entering message loop.",
            addr, session_id
        );

        // Phase 2: Handle ongoing messages (control messages, heartbeats)
        loop {
            match read.next().await {
                Some(Ok(msg)) => match msg {
                    WsMessage::Binary(data) => {
                        // Try to decode as ControlMessage
                        match ControlMessage::decode(data.as_ref()) {
                            Ok(control_msg) => {
                                let result = manager
                                    .handle_control_message(
                                        &session_id,
                                        control_msg.r#type,
                                        &control_msg.payload,
                                    )
                                    .await;

                                let response = match result {
                                    Ok(message) => ControlResponse {
                                        success: true,
                                        message,
                                        timestamp_us: std::time::SystemTime::now()
                                            .duration_since(std::time::UNIX_EPOCH)
                                            .unwrap_or_default()
                                            .as_micros()
                                            as u64,
                                    },
                                    Err(e) => ControlResponse {
                                        success: false,
                                        message: e,
                                        timestamp_us: 0,
                                    },
                                };

                                let mut w = write.lock().await;
                                if let Err(e) =
                                    w.send(WsMessage::Binary(response.encode_to_vec().into())).await
                                {
                                    error!("Failed to send control response: {}", e);
                                    break;
                                }

                                // If client requested disconnect, break the loop
                                if control_msg.r#type
                                    == crate::proto::ControlMessageType::Disconnect as i32
                                {
                                    info!("Client {} gracefully disconnected", session_id);
                                    break;
                                }
                            }
                            Err(e) => {
                                warn!(
                                    "Failed to decode message from session {}: {}",
                                    session_id, e
                                );
                            }
                        }
                    }
                    WsMessage::Ping(data) => {
                        let mut w = write.lock().await;
                        w.send(WsMessage::Pong(data)).await.ok();
                        // Also count pings as heartbeats
                        manager.handle_heartbeat(&session_id).await.ok();
                    }
                    WsMessage::Pong(_) => {
                        // Count pongs as heartbeats too
                        manager.handle_heartbeat(&session_id).await.ok();
                    }
                    WsMessage::Close(_) => {
                        info!("Client {} closed WebSocket connection", session_id);
                        break;
                    }
                    _ => {}
                },
                Some(Err(e)) => {
                    error!("WebSocket error from session {}: {}", session_id, e);
                    break;
                }
                None => {
                    info!("Client {} disconnected", session_id);
                    break;
                }
            }
        }

        // Clean up
        manager
            .disconnect_client(&session_id, "Connection closed")
            .await
            .ok();

        Ok(())
    }

    /// Send a video frame to a specific client
    /// This is intended to be called externally by the frame streaming pipeline
    pub async fn send_frame_to_client(
        manager: &ConnectionManager,
        session_id: &str,
        frame: &VideoFrame,
    ) -> Result<(), String> {
        // This is a placeholder - actual frame sending will be connected
        // in Step 3.2 when we implement the frame streaming pipeline.
        // The WebSocket write half needs to be stored per-client for this to work.
        manager.record_frame_sent(session_id).await;
        Ok(())
    }
}
