import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../posts/presentation/pages/organization_posts_page.dart';
import '../../../reports/domain/entities/report_target.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../../roadmaps/presentation/pages/organization_roadmaps_page.dart';
import '../../domain/entities/organization_entity.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_details_state.dart';
import 'organization_courses_page.dart';

class OrganizationDetailsPage extends StatelessWidget {
  final String slug;
  const OrganizationDetailsPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<OrganizationDetailsBloc, OrganizationDetailsState>(
          listenWhen: (previous, current) =>
              current is OrganizationDetailsError ||
              current is OrganizationDeleted,
          listener: (context, state) {
            if (state is OrganizationDetailsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is OrganizationDeleted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم حذف المنظمة')));
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            if (state is OrganizationDetailsLoading ||
                state is OrganizationDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrganizationDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OrganizationDetailsBloc>().add(
                            GetOrganizationDetailsEvent(slug),
                          );
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is OrganizationDetailsLoaded) {
              return _OrganizationDetailsContent(
                slug: slug,
                organization: state.organization,
                isProcessing: state.isProcessing,
                onJoin: () {
                  context.read<OrganizationDetailsBloc>().add(
                    JoinOrganizationEvent(slug),
                  );
                },
                onLeave: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('مغادرة المنظمة'),
                      content: const Text(
                        'هل أنت متأكد من مغادرة هذه المنظمة؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'مغادرة',
                            style: TextStyle(color: Color(0xffD9534F)),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<OrganizationDetailsBloc>().add(
                      LeaveOrganizationEvent(slug),
                    );
                  }
                },
                onCancelRequest: () {
                  context.read<OrganizationDetailsBloc>().add(
                    CancelJoinRequestEvent(slug),
                  );
                },
                onAcceptInvite: (inviteId) {
                  context.read<OrganizationDetailsBloc>().add(
                    AcceptOrganizationDetailsInviteEvent(
                      slug: slug,
                      inviteId: inviteId,
                    ),
                  );
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('حذف المنظمة'),
                      content: const Text(
                        'هذا الإجراء نهائي ولا يمكن التراجع عنه. هل أنت متأكد من حذف هذه المنظمة؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'حذف',
                            style: TextStyle(color: Color(0xffD9534F)),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<OrganizationDetailsBloc>().add(
                      DeleteOrganizationEvent(slug),
                    );
                  }
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _OrganizationDetailsContent extends StatelessWidget {
  final OrganizationEntity organization;
  final bool isProcessing;
  final VoidCallback onJoin, onLeave, onCancelRequest, onDelete;
  final ValueChanged<int> onAcceptInvite;
  final String slug;
  const _OrganizationDetailsContent({
    required this.slug,
    required this.organization,
    required this.isProcessing,
    required this.onJoin,
    required this.onLeave,
    required this.onCancelRequest,
    required this.onAcceptInvite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasImage =
        organization.image != null && organization.image!.isNotEmpty;
    final isMember = organization.viewerJoined;
    final isOwner = organization.viewerRole == 'OWNER';
    final isPrivate = organization.visibility == OrganizationVisibility.private;
    final isPending = organization.joinRequestStatus == 'PENDING';
    final hasPendingInvite =
        organization.inviteStatus == 'PENDING' &&
        organization.inviteId != null &&
        !isMember &&
        !isOwner;
    final showsCancelRequest =
        isPending && !hasPendingInvite && !isMember && !isOwner;
    final bottomContentPadding = showsCancelRequest || hasPendingInvite
        ? 230.0
        : 180.0;
    final visibility = switch (organization.visibility) {
      OrganizationVisibility.public => "عامة",
      OrganizationVisibility.private => "خاصة",
      _ => "غير معروف",
    };

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomContentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    child: hasImage
                        ? Image.network(
                            organization.image!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _roundIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          _roundIconButton(
                            icon: Icons.outlined_flag_rounded,
                            onTap: () {
                              showReportBottomSheet(
                                context,
                                ReportTarget.organization(
                                  organizationId: organization.id,
                                  title: organization.name,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPrivate
                                ? Icons.lock_rounded
                                : Icons.public_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            visibility,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            organization.name,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (organization.verified)
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xff0EA5E9,
                              ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 20,
                              color: Color(0xff0EA5E9),
                            ),
                          ),
                      ],
                    ),
                    if (organization.verified) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xff0EA5E9),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'منظمة موثقة',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_alt_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          organization.membersCount == 1
                              ? 'عضو واحد'
                              : '${organization.membersCount} أعضاء',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'منظمتك',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (hasPendingInvite) ...[
                      _InviteNoticeCard(
                        isProcessing: isProcessing,
                        onAccept: () => onAcceptInvite(organization.inviteId!),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (organization.description != null &&
                        organization.description!.trim().isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.info_outline_rounded,
                        title: 'عن المنظمة',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          organization.description!,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.onSurfaceVariant,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_alt_rounded,
                            iconColor: colors.primary,
                            iconBg: colors.primary.withValues(alpha: 0.1),
                            label: "الأعضاء",
                            value: organization.membersCount.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: isPrivate
                                ? Icons.lock_rounded
                                : Icons.public_rounded,
                            iconColor: isPrivate
                                ? const Color(0xffB4780F)
                                : const Color(0xff2E7D53),
                            iconBg: isPrivate
                                ? AppColors.peach.withValues(alpha: .45)
                                : AppColors.mint.withValues(alpha: .45),
                            label: "النوع",
                            value: visibility,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (organization.ownerName != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "مالك المنظمة",
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    organization.ownerName!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    _SectionHeader(
                      icon: Icons.campaign_outlined,
                      title: 'منشورات المنظمة',
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      slug: slug,
                      icon: Icons.campaign_outlined,
                      iconBg: colors.primary.withOpacity(0.1),
                      iconColor: colors.primary,
                      title: ' المنشورات والإعلانات',
                      subtitle: 'تفاعل مع منشورات المنظمة!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrganizationPostsPage(orgSlug: slug),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      slug: slug,
                      icon: Icons.map_outlined,
                      iconBg: colors.primary.withOpacity(0.1),
                      iconColor: colors.primary,
                      title: 'المسارات التعليمية',
                      subtitle: 'استعرض مسارات التعلم',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrganizationRoadmapsPage(slug: slug),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    _SectionHeader(
                      icon: Icons.menu_book_rounded,
                      title: 'كورسات المنظمة',
                    ),
                    const SizedBox(height: 12),
                    _FeatureCard(
                      slug: slug,
                      icon: Icons.school_rounded,
                      iconBg: const Color(0xff2E7D53).withValues(alpha: 0.1),
                      iconColor: const Color(0xff2E7D53),
                      title: 'استعرض الكورسات المتاحة',
                      subtitle: 'سجل في كورسات المنظمة!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganizationCoursesPage(slug: slug),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _membershipButton(
                    isMember: isMember,
                    isOwner: isOwner,
                    isPrivate: isPrivate,
                    isPending: isPending,
                    hasPendingInvite: hasPendingInvite,
                    isProcessing: isProcessing,
                    onJoin: onJoin,
                    onAcceptInvite: () =>
                        onAcceptInvite(organization.inviteId!),
                    onLeave: onLeave,
                    onDelete: onDelete,
                  ),
                  if (showsCancelRequest) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: isProcessing ? null : onCancelRequest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xffD9534F),
                          side: const BorderSide(color: Color(0xffD9534F)),
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text("إلغاء الطلب"),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrganizationPostsPage(orgSlug: slug),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.campaign_outlined, size: 18),
                      label: const Text("منشورات المنظمة"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _membershipButton({
    required bool isMember,
    required bool isOwner,
    required bool isPrivate,
    required bool isPending,
    required bool hasPendingInvite,
    required bool isProcessing,
    required VoidCallback onJoin,
    required VoidCallback onAcceptInvite,
    required VoidCallback onLeave,
    required VoidCallback onDelete,
  }) {
    String label;
    IconData icon;
    Color backgroundColor;
    VoidCallback? onPressed;

    if (isOwner) {
      label = "حذف المنظمة";
      icon = Icons.delete_outline_rounded;
      backgroundColor = const Color(0xffD9534F);
      onPressed = isProcessing ? null : onDelete;
    } else if (isMember) {
      label = "غادر المنظمة";
      icon = Icons.logout_rounded;
      backgroundColor = const Color(0xffD9534F);
      onPressed = isProcessing ? null : onLeave;
    } else if (hasPendingInvite) {
      label = "قبول الدعوة";
      icon = Icons.mark_email_read_rounded;
      backgroundColor = AppColors.primary;
      onPressed = isProcessing ? null : onAcceptInvite;
    } else if (isPending) {
      label = "بانتظار موافقة الإدارة";
      icon = Icons.hourglass_top_rounded;
      backgroundColor = AppColors.darkSoft;
      onPressed = null;
    } else if (isPrivate) {
      label = "طلب الانضمام";
      icon = Icons.person_add_alt_1_rounded;
      backgroundColor = AppColors.primary;
      onPressed = isProcessing ? null : onJoin;
    } else {
      label = "انضم إلى المنظمة";
      icon = Icons.group_add_rounded;
      backgroundColor = AppColors.primary;
      onPressed = isProcessing ? null : onJoin;
    }

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          elevation: 0,
          minimumSize: const Size.fromHeight(58),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _InviteNoticeCard extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onAccept;

  const _InviteNoticeCard({required this.isProcessing, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لديك دعوة لهذه المنظمة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يمكنك قبول الدعوة والانضمام مباشرة.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: isProcessing ? null : onAccept,
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String slug;
  const _FeatureCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _coverPlaceholder() {
  return Container(
    height: 220,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primary.withValues(alpha: .65)],
      ),
    ),
    child: const Center(
      child: Icon(Icons.apartment_rounded, color: Colors.white, size: 60),
    ),
  );
}

Widget _roundIconButton({required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.dark),
    ),
  );
}
