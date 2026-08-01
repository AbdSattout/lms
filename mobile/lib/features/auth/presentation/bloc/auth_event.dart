abstract class AuthEvent {}

class LoginWithTelegramRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}