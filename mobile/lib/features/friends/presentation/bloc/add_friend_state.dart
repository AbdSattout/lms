import '../../domain/entities/search_user_entity.dart';

abstract class AddFriendState {}

class AddFriendInitial extends AddFriendState {}

class AddFriendLoading extends AddFriendState {}

class AddFriendLoaded extends AddFriendState {
  final List<SearchUserEntity> results;
  final Set<int> sentRequestIds;
  final int? processingUserId;
  final String? actionMessage;
  final String? errorMessage;

  AddFriendLoaded({
    required this.results,
    required this.sentRequestIds,
    this.processingUserId,
    this.actionMessage,
    this.errorMessage,
  });

  AddFriendLoaded copyWith({
    List<SearchUserEntity>? results,
    Set<int>? sentRequestIds,
    int? processingUserId,
    bool clearProcessingUserId = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AddFriendLoaded(
      results: results ?? this.results,
      sentRequestIds: sentRequestIds ?? this.sentRequestIds,
      processingUserId: clearProcessingUserId
          ? null
          : processingUserId ?? this.processingUserId,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class AddFriendError extends AddFriendState {
  final String message;

  AddFriendError(this.message);
}
