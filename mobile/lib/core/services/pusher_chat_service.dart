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

  PusherChatService({required this.api, required this.conversationId});

  Stream<PusherChatEvent> get events => _controller.stream;

  bool get isSubscribed => _subscribed;

  static String get _pusherKey => const String.fromEnvironment(
    'PUSHER_APP_KEY',
    defaultValue: 'ecf858df608de054470a',
  );

  static String get _pusherCluster =>
      const String.fromEnvironment('PUSHER_APP_CLUSTER', defaultValue: 'eu');

  Future<void> initialize() async {
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
        onAuthorizer: (channelName, socketId, options) async {
          debugPrint(
            '[pusher] authorizing channel=$channelName socketId=$socketId',
          );
          try {
            final result = await api.post(
              EndPoints.chatPusherAuth,
              queryParameters: {
                'socketId': socketId,
                'channelName': channelName,
              },
            );
            debugPrint('[pusher] auth response: $result');
            return result;
          } catch (e) {
            debugPrint('[pusher] auth failed: $e');
            return <String, dynamic>{};
          }
        },
      );
      debugPrint('[pusher] init done, connecting...');
      await pusher.connect();
      debugPrint('[pusher] connected');
    } catch (e) {
      debugPrint('[pusher] initialize error: $e');
      _pusher = null;
    }
  }

  Future<void> subscribe() async {
    final pusher = _pusher;
    if (pusher == null) {
      debugPrint('[pusher] subscribe skipped, not initialized');
      return;
    }

    debugPrint('[pusher] subscribing to private-conversation-$conversationId');
    try {
      await pusher.subscribe(
        channelName: 'private-conversation-$conversationId',
        onEvent: (event) {
          final raw = event.data;
          debugPrint(
            '[pusher] event received channel=private-conversation-$conversationId name=${event.eventName} data=$raw',
          );
          if (raw == null) return;
          final data = _decodeData(raw);
          if (data == null || _controller.isClosed) return;
          _controller.add(PusherChatEvent(event.eventName, data));
        },
      );
      _subscribed = true;
      debugPrint('[pusher] subscribed');
    } catch (e) {
      debugPrint('[pusher] subscribe error: $e');
    }
  }

  Map<String, dynamic>? _decodeData(dynamic raw) {
    try {
      return jsonDecode(raw.toString()) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  void unsubscribe() {
    _pusher?.unsubscribe(channelName: 'private-conversation-$conversationId');
    _subscribed = false;
  }

  void disconnect() {
    _pusher?.disconnect();
    _pusher = null;
  }

  Future<void> dispose() async {
    unsubscribe();
    disconnect();
    await _controller.close();
  }
}
