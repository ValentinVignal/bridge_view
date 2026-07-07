/// The status of the connection to the Bridge View server.
enum ConnectionStatus {
  /// No active connection. Either never connected or explicitly disconnected.
  disconnected,

  /// TCP/WebSocket connection is being established to the server.
  connecting,

  /// WebSocket is open; sending [ClientRegistration] and awaiting
  /// [DisplayConfig] from the server.
  registering,

  /// Fully registered and actively receiving video frames.
  connected,

  /// Connection was lost unexpectedly; automatically retrying.
  reconnecting,
}
