import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';

abstract class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;
  final List<FriendRequestEntity> receivedRequests;
  final List<FriendRequestEntity> sentRequests;
  final int? processingId;
  final String? actionMessage;
  final String? errorMessage;

  FriendsLoaded({
    required this.friends,
    required this.receivedRequests,
    required this.sentRequests,
    this.processingId,
    this.actionMessage,
    this.errorMessage,
  });

  FriendsLoaded copyWith({
    List<FriendEntity>? friends,
    List<FriendRequestEntity>? receivedRequests,
    List<FriendRequestEntity>? sentRequests,
    int? processingId,
    bool clearProcessingId = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      processingId: clearProcessingId
          ? null
          : processingId ?? this.processingId,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError(this.message);
}
