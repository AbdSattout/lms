enum ChatMessageType { text, image, file }

class MessageEntity {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderPicture;
  final String? content;
  final ChatMessageType type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderPicture,
    this.content,
    this.type = ChatMessageType.text,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  bool isMine(int currentUserId) => senderId == currentUserId;

  MessageEntity copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? senderName,
    String? senderPicture,
    String? content,
    ChatMessageType? type,
    DateTime? createdAt,
    DateTime? editedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPicture: senderPicture ?? this.senderPicture,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}
