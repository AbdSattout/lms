import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../assessments/final_exam/presentation/pages/final_exam_page.dart';
import '../../../organizations/presentation/bloc/organization_details_bloc.dart';
import '../../../organizations/presentation/bloc/organization_details_event.dart';
import '../../../reports/domain/entities/report_target.dart';
import '../../../reports/presentation/widgets/report_bottom_sheet.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course_details_bloc.dart';
import '../bloc/course_details_event.dart';
import '../bloc/course_details_state.dart';
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
              current is CourseStartSuccess ||
              current is CourseDetailsActionError ||
              (current is CourseDetailsError &&
                  previous is CourseDetailsLoading),
          listener: (context, state) async {
            if (state is CourseEnrollSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تسجيلك في "${state.result.courseTitle}"'),
                ),
              );
            }
            if (state is CourseStartSuccess) {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseContentsPage(course: state.course),
                ),
              );
              if (context.mounted) {
                final orgSlug = state.course.organization?.slug;
                context.read<CourseDetailsBloc>().add(
                  orgSlug != null && orgSlug.isNotEmpty
                      ? GetCourseDetailsEvent(
                          orgSlug: orgSlug,
                          courseSlug: state.course.slug,
                        )
                      : GetCourseDetailsEvent(id: state.course.id),
                );
              }
              return;
            }
            if (state is CourseDetailsActionError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is CourseDetailsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          buildWhen: (previous, current) =>
              current is CourseDetailsLoading ||
              current is CourseDetailsLoaded ||
              (current is CourseDetailsError &&
                  previous is! CourseDetailsLoaded),
          builder: (context, state) {
            if (state is CourseDetailsLoading ||
                state is CourseDetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CourseDetailsError) {
              return Center(
                child: Text(state.message, textAlign: TextAlign.center),
              );
            }
            if (state is CourseDetailsLoaded) {
              return _CourseDetailsContent(
                course: state.course,
                isStartingCourse: state.isStartingCourse,
                onEnroll: () => context.read<CourseDetailsBloc>().add(
                  EnrollEvent(state.course.id),
                ),
                onStartCourse: () => context.read<CourseDetailsBloc>().add(
                  StartCourseEvent(state.course.id),
                ),
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
  final VoidCallback onStartCourse;
  final bool isStartingCourse;

  const _CourseDetailsContent({
    required this.course,
    required this.onEnroll,
    required this.onStartCourse,
    required this.isStartingCourse,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEnrolled = course.enrollment != null;
    final progressPercentage = course.learningProgressPercentage;
    final isCompleted = course.isCompleted;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;
    final hasOrgImage =
        course.organization?.image != null &&
        course.organization!.image!.isNotEmpty;

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
                onReport: course.organization == null
                    ? null
                    : () {
                        showReportBottomSheet(
                          context,
                          ReportTarget.course(
                            courseId: course.id,
                            organizationId: course.organization!.id,
                            title: course.title,
                          ),
                        );
                      },
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
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CourseContentsPage(course: course),
                            ),
                          );
                          if (context.mounted) {
                            context.read<CourseDetailsBloc>().add(
                              GetCourseDetailsEvent(
                                orgSlug: course.organization?.slug ?? '',
                                courseSlug: course.slug,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (course.description != null &&
                        course.description!.isNotEmpty) ...[
                      const CourseSectionHeader(
                        icon: Icons.info_outline_rounded,
                        title: 'عن الكورس',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: _cardDecoration(colors),
                        child: Text(
                          course.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (course.organization != null) ...[
                      const CourseSectionHeader(
                        icon: Icons.apartment_rounded,
                        title: 'المنظمة',
                      ),
                      const SizedBox(height: 10),
                      CourseOrganizationCard(
                        organization: course.organization!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) =>
                                    sl<OrganizationDetailsBloc>()..add(
                                      GetOrganizationDetailsEvent(
                                        course.organization!.slug,
                                      ),
                                    ),
                                child: OrganizationDetailsPage(
                                  slug: course.organization!.slug,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
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
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: _buildCta(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCta(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEnrolled = course.enrollment != null;
    final placementTestCompleted =
        course.enrollment?.placementTestCompleted ?? false;
    final viewerRole = course.organization?.viewerRole;
    final isOwner = viewerRole == 'OWNER';
    final viewerJoined = course.organization?.viewerJoined;
    final isBlockedByMembership =
        !isEnrolled && viewerJoined == false && !isOwner;
    final progressPercentage = course.learningProgressPercentage;
    final isCompleted = course.isCompleted;
    final isReadyForFinalQuiz = course.isReadyForFinalQuiz;

    if (isOwner) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.surfaceContainerHighest,
          foregroundColor: colors.onSurfaceVariant,
          disabledBackgroundColor: colors.surfaceContainerHighest,
          disabledForegroundColor: colors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.admin_panel_settings_rounded),
        label: const Text('أنت مالك المنظمة'),
      );
    }

    if (isBlockedByMembership) {
      return ElevatedButton.icon(
        onPressed: () => _showMembershipRequiredDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.apartment_rounded, size: 18),
        label: const Text('عرض المنظمة'),
      );
    }

    if (!isEnrolled) {
      return ElevatedButton.icon(
        onPressed: onEnroll,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.rocket_launch_rounded, size: 18),
        label: const Text('سجّل الآن'),
      );
    }

    if (!placementTestCompleted) {
      return ElevatedButton.icon(
        onPressed: isStartingCourse ? null : onStartCourse,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: isStartingCourse
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
            : const Icon(Icons.play_circle_fill_rounded, size: 18),
        label: Text(
          isStartingCourse ? 'جارٍ بدء الكورس...' : 'ابدأ الكورس',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    if (isCompleted) {
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: const Color(
            0xff2E7D53,
          ).withValues(alpha: 0.12),
          disabledForegroundColor: const Color(0xff2E7D53),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.check_circle_rounded, size: 18),
        label: const Text(
          'مكتملة بالكامل',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () async {
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => isReadyForFinalQuiz
                ? FinalExamPage(courseId: course.id)
                : CourseContentsPage(course: course),
          ),
        );
        if (context.mounted) {
          context.read<CourseDetailsBloc>().add(
            GetCourseDetailsEvent(
              orgSlug: course.organization?.slug ?? '',
              courseSlug: course.slug,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      icon: Icon(
        isReadyForFinalQuiz
            ? Icons.emoji_events_rounded
            : Icons.play_circle_fill_rounded,
        size: 18,
      ),
      label: Text(
        isReadyForFinalQuiz
            ? 'الذهاب للاختبار النهائي'
            : 'متابعة التعلم • ${progressPercentage.toStringAsFixed(0)}٪',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
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
          content: Text(
            course.organizationDisplayName != null
                ? 'التسجيل في هذا الكورس يتطلب أن تكون عضواً في "${course.organizationDisplayName}".'
                : 'التسجيل في هذا الكورس يتطلب عضوية المنظمة المالكة له.',
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 10),
                if (orgSlug.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) =>
                                  sl<OrganizationDetailsBloc>()
                                    ..add(GetOrganizationDetailsEvent(orgSlug)),
                              child: OrganizationDetailsPage(slug: orgSlug),
                            ),
                          ),
                        );
                        if (context.mounted) {
                          context.read<CourseDetailsBloc>().add(
                            GetCourseDetailsEvent(
                              orgSlug: orgSlug,
                              courseSlug: course.slug,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.apartment_rounded, size: 18),
                      label: const Text('عرض المنظمة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
    );
  }
}
