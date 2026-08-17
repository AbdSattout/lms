import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/chat_updates_notifier.dart';
import '../../../../core/services/pusher_chat_service.dart';
import '../../../../core/utils/api_error_resolver.dart';
import '../../data/models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/mark_conversation_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_messages_event.dart';
import 'chat_messages_state.dart';

class ChatMessagesBloc extends Bloc<ChatMessagesEvent, ChatMessagesState> {
  final int conversationId;
  final int currentUserId;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkConversationAsReadUseCase markConversationAsReadUseCase;
  final ChatUpdatesNotifier chatUpdatesNotifier;
  final PusherChatService pusherService;

  StreamSubscription<PusherChatEvent>? _pusherSubscription;
  bool _opened = false;
  int _localCounter = 0;

  ChatMessagesBloc({
    required this.conversationId,
    required this.currentUserId,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markConversationAsReadUseCase,
    required this.chatUpdatesNotifier,
    required this.pusherService,
  }) : super(ChatMessagesInitial()) {
    on<OpenChatConversationEvent>(_open);
    on<LoadMoreMessagesEvent>(_loadMore);
    on<SendChatMessageEvent>(_send);
    on<RetryChatMessageEvent>(_retry);
    on<UpdateMessageEvent>(_updateMessage);
    on<DeleteMessageEvent>(_deleteMessage);
    on<MarkMessagesReadEvent>(_markRead);
  }

  @override
  Future<void> close() async {
    await _pusherSubscription?.cancel();
    await pusherService.dispose();
    return super.close();
  }

  Future<void> _open(
    OpenChatConversationEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    if (_opened) return;
    _opened = true;
    emit(ChatMessagesLoading());

    await pusherService.initialize();
    _pusherSubscription ??= pusherService.events.listen(_handlePusherEvent);
    await pusherService.subscribe();

    try {
      final page = await getMessagesUseCase(conversationId, page: 0);
      emit(
        ChatMessagesLoaded(
          messages: page.content,
          pendingMessages: const {},
          failedMessages: const {},
          hasMore: !page.last,
          pageNumber: 0,
          isLoadingMore: false,
        ),
      );
      if (page.content.isNotEmpty) {
        add(MarkMessagesReadEvent(page.content.first.id));
      }
    } catch (e) {
      _opened = false;
      emit(ChatMessagesError(resolveApiErrorMessage(e)));
    }
  }

  void _handlePusherEvent(PusherChatEvent event) {
    debugPrint(
      '[chat] pusher event name=${event.eventName} data=${event.data}',
    );
    switch (event.eventName) {
      case 'message.created':
      case 'message.updated':
        add(UpdateMessageEvent(MessageModel.fromJson(event.data)));
        break;
      case 'message.deleted':
        final messageId = (event.data['messageId'] as num?)?.toInt() ?? 0;
        if (messageId > 0) add(DeleteMessageEvent(messageId));
        break;
    }
  }

  Future<void> _loadMore(
    LoadMoreMessagesEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final current = state;
    if (current is! ChatMessagesLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await getMessagesUseCase(
        conversationId,
        page: current.pageNumber + 1,
      );
      emit(
        current.copyWith(
          messages: [...current.messages, ...page.content],
          hasMore: !page.last,
          pageNumber: current.pageNumber + 1,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoadingMore: false,
          errorMessage: resolveApiErrorMessage(e),
          clearActionMessage: true,
        ),
      );
    }
  }

  Future<void> _send(
    SendChatMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    final current = state;
    if (current is! ChatMessagesLoaded) return;

    final localId =
        'local_${DateTime.now().millisecondsSinceEpoch}_${_localCounter++}';
    emit(
      current.copyWith(
        pendingMessages: {...current.pendingMessages, localId: text},
        clearErrorMessage: true,
        clearActionMessage: true,
      ),
    );

    try {
      final message = await sendMessageUseCase(
        conversationId: conversationId,
        content: text,
      );
      _replacePendingMessage(localId, message, emit);
    } catch (e) {
      final newCurrent = state;
      if (newCurrent is! ChatMessagesLoaded) return;
      final pending = Map<String, String>.from(newCurrent.pendingMessages);
      pending.remove(localId);
      emit(
        newCurrent.copyWith(
          pendingMessages: pending,
          failedMessages: {...newCurrent.failedMessages, localId: text},
          errorMessage: resolveApiErrorMessage(e),
          clearActionMessage: true,
        ),
      );
    }
  }

  void _replacePendingMessage(
    String localId,
    MessageEntity message,
    Emitter<ChatMessagesState> emit,
  ) {
    final current = state;
    if (current is! ChatMessagesLoaded) return;

    final pending = Map<String, String>.from(current.pendingMessages);
    pending.remove(localId);

    final existingIndex = current.messages.indexWhere(
      (m) => m.id == message.id,
    );
    final messages = existingIndex >= 0
        ? [
            ...current.messages.sublist(0, existingIndex),
            message,
            ...current.messages.sublist(existingIndex + 1),
          ]
        : [message, ...current.messages];

    emit(
      current.copyWith(
        messages: messages,
        pendingMessages: pending,
        clearErrorMessage: true,
      ),
    );
    chatUpdatesNotifier.notify();
  }

  Future<void> _retry(
    RetryChatMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final current = state;
    if (current is! ChatMessagesLoaded) return;
    final text = current.failedMessages[event.localId];
    if (text == null) return;

    final failed = Map<String, String>.from(current.failedMessages);
    failed.remove(event.localId);
    emit(current.copyWith(failedMessages: failed, clearErrorMessage: true));

    await _send(SendChatMessageEvent(text), emit);
  }

  Future<void> _updateMessage(
    UpdateMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final current = state;
    if (current is! ChatMessagesLoaded) return;

    final message = event.message;
    final existingIndex = current.messages.indexWhere(
      (m) => m.id == message.id,
    );
    if (existingIndex >= 0) {
      final messages = [...current.messages];
      messages[existingIndex] = message;
      emit(current.copyWith(messages: messages, clearErrorMessage: true));
      chatUpdatesNotifier.notify();
      _markIncomingMessageRead(message);
      return;
    }

    emit(
      current.copyWith(
        messages: [message, ...current.messages],
        clearErrorMessage: true,
      ),
    );
    chatUpdatesNotifier.notify();
    _markIncomingMessageRead(message);
  }

  Future<void> _deleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    final current = state;
    if (current is! ChatMessagesLoaded) return;

    final index = current.messages.indexWhere((m) => m.id == event.messageId);
    if (index < 0) return;

    final messages = [...current.messages];
    messages[index] = messages[index].copyWith(
      deletedAt: DateTime.now(),
      content: null,
    );
    emit(current.copyWith(messages: messages));
    chatUpdatesNotifier.notify();
  }

  void _markIncomingMessageRead(MessageEntity message) {
    if (currentUserId <= 0 || message.senderId == currentUserId) return;
    add(MarkMessagesReadEvent(message.id));
  }

  Future<void> _markRead(
    MarkMessagesReadEvent event,
    Emitter<ChatMessagesState> emit,
  ) async {
    try {
      await markConversationAsReadUseCase(
        conversationId: conversationId,
        lastReadMessageId: event.lastReadMessageId,
      );
    } catch (e) {
      // Read receipts are best-effort; failures are intentionally ignored.
    }
  }
}
