import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../../features/notifications/domain/usecases/register_notification_device_usecase.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseMessagingService.ensureFirebaseInitialized();
}

class FirebaseMessagingService {
  final RegisterNotificationDeviceUseCase registerDevice;

  final _messageController = StreamController<RemoteMessage>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _openedMessageSubscription;
  bool _initialized = false;

  FirebaseMessagingService({required this.registerDevice});

  Stream<RemoteMessage> get messages => _messageController.stream;

  static Future<bool> ensureFirebaseInitialized() async {
    if (Firebase.apps.isNotEmpty) return true;

    try {
      final FirebaseOptions? options = DefaultFirebaseOptions.currentPlatform;
      await Firebase.initializeApp(options: options);
      return true;
    } catch (e) {
      debugPrint(
        'Firebase is not configured yet. Run flutterfire configure or pass '
        'FIREBASE_* dart-defines to enable push notifications. $e',
      );
      return false;
    }
  }

  static Future<void> configureBackgroundHandling() async {
    final initialized = await ensureFirebaseInitialized();
    if (!initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final initialized = await ensureFirebaseInitialized();
    if (!initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      await _registerCurrentToken(messaging);

      _tokenRefreshSubscription ??= messaging.onTokenRefresh.listen(
        _registerTokenSafely,
      );

      _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
        _messageController.add,
      );

      _openedMessageSubscription ??= FirebaseMessaging.onMessageOpenedApp
          .listen(_messageController.add);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _messageController.add(initialMessage);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize Firebase Messaging. $e');
    }
  }

  Future<void> _registerCurrentToken(FirebaseMessaging messaging) async {
    final token = await messaging.getToken();
    if (token == null || token.isEmpty) return;

    await _registerTokenSafely(token);
  }

  Future<void> _registerTokenSafely(String token) async {
    try {
      await registerDevice(token);
    } catch (e) {
      debugPrint('Failed to register notification device token. $e');
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessageSubscription?.cancel();
    await _openedMessageSubscription?.cancel();
    await _messageController.close();
  }
}
