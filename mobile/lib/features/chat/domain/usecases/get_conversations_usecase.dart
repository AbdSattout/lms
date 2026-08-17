import '../../../../core/models/page_response.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Future<PageResponse<ConversationEntity>> call({int page = 0, int size = 20}) {
    return repository.getConversations(page: page, size: size);
  }
}
