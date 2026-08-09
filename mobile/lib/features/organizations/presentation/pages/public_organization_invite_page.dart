import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/public_organization_invite_bloc.dart';
import '../bloc/public_organization_invite_event.dart';
import '../bloc/public_organization_invite_state.dart';

class PublicOrganizationInvitePage extends StatelessWidget {
  final String token;
  final bool isAuthenticated;
  final VoidCallback onDismiss;
  final VoidCallback onSignInRequested;
  final VoidCallback onAccepted;

  const PublicOrganizationInvitePage({
    super.key,
    required this.token,
    required this.isAuthenticated,
    required this.onDismiss,
    required this.onSignInRequested,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body:
            BlocBuilder<
              PublicOrganizationInviteBloc,
              PublicOrganizationInviteState
            >(
              builder: (context, state) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: onDismiss,
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'إغلاق',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InviteHeader(token: token),
                        const SizedBox(height: 18),
                        _InviteDetailsPanel(isAuthenticated: isAuthenticated),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _ActionPanel(
                            key: ValueKey(
                              '${state.status}-$isAuthenticated-${state.message}',
                            ),
                            state: state,
                            isAuthenticated: isAuthenticated,
                            onAccept: () {
                              context.read<PublicOrganizationInviteBloc>().add(
                                AcceptPublicOrganizationInviteEvent(token),
                              );
                            },
                            onSignInRequested: onSignInRequested,
                            onDone: onAccepted,
                            onRetry: () {
                              context.read<PublicOrganizationInviteBloc>().add(
                                ResetPublicOrganizationInviteEvent(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}

class _InviteHeader extends StatelessWidget {
  final String token;

  const _InviteHeader({required this.token});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.18)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_3_rounded,
              color: colors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'دعوة للانضمام',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: colors.primary,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'افتح الدعوة من تطبيق مسار، ثم اقبلها لإضافتك إلى المنظمة.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _TokenBadge(token: token),
        ],
      ),
    );
  }
}

class _TokenBadge extends StatelessWidget {
  final String token;

  const _TokenBadge({required this.token});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_rounded, size: 16, color: colors.primary),
          const SizedBox(width: 7),
          Text(
            _shortToken(token),
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _shortToken(String value) {
    if (value.length <= 16) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }
}

class _InviteDetailsPanel extends StatelessWidget {
  final bool isAuthenticated;

  const _InviteDetailsPanel({required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.verified_user_rounded,
            title: 'رابط عام',
            value: 'سيتم التحقق من صلاحية الرابط عند القبول',
            color: colors.primary,
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.school_rounded,
            title: 'الدور',
            value: 'طالب داخل المنظمة',
            color: const Color(0xff238A5A),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: isAuthenticated
                ? Icons.lock_open_rounded
                : Icons.lock_outline_rounded,
            title: 'الحساب',
            value: isAuthenticated
                ? 'أنت جاهز لقبول الدعوة'
                : 'سجّل الدخول أولاً للحفاظ على حسابك',
            color: isAuthenticated ? const Color(0xff238A5A) : AppColors.pink,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final PublicOrganizationInviteState state;
  final bool isAuthenticated;
  final VoidCallback onAccept;
  final VoidCallback onSignInRequested;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  const _ActionPanel({
    super.key,
    required this.state,
    required this.isAuthenticated,
    required this.onAccept,
    required this.onSignInRequested,
    required this.onDone,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isAccepted) {
      return _ResultPanel(
        icon: Icons.check_circle_rounded,
        title: state.message ?? 'تم قبول الدعوة',
        message: 'يمكنك الآن متابعة التعلم وإدارة انضمامك من داخل التطبيق.',
        color: const Color(0xff238A5A),
        actionText: 'العودة إلى التطبيق',
        actionIcon: Icons.arrow_back_rounded,
        onPressed: onDone,
      );
    }

    if (state.hasError) {
      return _ResultPanel(
        icon: Icons.error_outline_rounded,
        title: 'تعذر قبول الدعوة',
        message: state.message ?? 'حدث خطأ غير متوقع. حاول مرة أخرى.',
        color: Colors.red,
        actionText: 'المحاولة مرة أخرى',
        actionIcon: Icons.refresh_rounded,
        onPressed: onRetry,
      );
    }

    if (!isAuthenticated) {
      return _CallToActionPanel(
        title: 'سجّل الدخول أولاً',
        message: 'بعد تسجيل الدخول ستعود إلى هذه الدعوة وتظهر لك أداة القبول.',
        buttonText: 'تسجيل الدخول',
        buttonIcon: Icons.login_rounded,
        onPressed: onSignInRequested,
      );
    }

    return _CallToActionPanel(
      title: 'جاهز للانضمام',
      message: 'اضغط قبول الدعوة لإضافة حسابك إلى المنظمة كطالب.',
      buttonText: state.isAccepting ? 'جاري القبول...' : 'قبول الدعوة',
      buttonIcon: Icons.check_rounded,
      isLoading: state.isAccepting,
      onPressed: state.isAccepting ? null : onAccept,
    );
  }
}

class _CallToActionPanel extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData buttonIcon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _CallToActionPanel({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.45,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    )
                  : Icon(buttonIcon, size: 21),
              label: Text(
                buttonText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final String actionText;
  final IconData actionIcon;
  final VoidCallback onPressed;

  const _ResultPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.actionText,
    required this.actionIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.32)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(actionIcon, size: 20),
              label: Text(
                actionText,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
