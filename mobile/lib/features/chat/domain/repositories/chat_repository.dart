import '../../../../core/models/page_response.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<PageResponse<ConversationEntity>> getConversations({
    int page,
    int size,
  });

  Future<PageResponse<MessageEntity>> getMessages(
    int conversationId, {
    int page,
    int size,
  });

  Future<MessageEntity> sendMessage({
    required int conversationId,
    required String content,
  });

  Future<ConversationEntity> createDirectConversation(int targetUserId);

  Future<void> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  });
}
