import '../../../../core/models/page_response.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Future<PageResponse<ConversationEntity>> getConversations({
    int page = 0,
    int size = 20,
  }) {
    return remote.getConversations(page: page, size: size);
  }

  @override
  Future<PageResponse<MessageEntity>> getMessages(
    int conversationId, {
    int page = 0,
    int size = 30,
  }) {
    return remote.getMessages(conversationId, page: page, size: size);
  }

  @override
  Future<MessageEntity> sendMessage({
    required int conversationId,
    required String content,
  }) {
    return remote.sendMessage(conversationId: conversationId, content: content);
  }

  @override
  Future<ConversationEntity> createDirectConversation(int targetUserId) {
    return remote.createDirectConversation(targetUserId);
  }

  @override
  Future<void> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  }) {
    return remote.markAsRead(
      conversationId: conversationId,
      lastReadMessageId: lastReadMessageId,
    );
  }
}
