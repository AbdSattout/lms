import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_cached_auth_usecase.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/login_with_telegram.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/request_email_otp.dart';
import '../../domain/usecases/verify_email_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithTelegram loginWithTelegram;
  final LoginWithGoogle loginWithGoogle;
  final RequestEmailOtp requestEmailOtp;
  final VerifyEmailOtp verifyEmailOtp;
  final CheckCachedAuth checkCachedAuth;
  final Logout logout;

  AuthBloc({
    required this.loginWithTelegram,
    required this.loginWithGoogle,
    required this.requestEmailOtp,
    required this.verifyEmailOtp,
    required this.checkCachedAuth,
    required this.logout,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_checkAuthStatus);
    on<LoginWithTelegramRequested>(_loginWithTelegram);
    on<LoginWithGoogleRequested>(_loginWithGoogle);
    on<RequestEmailOtpRequested>(_requestEmailOtp);
    on<VerifyEmailOtpRequested>(_verifyEmailOtp);
    on<LogoutRequested>(_logout);
  }

  Future<void> _checkAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkCachedAuth();

    result.fold((_) => emit(Unauthenticated()), (authEntity) {
      if (authEntity != null && authEntity.token.isNotEmpty) {
        emit(Authenticated(authEntity: authEntity));
        return;
      }

      emit(Unauthenticated());
    });
  }

  Future<void> _loginWithTelegram(
    LoginWithTelegramRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithTelegram();

    result.fold(
      (failure) => emit(AuthError(failure.errMessage)),
      (authEntity) => emit(
        AuthSuccess(message: 'تم تسجيل الدخول بنجاح', authEntity: authEntity),
      ),
    );
  }

  Future<void> _loginWithGoogle(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(GoogleAuthLoading());
    final result = await loginWithGoogle();

    result.fold(
      (failure) => emit(AuthError(failure.errMessage)),
      (authEntity) => emit(
        AuthSuccess(
          message: 'Google sign-in successful',
          authEntity: authEntity,
        ),
      ),
    );
  }

  Future<void> _requestEmailOtp(
    RequestEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(EmailOtpRequestLoading());
    final result = await requestEmailOtp(event.email);

    result.fold(
      (failure) => emit(AuthError(failure.errMessage)),
      (_) => emit(
        EmailOtpRequestSuccess(
          email: event.email,
          message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
        ),
      ),
    );
  }

  Future<void> _verifyEmailOtp(
    VerifyEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(EmailOtpVerifyLoading());
    final result = await verifyEmailOtp(email: event.email, otp: event.otp);

    result.fold(
      (failure) => emit(AuthError(failure.errMessage)),
      (authEntity) => emit(
        AuthSuccess(message: 'تم تسجيل الدخول بنجاح', authEntity: authEntity),
      ),
    );
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await logout();
      emit(Unauthenticated());
    } catch (_) {
      emit(AuthError('Failed to logout'));
    }
  }
}
