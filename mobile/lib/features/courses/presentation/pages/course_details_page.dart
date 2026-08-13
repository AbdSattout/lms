import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../organizations/domain/entities/organization_entity.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../posts/presentation/pages/course_posts_page.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_details_bloc.dart';
import '../bloc/course_details_event.dart';
import '../bloc/course_details_state.dart';
import '../widgets/course_feature_card.dart';
import '../widgets/course_hero_header.dart';
import '../widgets/course_organization_card.dart';
import '../widgets/course_progress_bar.dart';
import '../widgets/course_section_header.dart';
import '../widgets/course_state_row.dart';
import 'course_contents_page.dart';
import '../../../organizations/presentation/pages/organization_details_page.dart';

class CourseDetailsPage extends StatelessWidget {
  const CourseDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<CourseDetailsBloc, CourseDetailsState>(
          listenWhen: (previous, current) =>
          current is CourseEnrollSuccess ||
              (current is CourseDetailsError && previous is CourseDetailsLoading),
          listener: (context, state) {
            if (state is CourseEnrollSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تسجيلك في "${state.result.courseTitle}"')),
              );
            }
            if (state is CourseDetailsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          buildWhen: (previous, current) =>
          current is CourseDetailsLoading ||
              current is CourseDetailsLoaded ||
              (current is CourseDetailsError && previous is! CourseDetailsLoaded),
          builder: (context, state) {
            if (state is CourseDetailsLoading || state is CourseDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CourseDetailsError) {
              return Center(child: Text(state.message, textAlign: TextAlign.center));
            }
            if (state is CourseDetailsLoaded) {
              return _CourseDetailsContent(
                course: state.course,
                onEnroll: () => context.read<CourseDetailsBloc>().add(EnrollEvent(state.course.id)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _CourseDetailsContent extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onEnroll;

  const _CourseDetailsContent({required this.course, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnrolled = course.enrollment != null;
    final viewerJoined = course.organization?.viewerJoined;
    final viewerRole = course.organization?.viewerRole;
    final isOwner = viewerRole == 'OWNER';
    final isBlockedByMembership = !isEnrolled && viewerJoined == false && !isOwner;
    final progressPercentage = course.enrollment?.progressPercentage ?? 0;
    final isCompleted = course.isCompleted;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;
    final placementTestCompleted = course.enrollment?.placementTestCompleted ?? false;
    final hasOrgImage = course.organization?.image != null && course.organization!.image!.isNotEmpty;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseHeroHeader(
                course: course,
                hasCover: hasCover,
                hasOrgImage: hasOrgImage,
                onBack: () => Navigator.maybePop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseStatsRow(course: course),
                    const SizedBox(height: 24),
                    if (isEnrolled) ...[
                      CourseProgressCard(
                        progress: progressPercentage,
                        isCompleted: isCompleted,
                        onContinue: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseContentsPage(course: course)));
                          if (context.mounted) context.read<CourseDetailsBloc>().add(GetCourseDetailsEvent(orgSlug: course.organization?.slug ?? '', courseSlug: course.slug));
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (course.description != null && course.description!.isNotEmpty) ...[
                      const CourseSectionHeader(icon: Icons.info_outline_rounded, title: 'عن الكورس'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: _cardDecoration(colors),
                        child: Text(course.description!, style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.7)),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (course.organization != null) ...[
                      const CourseSectionHeader(icon: Icons.apartment_rounded, title: 'المنظمة'),
                      const SizedBox(height: 10),
                      CourseOrganizationCard(
                        organization: course.organization!,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(
                            create: (_) => sl<OrganizationDetailsBloc>()..add(GetOrganizationDetailsEvent(course.organization!.slug)),
                            child: OrganizationDetailsPage(slug: course.organization!.slug),
                          )));
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    const CourseSectionHeader(icon: Icons.groups_rounded, title: 'مجتمع الكورس'),
                    const SizedBox(height: 12),
                    CourseFeatureCard(icon: Icons.forum_outlined, iconBg: colors.primary.withOpacity(0.1), iconColor: colors.primary, title: 'منشورات الكورس', subtitle: 'مناقشات وإعلانات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoursePostsPage(courseId: course.id)))),
                    const SizedBox(height: 10),
                    CourseFeatureCard(icon: Icons.chat_bubble_outline_rounded, iconBg: const Color(0xff2E7D53).withOpacity(0.1), iconColor: const Color(0xff2E7D53), title: 'محادثة المجموعة', subtitle: 'تواصل مع زملائك', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('محادثة المجموعة قريباً')))),
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(color: colors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
            child: SafeArea(top: false, child: SizedBox(width: double.infinity, height: 54, child: _buildCta(context))),
          ),
        ),
      ],
    );
  }

  Widget _buildCta(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEnrolled = course.enrollment != null;
    final placementTestCompleted = course.enrollment?.placementTestCompleted ?? false;
    final viewerRole = course.organization?.viewerRole;
    final isOwner = viewerRole == 'OWNER';
    final viewerJoined = course.organization?.viewerJoined;
    final isBlockedByMembership = !isEnrolled && viewerJoined == false && !isOwner;
    final progressPercentage = course.enrollment?.progressPercentage ?? 0;
    final isCompleted = course.isCompleted;

    if (isOwner) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: colors.surfaceContainerHighest, foregroundColor: colors.onSurfaceVariant, disabledBackgroundColor: colors.surfaceContainerHighest, disabledForegroundColor: colors.onSurfaceVariant, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        icon: const Icon(Icons.admin_panel_settings_rounded),
        label: const Text('أنت مالك المنظمة'),
      );
    }

    if (isBlockedByMembership) {
      return ElevatedButton.icon(
        onPressed: () => _showMembershipRequiredDialog(context),
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        icon: const Icon(Icons.apartment_rounded, size: 18),
        label: const Text('عرض المنظمة'),
      );
    }

    if (!isEnrolled) {
      return ElevatedButton.icon(
        onPressed: onEnroll,
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        icon: const Icon(Icons.rocket_launch_rounded, size: 18),
        label: const Text('سجّل الآن'),
      );
    }

    if (!placementTestCompleted) {
      return ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseContentsPage(course: course)));
        },
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: colors.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        icon: const Icon(Icons.psychology_alt_rounded, size: 18),
        label: const Text('ابدأ اختبار تحديد المستوى'),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseContentsPage(course: course)));
        if (context.mounted) context.read<CourseDetailsBloc>().add(GetCourseDetailsEvent(orgSlug: course.organization?.slug ?? '', courseSlug: course.slug));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted ? const Color(0xff2E7D53) : colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: Icon(isCompleted ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded, size: 18),
      label: Text(isCompleted ? 'مكتملة بالكامل' : 'متابعة التعلم • ${progressPercentage.toStringAsFixed(0)}٪', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  void _showMembershipRequiredDialog(BuildContext context) {
    final orgSlug = course.organization?.slug ?? '';
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('يجب الانضمام إلى المنظمة أولاً'),
          content: Text(course.organizationDisplayName != null ? 'التسجيل في هذا الكورس يتطلب أن تكون عضواً في "${course.organizationDisplayName}".' : 'التسجيل في هذا الكورس يتطلب عضوية المنظمة المالكة له.'),
          actions: [
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء'))),
                const SizedBox(width: 10),
                if (orgSlug.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => sl<OrganizationDetailsBloc>()..add(GetOrganizationDetailsEvent(orgSlug)), child: OrganizationDetailsPage(slug: orgSlug))));
                        if (context.mounted) context.read<CourseDetailsBloc>().add(GetCourseDetailsEvent(orgSlug: orgSlug, courseSlug: course.slug));
                      },
                      icon: const Icon(Icons.apartment_rounded, size: 18),
                      label: const Text('عرض المنظمة'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
    );
  }
}

