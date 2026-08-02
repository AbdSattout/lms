import 'package:lms/features/auth/domain/entities/auth_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

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