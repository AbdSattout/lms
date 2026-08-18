import '../../domain/entities/message_entity.dart';

abstract class ChatMessagesState {
  const ChatMessagesState();
}

class ChatMessagesInitial extends ChatMessagesState {}

class ChatMessagesLoading extends ChatMessagesState {}

class ChatMessagesError extends ChatMessagesState {
  final String message;

  ChatMessagesError(this.message);
}

class ChatMessagesLoaded extends ChatMessagesState {
  final List<MessageEntity> messages;
  final Map<String, String> pendingMessages;
  final Map<String, String> failedMessages;
  final bool hasMore;
  final int pageNumber;
  final bool isLoadingMore;
  final String? actionMessage;
  final String? errorMessage;

  const ChatMessagesLoaded({
    required this.messages,
    required this.pendingMessages,
    required this.failedMessages,
    required this.hasMore,
    required this.pageNumber,
    required this.isLoadingMore,
    this.actionMessage,
    this.errorMessage,
  });

  ChatMessagesLoaded copyWith({
    List<MessageEntity>? messages,
    Map<String, String>? pendingMessages,
    Map<String, String>? failedMessages,
    bool? hasMore,
    int? pageNumber,
    bool? isLoadingMore,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      pendingMessages: pendingMessages ?? this.pendingMessages,
      failedMessages: failedMessages ?? this.failedMessages,
      hasMore: hasMore ?? this.hasMore,
      pageNumber: pageNumber ?? this.pageNumber,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
