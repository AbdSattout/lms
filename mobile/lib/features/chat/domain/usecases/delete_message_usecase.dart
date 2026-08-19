import '../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<void> call({
    required int conversationId,
    required int messageId,
  }) {
    return repository.deleteMessage(
      conversationId: conversationId,
      messageId: messageId,
    );
  }
}