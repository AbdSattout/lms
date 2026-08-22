import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'video_controls.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  static final Map<String, Duration> _sessionPositions = {};

  VideoPlayerController? _controller;
  bool _hasError = false;
  bool _isFullscreenOpen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final saved = _sessionPositions[widget.url];
      final durationMs = controller.value.duration.inMilliseconds;
      if (saved != null &&
          saved.inMilliseconds > 0 &&
          saved.inMilliseconds < durationMs) {
        await controller.seekTo(saved);
      }

      controller.addListener(() {
        final value = controller.value;
        if (!value.isInitialized) return;
        if (value.isCompleted) {
          _sessionPositions.remove(widget.url);
        } else if (value.position > Duration.zero) {
          _sessionPositions[widget.url] = value.position;
        }
      });

      setState(() {});
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _toggleFullscreen() async {
    final controller = _controller;
    if (controller == null || _isFullscreenOpen || !mounted) return;

    setState(() => _isFullscreenOpen = true);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (!mounted) {
      _restoreOrientation();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (_) => _FullscreenPlayerPage(controller: controller),
    );

    _isFullscreenOpen = false;
    _restoreOrientation();
    if (mounted) setState(() {});
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_hasError) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_camera_back_outlined, color: colors.error),
              const SizedBox(width: 8),
              Text(
                'تعذر تحميل الفيديو',
                style: TextStyle(color: colors.error, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio > 0
            ? controller.value.aspectRatio
            : 16 / 9,
        child: _isFullscreenOpen
            ? const ColoredBox(color: Colors.black)
            : Stack(
                fit: StackFit.expand,
                children: [
                  VideoPlayer(controller),
                  VideoControlsOverlay(
                    controller: controller,
                    isFullscreen: false,
                    onToggleFullscreen: _toggleFullscreen,
                  ),
                ],
              ),
      ),
    );
  }
}

class _FullscreenPlayerPage extends StatelessWidget {
  final VideoPlayerController controller;

  const _FullscreenPlayerPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: VideoPlayer(controller),
            ),
          ),
          VideoControlsOverlay(
            controller: controller,
            isFullscreen: true,
            onToggleFullscreen: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
