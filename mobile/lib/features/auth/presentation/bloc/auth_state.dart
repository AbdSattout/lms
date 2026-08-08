import 'package:lms/features/auth/domain/entities/auth_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class GoogleAuthLoading extends AuthState {}

class EmailOtpRequestLoading extends AuthState {}

class EmailOtpVerifyLoading extends AuthState {}

class EmailOtpRequestSuccess extends AuthState {
  final String email;
  final String message;

  EmailOtpRequestSuccess({required this.email, required this.message});
}

class AuthSuccess extends AuthState {
  final String message;
  final AuthEntity authEntity;

  AuthSuccess({required this.message, required this.authEntity});
}

class Authenticated extends AuthState {
  final AuthEntity authEntity;

  Authenticated({required this.authEntity});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
