import '../../domain/entities/profile_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final String? accountEmail;
  final String? pendingAccountEmail;
  final bool isRequestingAccountEmailOtp;
  final bool isVerifyingAccountEmailOtp;
  final String? accountEmailMessage;
  final String? accountEmailError;

  ProfileLoaded(
    this.profile, {
    this.accountEmail,
    this.pendingAccountEmail,
    this.isRequestingAccountEmailOtp = false,
    this.isVerifyingAccountEmailOtp = false,
    this.accountEmailMessage,
    this.accountEmailError,
  });
}

class ProfileUpdated extends ProfileState {}

class ProfilePictureUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
