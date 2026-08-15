abstract class UserProfileEvent {}

class LoadUserProfileEvent extends UserProfileEvent {
  final int userId;

  LoadUserProfileEvent(this.userId);
}

class SendFriendRequestEvent extends UserProfileEvent {
  final int userId;

  SendFriendRequestEvent(this.userId);
}

class AcceptFriendRequestEvent extends UserProfileEvent {
  final int requestId;

  AcceptFriendRequestEvent(this.requestId);
}

class RejectFriendRequestEvent extends UserProfileEvent {
  final int requestId;

  RejectFriendRequestEvent(this.requestId);
}

class CancelFriendRequestEvent extends UserProfileEvent {
  final int requestId;

  CancelFriendRequestEvent(this.requestId);
}

class RemoveFriendEvent extends UserProfileEvent {
  final int friendId;

  RemoveFriendEvent(this.friendId);
}
