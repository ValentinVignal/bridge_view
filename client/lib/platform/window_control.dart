import 'package:flutter/foundation.dart';

import 'native_apis.g.dart';

/// Convenience wrapper around [WindowControlApi].
///
/// macOS only; calling these on other platforms is a no-op host-side error,
/// so callers should guard with `defaultTargetPlatform == TargetPlatform.macOS`.
class WindowControl {
  static final _api = WindowControlApi();

  static Future<void> enterFullScreen() async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return _api.enterFullScreen();
    }
  }

  static Future<void> exitFullScreen() async {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return _api.exitFullScreen();
    }
  }
}
