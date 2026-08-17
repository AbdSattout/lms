import '../../../../core/models/page_response.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<PageResponse<MessageEntity>> call(
    int conversationId, {
    int page = 0,
    int size = 30,
  }) {
    return repository.getMessages(conversationId, page: page, size: size);
  }
}
