import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../../domain/entities/roadmap_entity.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';
import '../widgets/roadmap_course_tile_widget.dart';

class RoadmapDetailsPage extends StatelessWidget {
  final String slug;
  final int roadmapId;
  const RoadmapDetailsPage({super.key, required this.slug, required this.roadmapId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoadmapBloc>()..add(LoadRoadmapDetails(slug: slug, roadmapId: roadmapId)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocConsumer<RoadmapBloc, RoadmapState>(
            listener: (context, state) {
              if (state is RoadmapError) {
                AppToast.show(
                  context,
                  type: ToastType.error,
                  title: 'تعذر تحميل تفاصيل المسار',
                  message: state.message,
                );
              }
            },
            builder: (context, state) {
              if (state is RoadmapLoading || state is RoadmapInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is RoadmapError) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<RoadmapBloc>().add(LoadRoadmapDetails(slug: slug, roadmapId: roadmapId)),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ]),
                );
              }
              if (state is RoadmapDetailsLoaded) {
                return _RoadmapDetailsContent(
                  roadmap: state.roadmap,
                  slug: slug,
                  isProcessing: state.isProcessing,
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

class _RoadmapDetailsContent extends StatelessWidget {
  final RoadmapEntity roadmap;
  final String slug;
  final bool isProcessing;

  const _RoadmapDetailsContent({
    required this.roadmap,
    required this.slug,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final org = roadmap.organization;
    final isMember = org?.viewerJoined == true;
    final items = roadmap.items;

    final completedCount = items.where((item) => item.course.isCompleted).length;
    final enrolledCount = items.where((item) => item.course.enrollment != null && !item.course.isCompleted).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: colors.primaryContainer.withValues(alpha: 0.3),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(
                roadmap: roadmap,
                org: org,
                onOrgTap: () => _navigateToOrganization(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    totalCourses: items.length,
                    completedCount: completedCount,
                    enrolledCount: enrolledCount,
                  ),
                  const SizedBox(height: 20),
                  _buildFollowCTA(
                    context,
                    isMember: isMember,
                    isFollowing: roadmap.isFollowing,
                    isProcessing: isProcessing,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.menu_book_rounded, size: 18, color: colors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'كورسات المسار',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${items.length}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (items.isEmpty)
                    _EmptyPathState()
                  else
                    ...items.asMap().entries.map((entry) {
                      return RoadmapCourseTile(
                        position: entry.value.position,
                        course: entry.value.course,
                        isMember: isMember,
                        slug: slug,
                        isLast: entry.key == items.length - 1,
                        onNavigateToOrg: () => _navigateToOrganization(context),
                      );
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOrganization(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<OrganizationDetailsBloc>()
            ..add(GetOrganizationDetailsEvent(slug)),
          child: OrganizationDetailsPage(slug: slug),
        ),
      ),
    );
  }

  Widget _buildFollowCTA(
      BuildContext context, {
        required bool isMember,
        required bool isFollowing,
        required bool isProcessing,
      }) {
    final colors = Theme.of(context).colorScheme;

    if (!isMember) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primary.withOpacity(0.15)),
        ),
        child: Row(children: [
          Icon(Icons.lock_outline_rounded, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'انضم إلى المنظمة لمتابعة هذا المسار',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => _navigateToOrganization(context),
            child: const Text('عرض المنظمة'),
          ),
        ]),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isProcessing
            ? null
            : () {
          if (isFollowing) {
            context.read<RoadmapBloc>().add(
              UnfollowRoadmapRequested(slug: slug, roadmapId: roadmap.id),
            );
          } else {
            context.read<RoadmapBloc>().add(
              FollowRoadmapRequested(slug: slug, roadmapId: roadmap.id),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? const Color(0xffD9534F) : colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(isFollowing ? Icons.close_rounded : Icons.add_rounded, color: Colors.white),
        label: Text(
          isFollowing ? 'إلغاء المتابعة' : 'متابعة المسار',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final RoadmapEntity roadmap;
  final dynamic org;
  final VoidCallback onOrgTap;

  const _HeroHeader({
    required this.roadmap,
    required this.org,
    required this.onOrgTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  colors.secondaryContainer,
                  colors.primaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.map_outlined, color: colors.primary, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            roadmap.name,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              height: 1.2,
            ),
          ),
          if (roadmap.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              roadmap.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (org != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onOrgTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apartment_rounded, size: 14, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    org.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: colors.primary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int totalCourses;
  final int completedCount;
  final int enrolledCount;

  const _SummaryRow({
    required this.totalCourses,
    required this.completedCount,
    required this.enrolledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryChip(
            icon: Icons.menu_book_rounded,
            label: '$totalCourses كورس',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 6),  // Reduced spacing
        Expanded(
          child: _SummaryChip(
            icon: Icons.check_circle_rounded,
            label: '$completedCount مكتمل',
            color: const Color(0xff2E7D53),
          ),
        ),
        const SizedBox(width: 6),  // Reduced spacing
        Expanded(
          child: _SummaryChip(
            icon: Icons.trending_up_rounded,
            label: '$enrolledCount نشط',
            color: const Color(0xffB4780F),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _EmptyPathState extends StatelessWidget {
  const _EmptyPathState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.map_outlined, size: 56, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'لا توجد كورسات في هذا المسار بعد',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}