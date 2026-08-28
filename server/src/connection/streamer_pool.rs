use std::collections::HashMap;
use std::sync::Arc;

use log::{info, warn};
use tokio::sync::Mutex;

use super::manager::ConnectionManager;
use super::streaming::{FrameStreamer, StreamerHandle, StreamingConfig};

/// Watches the `ConnectionManager` event bus and maintains one dedicated
/// `FrameStreamer` per connected client, each capturing that client's
/// assigned display and streaming frames only to that client.
///
/// This is what implements "each client gets its own extended display": since
/// macOS doesn't let us create true virtual displays (see
/// doc/virtual-display-research.md), every client is instead assigned one of
/// the Mac's currently active displays (real or dummy-plug) and gets its own
/// capture/encode pipeline for it.
pub struct StreamerPool {
    manager: Arc<ConnectionManager>,
    /// Template streaming settings (fps, quality, queue behaviour). The
    /// `display_id` field is overridden per-client with its assigned display.
    template: StreamingConfig,
    handles: Mutex<HashMap<String, StreamerHandle>>,
}

impl StreamerPool {
    pub fn new(manager: Arc<ConnectionManager>, template: StreamingConfig) -> Arc<Self> {
        Arc::new(Self {
            manager,
            template,
            handles: Mutex::new(HashMap::new()),
        })
    }

    /// Spawn the background task that listens for client registration and
    /// disconnection events and starts/stops streamers accordingly.
    pub fn start(self: Arc<Self>) -> tokio::task::JoinHandle<()> {
        let mut events = self.manager.subscribe_events();
        tokio::spawn(async move {
            loop {
                match events.recv().await {
                    Ok(event) => self.handle_event(&event).await,
                    Err(tokio::sync::broadcast::error::RecvError::Lagged(n)) => {
                        warn!("StreamerPool event stream lagged by {} messages", n);
                    }
                    Err(tokio::sync::broadcast::error::RecvError::Closed) => break,
                }
            }
        })
    }

    async fn handle_event(&self, event: &str) {
        if let Some(session_id) = event.strip_prefix("registered:") {
            self.spawn_streamer(session_id).await;
        } else if let Some(session_id) = event
            .strip_prefix("disconnected:")
            .or_else(|| event.strip_prefix("timeout:"))
        {
            self.stop_streamer(session_id).await;
        }
    }

    async fn spawn_streamer(&self, session_id: &str) {
        let Some(display_id) = self.manager.assigned_display(session_id).await else {
            warn!(
                "No display assigned for session {}, skipping streamer",
                session_id
            );
            return;
        };

        let config = StreamingConfig {
            display_id,
            ..self.template.clone()
        };

        let streamer = FrameStreamer::new(config, self.manager.clone(), session_id.to_string());
        let handle = streamer.start();

        let mut handles = self.handles.lock().await;
        handles.insert(session_id.to_string(), handle);
    }

    async fn stop_streamer(&self, session_id: &str) {
        let mut handles = self.handles.lock().await;
        if let Some(mut handle) = handles.remove(session_id) {
            info!("Stopping streamer for session {}", session_id);
            handle.stop();
        }
    }

    /// Stop all remaining per-client streamers (called on server shutdown).
    pub async fn stop_all(&self) {
        let mut handles = self.handles.lock().await;
        for (session_id, mut handle) in handles.drain() {
            info!("Stopping streamer for session {}", session_id);
            handle.stop();
        }
    }
}
