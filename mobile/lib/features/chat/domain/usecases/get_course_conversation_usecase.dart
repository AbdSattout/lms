import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetCourseConversationUseCase {
  final ChatRepository repository;

  GetCourseConversationUseCase(this.repository);

  Future<ConversationEntity> call(int courseId) {
    return repository.getCourseConversation(courseId);
  }
}
