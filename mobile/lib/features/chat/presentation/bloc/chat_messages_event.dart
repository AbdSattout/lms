import '../../domain/entities/message_entity.dart';

abstract class ChatMessagesEvent {}

class OpenChatConversationEvent extends ChatMessagesEvent {}

class LoadMoreMessagesEvent extends ChatMessagesEvent {}

class SendChatMessageEvent extends ChatMessagesEvent {
  final String text;

  SendChatMessageEvent(this.text);
}

class RetryChatMessageEvent extends ChatMessagesEvent {
  final String localId;

  RetryChatMessageEvent(this.localId);
}

class UpdateMessageEvent extends ChatMessagesEvent {
  final MessageEntity message;

  UpdateMessageEvent(this.message);
}

class DeleteMessageEvent extends ChatMessagesEvent {
  final int messageId;

  DeleteMessageEvent(this.messageId);
}

class MarkMessagesReadEvent extends ChatMessagesEvent {
  final int lastReadMessageId;

  MarkMessagesReadEvent(this.lastReadMessageId);
}

class MemberMutedEvent extends ChatMessagesEvent {
  final int userId;
  final DateTime? mutedUntil;
  final String? reason;

  MemberMutedEvent(this.userId, this.mutedUntil, this.reason);
}

class MemberUnmutedEvent extends ChatMessagesEvent {
  final int userId;

  MemberUnmutedEvent(this.userId);
}
