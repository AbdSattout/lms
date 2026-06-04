import 'package:flutter/material.dart';
import 'package:lms/app.dart';
import 'package:lms/core/services/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(const MyApp());
}