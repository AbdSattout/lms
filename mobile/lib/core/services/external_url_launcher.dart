import 'dart:async';

import 'package:flutter/services.dart';

class ExternalUrlLauncher {
  static const String publicInviteBaseUrl =
      'https://lmscenter.vercel.app/invite';
  static const MethodChannel _channel = MethodChannel('app.lms/external_url');
  final StreamController<Uri> _billingDeepLinks =
      StreamController<Uri>.broadcast();
  final StreamController<Uri> _inviteDeepLinks =
      StreamController<Uri>.broadcast();

  ExternalUrlLauncher() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Stream<Uri> get billingDeepLinks => _billingDeepLinks.stream;
  Stream<Uri> get inviteDeepLinks => _inviteDeepLinks.stream;

  static Uri inviteUriForToken(String token) {
    return Uri(scheme: 'lms', host: 'invite', pathSegments: [token.trim()]);
  }

  static String publicInviteUrlForToken(String token) {
    return '$publicInviteBaseUrl/${Uri.encodeComponent(token.trim())}';
  }

  static String? publicInviteUrlFromInput(String input) {
    final token = inviteTokenFromInput(input);
    return token == null ? null : publicInviteUrlForToken(token);
  }

  static Uri? inviteUriFromInput(String input) {
    final token = inviteTokenFromInput(input);
    return token == null ? null : inviteUriForToken(token);
  }

  static String? inviteTokenFromInput(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final parsedUri = Uri.tryParse(trimmed);
    if (parsedUri != null) {
      final parsedToken = inviteTokenFromUri(parsedUri);
      if (parsedToken != null) return parsedToken;
      if (parsedUri.hasScheme) return null;
    }

    final normalizedUri = _parseInviteUrlWithoutScheme(trimmed);
    if (normalizedUri != null) {
      final normalizedToken = inviteTokenFromUri(normalizedUri);
      if (normalizedToken != null) return normalizedToken;
    }

    final pathToken = _inviteTokenFromPathLikeInput(trimmed);
    if (pathToken != null) return pathToken;
    if (_looksLikeNonTokenReference(trimmed)) return null;

    return _cleanInviteToken(trimmed);
  }

  static String? inviteTokenFromUri(Uri uri) {
    if (uri.scheme == 'lms' && uri.host == 'invite') {
      return _inviteTokenFromPathOrQuery(uri);
    }

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    final host = uri.host.toLowerCase();
    final isInviteHost =
        host == 'lmscenter.vercel.app' || host == 'www.lmscenter.vercel.app';
    if (!isHttp || !isInviteHost) return null;

    return _inviteTokenFromPathOrQuery(uri);
  }

  static Uri? _parseInviteUrlWithoutScheme(String input) {
    final lower = input.toLowerCase();
    if (lower.startsWith('lmscenter.vercel.app/') ||
        lower.startsWith('www.lmscenter.vercel.app/')) {
      return Uri.tryParse('https://$input');
    }

    if (lower.startsWith('/invite/') || lower.startsWith('/mobile/invite/')) {
      return Uri.tryParse('https://lmscenter.vercel.app$input');
    }

    return null;
  }

  static String? _inviteTokenFromPathOrQuery(Uri uri) {
    final pathToken = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    final queryToken = uri.queryParameters['token'];
    final segments = uri.pathSegments
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (uri.scheme == 'lms' && uri.host == 'invite') {
      return _cleanInviteToken(pathToken) ?? _cleanInviteToken(queryToken);
    }

    if (segments.length >= 2 && segments[0].toLowerCase() == 'invite') {
      return _cleanInviteToken(segments[1]);
    }

    if (segments.length >= 3 &&
        segments[0].toLowerCase() == 'mobile' &&
        segments[1].toLowerCase() == 'invite') {
      return _cleanInviteToken(segments[2]);
    }

    return _cleanInviteToken(queryToken);
  }

  static String? _inviteTokenFromPathLikeInput(String input) {
    final segments = input
        .split('/')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (segments.length >= 2 && segments[0].toLowerCase() == 'invite') {
      return _cleanInviteToken(segments[1]);
    }

    if (segments.length >= 3 &&
        segments[0].toLowerCase() == 'mobile' &&
        segments[1].toLowerCase() == 'invite') {
      return _cleanInviteToken(segments[2]);
    }

    return null;
  }

  static bool _looksLikeNonTokenReference(String input) {
    final lower = input.toLowerCase();
    return lower == 'lmscenter.vercel.app' ||
        lower == 'www.lmscenter.vercel.app' ||
        lower.contains('://') ||
        lower.contains('/') ||
        lower.contains(r'\') ||
        lower.contains('?') ||
        lower.contains('#');
  }

  static String? _cleanInviteToken(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    var token = trimmed;

    while (token.startsWith('"') || token.startsWith("'")) {
      token = token.substring(1).trimLeft();
    }

    while (token.endsWith('"') || token.endsWith("'")) {
      token = token.substring(0, token.length - 1).trimRight();
    }

    if (token.isEmpty || token.contains(RegExp(r'\s'))) return null;

    return token;
  }

  Future<void> open(String url) async {
    final uri = Uri.tryParse(url.trim());
    final isHttpUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (!isHttpUrl) {
      throw PlatformException(
        code: 'invalid_url',
        message: 'رابط الدفع غير صالح',
      );
    }

    final opened = await _channel.invokeMethod<bool>('openUrl', {
      'url': uri.toString(),
    });

    if (opened != true) {
      throw PlatformException(
        code: 'open_url_failed',
        message: 'تعذر فتح صفحة الدفع',
      );
    }
  }

  Future<Uri?> takeInitialBillingDeepLink() async {
    final url = await _channel.invokeMethod<String>(
      'takeInitialBillingDeepLink',
    );

    return _parseBillingDeepLink(url);
  }

  Future<void> clearInitialBillingDeepLink() async {
    await _channel.invokeMethod<void>('clearInitialBillingDeepLink');
  }

  Future<Uri?> takeInitialInviteDeepLink() async {
    final url = await _channel.invokeMethod<String>(
      'takeInitialInviteDeepLink',
    );

    return _parseInviteDeepLink(url);
  }

  Future<void> clearInitialInviteDeepLink() async {
    await _channel.invokeMethod<void>('clearInitialInviteDeepLink');
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final args = call.arguments;
    final url = args is Map ? args['url']?.toString() : null;

    if (call.method == 'billingDeepLink') {
      final uri = _parseBillingDeepLink(url);

      if (uri != null && !_billingDeepLinks.isClosed) {
        _billingDeepLinks.add(uri);
      }
      return;
    }

    if (call.method == 'inviteDeepLink') {
      final uri = _parseInviteDeepLink(url);

      if (uri != null && !_inviteDeepLinks.isClosed) {
        _inviteDeepLinks.add(uri);
      }
    }
  }

  Uri? _parseBillingDeepLink(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || uri.scheme != 'lms' || uri.host != 'billing') {
      return null;
    }

    return uri;
  }

  Uri? _parseInviteDeepLink(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || inviteTokenFromUri(uri) == null) return null;

    return uri;
  }
}
