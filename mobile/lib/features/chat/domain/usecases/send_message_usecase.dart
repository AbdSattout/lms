import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<MessageEntity> call({
    required int conversationId,
    required String content,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      content: content,
    );
  }
}
