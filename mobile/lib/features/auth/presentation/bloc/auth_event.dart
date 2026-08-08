abstract class AuthEvent {}

class LoginWithTelegramRequested extends AuthEvent {}

class RequestEmailOtpRequested extends AuthEvent {
  final String email;

  RequestEmailOtpRequested(this.email);
}

class VerifyEmailOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  VerifyEmailOtpRequested({required this.email, required this.otp});
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
