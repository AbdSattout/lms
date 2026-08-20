import '../../../friends/domain/entities/friend_user_entity.dart';

enum ConversationType { direct, course }

class ConversationEntity {
  final int id;
  final ConversationType type;
  final int? courseId;
  final int? directUserOneId;
  final int? directUserTwoId;
  final FriendUserEntity? directUserOne;
  final FriendUserEntity? directUserTwo;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;

  const ConversationEntity({
    required this.id,
    required this.type,
    this.courseId,
    this.directUserOneId,
    this.directUserTwoId,
    this.directUserOne,
    this.directUserTwo,
    this.lastMessagePreview,
    this.lastMessageAt,
  });

  FriendUserEntity? otherUser(int currentUserId) {
    if (type != ConversationType.direct) return null;
    if (directUserOne?.id == currentUserId) return directUserTwo;
    return directUserOne;
  }

  int? otherUserId(int currentUserId) {
    if (type != ConversationType.direct) return null;
    if (directUserOneId == currentUserId) return directUserTwoId;
    return directUserOneId;
  }
}