import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/resilient_network_avatar.dart';
import '../../domain/entities/organization_invite_entity.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/public_organization_invite_bloc.dart';
import '../bloc/public_organization_invite_event.dart';
import '../bloc/public_organization_invite_state.dart';
import 'organization_details_page.dart';

class PublicOrganizationInvitePage extends StatefulWidget {
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
  State<PublicOrganizationInvitePage> createState() =>
      _PublicOrganizationInvitePageState();
}

class _PublicOrganizationInvitePageState
    extends State<PublicOrganizationInvitePage> {
  @override
  void initState() {
    super.initState();
    _previewInvite();
  }

  @override
  void didUpdateWidget(covariant PublicOrganizationInvitePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token ||
        oldWidget.isAuthenticated != widget.isAuthenticated) {
      _previewInvite();
    }
  }

  void _previewInvite() {
    if (!widget.isAuthenticated) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<PublicOrganizationInviteBloc>();
      final state = bloc.state;
      final token = widget.token.trim();
      if (token.isEmpty) return;
      if (state.token == token &&
          (state.isPreviewing || state.invite != null || state.hasError)) {
        return;
      }

      bloc.add(PreviewPublicOrganizationInviteEvent(token));
    });
  }

  void _openOrganization(OrganizationInviteEntity invite) {
    final slug = invite.organization.slug.trim();
    if (slug.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<OrganizationDetailsBloc>()
                ..add(GetOrganizationDetailsEvent(slug)),
          child: OrganizationDetailsPage(slug: slug),
        ),
      ),
    );
  }

  void _acceptInvite() {
    context.read<PublicOrganizationInviteBloc>().add(
      AcceptPublicOrganizationInviteEvent(widget.token),
    );
  }

  void _retryPreview() {
    context.read<PublicOrganizationInviteBloc>().add(
      PreviewPublicOrganizationInviteEvent(widget.token),
    );
  }

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
                final invite = state.invite;

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: widget.onDismiss,
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'إغلاق',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InviteHeader(token: widget.token),
                        const SizedBox(height: 16),
                        if (!widget.isAuthenticated)
                          _SignInPanel(
                            onSignInRequested: widget.onSignInRequested,
                          )
                        else if (state.isPreviewing && invite == null)
                          const _StatusPanel(
                            icon: Icons.search_rounded,
                            title: 'جاري فتح الدعوة',
                            message: 'نراجع رابط الدعوة وبيانات المنظمة.',
                            isLoading: true,
                          )
                        else if (state.hasError)
                          _StatusPanel(
                            icon: Icons.error_outline_rounded,
                            title: 'تعذر فتح الدعوة',
                            message:
                                state.message ??
                                'الرابط غير صالح أو لم يعد متاحا.',
                            color: Colors.red,
                            actionText: 'إعادة المحاولة',
                            actionIcon: Icons.refresh_rounded,
                            onAction: _retryPreview,
                          )
                        else if (invite != null) ...[
                          _InviteOrganizationCard(
                            invite: invite,
                            accepted: state.isAccepted,
                            onViewOrganization: () => _openOrganization(invite),
                          ),
                          const SizedBox(height: 14),
                          _InviteActionPanel(
                            state: state,
                            onAccept: _acceptInvite,
                            onDone: widget.onAccepted,
                            onViewOrganization: () => _openOrganization(invite),
                          ),
                        ] else
                          const _StatusPanel(
                            icon: Icons.search_rounded,
                            title: 'جاري فتح الدعوة',
                            message: 'نراجع رابط الدعوة وبيانات المنظمة.',
                            isLoading: true,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: colors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دعوة منظمة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'راجع تفاصيل المنظمة ثم اختر الإجراء المناسب.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _TokenBadge(token: token),
              ],
            ),
          ),
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

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded, size: 15, color: colors.primary),
            const SizedBox(width: 6),
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
      ),
    );
  }

  String _shortToken(String value) {
    if (value.length <= 16) return value;
    return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
  }
}

class _SignInPanel extends StatelessWidget {
  final VoidCallback onSignInRequested;

  const _SignInPanel({required this.onSignInRequested});

  @override
  Widget build(BuildContext context) {
    return _StatusPanel(
      icon: Icons.login_rounded,
      title: 'سجل الدخول لفتح الدعوة',
      message: 'بعد تسجيل الدخول ستظهر تفاصيل المنظمة وخيار القبول.',
      actionText: 'تسجيل الدخول',
      actionIcon: Icons.login_rounded,
      onAction: onSignInRequested,
    );
  }
}

class _InviteOrganizationCard extends StatelessWidget {
  final OrganizationInviteEntity invite;
  final bool accepted;
  final VoidCallback onViewOrganization;

  const _InviteOrganizationCard({
    required this.invite,
    required this.accepted,
    required this.onViewOrganization,
  });

  @override
  Widget build(BuildContext context) {
    final organization = invite.organization;
    final overview = invite.overview;
    final colors = Theme.of(context).colorScheme;
    final isDone = accepted || invite.alreadyJoined;
    final statusColor = isDone ? const Color(0xff238A5A) : colors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResilientNetworkAvatar(
                radius: 28,
                imageUrl: organization.imageUrl,
                fallbackLabel: organization.name,
                backgroundColor: colors.surfaceContainerHighest,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            organization.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(
                          color: statusColor,
                          icon: isDone
                              ? Icons.check_circle_rounded
                              : Icons.mail_rounded,
                          label: isDone ? 'عضو' : 'دعوة',
                        ),
                      ],
                    ),
                    if (organization.ownerName != null &&
                        organization.ownerName!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        organization.ownerName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (organization.description != null &&
                        organization.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        organization.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _MetricChip(
                icon: Icons.group_rounded,
                label: '${overview?.membersCount ?? 0} عضو',
              ),
              _MetricChip(
                icon: Icons.school_rounded,
                label: '${overview?.publishedCoursesCount ?? 0} كورس',
              ),
              _MetricChip(
                icon: Icons.badge_rounded,
                label: _roleLabel(invite.role),
              ),
              if (invite.maxUses != null)
                _MetricChip(
                  icon: Icons.how_to_reg_rounded,
                  label: '${invite.usedCount}/${invite.maxUses}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          _InlineNotice(
            icon: isDone
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            message: isDone
                ? 'حسابك موجود داخل هذه المنظمة.'
                : 'يمكنك قبول الدعوة أو فتح صفحة المنظمة أولا.',
            color: statusColor,
          ),
          if (organization.slug.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onViewOrganization,
                style: OutlinedButton.styleFrom(
                  foregroundColor: statusColor,
                  side: BorderSide(color: statusColor.withValues(alpha: 0.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.apartment_rounded, size: 19),
                label: const Text(
                  'عرض صفحة المنظمة',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'مشرف';
      case 'OWNER':
        return 'مالك';
      default:
        return 'طالب';
    }
  }
}

class _InviteActionPanel extends StatelessWidget {
  final PublicOrganizationInviteState state;
  final VoidCallback onAccept;
  final VoidCallback onDone;
  final VoidCallback onViewOrganization;

  const _InviteActionPanel({
    required this.state,
    required this.onAccept,
    required this.onDone,
    required this.onViewOrganization,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isAccepted) {
      return _ResultPanel(
        icon: Icons.check_circle_rounded,
        title: 'تم قبول الدعوة',
        message: 'تم تحديث حسابك وإضافتك إلى المنظمة.',
        color: const Color(0xff238A5A),
        primaryText: 'عرض المنظمة',
        primaryIcon: Icons.apartment_rounded,
        onPrimary: onViewOrganization,
        secondaryText: 'العودة',
        onSecondary: onDone,
      );
    }

    if (state.alreadyJoined) {
      return _ResultPanel(
        icon: Icons.check_circle_rounded,
        title: 'أنت عضو في هذه المنظمة',
        message: 'لا تحتاج لقبول الدعوة مرة أخرى.',
        color: const Color(0xff238A5A),
        primaryText: 'عرض المنظمة',
        primaryIcon: Icons.apartment_rounded,
        onPrimary: onViewOrganization,
        secondaryText: 'العودة',
        onSecondary: onDone,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'قبول الدعوة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'سيتم ربط حسابك بهذه المنظمة بعد القبول.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: state.isAccepting ? null : onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.45,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: state.isAccepting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 21),
              label: Text(
                state.isAccepting ? 'جاري القبول...' : 'قبول الدعوة',
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

class _StatusPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? color;
  final bool isLoading;
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const _StatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.color,
    this.isLoading = false,
    this.actionText,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: accent,
                        ),
                      )
                    : Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
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
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: Icon(actionIcon ?? Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  actionText!,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
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
  final String primaryText;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String secondaryText;
  final VoidCallback onSecondary;

  const _ResultPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.primaryText,
    required this.primaryIcon,
    required this.onPrimary,
    required this.secondaryText,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: Icon(primaryIcon, size: 19),
                    label: Text(
                      primaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withValues(alpha: 0.30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      secondaryText,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _InlineNotice({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _StatusBadge({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
