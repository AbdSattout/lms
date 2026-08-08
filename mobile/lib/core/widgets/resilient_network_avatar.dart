import 'dart:async';

import 'package:flutter/material.dart';

class ResilientNetworkAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackLabel;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const ResilientNetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackLabel,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  @override
  State<ResilientNetworkAvatar> createState() => _ResilientNetworkAvatarState();
}

class _ResilientNetworkAvatarState extends State<ResilientNetworkAvatar>
    with WidgetsBindingObserver {
  static const _retryDelay = Duration(seconds: 4);

  Timer? _retryTimer;
  int _retryToken = 0;
  bool _hasImageError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant ResilientNetworkAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizedUrl(oldWidget.imageUrl) != _normalizedUrl(widget.imageUrl)) {
      _retryTimer?.cancel();
      _hasImageError = false;
      _retryToken = 0;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasImageError) {
      _retryNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = _normalizedUrl(widget.imageUrl);
    final avatar = Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        border: widget.border,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null ? _fallbackImage() : _networkImage(url),
    );

    if (widget.onTap == null) return avatar;

    return GestureDetector(onTap: widget.onTap, child: avatar);
  }

  Widget _networkImage(String url) {
    final requestedUrl = _retryUrl(url);

    return Image.network(
      requestedUrl,
      key: ValueKey(requestedUrl),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          if (_hasImageError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _hasImageError = false);
              }
            });
          }

          return child;
        }

        return _fallbackImage();
      },
      errorBuilder: (context, error, stackTrace) {
        _handleImageError(url, requestedUrl);
        return _fallbackImage();
      },
    );
  }

  Widget _fallbackImage() {
    final colors = Theme.of(context).colorScheme;
    final initial = _fallbackInitial(widget.fallbackLabel);
    final foreground = colors.primary;
    final background =
        widget.backgroundColor ?? colors.primary.withValues(alpha: 0.10);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            background,
            foreground.withValues(alpha: 0.16),
          ],
        ),
      ),
      child: Center(
        child: initial == null
            ? Icon(
                Icons.person_rounded,
                color: foreground,
                size: widget.radius * 1.05,
              )
            : Text(
                initial,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontSize: widget.radius * 0.95,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
      ),
    );
  }

  void _handleImageError(String url, String requestedUrl) {
    NetworkImage(url).evict();
    NetworkImage(requestedUrl).evict();

    if (!_hasImageError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _hasImageError = true);
        }
      });
    }

    _retryTimer ??= Timer(_retryDelay, () {
      _retryTimer = null;
      if (mounted && _normalizedUrl(widget.imageUrl) == url) {
        NetworkImage(url).evict();
        setState(() => _retryToken++);
      }
    });
  }

  void _retryNow() {
    _retryTimer?.cancel();
    _retryTimer = null;

    final url = _normalizedUrl(widget.imageUrl);
    if (url != null) {
      NetworkImage(url).evict();
    }

    setState(() => _retryToken++);
  }

  String _retryUrl(String url) {
    if (_retryToken == 0 || _retryToken.isEven) return url;

    final uri = Uri.parse(url);
    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters['_lmsAvatarRetry'] = _retryToken.toString();

    return uri.replace(queryParameters: queryParameters).toString();
  }

  String? _fallbackInitial(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    return normalized.characters.first.toUpperCase();
  }

  String? _normalizedUrl(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }

    return uri.toString();
  }
}
