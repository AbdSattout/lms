abstract class AddFriendEvent {}

class SearchUsersEvent extends AddFriendEvent {
  final String query;

  SearchUsersEvent(this.query);
}

class SendFriendRequestEvent extends AddFriendEvent {
  final int userId;

  SendFriendRequestEvent(this.userId);
}

class ClearAddFriendEvent extends AddFriendEvent {}
