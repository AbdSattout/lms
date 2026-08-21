import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lms/core/databases/api/end_points.dart';

class ResilientNetworkAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackLabel;
  final String fallbackAsset;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const ResilientNetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackLabel,
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

    final innerAvatar = Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null ? _fallbackImage() : _networkImage(url),
    );

    final avatar = widget.border == null
        ? innerAvatar
        : Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: widget.border,
      ),
      child: ClipOval(child: innerAvatar),
    );

    if (widget.onTap == null) return avatar;

    return GestureDetector(onTap: widget.onTap, child: avatar);
  }

  Widget _networkImage(String url) {
    final requestedUrl = _retryUrl(url);
    final headers = _imageHeaders(requestedUrl);

    return Image.network(
      requestedUrl,
      headers: headers,
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
    return Image.asset(
      widget.fallbackAsset,
      fit: BoxFit.cover,
      semanticLabel: widget.fallbackLabel,
    );
  }

  void _handleImageError(String url, String requestedUrl) {
    NetworkImage(url, headers: _imageHeaders(url)).evict();
    NetworkImage(requestedUrl, headers: _imageHeaders(requestedUrl)).evict();

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
        NetworkImage(url, headers: _imageHeaders(url)).evict();
        setState(() => _retryToken++);
      }
    });
  }

  void _retryNow() {
    _retryTimer?.cancel();
    _retryTimer = null;

    final url = _normalizedUrl(widget.imageUrl);
    if (url != null) {
      NetworkImage(url, headers: _imageHeaders(url)).evict();
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

  String? _normalizedUrl(String? value) {
    var normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized.toLowerCase() == 'null') return null;

    normalized = normalized.replaceAll(r'\/', '/');
    if (_isQuoted(normalized)) {
      normalized = normalized.substring(1, normalized.length - 1).trim();
    }

    if (normalized.startsWith('//')) {
      normalized = 'https:$normalized';
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) return null;

    if (uri.hasScheme) {
      if (uri.host.isEmpty || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return null;
      }

      return uri.toString();
    }

    final baseUri = Uri.tryParse(EndPoints.baseUrl);
    if (baseUri == null || baseUri.host.isEmpty) {
      return null;
    }

    return baseUri.resolveUri(uri).toString();
  }

  bool _isQuoted(String value) {
    return value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")));
  }

  Map<String, String>? _imageHeaders(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase();
    if (host == null) return null;

    final isTelegramImage =
        host == 't.me' ||
        host.endsWith('.t.me') ||
        host == 'telegram.org' ||
        host.endsWith('.telegram.org') ||
        host == 'telegram-cdn.org' ||
        host.endsWith('.telegram-cdn.org');

    if (!isTelegramImage) return null;

    return const {
      'Accept':
          'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36',
    };
  }
}
