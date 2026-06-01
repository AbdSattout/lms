import 'package:flutter/material.dart';
import 'package:lms/app.dart';
import 'package:lms/core/services/injection_container.dart' as di;
import 'package:lms/core/services/injection_container.dart';
import 'package:lms/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lms/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  sl<AuthBloc>().add(CheckCachedAuth());

  runApp(const MyApp());
}
