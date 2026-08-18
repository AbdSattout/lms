import '../../../friends/domain/entities/friend_user_entity.dart';

abstract class NewChatState {
  const NewChatState();
}

class NewChatInitial extends NewChatState {}

class NewChatLoading extends NewChatState {}

class NewChatError extends NewChatState {
  final String message;

  NewChatError(this.message);
}

class NewChatLoaded extends NewChatState {
  final List<FriendUserEntity> friends;

  const NewChatLoaded(this.friends);
}
