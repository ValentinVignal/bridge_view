import 'package:flutter/services.dart';

/// Platform-channel bridge to the native H.264 hardware decoder.
///
/// Lifecycle: call [initialize] once, [decodeFrame] for each incoming frame,
/// and [dispose] when the session ends.
class H264Renderer {
  static const _channel = MethodChannel('bridge_view/h264_renderer');

  int? _textureId;

  /// The Flutter texture ID returned by [initialize].
  /// Null until [initialize] completes.
  int? get textureId => _textureId;

  /// Initializes the native decoder for a [width]×[height] display.
  /// Returns the texture ID to pass to [Texture.textureId].
  Future<int> initialize(int width, int height) async {
    final id = await _channel.invokeMethod<int>('initialize', {
      'width': width,
      'height': height,
    });
    _textureId = id!;
    return id;
  }

  /// Pushes a raw H.264 Annex-B frame to the native decoder.
  ///
  /// Fire-and-forget: do not await this in the frame callback.
  void decodeFrame(Uint8List frameData, {bool isKeyframe = false}) {
    if (_textureId == null) return;
    _channel.invokeMethod<void>('decodeFrame', {
      'frameData': frameData,
      'isKeyframe': isKeyframe,
    });
  }

  /// Releases the native decoder and unregisters the Flutter texture.
  Future<void> dispose() async {
    if (_textureId == null) return;
    _textureId = null;
    await _channel.invokeMethod<void>('dispose');
  }
}
