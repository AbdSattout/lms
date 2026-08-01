import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/organization_entity.dart';
import '../bloc/organization_details_bloc.dart';
import '../bloc/organization_details_event.dart';
import '../bloc/organization_details_state.dart';

class OrganizationDetailsPage extends StatelessWidget {
  final String slug;

  const OrganizationDetailsPage({
    super.key,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrganizationDetailsBloc>()
        ..add(GetOrganizationDetailsEvent(slug)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocConsumer<OrganizationDetailsBloc, OrganizationDetailsState>(
            listener: (context, state) {
              if (state is OrganizationDetailsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
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
                  organization: state.organization,
                  isProcessing: state.isProcessing,
                  onJoin: () {
                    context.read<OrganizationDetailsBloc>().add(
                      JoinOrganizationEvent(slug),
                    );
                  },
                  onLeave: () {
                    context.read<OrganizationDetailsBloc>().add(
                      LeaveOrganizationEvent(slug),
                    );
                  },
                  onCancelRequest: () {
                    context.read<OrganizationDetailsBloc>().add(
                      CancelJoinRequestEvent(slug),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
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

  const _OrganizationDetailsContent({
    required this.organization,
    required this.isProcessing,
    required this.onJoin,
    required this.onLeave,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage =
        organization.image != null && organization.image!.isNotEmpty;

    final joined = organization.viewerJoined;
    final joinStatus = organization.joinRequestStatus;
    final isPrivate = organization.visibility == OrganizationVisibility.private;

    final visibility = switch (organization.visibility) {
      OrganizationVisibility.public => "عامة",
      OrganizationVisibility.private => "خاصة",
      _ => "غير معروف",
    };

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 130),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
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
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
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
                            icon: isPrivate
                                ? Icons.lock_rounded
                                : Icons.public_rounded,
                            iconColor: isPrivate
                                ? const Color(0xffB4780F)
                                : const Color(0xff2E7D53),
                            iconBg: isPrivate
                                ? AppColors.peach.withOpacity(.45)
                                : AppColors.mint.withOpacity(.45),
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
          bottom: 1,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing
                        ? null
                        : _getPrimaryAction(
                      joined: joined,
                      joinStatus: joinStatus,
                      isPrivate: isPrivate,
                      onJoin: onJoin,
                      onLeave: onLeave,
                      onCancelRequest: onCancelRequest,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      _getPrimaryIcon(joined: joined, joinStatus: joinStatus),
                      color: Colors.white,
                    ),
                    label: Text(
                      _getPrimaryLabel(joined: joined, joinStatus: joinStatus),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('منشورات المنظمة قريباً'),
                        ),
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
}

VoidCallback? _getPrimaryAction({
  required bool joined,
  required String? joinStatus,
  required bool isPrivate,
  required VoidCallback onJoin,
  required VoidCallback onLeave,
  required VoidCallback onCancelRequest,
}) {
  if (joined) return onLeave;
  if (joinStatus == 'PENDING') return onCancelRequest;
  return onJoin;
}

IconData _getPrimaryIcon({
  required bool joined,
  required String? joinStatus,
}) {
  if (joined) return Icons.logout_rounded;
  if (joinStatus == 'PENDING') return Icons.close_rounded;
  return Icons.group_add_rounded;
}

String _getPrimaryLabel({
  required bool joined,
  required String? joinStatus,
}) {
  if (joined) return 'مغادرة المنظمة';
  if (joinStatus == 'PENDING') return 'إلغاء الطلب';
  return 'انضم إلى المنظمة';
}
Widget _coverPlaceholder() {
  return Container(
    height: 220,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(.65),
        ],
      ),
    ),
    child: const Center(
      child: Icon(Icons.apartment_rounded, color: Colors.white, size: 60),
    ),
  );
}

Widget _roundIconButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
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