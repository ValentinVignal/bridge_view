import 'package:pigeon/pigeon.dart';

/// Platform-channel bridge to the native H.264 hardware decoder.
///
/// Lifecycle: call [initialize] once, [decodeFrame] for each incoming frame,
/// and [dispose] when the session ends.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/video/h264_renderer.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/example/bridge_view_client/H264Renderer.g.kt',
    swiftOut: 'macos/Runner/H264Renderer.g.swift',
  ),
)
@HostApi()
abstract class H264RendererApi {
  /// Platform-channel bridge to the native H.264 hardware decoder.
  ///
  /// Lifecycle: call [initialize] once, [decodeFrame] for each incoming frame,
  /// and [dispose] when the session ends.
  int initialize(int width, int height);

  /// Pushes a raw H.264 Annex-B frame to the native decoder.
  ///
  /// Fire-and-forget: do not await this in the frame callback.
  void decodeFrame(Uint8List frameData, {bool isKeyframe = false});

  /// Releases the native decoder and unregisters the Flutter texture.
  void dispose();
}
