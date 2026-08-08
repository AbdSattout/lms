import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

Color kLightPrimaryColor = AppColors.primary;
Color kLightSecondaryColor = AppColors.pink;

class TelegramLoginPage extends StatefulWidget {
  const TelegramLoginPage({super.key});

  @override
  State<TelegramLoginPage> createState() => _TelegramLoginPageState();
}

class _TelegramLoginPageState extends State<TelegramLoginPage> {
  static const Duration _otpLifetime = Duration(minutes: 5);
  static const Duration _resendDelay = Duration(minutes: 1);

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  Timer? _otpTimer;
  DateTime? _otpRequestStartedAt;
  String? _activeEmail;
  int _otpSecondsLeft = 0;
  int _resendSecondsLeft = 0;
  bool _otpRequested = false;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp({bool resend = false}) {
    if (!resend && !(_emailFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = (resend ? _activeEmail : _emailController.text)?.trim() ?? '';
    if (email.isEmpty) return;

    _otpRequestStartedAt = DateTime.now();
    context.read<AuthBloc>().add(RequestEmailOtpRequested(email));
  }

  void _verifyOtp() {
    if (_otpSecondsLeft <= 0) {
      _showSnackBar('انتهت صلاحية الرمز، أرسل رمزاً جديداً');
      return;
    }

    if (!(_otpFormKey.currentState?.validate() ?? false)) return;

    final email = _activeEmail ?? _emailController.text.trim();
    context.read<AuthBloc>().add(
      VerifyEmailOtpRequested(email: email, otp: _otpController.text.trim()),
    );
  }

  void _startOtpWindow(String email) {
    final elapsedSeconds = DateTime.now()
        .difference(_otpRequestStartedAt ?? DateTime.now())
        .inSeconds;

    _otpTimer?.cancel();
    setState(() {
      _activeEmail = email;
      _emailController.text = email;
      _otpController.clear();
      _otpRequested = true;
      _otpSecondsLeft = (_otpLifetime.inSeconds - elapsedSeconds)
          .clamp(0, _otpLifetime.inSeconds)
          .toInt();
      _resendSecondsLeft = (_resendDelay.inSeconds - elapsedSeconds)
          .clamp(0, _resendDelay.inSeconds)
          .toInt();
    });

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_otpSecondsLeft == 0 && _resendSecondsLeft == 0) {
        _otpTimer?.cancel();
        return;
      }

      setState(() {
        if (_otpSecondsLeft > 0) _otpSecondsLeft--;
        if (_resendSecondsLeft > 0) _resendSecondsLeft--;
      });
    });
  }

  void _changeEmail() {
    _otpTimer?.cancel();
    setState(() {
      _otpRequested = false;
      _activeEmail = null;
      _otpSecondsLeft = 0;
      _resendSecondsLeft = 0;
      _otpController.clear();
    });
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              _showSnackBar(state.message, backgroundColor: Colors.red);
            }

            if (state is EmailOtpRequestSuccess) {
              _startOtpWindow(state.email);
              _showSnackBar(state.message);
            }

            if (state is AuthSuccess) {
              _otpTimer?.cancel();
            }
          },
          builder: (context, state) {
            final isRequestingOtp = state is EmailOtpRequestLoading;
            final isVerifyingOtp = state is EmailOtpVerifyLoading;
            final isTelegramLoading = state is AuthLoading;
            final isGoogleLoading = state is GoogleAuthLoading;
            final isBusy =
                isRequestingOtp ||
                isVerifyingOtp ||
                isTelegramLoading ||
                isGoogleLoading;

            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.34,
                  decoration: BoxDecoration(
                    color: kLightPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
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
                            height: 220,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'مرحباً بك مجدداً',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'ادخل بريدك الإلكتروني لاستلام رمز الدخول',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _EmailOtpForm(
                            emailFormKey: _emailFormKey,
                            otpFormKey: _otpFormKey,
                            emailController: _emailController,
                            otpController: _otpController,
                            otpRequested: _otpRequested,
                            otpSecondsLeft: _otpSecondsLeft,
                            resendSecondsLeft: _resendSecondsLeft,
                            isRequestingOtp: isRequestingOtp,
                            isVerifyingOtp: isVerifyingOtp,
                            isBusy: isBusy,
                            onRequestOtp: () => _requestOtp(),
                            onVerifyOtp: _verifyOtp,
                            onResendOtp: () => _requestOtp(resend: true),
                            onChangeEmail: _changeEmail,
                            formatSeconds: _formatSeconds,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'أو',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _GoogleAuthButton(
                            isLoading: isGoogleLoading,
                            onPressed: isBusy
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                      LoginWithGoogleRequested(),
                                    );
                                  },
                          ),
                          const SizedBox(height: 12),
                          _TelegramAuthButton(
                            isLoading: isTelegramLoading,
                            onPressed: isBusy
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                      LoginWithTelegramRequested(),
                                    );
                                  },
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'دخول آمن ومشفر 100%',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
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

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _EmailOtpForm extends StatelessWidget {
  final GlobalKey<FormState> emailFormKey;
  final GlobalKey<FormState> otpFormKey;
  final TextEditingController emailController;
  final TextEditingController otpController;
  final bool otpRequested;
  final int otpSecondsLeft;
  final int resendSecondsLeft;
  final bool isRequestingOtp;
  final bool isVerifyingOtp;
  final bool isBusy;
  final VoidCallback onRequestOtp;
  final VoidCallback onVerifyOtp;
  final VoidCallback onResendOtp;
  final VoidCallback onChangeEmail;
  final String Function(int seconds) formatSeconds;

  const _EmailOtpForm({
    required this.emailFormKey,
    required this.otpFormKey,
    required this.emailController,
    required this.otpController,
    required this.otpRequested,
    required this.otpSecondsLeft,
    required this.resendSecondsLeft,
    required this.isRequestingOtp,
    required this.isVerifyingOtp,
    required this.isBusy,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onChangeEmail,
    required this.formatSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final otpExpired = otpRequested && otpSecondsLeft <= 0;

    return Column(
      children: [
        Form(
          key: emailFormKey,
          child: TextFormField(
            controller: emailController,
            enabled: !otpRequested && !isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              context,
              label: 'البريد الإلكتروني',
              icon: Icons.email_rounded,
            ),
            validator: _validateEmail,
          ),
        ),
        if (!otpRequested) ...[
          const SizedBox(height: 16),
          _PrimaryAuthButton(
            label: 'إرسال رمز التحقق',
            icon: Icons.mark_email_read_rounded,
            isLoading: isRequestingOtp,
            onPressed: isBusy ? null : onRequestOtp,
          ),
        ] else ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  otpExpired
                      ? 'انتهت صلاحية الرمز'
                      : 'ينتهي الرمز خلال ${formatSeconds(otpSecondsLeft)}',
                  style: TextStyle(
                    color: otpExpired ? Colors.red : colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: isBusy ? null : onChangeEmail,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('تغيير البريد'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Form(
            key: otpFormKey,
            child: TextFormField(
              controller: otpController,
              enabled: !isBusy && !otpExpired,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: _inputDecoration(
                context,
                label: 'رمز التحقق',
                icon: Icons.lock_rounded,
              ).copyWith(counterText: ''),
              validator: _validateOtp,
              onFieldSubmitted: (_) => onVerifyOtp(),
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryAuthButton(
            label: 'تأكيد الدخول',
            icon: Icons.verified_rounded,
            isLoading: isVerifyingOtp,
            onPressed: isBusy || otpExpired ? null : onVerifyOtp,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton.icon(
              onPressed: isBusy || resendSecondsLeft > 0 ? null : onResendOtp,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                resendSecondsLeft > 0
                    ? 'إعادة الإرسال بعد ${formatSeconds(resendSecondsLeft)}'
                    : 'إعادة إرسال الرمز',
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.6,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    if (!emailRegex.hasMatch(email)) {
      return 'ادخل بريداً إلكترونياً صحيحاً';
    }

    return null;
  }

  String? _validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    return null;
  }
}

class _GoogleAuthButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GoogleAuthButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.surfaceContainerHighest;
              }

              return Colors.white;
            }),
            foregroundColor: const WidgetStatePropertyAll(Color(0xFF15191C)),
            overlayColor: WidgetStatePropertyAll(
              Colors.black.withValues(alpha: 0.04),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              return BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? Theme.of(context).dividerColor
                    : const Color(0xFFD6DEE2),
                width: 1.35,
              );
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    color: Color(0xFF15191C),
                    strokeWidth: 2.3,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GoogleLogo(size: 20),
                    SizedBox(width: 11),
                    Text(
                      'تسجيل الدخول عبر جوجل',
                      style: TextStyle(
                        color: Color(0xFF15191C),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TelegramAuthButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _TelegramAuthButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isEnabled = onPressed != null;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colors.surfaceContainerHighest;
              }

              return Colors.white;
            }),
            foregroundColor: WidgetStatePropertyAll(primaryColor),
            overlayColor: WidgetStatePropertyAll(
              primaryColor.withValues(alpha: 0.06),
            ),
            side: WidgetStateProperty.resolveWith((states) {
              return BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? Theme.of(context).dividerColor
                    : primaryColor.withValues(alpha: 0.72),
                width: 1.35,
              );
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2.4,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.telegram_rounded, color: primaryColor, size: 25),
                    const SizedBox(width: 11),
                    Flexible(
                      child: Text(
                        'الدخول بواسطة تيليجرام',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;

  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double degrees(double value) => value * math.pi / 180;

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, degrees(215), degrees(95), false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, degrees(150), degrees(65), false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, degrees(45), degrees(105), false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, degrees(-25), degrees(70), false, paint);

    paint
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.53, size.height * 0.50),
      Offset(size.width * 0.92, size.height * 0.50),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryAuthButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: kLightPrimaryColor.withValues(alpha: 0.35),
        ),
        icon: isLoading ? const SizedBox.shrink() : Icon(icon, size: 24),
        label: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
