import 'package:flutter_bloc/flutter_bloc.dart';

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
          emit(AuthSuccess(
            'تم تسجيل الدخول بنجاح',
          ));
        },
      );
    });
  }
}