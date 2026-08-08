import 'dart:async';

import 'package:flutter/services.dart';

class ExternalUrlLauncher {
  static const MethodChannel _channel = MethodChannel('app.lms/external_url');
  final StreamController<Uri> _billingDeepLinks =
      StreamController<Uri>.broadcast();

  ExternalUrlLauncher() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Stream<Uri> get billingDeepLinks => _billingDeepLinks.stream;

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

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'billingDeepLink') return;

    final args = call.arguments;
    final url = args is Map ? args['url']?.toString() : null;
    final uri = _parseBillingDeepLink(url);

    if (uri != null && !_billingDeepLinks.isClosed) {
      _billingDeepLinks.add(uri);
    }
  }

  Uri? _parseBillingDeepLink(String? url) {
    final uri = url == null ? null : Uri.tryParse(url);
    if (uri == null || uri.scheme != 'lms' || uri.host != 'billing') {
      return null;
    }

    return uri;
  }
}
