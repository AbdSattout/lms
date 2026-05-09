import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class TelegramLoginPage extends StatelessWidget {
  const TelegramLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'تسجيل الدخول',
          ),
        ),

        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {

            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }

            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },

          builder: (context, state) {

            final isLoading = state is AuthLoading;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEAF4FF),
                    Colors.white,
                  ],
                ),
              ),

              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),

                    child: Container(
                      padding: const EdgeInsets.all(28),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          SizedBox(
                            height: 240,
                            child: Lottie.asset(
                              'assets/lotties/book_loading.json',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'مرحباً بك في منصة التعلم',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2B48),
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'ابدأ رحلتك التعليمية وسجل الدخول عبر تيليجرام للوصول إلى الدورات والمحتوى التعليمي',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7A90),
                              height: 1.7,
                            ),
                          ),

                          const SizedBox(height: 36),

                          SizedBox(
                            width: double.infinity,
                            height: 58,

                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                context.read<AuthBloc>().add(
                                  LoginWithTelegramRequested(),
                                );
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),

                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),

                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [

                                  Icon(
                                    Icons.telegram,
                                    color: Colors.white,
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    'تسجيل الدخول عبر تيليجرام',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'تسجيل آمن وسريع',
                            style: TextStyle(
                              color: Color(0xFF9AA7B8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}