import 'friend_user_entity.dart';

class FriendEntity {
  final int id;
  final FriendUserEntity user;
  final DateTime? createdAt;

  const FriendEntity({required this.id, required this.user, this.createdAt});
}
