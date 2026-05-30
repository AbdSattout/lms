import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/services/injection_container.dart';
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';

import '../../domain/usecases/login_with_telegram.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithTelegram loginWithTelegram;

  AuthBloc(this.loginWithTelegram) : super(AuthInitial()) {
    on<LoginWithTelegramRequested>((event, emit) async {
      emit(AuthLoading());

      final result = await loginWithTelegram();

      result.fold(
        (failure) {
          emit(AuthError(failure.errMessage));
        },
        (authEntity) {
          emit(
            AuthSuccess(
              message: 'تم تسجيل الدخول بنجاح',
              authEntity: authEntity, // Edited
            ),
          );
        },
      );
    });

    on<CheckCachedAuth>((event, emit) async {
      try {
        final auth = await sl<AuthLocalDataSource>().getCachedAuthData();
        emit(AuthSuccess(message: 'مرحبا بعودتك', authEntity: auth));
      } catch (_) {
        emit(AuthInitial());
      }
    });
  }
}
