import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class CreateDirectConversationUseCase {
  final ChatRepository repository;

  CreateDirectConversationUseCase(this.repository);

  Future<ConversationEntity> call(int targetUserId) {
    return repository.createDirectConversation(targetUserId);
  }
}
