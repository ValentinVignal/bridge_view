import 'package:pigeon/pigeon.dart';

/// Native platform-channel APIs for bridge_view_client.
///
/// Merged into a single Pigeon file (rather than one file per API) because
/// Pigeon's generated Swift/Kotlin helper declarations (e.g. `PigeonError`)
/// are top-level and would collide if generated into separate files that are
/// compiled into the same target.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/platform/native_apis.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/example/bridge_view_client/NativeApis.g.kt',
    swiftOut: 'macos/Runner/NativeApis.g.swift',
  ),
)
/// Platform-channel bridge to the native H.264 hardware decoder.
///
/// Lifecycle: call [initialize] once, [decodeFrame] for each incoming frame,
/// and [dispose] when the session ends.
@HostApi()
abstract class H264RendererApi {
  const H264RendererApi();

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

/// Platform-channel bridge for native window management.
///
/// macOS only: the Flutter window doesn't expose a way to enter/exit
/// fullscreen from Dart, so this delegates to `NSWindow.toggleFullScreen`.
@HostApi()
abstract class WindowControlApi {
  const WindowControlApi();

  /// Puts the native window into fullscreen mode if it isn't already.
  void enterFullScreen();

  /// Takes the native window out of fullscreen mode if it is currently in it.
  void exitFullScreen();
}
