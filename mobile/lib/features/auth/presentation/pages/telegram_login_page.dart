import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:lms/features/home/presentation/pages/main_home_screen.dart';
Color kLightPrimaryColor =  AppColors.primary;
Color kLightSecondaryColor = AppColors.pink;

class TelegramLoginPage extends StatelessWidget {
  const TelegramLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        Theme.of(context).scaffoldBackgroundColor,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
            if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainHomeScreen(userAuthData: state.authEntity)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    color: kLightPrimaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/lotties/book_loading.json',
                            height: 280,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'مرحباً بك مجدداً',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'سجل دخولك عبر تيليجرام لتبدأ رحلة التعلم',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: AppColors.darkSoft),
                          ),
                          const SizedBox(height: 40),
                          
                          // زر تسجيل الدخول المصمم بشكل عصري
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () {
                                print("BUTTON PRESSED");
                                context.read<AuthBloc>().add(LoginWithTelegramRequested());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 8,
                                shadowColor: kLightPrimaryColor.withOpacity(0.4),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.telegram_rounded, size: 28),
                                        SizedBox(width: 12),
                                        Text('الدخول بواسطة تيليجرام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('دخول آمن ومشفر 100%', style: TextStyle(color: AppColors.darkSoft, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}