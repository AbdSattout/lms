import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/injection_container.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';
import 'core/widgets/immersive_mode_guard.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/telegram_login_page.dart';
import 'features/home/presentation/pages/main_home_screen.dart';

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: sl<ThemeCubit>(),
      builder: (context, mode) {
        return BlocProvider.value(
          value: authBloc,
          child: ImmersiveModeGuard(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'LMS Mobile',

              locale: const Locale('ar', 'SY'),

              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: mode,

              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthError) {
                    debugPrint("Current auth error: ${state.message}");
                  } else {
                    debugPrint("Current auth state: ${state.runtimeType}");
                  }

                  if (state is AuthInitial || state is AuthLoading) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is Authenticated) {
                    return MainHomeScreen(userAuthData: state.authEntity);
                  } else if (state is AuthSuccess) {
                    return MainHomeScreen(userAuthData: state.authEntity);
                  } else {
                    return const TelegramLoginPage();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
