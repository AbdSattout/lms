import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/error_retry_card.dart';
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
import '../../../organizations/presentation/pages/organization_details_page.dart';
import '../widgets/course_learning_content.dart';

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
            if (state is CourseDetailsActionError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is CourseDetailsError) {
               Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorRetryCard(
                  message: state.message,
                  onRetry: () => context.read<CourseDetailsBloc>().add(RetryCourseDetailsEvent()),
                ),t 
              );
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
                key: ValueKey(state.course.id),
                course: state.course,
                onEnroll: () => context.read<CourseDetailsBloc>().add(
                  EnrollEvent(state.course.id),
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

class _CourseDetailsContent extends StatefulWidget {
  final CourseEntity course;
  final VoidCallback onEnroll;

  const _CourseDetailsContent({
    super.key,
    required this.course,
    required this.onEnroll,
  });

  @override
  State<_CourseDetailsContent> createState() => _CourseDetailsContentState();
}

class _CourseDetailsContentState extends State<_CourseDetailsContent> {
  final GlobalKey _learningSectionKey = GlobalKey();

  CourseEntity get course => widget.course;

  VoidCallback get onEnroll => widget.onEnroll;

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
                        onContinue: () =>
                            _scrollToLearningSection(context),
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
                    if (isEnrolled) ...[
                      KeyedSubtree(
                        key: _learningSectionKey,
                        child: CourseLearningContent(
                          key: ValueKey(
                            'learning-${course.enrollment?.placementTestCompleted ?? false}',
                          ),
                          course: course,
                        ),
                      ),
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

  void _scrollToLearningSection(BuildContext context) {
    final target = _learningSectionKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  Widget _buildCta(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEnrolled = course.enrollment != null;
    final placementTestCompleted =
        course.enrollment?.placementTestCompleted ?? false;
    final detailsState = context.read<CourseDetailsBloc>().state;
    final isStartingCourse =
        detailsState is CourseDetailsLoaded && detailsState.isStartingCourse;
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

    if (isReadyForFinalQuiz) {
      return ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => FinalExamPage(courseId: course.id),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.emoji_events_rounded, size: 18),
        label: const Text(
          'الذهاب للاختبار النهائي',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isStartingCourse
          ? null
          : placementTestCompleted
          ? () => _scrollToLearningSection(context)
          : () {
              context.read<CourseDetailsBloc>().add(
                StartCourseEvent(course.id),
              );
              _scrollToLearningSection(context);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          : Icon(
              placementTestCompleted
                  ? Icons.menu_book_rounded
                  : Icons.play_circle_fill_rounded,
              size: 18,
            ),
      label: Text(
        isStartingCourse
            ? 'جارٍ بدء الكورس...'
            : placementTestCompleted
            ? 'متابعة التعلم • ${progressPercentage.toStringAsFixed(0)}٪'
            : 'ابدأ الكورس',
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
