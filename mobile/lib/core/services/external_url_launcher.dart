import 'dart:async';

import 'package:flutter/services.dart';

class ExternalUrlLauncher {
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

  static String? inviteTokenFromUri(Uri uri) {
    if (uri.scheme != 'lms' || uri.host != 'invite') return null;

    final pathToken = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    final queryToken = uri.queryParameters['token'];
    final token = (pathToken?.trim().isNotEmpty ?? false)
        ? pathToken?.trim()
        : queryToken?.trim();

    return token == null || token.isEmpty ? null : token;
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
