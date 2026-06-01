abstract class AuthEvent {}

class LoginWithTelegramRequested extends AuthEvent {}

class CheckCachedAuth extends AuthEvent {}
