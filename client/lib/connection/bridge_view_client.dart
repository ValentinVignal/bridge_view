import 'dart:async';
import 'dart:io';

import 'package:bridge_view_client/connection/connection_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../proto/proto/display.pb.dart';
import 'connection_state.dart';

part 'bridge_view_client.freezed.dart';

@freezed
sealed class BridgeViewClientState with _$BridgeViewClientState {
  const factory BridgeViewClientState({
    required ConnectionStatus status,
    String? sessionId,
    DisplayConfig? displayConfig,
    String? errorMessage,
    required int reconnectAttempts,
    required int framesReceived,
    required String webSocketUrl,
  }) = _BridgeViewClientState;
}

class BridgeViewClient extends Notifier<BridgeViewClientState> {
  static final Duration heartbeatInterval = const Duration(seconds: 5);
  static final Duration reconnectDelay = const Duration(seconds: 3);
  static final int maxReconnectAttempts = 10;

  @override
  build() {
    final webSocketUrl = ref.watch(webSocketUrlProvider);
    ref.onDispose(dispose);
    return BridgeViewClientState(
      status: ConnectionStatus.disconnected,
      reconnectAttempts: 0,
      framesReceived: 0,
      webSocketUrl: webSocketUrl,
    );
  }

  @override
  BridgeViewClientState get state => super.state;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  StreamSubscription? _subscription;
  bool _connected = false;

  final _frameController = StreamController<VideoFrame>.broadcast();
  Stream<VideoFrame> get frameStream => _frameController.stream;

  Future<void> connect() async {
    if (_connected) return;
    _connected = true;
    state = state.copyWith(
      status: ConnectionStatus.connecting,
      errorMessage: null,
    );

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(state.webSocketUrl),
        pingInterval: heartbeatInterval,
      );
      await _channel!.ready;

      state = state.copyWith(status: ConnectionStatus.registering);

      _sendRegistration();
      _listenToMessages();
    } on WebSocketChannelException catch (e, s) {
      _handleConnectionError('Connection failed: ${e.message}, $s');
    } on SocketException catch (e) {
      _handleConnectionError('Connection failed: ${e.message}');
    } catch (e) {
      _handleConnectionError('Connection failed: $e');
    }
  }

  void _sendRegistration() {
    final registration = ClientRegistration(
      clientId: _generateClientId(),
      deviceType: _detectDeviceType(),
      deviceName: _getDeviceName(),
      capabilities: ClientCapabilities(
        maxWidth: 1920,
        maxHeight: 1080,
        supportedCodecs: const [VideoCodec.VIDEO_CODEC_H264],
        supportsTouch: Platform.isAndroid || Platform.isIOS,
        supportsKeyboard:
            Platform.isMacOS || Platform.isLinux || Platform.isWindows,
        supportsMouse:
            Platform.isMacOS || Platform.isLinux || Platform.isWindows,
        maxFramerate: 30,
      ),
    );

    _channel!.sink.add(registration.writeToBuffer());
  }

  void _listenToMessages() {
    _subscription = _channel!.stream.listen(
      _onMessage,
      onError: (error) {
        _handleConnectionError('WebSocket error: $error');
      },
      onDone: () {
        if (_connected && state.status != ConnectionStatus.disconnected) {
          _handleConnectionError('Connection closed by server');
        }
      },
    );
  }

  void _onMessage(dynamic data) {
    if (data is! List<int>) return;
    final bytes = Uint8List.fromList(data);

    if (state.status == ConnectionStatus.registering) {
      _handleRegistrationResponse(bytes);
    } else if (state.status == ConnectionStatus.connected) {
      _handleFrameOrControl(bytes);
    }
  }

  void _handleRegistrationResponse(Uint8List bytes) {
    try {
      final config = DisplayConfig.fromBuffer(bytes);
      if (config.hasSessionId()) {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          sessionId: config.sessionId,
          displayConfig: config,
          reconnectAttempts: 0,
        );
      } else {
        // Might be a ControlResponse error
        try {
          final response = ControlResponse.fromBuffer(bytes);
          _handleConnectionError('Registration rejected: ${response.message}');
        } catch (_) {
          _handleConnectionError('Invalid registration response');
        }
      }
    } catch (e) {
      _handleConnectionError('Failed to parse registration response: $e');
    }
  }

  void _handleFrameOrControl(Uint8List bytes) {
    try {
      final frame = VideoFrame.fromBuffer(bytes);
      if (frame.hasFrameData() && frame.frameData.isNotEmpty) {
        state = state.copyWith(framesReceived: state.framesReceived + 1);
        _frameController.add(frame);
        return;
      }
    } catch (_) {}

    // Try parsing as ControlResponse
    try {
      final control = ControlResponse.fromBuffer(bytes);
      if (control.hasMessage()) {
        debugPrint('Control message: ${control.message}');
      }
    } catch (_) {}
  }

  void _handleConnectionError(String message) {
    debugPrint('Connection error: $message');
    state = state.copyWith(errorMessage: message);
    _cleanup();

    if (_connected && state.reconnectAttempts < maxReconnectAttempts) {
      state = state.copyWith(status: ConnectionStatus.reconnecting);
      _scheduleReconnect();
    } else {
      state = state.copyWith(status: ConnectionStatus.disconnected);
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final delay = reconnectDelay * (state.reconnectAttempts + 1);
    _reconnectTimer = Timer(delay, () {
      if (_connected) return;
      state = state.copyWith(reconnectAttempts: state.reconnectAttempts + 1);
      connect();
    });
  }

  Future<void> disconnect() async {
    _connected = false; // Allow reconnect after manual disconnect
    state = state.copyWith(
      reconnectAttempts: maxReconnectAttempts,
    ); // Prevent auto-reconnect
    if (state.sessionId != null) {
      try {
        final msg = ControlMessage(
          sessionId: state.sessionId!,
          type: ControlMessageType.CONTROL_MESSAGE_TYPE_DISCONNECT,
        );
        _channel?.sink.add(msg.writeToBuffer());
        // Brief delay to let the message send
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (_) {}
    }
    _cleanup();
    state = state.copyWith(status: ConnectionStatus.disconnected);
  }

  void _cleanup() {
    _connected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close().ignore();
    _channel = null;
  }

  String _generateClientId() {
    // Simple unique ID based on timestamp + platform
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'flutter-${Platform.operatingSystem}-$timestamp';
  }

  DeviceType _detectDeviceType() {
    if (Platform.isAndroid) return DeviceType.DEVICE_TYPE_ANDROID_PHONE;
    if (Platform.isMacOS) return DeviceType.DEVICE_TYPE_MACOS_LAPTOP;
    if (Platform.isIOS) return DeviceType.DEVICE_TYPE_IOS_PHONE;
    return DeviceType.DEVICE_TYPE_UNSPECIFIED;
  }

  String _getDeviceName() {
    return '${Platform.operatingSystem}-${Platform.localHostname}';
  }

  void dispose() {
    _cleanup();
    _frameController.close();
  }
}

final bridgeViewClientProvider =
    NotifierProvider.autoDispose<BridgeViewClient, BridgeViewClientState>(() {
      return BridgeViewClient();
    }, dependencies: [webSocketUrlProvider]);
