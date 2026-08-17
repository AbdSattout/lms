import '../../domain/entities/user_profile_entity.dart';

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfileEntity profile;
  final int? processingId;
  final String? actionMessage;
  final String? errorMessage;

  UserProfileLoaded({
    required this.profile,
    this.processingId,
    this.actionMessage,
    this.errorMessage,
  });

  UserProfileLoaded copyWith({
    UserProfileEntity? profile,
    int? processingId,
    bool clearProcessingId = false,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return UserProfileLoaded(
      profile: profile ?? this.profile,
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

class UserProfileError extends UserProfileState {
  final String message;

  UserProfileError(this.message);
}
