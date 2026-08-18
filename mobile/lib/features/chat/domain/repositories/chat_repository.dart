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

  Future<MessageEntity> editMessage({
    required int conversationId,
    required int messageId,
    required String content,
  });

  Future<void> deleteMessage({
    required int conversationId,
    required int messageId,
  });

  Future<ConversationEntity> createDirectConversation(int targetUserId);

  Future<ConversationEntity> getCourseConversation(int courseId);

  Future<void> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  });
}
