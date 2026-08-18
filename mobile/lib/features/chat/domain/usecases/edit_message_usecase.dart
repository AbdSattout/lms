import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class EditMessageUseCase {
  final ChatRepository repository;

  EditMessageUseCase(this.repository);

  Future<MessageEntity> call({
    required int conversationId,
    required int messageId,
    required String content,
  }) {
    return repository.editMessage(
      conversationId: conversationId,
      messageId: messageId,
      content: content,
    );
  }
}