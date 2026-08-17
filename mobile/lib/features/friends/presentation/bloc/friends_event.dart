import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';

abstract class FriendsEvent {}

class LoadFriendsEvent extends FriendsEvent {}

class RefreshFriendsEvent extends FriendsEvent {}

class AcceptFriendRequestEvent extends FriendsEvent {
  final FriendRequestEntity request;

  AcceptFriendRequestEvent(this.request);
}

class RejectFriendRequestEvent extends FriendsEvent {
  final FriendRequestEntity request;

  RejectFriendRequestEvent(this.request);
}

class CancelFriendRequestEvent extends FriendsEvent {
  final FriendRequestEntity request;

  CancelFriendRequestEvent(this.request);
}

class RemoveFriendEvent extends FriendsEvent {
  final FriendEntity friend;

  RemoveFriendEvent(this.friend);
}
