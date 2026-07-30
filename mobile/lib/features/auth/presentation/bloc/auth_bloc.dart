import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_with_telegram.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithTelegram loginWithTelegram;

  AuthBloc(this.loginWithTelegram) : super(AuthInitial()) {

    on<LoginWithTelegramRequested>((event, emit) async {
      print("EVENT RECEIVED");
      emit(AuthLoading());
      print("BEFORE LOGIN LOADING");
      final result = await loginWithTelegram();
      print("AFTER LOGIN");
      result.fold(
            (failure) {
          emit(AuthError(failure.errMessage));
        },
            (authEntity) {
          emit(AuthSuccess(
            message: 'تم تسجيل الدخول بنجاح',
            authEntity: authEntity,
          ));
        },
      );
    });
  }
}