import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/organization_entity.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_details_state.dart';

class OrganizationDetailsPage extends StatelessWidget {
  // FIX: takes the slug now, not a static OrganizationEntity — page
  // always fetches fresh state on open (per the agreed architecture:
  // no local/passed-in flags), so it can't show a stale Join/Leave
  // button if something changed since the last time it was open (e.g.
  // an admin approved a pending request elsewhere).
  final String slug;

  const OrganizationDetailsPage({
    super.key,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<OrganizationDetailsBloc, OrganizationDetailsState>(
          listenWhen: (previous, current) =>
          current is OrganizationDetailsError || current is OrganizationDeleted,
          listener: (context, state) {
            if (state is OrganizationDetailsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }

            if (state is OrganizationDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف المنظمة')),
              );
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
                          context
                              .read<OrganizationDetailsBloc>()
                              .add(GetOrganizationDetailsEvent(slug));
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
                organization: state.organization,
                isProcessing: state.isProcessing,
                onJoin: () {
                  context
                      .read<OrganizationDetailsBloc>()
                      .add(JoinOrganizationEvent(slug));
                },
                onLeave: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('مغادرة المنظمة'),
                      content: const Text('هل أنت متأكد من مغادرة هذه المنظمة؟'),
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
                    context
                        .read<OrganizationDetailsBloc>()
                        .add(LeaveOrganizationEvent(slug));
                  }
                },
                onCancelRequest: () {
                  context
                      .read<OrganizationDetailsBloc>()
                      .add(CancelJoinRequestEvent(slug));
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
                    context
                        .read<OrganizationDetailsBloc>()
                        .add(DeleteOrganizationEvent(slug));
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
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onCancelRequest;
  final VoidCallback onDelete;

  const _OrganizationDetailsContent({
    required this.organization,
    required this.isProcessing,
    required this.onJoin,
    required this.onLeave,
    required this.onCancelRequest,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage =
        organization.image != null && organization.image!.isNotEmpty;

    final isMember = organization.viewerJoined;
    final isOwner = organization.viewerRole == 'OWNER';
    final isPrivate = organization.visibility == OrganizationVisibility.private;
    final isPending = organization.joinRequestStatus == 'PENDING';

    final visibility = switch (organization.visibility) {
      OrganizationVisibility.public => "عامة",
      OrganizationVisibility.private => "خاصة",
      _ => "غير معروف",
    };

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
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
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        visibility,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
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
                    Text(
                      organization.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colors.onSurface,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (organization.description != null &&
                        organization.description!.trim().isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "عن المنظمة",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
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
                            color: colors.onSurfaceVariant,
                            fontSize: 13.5,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.people_alt_rounded,
                            iconColor: AppColors.primary,
                            iconBg: AppColors.primaryLight,
                            label: "الأعضاء",
                            value: organization.membersCount.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: organization.visibility == OrganizationVisibility.public
                                ? Icons.public_rounded
                                : Icons.lock_rounded,
                            iconColor: organization.visibility == OrganizationVisibility.public
                                ? const Color(0xff2E7D53)
                                : const Color(0xffB4780F),
                            iconBg: organization.visibility == OrganizationVisibility.public
                                ? AppColors.mint.withOpacity(.45)
                                : AppColors.peach.withOpacity(.45),
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
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: AppColors.primary,
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
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _membershipButton(
                  isMember: isMember,
                  isOwner: isOwner,
                  isPrivate: isPrivate,
                  isPending: isPending,
                  isProcessing: isProcessing,
                  onJoin: onJoin,
                  onLeave: onLeave,
                  onDelete: onDelete,
                ),

                // Owners can't have a pending request on their own org —
                // this only ever applies to non-owner, non-member users.
                if (isPending && !isMember && !isOwner) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : onCancelRequest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffD9534F),
                        side: const BorderSide(color: Color(0xffD9534F)),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text("إلغاء الطلب"),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('منشورات المنظمة قريباً')),
                      );
                    },
                    icon: const Icon(Icons.campaign_outlined, size: 18),
                    label: const Text("منشورات المنظمة"),
                  ),
                ),
              ],
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
    required bool isProcessing,
    required VoidCallback onJoin,
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
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: isProcessing
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
        )
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
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

Widget _coverPlaceholder() {
  return Container(
    height: 220,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primary.withOpacity(.65)],
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
        color: Colors.white.withOpacity(.85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.dark),
    ),
  );
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
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: colors.onSurface)),
        ],
      ),
    );
  }
}