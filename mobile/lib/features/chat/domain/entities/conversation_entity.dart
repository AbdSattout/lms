enum ConversationType { direct, course }

class ConversationEntity {
  final int id;
  final ConversationType type;
  final int? courseId;
  final int? directUserOneId;
  final int? directUserTwoId;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.type,
    this.courseId,
    this.directUserOneId,
    this.directUserTwoId,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  int? otherUserId(int currentUserId) {
    if (type != ConversationType.direct) return null;
    if (directUserOneId == currentUserId) return directUserTwoId;
    return directUserOneId;
  }
}
