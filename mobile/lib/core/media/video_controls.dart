import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

String formatVideoDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

enum _SeekDirection { back, forward }

class VideoControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.onToggleFullscreen,
    this.isFullscreen = false,
  });

  @override
  State<VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<VideoControlsOverlay> {
  static const _hideDelay = Duration(seconds: 3);
  static const _flashDuration = Duration(milliseconds: 550);
  static const _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Timer? _hideTimer;
  Timer? _flashTimer;
  bool _visible = true;
  bool _wasPlaying = false;
  bool _wasMuted = false;
  bool _wasCompleted = false;
  _SeekDirection? _flash;
  int _flashTick = 0;

  VideoPlayerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _wasPlaying = _controller.value.isPlaying;
    _wasMuted = _controller.value.volume <= 0;
    _wasCompleted = _controller.value.isCompleted;
    _controller.addListener(_onValueChanged);
    _scheduleHide();
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _onValueChanged() {
    final value = _controller.value;
    final muted = value.volume <= 0;
    if (value.isPlaying == _wasPlaying &&
        muted == _wasMuted &&
        value.isCompleted == _wasCompleted) {
      return;
    }
    _wasPlaying = value.isPlaying;
    _wasMuted = muted;
    _wasCompleted = value.isCompleted;
    if (!mounted) return;
    setState(() {});
    if (value.isPlaying) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
      if (!_visible) setState(() => _visible = true);
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_controller.value.isPlaying) return;
    _hideTimer = Timer(_hideDelay, () {
      if (mounted && _controller.value.isPlaying && _visible) {
        setState(() => _visible = false);
      }
    });
  }

  void _revealControls() {
    _hideTimer?.cancel();
    if (!_visible) setState(() => _visible = true);
    _scheduleHide();
  }

  Future<void> _togglePlayPause() async {
    final value = _controller.value;
    if (!value.isInitialized) return;
    if (value.isPlaying) {
      await _controller.pause();
    } else {
      if (value.duration > Duration.zero && value.position >= value.duration) {
        await _controller.seekTo(Duration.zero);
      }
      await _controller.play();
    }
    if (!mounted) return;
    _revealControls();
  }

  Future<void> _seekBy(int seconds) async {
    final value = _controller.value;
    if (!value.isInitialized || value.duration <= Duration.zero) return;
    final targetMs = (value.position.inMilliseconds + seconds * 1000)
        .clamp(0, value.duration.inMilliseconds)
        .toInt();
    await _controller.seekTo(Duration(milliseconds: targetMs));
  }

  void _toggleMute() {
    final value = _controller.value;
    _controller.setVolume(value.volume > 0 ? 0 : 1);
    _revealControls();
  }

  String _formatSpeed(double speed) =>
      speed == speed.roundToDouble() ? '${speed.toInt()}x' : '$speed';

  Future<void> _showSpeedSheet() async {
    _revealControls();
    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        final current = _controller.value.playbackSpeed;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'سرعة التشغيل',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              for (final speed in _speedOptions)
                ListTile(
                  dense: true,
                  title: Text(
                    _formatSpeed(speed),
                    style: TextStyle(fontSize: 13.5, color: colors.onSurface),
                  ),
                  trailing: speed == current
                      ? Icon(Icons.check_rounded, color: colors.primary)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, speed),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      _controller.setPlaybackSpeed(selected);
    }
  }

  void _handleDoubleTap(Offset localPosition, double width) {
    final forward = localPosition.dx > width / 2;
    _seekBy(forward ? 10 : -10);
    _flashTimer?.cancel();
    setState(() {
      _flash = forward ? _SeekDirection.forward : _SeekDirection.back;
      _flashTick++;
    });
    _flashTimer = Timer(_flashDuration, () {
      if (mounted) setState(() => _flash = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_visible) {
                _hideTimer?.cancel();
                setState(() => _visible = false);
              } else {
                _revealControls();
              }
            },
            onDoubleTapDown: (details) =>
                _handleDoubleTap(details.localPosition, constraints.maxWidth),
            onDoubleTap: () {},
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_flash != null) _buildFlash(),
                _buildCenterControls(),
                _buildBottomBar(colors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlash() {
    final isBack = _flash == _SeekDirection.back;
    return Align(
      alignment: isBack ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: TweenAnimationBuilder<double>(
          key: ValueKey('$_flash$_flashTick'),
          tween: Tween(begin: 0, end: 1),
          duration: _flashDuration,
          curve: Curves.easeOut,
          builder: (context, t, child) {
            final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
            return Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
            );
          },
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isBack ? Icons.replay_10_rounded : Icons.forward_10_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(height: 2),
                Text(
                  isBack ? '-10s' : '+10s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        ignoring: !_visible,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCircleButton(
                icon: Icons.replay_10_rounded,
                onTap: () => _seekBy(-10),
              ),
              const SizedBox(width: 24),
              _buildPlayPauseButton(),
              const SizedBox(width: 24),
              _buildCircleButton(
                icon: Icons.forward_10_rounded,
                onTap: () => _seekBy(10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          onTap();
          _revealControls();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _togglePlayPause,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value;
            final buffering = value.isBuffering && !value.isPlaying;
            return Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: buffering
                  ? const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colors) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: IgnorePointer(
          ignoring: !_visible,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final value = _controller.value;
                  final muted = value.volume <= 0;
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 10),
                        child: Text(
                          '${formatVideoDuration(value.position)} / '
                          '${formatVideoDuration(value.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black38, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: VideoProgressBar(
                          controller: _controller,
                          playedColor: colors.primary,
                          handleColor: colors.primary,
                          backgroundColor: Colors.white24,
                          bufferedColor: Colors.white38,
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleMute,
                        visualDensity: VisualDensity.compact,
                        iconSize: 21,
                        color: Colors.white,
                        icon: Icon(
                          muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _showSpeedSheet,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            child: Text(
                              _formatSpeed(value.playbackSpeed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onToggleFullscreen,
                        visualDensity: VisualDensity.compact,
                        iconSize: 22,
                        color: Colors.white,
                        icon: Icon(
                          widget.isFullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Color handleColor;

  const VideoProgressBar({
    super.key,
    required this.controller,
    required this.playedColor,
    required this.bufferedColor,
    required this.backgroundColor,
    required this.handleColor,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  static const _throttle = Duration(milliseconds: 120);

  bool _dragging = false;
  double _dragFraction = 0;
  DateTime _lastSeekTime = DateTime.fromMillisecondsSinceEpoch(0);

  VideoPlayerController get _controller => widget.controller;

  double get _playedFraction {
    if (_dragging) return _dragFraction;
    final value = _controller.value;
    final durationMs = value.duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    return (value.position.inMilliseconds / durationMs)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double get _bufferedFraction {
    final value = _controller.value;
    final durationMs = value.duration.inMilliseconds;
    if (durationMs <= 0 || value.buffered.isEmpty) return 0;
    return (value.buffered.last.end.inMilliseconds / durationMs)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  void _scrubTo(double fraction, {bool force = false}) {
    final target = fraction.clamp(0.0, 1.0).toDouble();
    if (_dragging) {
      setState(() => _dragFraction = target);
    }
    final now = DateTime.now();
    if (!force && now.difference(_lastSeekTime) < _throttle) return;
    _lastSeekTime = now;
    final durationMs = _controller.value.duration.inMilliseconds;
    if (durationMs > 0) {
      _controller.seekTo(Duration(milliseconds: (target * durationMs).round()));
    }
  }

  void _onDragStart(double fraction) {
    setState(() {
      _dragging = true;
      _dragFraction = fraction.clamp(0.0, 1.0).toDouble();
    });
    _scrubTo(fraction, force: true);
  }

  void _onDragEnd() {
    if (!_dragging) return;
    _scrubTo(_dragFraction, force: true);
    setState(() => _dragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final played = _playedFraction;
        final buffered = _bufferedFraction;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final handleSize = _dragging ? 18.0 : 12.0;
            final handleLeft =
                (played * width - handleSize / 2)
                    .clamp(0.0, math.max(0.0, width - handleSize))
                    .toDouble();
            final bubbleLeft =
                (_dragFraction * width - 26)
                    .clamp(0.0, math.max(0.0, width - 52))
                    .toDouble();
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _scrubTo(details.localPosition.dx / width, force: true),
              onHorizontalDragStart: (details) =>
                  _onDragStart(details.localPosition.dx / width),
              onHorizontalDragUpdate: (details) =>
                  _scrubTo(details.localPosition.dx / width),
              onHorizontalDragEnd: (_) => _onDragEnd(),
              onHorizontalDragCancel: _onDragEnd,
              child: SizedBox(
                height: 36,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: buffered,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.bufferedColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: played,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.playedColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (_dragging)
                      Positioned(
                        left: bubbleLeft,
                        bottom: 26,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            formatVideoDuration(
                              Duration(
                                milliseconds:
                                    (_dragFraction *
                                            _controller
                                                .value
                                                .duration
                                                .inMilliseconds)
                                        .round(),
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: handleLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: handleSize,
                        height: handleSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.handleColor,
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
