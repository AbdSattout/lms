import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/injection_container.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_cubit.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/telegram_login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: sl<ThemeCubit>(),
      builder: (context, mode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LMS Mobile',

          locale: const Locale('ar', 'SY'),

          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: mode,

          home: BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const TelegramLoginPage(),
          ),
        );
      },
    );
  }
}