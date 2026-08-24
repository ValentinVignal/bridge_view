import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../connection/bridge_view_client.dart';
import '../connection/connection_providers.dart';
import '../connection/connection_state.dart';
import '../platform/window_control.dart';
import '../proto/proto/display.pb.dart';
import '../video/video_display_widget.dart';

/// Full-screen display shown once the client is registered and receiving
/// frames.
///
/// Hides system UI for an immersive experience and automatically returns to the
/// connection screen if the server disconnects.
class DisplayScreen extends ConsumerStatefulWidget {
  const DisplayScreen({super.key});

  @override
  ConsumerState<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends ConsumerState<DisplayScreen> {
  late final Stream<VideoFrame> _frameStream;
  bool _orientationLocked = false;

  @override
  void initState() {
    super.initState();
    _frameStream = ref.read(bridgeViewClientProvider.notifier).frameStream;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    WindowControl.enterFullScreen();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const []);
    WakelockPlus.disable();
    WindowControl.exitFullScreen();
    super.dispose();
  }

  /// Locks device rotation to match the assigned display's aspect ratio so the
  /// rendered frame always fills the screen without being rotated relative to
  /// the server's layout.
  void _lockOrientation(DisplayConfig config) {
    if (_orientationLocked || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _orientationLocked = true;
    final isLandscape = config.displayWidth >= config.displayHeight;
    SystemChrome.setPreferredOrientations(
      isLandscape
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectionStatus>(statusProvider, (_, next) {
      if (next == ConnectionStatus.disconnected && mounted) {
        Navigator.of(context).maybePop();
      }
    });
    ref.listen(bridgeViewClientProvider, (_, next) {
      if (next.displayConfig == null) {
        return;
      }
      _lockOrientation(next.displayConfig!);
    });

    final config = ref.watch(bridgeViewClientProvider).displayConfig;
    if (config == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // Keep the whole frame clear of notches/cutouts on every platform.
      body: SafeArea(
        child: VideoDisplayWidget(
          frameStream: _frameStream,
          width: config.displayWidth.toInt(),
          height: config.displayHeight.toInt(),
        ),
      ),
    );
  }
}
