import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/databases/cache/cache_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../billing/presentation/bloc/billing_event.dart';
import '../../../billing/presentation/pages/billing_page.dart';
import '../../../gamification/presentation/widgets/gamification_card.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_option_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            current is ProfileUpdated ||
            current is ProfilePictureUpdated ||
            current is ProfileError ||
            (current is ProfileLoaded &&
                (current.accountEmailMessage != null ||
                    current.accountEmailError != null)),
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
            );
          }

          if (state is ProfilePictureUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث الصورة بنجاح')),
            );
          }

          if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ProfileLoaded && state.accountEmailMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.accountEmailMessage!)));
          }

          if (state is ProfileLoaded && state.accountEmailError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.accountEmailError!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is ProfileLoading ||
            current is ProfileLoaded ||
            (current is ProfileError && previous is! ProfileLoaded),
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;
            final displayName = _displayName(profile);
            final profileImage = _profileImageProvider(profile.user.picture);

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 235,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(35),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 55,
                                      backgroundImage: profileImage,
                                    ),

                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _pickImage(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _displayValue(
                        profile.email,
                        fallback: "لم يتم إضافة البريد الإلكتروني",
                      ),
                      style: const TextStyle(color: AppColors.darkSoft),
                    ),

                    const SizedBox(height: 24),

                    _AccountEmailCard(
                      accountEmail: state.accountEmail,
                      pendingEmail: state.pendingAccountEmail,
                      isRequesting: state.isRequestingAccountEmailOtp,
                      isVerifying: state.isVerifyingAccountEmailOtp,
                      onRequestOtp: (email) {
                        context.read<ProfileBloc>().add(
                          RequestAccountEmailOtpEvent(email),
                        );
                      },
                      onVerifyOtp: (email, otp) {
                        context.read<ProfileBloc>().add(
                          VerifyAccountEmailOtpEvent(email: email, otp: otp),
                        );
                      },
                      onCancelPending: () {
                        context.read<ProfileBloc>().add(
                          CancelAccountEmailOtpEvent(),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    _buildInfoCard(
                      title: "رقم الهاتف",
                      value: _displayValue(profile.phone, fallback: ""),
                      icon: Icons.phone_outlined,
                    ),

                    _buildInfoCard(
                      title: "الجامعة",
                      value: _displayValue(profile.university, fallback: ""),
                      icon: Icons.school_outlined,
                    ),

                    const SizedBox(height: 30),

                    ProfileOptionTile(
                      title: "الإعدادات الشخصية",
                      icon: Icons.edit_outlined,
                      onTap: () {
                        _showEditProfileSheet(context, profile);
                      },
                    ),

                    ProfileOptionTile(
                      title: "المظهر",
                      icon: Icons.palette_outlined,
                      onTap: () {
                        _showThemeSheet(context);
                      },
                    ),

                    ProfileOptionTile(
                      title: "الخطط والمدفوعات",
                      icon: Icons.payments_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) =>
                                  sl<BillingBloc>()
                                    ..add(const LoadBillingEvent()),
                              child: const BillingPage(),
                            ),
                          ),
                        );
                      },
                    ),

                    ProfileOptionTile(
                      title: "شهاداتي",
                      icon: Icons.workspace_premium_outlined,
                      onTap: () {},
                    ),

                    ProfileOptionTile(
                      title: "تسجيل الخروج",
                      icon: Icons.logout_rounded,
                      destructive: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('تسجيل الخروج'),
                            content: const Text('هل أنت متأكد؟'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthBloc>().add(
                                    LogoutRequested(),
                                  );
                                },
                                child: const Text('خروج'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const GamificationCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

String _displayName(ProfileEntity profile) {
  final candidates = [
    profile.name,
    profile.user.name,
    _nameFromEmail(profile.email),
  ];

  for (final candidate in candidates) {
    final value = candidate?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  return 'مستخدم';
}

String _displayValue(String? value, {String fallback = 'غير مضاف'}) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  return normalized;
}

String? _nameFromEmail(String? email) {
  final normalized = email?.trim();
  if (normalized == null || normalized.isEmpty) return null;

  final atIndex = normalized.indexOf('@');
  if (atIndex <= 0) return normalized;

  return normalized.substring(0, atIndex);
}

ImageProvider _profileImageProvider(String? picture) {
  final normalized = picture?.trim();
  final uri = normalized == null ? null : Uri.tryParse(normalized);
  final isNetworkImage =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;

  if (isNetworkImage) {
    return NetworkImage(uri.toString());
  }

  return const AssetImage('assets/images/user.png');
}

class _AccountEmailCard extends StatefulWidget {
  final String? accountEmail;
  final String? pendingEmail;
  final bool isRequesting;
  final bool isVerifying;
  final ValueChanged<String> onRequestOtp;
  final void Function(String email, String otp) onVerifyOtp;
  final VoidCallback onCancelPending;

  const _AccountEmailCard({
    required this.accountEmail,
    required this.pendingEmail,
    required this.isRequesting,
    required this.isVerifying,
    required this.onRequestOtp,
    required this.onVerifyOtp,
    required this.onCancelPending,
  });

  @override
  State<_AccountEmailCard> createState() => _AccountEmailCardState();
}

class _AccountEmailCardState extends State<_AccountEmailCard> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncPendingEmail();
  }

  @override
  void didUpdateWidget(covariant _AccountEmailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPendingEmail();

    if (_hasText(widget.accountEmail) && !_hasText(oldWidget.accountEmail)) {
      _otpController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountEmail = _normalized(widget.accountEmail);
    final pendingEmail = _normalized(widget.pendingEmail);
    final hasAccountEmail = _hasText(accountEmail);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isLinked: hasAccountEmail),
          const SizedBox(height: 16),
          if (hasAccountEmail)
            _buildLinkedEmail(context, accountEmail!)
          else if (_hasText(pendingEmail))
            _buildOtpForm(context, pendingEmail!)
          else
            _buildEmailForm(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isLinked}) {
    final statusColor = isLinked ? Colors.green : AppColors.primary;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            isLinked ? Icons.mark_email_read_rounded : Icons.email_outlined,
            color: statusColor,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بريد تسجيل الدخول',
                style: TextStyle(
                  color: AppColors.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'مختلف عن بريد الملف الشخصي',
                style: TextStyle(color: AppColors.darkSoft, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isLinked ? 'مربوط' : 'مطلوب',
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedEmail(BuildContext context, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                email,
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(BuildContext context) {
    final isBusy = widget.isRequesting || widget.isVerifying;

    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            enabled: !isBusy,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: _inputDecoration(
              context,
              label: 'البريد الإلكتروني',
              hint: 'name@example.com',
              icon: Icons.alternate_email_rounded,
            ),
            validator: _validateEmail,
            onFieldSubmitted: (_) => _submitEmail(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isBusy ? null : _submitEmail,
              child: widget.isRequesting
                  ? _loadingIndicator()
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_email_read_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'إرسال رمز التحقق',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(BuildContext context, String pendingEmail) {
    final isBusy = widget.isRequesting || widget.isVerifying;

    return Form(
      key: _otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                pendingEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _otpController,
            enabled: !isBusy,
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
              hint: '000000',
              icon: Icons.password_rounded,
            ).copyWith(counterText: ''),
            validator: _validateOtp,
            onFieldSubmitted: (_) => _submitOtp(pendingEmail),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isBusy ? null : () => _submitOtp(pendingEmail),
              child: widget.isVerifying
                  ? _loadingIndicator()
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تأكيد البريد',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: isBusy
                    ? null
                    : () => widget.onRequestOtp(pendingEmail),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة الإرسال'),
              ),
              TextButton.icon(
                onPressed: isBusy
                    ? null
                    : () {
                        _otpController.clear();
                        widget.onCancelPending();
                      },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('تغيير البريد'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
    );
  }

  void _submitEmail() {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    widget.onRequestOtp(_emailController.text.trim());
  }

  void _submitOtp(String pendingEmail) {
    if (!(_otpFormKey.currentState?.validate() ?? false)) return;

    widget.onVerifyOtp(pendingEmail, _otpController.text.trim());
  }

  void _syncPendingEmail() {
    final pendingEmail = _normalized(widget.pendingEmail);
    if (_hasText(pendingEmail) && _emailController.text != pendingEmail) {
      _emailController.text = pendingEmail!;
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (email.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    if (!emailRegex.hasMatch(email)) {
      return 'أدخل بريداً إلكترونياً صحيحاً';
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

  static String? _normalized(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

Widget _buildInfoCard({
  required String title,
  required String value,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.darkSoft, fontSize: 13),
              ),

              const SizedBox(height: 4),

              Text(
                value.isEmpty ? "غير مضاف" : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: value.isEmpty ? Colors.grey : AppColors.dark,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showEditProfileSheet(BuildContext context, ProfileEntity profile) {
  final emailController = TextEditingController(text: profile.email ?? '');

  final phoneController = TextEditingController(text: profile.phone ?? '');

  final universityController = TextEditingController(
    text: profile.university ?? '',
  );

  // capture the ProfileBloc BEFORE opening the bottom sheet, since the
  // sheet's own builder context is a different subtree.
  final profileBloc = context.read<ProfileBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "تعديل الملف الشخصي",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني",
                hintText: "example@gmail.com",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                hintText: "09XXXXXXXX",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: universityController,
              decoration: const InputDecoration(labelText: "الجامعة"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  profileBloc.add(
                    UpdateProfileEvent(
                      email: emailController.text,
                      phone: phoneController.text,
                      university: universityController.text,
                    ),
                  );

                  Navigator.pop(sheetContext);
                },
                child: const Text("حفظ التعديلات"),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _pickImage(BuildContext context) async {
  final profileBloc = context.read<ProfileBloc>();

  try {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    debugPrint('picker returned: ${image?.path}');

    if (image == null) {
      debugPrint(
        'No image selected — either cancelled, permission denied, or no picker available on this device/emulator.',
      );
      return;
    }

    profileBloc.add(UpdateProfilePictureEvent(image.path));
  } catch (e) {
    debugPrint('Image picker failed: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر اختيار الصورة: $e')));
    }
  }
}

void _showThemeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      final cubit = sl<ThemeCubit>();

      return BlocBuilder<ThemeCubit, ThemeMode>(
        bloc: cubit,
        builder: (context, mode) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text("فاتح"),
                trailing: Radio(
                  value: ThemeMode.light,
                  groupValue: mode,
                  onChanged: (value) async {
                    cubit.setTheme(value!);
                    await sl<CacheHelper>().saveTheme(value);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("داكن"),
                trailing: Radio(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  onChanged: (value) async {
                    cubit.setTheme(value!);
                    await sl<CacheHelper>().saveTheme(value);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text("حسب النظام"),
                trailing: Radio(
                  value: ThemeMode.system,
                  groupValue: mode,
                  onChanged: (value) async {
                    cubit.setTheme(value!);
                    await sl<CacheHelper>().saveTheme(value);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
