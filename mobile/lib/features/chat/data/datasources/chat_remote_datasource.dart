import '../../../../core/databases/api/api_consumer.dart';
import '../../../../core/databases/api/end_points.dart';
import '../../../../core/models/page_response.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<PageResponse<ConversationModel>> getConversations({
    int page,
    int size,
  });

  Future<PageResponse<MessageModel>> getMessages(
    int conversationId, {
    int page,
    int size,
  });

  Future<MessageModel> sendMessage({
    required int conversationId,
    required String content,
  });

  Future<ConversationModel> createDirectConversation(int targetUserId);

  Future<ConversationModel> getCourseConversation(int courseId);

  Future<void> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiConsumer api;

  ChatRemoteDataSourceImpl(this.api);

  @override
  Future<PageResponse<ConversationModel>> getConversations({
    int page = 0,
    int size = 20,
  }) async {
    final response = await api.get(
      EndPoints.chatConversations,
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse<ConversationModel>.fromJson(
      response as Map<String, dynamic>,
      ConversationModel.fromJson,
    );
  }

  @override
  Future<PageResponse<MessageModel>> getMessages(
    int conversationId, {
    int page = 0,
    int size = 30,
  }) async {
    final response = await api.get(
      EndPoints.chatConversationMessages(conversationId),
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse<MessageModel>.fromJson(
      response as Map<String, dynamic>,
      MessageModel.fromJson,
    );
  }

  @override
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final response = await api.post(
      EndPoints.chatConversationMessages(conversationId),
      data: {'content': content},
    );
    return MessageModel.fromJson(response);
  }

  @override
  Future<ConversationModel> createDirectConversation(int targetUserId) async {
    final response = await api.post(
      EndPoints.chatCreateDirectConversation(targetUserId),
    );
    return ConversationModel.fromJson(response);
  }

  @override
  Future<ConversationModel> getCourseConversation(int courseId) async {
    final response = await api.get(EndPoints.chatCourseConversation(courseId));
    return ConversationModel.fromJson(response);
  }

  @override
  Future<void> markAsRead({
    required int conversationId,
    required int lastReadMessageId,
  }) {
    return api.post(
      EndPoints.chatMarkMessageRead(conversationId, lastReadMessageId),
    );
  }
}
