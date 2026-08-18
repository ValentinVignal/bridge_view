import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connection/bridge_view_client.dart';
import '../connection/connection_providers.dart';
import '../connection/connection_state.dart';
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

  @override
  void initState() {
    super.initState();
    _frameStream = ref.read(bridgeViewClientProvider.notifier).frameStream;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectionStatus>(statusProvider, (_, next) {
      if (next == ConnectionStatus.disconnected && mounted) {
        Navigator.of(context).maybePop();
      }
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
      body: VideoDisplayWidget(
        frameStream: _frameStream,
        width: config.displayWidth.toInt(),
        height: config.displayHeight.toInt(),
      ),
    );
  }
}
