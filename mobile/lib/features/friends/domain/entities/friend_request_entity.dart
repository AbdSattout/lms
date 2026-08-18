import 'friend_user_entity.dart';

class FriendRequestEntity {
  final int id;
  final FriendUserEntity sender;
  final FriendUserEntity receiver;
  final String status;
  final DateTime? createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.status,
    this.createdAt,
  });
}
