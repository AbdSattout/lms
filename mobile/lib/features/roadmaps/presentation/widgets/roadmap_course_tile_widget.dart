import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/domain/entities/course_entity.dart';
import '../../../courses/presentation/bloc/course_details_bloc.dart';
import '../../../courses/presentation/bloc/course_details_event.dart';
import '../../../courses/presentation/pages/course_details_page.dart';

class RoadmapCourseTile extends StatelessWidget {
  final int position;
  final CourseEntity course;
  final bool isMember;
  final String slug;
  final bool isLast;
  final VoidCallback onNavigateToOrg;

  const RoadmapCourseTile({
    super.key,
    required this.position,
    required this.course,
    required this.isMember,
    required this.slug,
    required this.isLast,
    required this.onNavigateToOrg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;

    final isCompleted = course.isCompleted;
    final isEnrolled = course.enrollment != null;
    final progress = course.learningProgressPercentage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline connector
        SizedBox(
          width: 44,
          child: Column(
            children: [
              _StatusNode(
                isCompleted: isCompleted,
                isEnrolled: isEnrolled,
                position: position,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: isCompleted
                      ? const Color(0xff2E7D53).withOpacity(0.3)
                      : colors.outlineVariant.withOpacity(0.4),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Course content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xff2E7D53).withOpacity(0.3)
                    : isEnrolled
                    ? colors.primary.withOpacity(0.25)
                    : colors.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleTap(context),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover image
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primaryLight,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: hasCover
                              ? Image.network(
                            course.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.menu_book_rounded,
                              color: colors.primary,
                            ),
                          )
                              : Icon(Icons.menu_book_rounded, color: colors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (course.completionXp != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 13, color: const Color(0xffB4780F)),
                                    const SizedBox(width: 3),
                                    Text(
                                      '+${course.completionXp} XP',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xffB4780F),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Status section
                    if (isCompleted)
                      _CompletedStatus()
                    else if (isEnrolled)
                      _ProgressStatus(progress: progress)
                    else
                      _NotEnrolledStatus(isMember: isMember),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context) {
    if (!isMember) {
      _showMembershipRequiredDialog(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<CourseDetailsBloc>()
            ..add(GetCourseDetailsEvent(orgSlug: slug, courseSlug: course.slug)),
          child: const CourseDetailsPage(),
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

class _StatusNode extends StatelessWidget {
  final bool isCompleted;
  final bool isEnrolled;
  final int position;

  const _StatusNode({
    required this.isCompleted,
    required this.isEnrolled,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isCompleted) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xff2E7D53),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2E7D53).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
      );
    }

    if (isEnrolled) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            position.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: colors.outlineVariant, width: 1.5),
      ),
      child: Center(
        child: Text(
          position.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: colors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CompletedStatus extends StatelessWidget {
  const _CompletedStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff2E7D53).withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xff2E7D53)),
          const SizedBox(width: 6),
          Text(
            'مكتمل',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xff2E7D53),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStatus extends StatelessWidget {
  final double progress;

  const _ProgressStatus({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'قيد التعلم',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.primary),
            ),
            const Spacer(),
            Text(
              '${progress.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 6,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      ],
    );
  }
}

class _NotEnrolledStatus extends StatelessWidget {
  final bool isMember;

  const _NotEnrolledStatus({required this.isMember});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.lock_outline_rounded, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          isMember ? 'غير مسجل — اضغط للبدء' : 'يتطلب عضوية المنظمة',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isMember ? colors.onSurfaceVariant : colors.error,
          ),
        ),
      ],
    );
  }
}