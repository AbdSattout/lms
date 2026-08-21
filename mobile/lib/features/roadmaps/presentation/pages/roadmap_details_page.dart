import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/pages/course_details_page.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../bloc/roadmap_bloc.dart';
import '../bloc/roadmap_event.dart';
import '../bloc/roadmap_state.dart';

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
          appBar: AppBar(title: const Text('تفاصيل المسار')),
          body: BlocConsumer<RoadmapBloc, RoadmapState>(
            listener: (context, state) {
              if (state is RoadmapError) {
                AppToast.show(
                  context,
                  type: ToastType.error,
                  title: 'تعذر تحميل تفاصيل المسار',
                  message: state.message,
                );              }
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
  final dynamic roadmap;
  final String slug;
  final bool isProcessing;
  const _RoadmapDetailsContent({required this.roadmap, required this.slug, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isFollowing = roadmap.followStatus == 'ACTIVE';

    final org = roadmap.organization;
    final isMember = org?.viewerJoined == true;

    final items = roadmap.items as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(roadmap.name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)),
        const SizedBox(height: 8),
        if (org != null)
          GestureDetector(
            onTap: () => _navigateToOrganization(context),
            child: Row(children: [
              Icon(Icons.apartment_rounded, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Text(org.name, style: TextStyle(fontSize: 13, color: colors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        const SizedBox(height: 16),
        if (roadmap.description.isNotEmpty) ...[
          Text(roadmap.description, style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant, height: 1.6)),
          const SizedBox(height: 20),
        ],

        _buildFollowCTA(context, isMember: isMember, isFollowing: isFollowing, isProcessing: isProcessing),
        const SizedBox(height: 28),

        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.menu_book_rounded, size: 18, color: colors.primary)),
          const SizedBox(width: 10),
          Text('كورسات المسار', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('${items.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: colors.primary))),
        ]),
        const SizedBox(height: 16),

        ...items.map((item) => _RoadmapCourseTile(
          position: item.position,
          course: item.course,
          isMember: isMember,
          slug: slug,
          onNavigateToOrg: () => _navigateToOrganization(context),
        )),
      ]),
    );
  }

  void _navigateToOrganization(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<OrganizationDetailsBloc>()..add(GetOrganizationDetailsEvent(slug)),
          child: OrganizationDetailsPage(slug: slug),
        ),
      ),
    );
  }

  Widget _buildFollowCTA(BuildContext context, {required bool isMember, required bool isFollowing, required bool isProcessing}) {
    final colors = Theme.of(context).colorScheme;

    if (!isMember) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.primary.withOpacity(0.15))),
        child: Row(children: [
          Icon(Icons.lock_outline_rounded, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text('انضم إلى المنظمة لمتابعة هذا المسار', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.onSurface))),
          const SizedBox(width: 10),
          OutlinedButton(onPressed: () => _navigateToOrganization(context), child: const Text('عرض المنظمة')),
        ]),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : () {
          if (isFollowing) {
            context.read<RoadmapBloc>().add(UnfollowRoadmapRequested(slug: slug, roadmapId: roadmap.id));
          } else {
            context.read<RoadmapBloc>().add(FollowRoadmapRequested(slug: slug, roadmapId: roadmap.id));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? const Color(0xffD9534F) : colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: isProcessing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(isFollowing ? Icons.close_rounded : Icons.add_rounded, color: Colors.white),
        label: Text(isFollowing ? 'إلغاء المتابعة' : 'متابعة المسار', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class _RoadmapCourseTile extends StatelessWidget {
  final int position;
  final dynamic course;
  final bool isMember;
  final String slug;
  final VoidCallback onNavigateToOrg;

  const _RoadmapCourseTile({
    required this.position,
    required this.course,
    required this.isMember,
    required this.slug,
    required this.onNavigateToOrg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasCover = course.coverUrl != null && course.coverUrl.toString().isNotEmpty;
    final isEnrolled = course.enrollment != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () {
          if (!isMember) {
            _showMembershipRequiredDialog(context);
            return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(
            create: (_) => sl<CourseDetailsBloc>()..add(GetCourseDetailsEvent(orgSlug: slug, courseSlug: course.slug)),
            child: const CourseDetailsPage(),
          )));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isEnrolled ? const Color(0xff2E7D53).withOpacity(0.1) : colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isEnrolled
                    ? const Icon(Icons.check_rounded, color: Color(0xff2E7D53), size: 22)
                    : Text(position.toString().padLeft(2, '0'), style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.primaryLight),
              clipBehavior: Clip.antiAlias,
              child: hasCover ? Image.network(course.coverUrl.toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.menu_book_rounded, color: colors.primary)) : Icon(Icons.menu_book_rounded, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(course.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: colors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (!isMember) Text('يتطلب عضوية المنظمة', style: TextStyle(fontSize: 11, color: colors.error)),
              ]),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colors.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }

  void _showMembershipRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('عضوية المنظمة مطلوبة'),
          content: const Text('للوصول إلى محتوى هذا الكورس يجب أولاً الانضمام إلى المنظمة.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onNavigateToOrg();
              },
              child: const Text('عرض المنظمة'),
            ),
          ],
        ),
      ),
    );
  }
}