import 'package:flutter/material.dart';
import 'package:lms/core/services/injection_container.dart' as di; 
import 'package:lms/core/services/injection_container.dart'; 
import 'package:lms/features/auth/domain/usecases/login_with_telegram.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preparing all services and UseCases
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LMS Mobile',
      locale: const Locale('ar', 'SY'),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const TelegramLoginPage(),
    );
  }
}

class TelegramLoginPage extends StatefulWidget {
  const TelegramLoginPage({super.key});

  @override
  State<TelegramLoginPage> createState() => _TelegramLoginPageState();
}

class _TelegramLoginPageState extends State<TelegramLoginPage> {
  // The injection has been activated here to bring in the UseCase From the box (Service Locator) (injection_serverce.dart)
  final LoginWithTelegram _loginWithTelegramUseCase = sl<LoginWithTelegram>();
  
  String _status = 'جاهز';
  String _result = '-';
  bool _loading = false;

  Future<void> _loginProcess() async {
    setState(() {
      _loading = true;
      _status = 'Connecting to Telegram...';
      _result = '-';
    });

    final eitherResult = await _loginWithTelegramUseCase.call(); 

    eitherResult.fold(
      (failure) {
        setState(() {
          _loading = false;
          _status = 'Login Failed';
          _result = failure.errMessage; 
        });
      },
      (authEntity) {
        setState(() {
          _loading = false;
          _status = 'Login Success';
          
          _result = '''
[Success] User authenticated!

ID Token:
${authEntity.idToken}

Access Token:
${authEntity.accessToken ?? 'No Access Token Provided'}
          ''';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('تسجيل الدخول عبر تيليجرام'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('اختبار تسجيل الدخول', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              
              Text(
                _status,
                style: Theme.of(context).textTheme.titleMedium,
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _result,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _loginProcess,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تسجيل الدخول الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}