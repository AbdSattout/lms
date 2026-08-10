import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ForegroundNotificationService {
  static const MethodChannel _channel = MethodChannel(
    'app.lms/foreground_notifications',
  );

  Future<void> show(RemoteMessage message) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final title = _readTitle(message);
    final body = _readBody(message);
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    try {
      await _channel.invokeMethod<bool>('showNotification', {
        'title': title,
        'body': body,
        'notificationId': _readNotificationId(message),
      });
    } on MissingPluginException {
      // Non-Android platforms use Firebase's native foreground presentation.
    } catch (e) {
      debugPrint('Failed to show foreground notification. $e');
    }
  }

  String? _readTitle(RemoteMessage message) {
    return _firstNotBlank([
      message.notification?.title,
      message.data['title']?.toString(),
      message.data['notificationTitle']?.toString(),
    ]);
  }

  String? _readBody(RemoteMessage message) {
    return _firstNotBlank([
      message.notification?.body,
      message.data['body']?.toString(),
      message.data['message']?.toString(),
      message.data['notificationBody']?.toString(),
    ]);
  }

  int? _readNotificationId(RemoteMessage message) {
    return int.tryParse(
      _firstNotBlank([
            message.data['notificationId']?.toString(),
            message.data['id']?.toString(),
            message.messageId,
          ]) ??
          '',
    );
  }

  String? _firstNotBlank(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }

    return null;
  }
}
