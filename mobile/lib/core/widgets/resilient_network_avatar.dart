import 'dart:async';

import 'package:flutter/material.dart';

class ResilientNetworkAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackAsset;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const ResilientNetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackAsset = 'assets/images/user.png',
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
    return Image.network(
      url,
      key: ValueKey('$url:$_retryToken'),
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
        _handleImageError(url);
        return _fallbackImage();
      },
    );
  }

  Widget _fallbackImage() {
    return Image.asset(widget.fallbackAsset, fit: BoxFit.cover);
  }

  void _handleImageError(String url) {
    final provider = NetworkImage(url);
    provider.evict();

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
        provider.evict();
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
