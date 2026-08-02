import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_with_telegram.dart';
import '../../domain/usecases/check_cached_auth_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithTelegram loginWithTelegram;
  final CheckCachedAuth checkCachedAuth;
  final Logout logout;

  AuthBloc({
    required this.loginWithTelegram,
    required this.checkCachedAuth,
    required this.logout,
  }) : super(AuthInitial()) {

    on<CheckAuthStatus>((event, emit) async {
      print("CHECKING AUTH STATUS");
      final result = await checkCachedAuth();

      result.fold(
            (failure) {
          print("AUTH CHECK FAILED - Emitting Unauthenticated");
          emit(Unauthenticated());
        },
            (authEntity) {
          if (authEntity != null && authEntity.token.isNotEmpty) {
            print("CACHED AUTH FOUND");
            emit(Authenticated(authEntity: authEntity));
          } else {
            print("NO CACHED AUTH");
            emit(Unauthenticated());
          }
        },
      );
    });

    on<LoginWithTelegramRequested>((event, emit) async {
      emit(AuthLoading());
      print("BEFORE LOGIN LOADING");
      final result = await loginWithTelegram();
      print("AFTER LOGIN");
      result.fold(
            (failure) {
          print("LOGIN FAILED: ${failure.errMessage}");
          emit(AuthError(failure.errMessage));
        },
            (authEntity) {
          print("LOGIN SUCCESS");
          emit(AuthSuccess(
            message: 'تم تسجيل الدخول بنجاح',
            authEntity: authEntity,
          ));
        },
      );
    });

    on<LogoutRequested>((event, emit) async {
      print("LOGOUT REQUESTED");
      emit(AuthLoading());
      try {
        await logout();
        print("LOGOUT SUCCESS");
        emit(Unauthenticated());
      } catch (e) {
        print("LOGOUT FAILED: $e");
        emit(AuthError("Failed to logout"));
      }
    });
  }
}