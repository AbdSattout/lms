import '../repositories/chat_repository.dart';

class MarkConversationAsReadUseCase {
  final ChatRepository repository;

  MarkConversationAsReadUseCase(this.repository);

  Future<void> call({
    required int conversationId,
    required int lastReadMessageId,
  }) {
    return repository.markAsRead(
      conversationId: conversationId,
      lastReadMessageId: lastReadMessageId,
    );
  }
}
