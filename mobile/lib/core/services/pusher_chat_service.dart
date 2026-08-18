import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../databases/api/api_consumer.dart';
import '../databases/api/end_points.dart';

class PusherChatEvent {
  final String eventName;
  final Map<String, dynamic> data;

  const PusherChatEvent(this.eventName, this.data);
}

class PusherChatService {
  final ApiConsumer api;
  final int conversationId;

  PusherChannelsFlutter? _pusher;
  final StreamController<PusherChatEvent> _controller =
      StreamController<PusherChatEvent>.broadcast();
  bool _subscribed = false;
  bool _initialized = false;

  PusherChatService({required this.api, required this.conversationId});

  Stream<PusherChatEvent> get events => _controller.stream;

  bool get isSubscribed => _subscribed;

  String get _channelName => 'private-conversation-$conversationId';

  static const String _fallbackPusherKey = 'ecf858df608de054470a';
  static const String _fallbackPusherCluster = 'mt1';

  static String get _pusherKey {
    const value = String.fromEnvironment('PUSHER_APP_KEY');
    final normalized = value.trim();
    return normalized.isEmpty ? _fallbackPusherKey : normalized;
  }

  static String get _pusherCluster {
    const value = String.fromEnvironment('PUSHER_APP_CLUSTER');
    final normalized = value.trim();
    return normalized.isEmpty ? _fallbackPusherCluster : normalized;
  }

  Future<void> initialize() async {
    if (_initialized && _pusher != null) return;

    debugPrint(
      '[pusher] initialize conversation=$conversationId key=${_pusherKey.isEmpty ? "(empty)" : _pusherKey} cluster=$_pusherCluster',
    );
    if (_pusherKey.isEmpty) {
      debugPrint('[pusher] PUSHER_APP_KEY is empty, skipping initialization');
      return;
    }
    try {
      final pusher = PusherChannelsFlutter.getInstance();
      _pusher = pusher;

      await pusher.init(
        apiKey: _pusherKey,
        cluster: _pusherCluster,
        onConnectionStateChange: (current, previous) {
          debugPrint('[pusher] connection state: $previous -> $current');
        },
        onError: (message, code, e) {
          debugPrint('[pusher] error: code=$code message=$message e=$e');
        },
        onSubscriptionError: (message, e) {
          debugPrint('[pusher] subscription error: $message e=$e');
          _subscribed = false;
        },
        onSubscriptionSucceeded: (channelName, data) {
          if (channelName == _channelName) {
            _subscribed = true;
            debugPrint('[pusher] subscription succeeded channel=$channelName');
          }
        },
        onEvent: _handleRawEvent,
        onAuthorizer: (channelName, socketId, options) async {
          return _authorize(channelName, socketId);
        },
      );
      _initialized = true;
      debugPrint('[pusher] init done');
    } catch (e) {
      debugPrint('[pusher] initialize error: $e');
      _pusher = null;
      _initialized = false;
    }
  }

  Future<void> subscribe() async {
    final pusher = _pusher;
    if (pusher == null) {
      debugPrint('[pusher] subscribe skipped, not initialized');
      return;
    }

    if (_subscribed) {
      debugPrint(
        '[pusher] subscribe skipped, already subscribed $_channelName',
      );
      return;
    }

    debugPrint('[pusher] subscribing to $_channelName');
    try {
      await pusher.subscribe(channelName: _channelName);
      _subscribed = true;

      if (pusher.connectionState != 'CONNECTED' &&
          pusher.connectionState != 'CONNECTING') {
        debugPrint('[pusher] connecting after subscribe');
        await pusher.connect();
      }

      debugPrint('[pusher] subscribe requested');
    } catch (e) {
      debugPrint('[pusher] subscribe error: $e');
      _subscribed = false;
    }
  }

  Future<Map<String, dynamic>> _authorize(
    String channelName,
    String socketId,
  ) async {
    debugPrint('[pusher] authorizing channel=$channelName socketId=$socketId');

    try {
      final result = await api.post(
        EndPoints.chatPusherAuth,
        queryParameters: {'socketId': socketId, 'channelName': channelName},
      );
      final auth = _normalizePusherAuthResponse(result);
      final authSignature = auth?['auth']?.toString().trim();
      if (auth == null || authSignature == null || authSignature.isEmpty) {
        throw const FormatException('Invalid Pusher auth response');
      }
      debugPrint('[pusher] auth response accepted channel=$channelName');
      return auth;
    } catch (e) {
      debugPrint('[pusher] auth failed: $e');
      return const <String, dynamic>{};
    }
  }

  void _handleRawEvent(PusherEvent event) {
    if (event.channelName != _channelName) return;
    if (event.eventName.startsWith('pusher:')) return;

    debugPrint(
      '[pusher] event received channel=${event.channelName} name=${event.eventName}',
    );

    final data = _decodePusherEventData(event.data);
    if (data == null || _controller.isClosed) return;
    _controller.add(PusherChatEvent(event.eventName, data));
  }

  Future<void> unsubscribe() async {
    if (_pusher == null || !_subscribed) return;
    await _pusher?.unsubscribe(channelName: _channelName);
    _subscribed = false;
  }

  Future<void> disconnect() async {
    await _pusher?.disconnect();
    _pusher = null;
    _initialized = false;
  }

  Future<void> dispose() async {
    await unsubscribe();
    await disconnect();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}

Map<String, dynamic>? _normalizePusherAuthResponse(Object? raw) {
  try {
    final decoded = _decodeJsonLike(raw);
    if (decoded is Map) return _stringKeyedMap(decoded);
    return null;
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _decodePusherEventData(Object? raw) {
  try {
    final decoded = _decodeJsonLike(raw);
    if (decoded is Map) return _stringKeyedMap(decoded);
    return null;
  } catch (_) {
    return null;
  }
}

Object? _decodeJsonLike(Object? raw) {
  if (raw is Map) return raw;
  if (raw is! String) return raw;

  final text = raw.trim();
  if (text.isEmpty) return null;

  final decoded = jsonDecode(text);
  if (decoded is String && decoded != raw) {
    return _decodeJsonLike(decoded);
  }
  return decoded;
}

Map<String, dynamic> _stringKeyedMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) => MapEntry(key.toString(), value));
}
