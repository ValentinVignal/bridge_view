import 'package:flutter/services.dart';

import 'h264_renderer.g.dart';

class H264Renderer extends H264RendererApi {
  int? _textureId;

  /// The Flutter texture ID returned by [initialize].
  /// Null until [initialize] completes.
  int? get textureId => _textureId;

  @override
  Future<int> initialize(int width, int height) async {
    _textureId = await super.initialize(width, height);
    return _textureId!;
  }

  @override
  Future<void> decodeFrame(
    Uint8List frameData, {
    bool isKeyframe = false,
  }) async {
    if (_textureId == null) return;
    return super.decodeFrame(frameData, isKeyframe: isKeyframe);
  }

  @override
  Future<void> dispose() async {
    if (_textureId == null) return;
    _textureId = null;
    await super.dispose();
  }
}
