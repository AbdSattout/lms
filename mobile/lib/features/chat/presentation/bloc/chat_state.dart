import '../../domain/entities/conversation_entity.dart';

abstract class ChatsState {
  const ChatsState();
}

class ChatsInitial extends ChatsState {}

class ChatsLoading extends ChatsState {}

class ChatsError extends ChatsState {
  final String message;

  ChatsError(this.message);
}

class ChatsLoaded extends ChatsState {
  final List<ConversationEntity> conversations;
  final bool hasMore;
  final int pageNumber;
  final bool isLoadingMore;
  final String? actionMessage;
  final String? errorMessage;

  const ChatsLoaded({
    required this.conversations,
    required this.hasMore,
    required this.pageNumber,
    required this.isLoadingMore,
    this.actionMessage,
    this.errorMessage,
  });

  ChatsLoaded copyWith({
    List<ConversationEntity>? conversations,
    bool? hasMore,
    int? pageNumber,
    bool? isLoadingMore,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatsLoaded(
      conversations: conversations ?? this.conversations,
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