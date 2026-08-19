import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';

import '../proto/proto/display.pb.dart';
import 'h264_renderer.dart';

/// Full-size widget that decodes an H.264 stream via a native hardware decoder
/// and renders it through a Flutter [Texture].
///
/// Shows a loading indicator while the native decoder initializes, then
/// switches to the decoded video output. An FPS overlay is displayed in the
/// top-right corner.
class VideoDisplayWidget extends StatefulWidget {
  final Stream<VideoFrame> frameStream;
  final int width;
  final int height;

  const VideoDisplayWidget({
    super.key,
    required this.frameStream,
    required this.width,
    required this.height,
  });

  @override
  State<VideoDisplayWidget> createState() => _VideoDisplayWidgetState();
}

class _VideoDisplayWidgetState extends State<VideoDisplayWidget> {
  final _renderer = H264Renderer();
  int? _textureId;
  StreamSubscription<VideoFrame>? _subscription;

  // FPS tracking
  int _frameCount = 0;
  double _fps = 0.0;
  DateTime _fpsWindowStart = clock.now();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final id = await _renderer.initialize(widget.width, widget.height);
    if (!mounted) return;
    setState(() => _textureId = id);
    _subscription = widget.frameStream.listen(_onFrame);
  }

  void _onFrame(VideoFrame frame) {
    if (!frame.hasFrameData() || frame.frameData.isEmpty) return;

    final data = frame.frameData is Uint8List
        ? frame.frameData as Uint8List
        : Uint8List.fromList(frame.frameData);

    _renderer.decodeFrame(
      data,
      isKeyframe: frame.frameType == FrameType.FRAME_TYPE_KEYFRAME,
    );

    // Update FPS counter once per second
    _frameCount++;
    final now = clock.now();
    final elapsedMs = now.difference(_fpsWindowStart).inMilliseconds;
    if (elapsedMs >= 1000) {
      final fps = _frameCount * 1000.0 / elapsedMs;
      _frameCount = 0;
      _fpsWindowStart = now;
      if (mounted) setState(() => _fps = fps);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = _textureId;
    if (id == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Texture(textureId: id),
        Positioned(top: 8, right: 8, child: _FpsOverlay(fps: _fps)),
      ],
    );
  }
}

class _FpsOverlay extends StatelessWidget {
  final double fps;

  const _FpsOverlay({required this.fps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('${fps.toStringAsFixed(1)} fps'),
    );
  }
}
