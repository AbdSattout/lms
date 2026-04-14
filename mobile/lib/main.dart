import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS Mobile',
      locale: const Locale('ar', 'SY'),
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ApiCheckPage(),
    );
  }
}

class ApiCheckPage extends StatefulWidget {
  const ApiCheckPage({super.key});

  @override
  State<ApiCheckPage> createState() => _ApiCheckPageState();
}

class _ApiCheckPageState extends State<ApiCheckPage> {
  String _status = 'جاهز';
  String _result = '-';
  bool _loading = false;

  Future<void> _checkApi() async {
    setState(() {
      _loading = true;
      _status = 'جار الفحص...';
      _result = '-';
    });

    String status;
    String result;

    try {
      final response = await http.get(Uri.parse(apiUrl));
      status = 'متاح (${response.statusCode})';
      result = response.body.isEmpty ? '(استجابة فارغة)' : response.body;
    } catch (e) {
      status = 'غير متاح';
      result = e.toString();
    }

    setState(() {
      _loading = false;
      _status = status;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('اختبار API'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('اختبار الاتصال', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              SelectableText(
                apiUrl,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueAccent),
              ),
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
                  onPressed: _loading ? null : _checkApi,
                  child: _loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('اختبار الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
