import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/course_entity.dart';
import 'course_level_badge.dart';
import 'course_meta_chip.dart';

class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEnrolled = course.enrollment != null;
    final isCompleted = course.isCompleted;
    final progressPercentage = course.enrollment?.progressPercentage ?? 0;
    final hasCover = course.coverUrl != null && course.coverUrl!.isNotEmpty;
    final orgName = course.organization?.name ?? course.organizationName;
    final orgImage = course.organization?.image;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          splashColor: colors.primary.withOpacity(0.06),
          highlightColor: colors.primary.withOpacity(0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourseCover(
                  course: course,
                  hasCover: hasCover,
                  isCompleted: isCompleted,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (orgName != null) _OrganizationRow(name: orgName, image: orgImage),
                      const SizedBox(height: 12),
                      if (course.level != null || course.completionXp != null || course.chaptersCount != null)
                        _MetaRow(course: course),
                      if (isEnrolled) ...[
                        const SizedBox(height: 14),
                        _ProgressSection(progress: progressPercentage, isCompleted: isCompleted),
                      ] else ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'استكشف الكورس',
                              style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: colors.primary),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCover extends StatelessWidget {
  final CourseEntity course;
  final bool hasCover;
  final bool isCompleted;

  const _CourseCover({required this.course, required this.hasCover, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: hasCover
              ? Image.network(
            course.coverUrl!,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _placeholder(showLoading: true);
            },
          )
              : _placeholder(),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                stops: const [0.6, 1],
              ),
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xff2E7D53),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text('مكتملة', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
        if (course.level != null)
          Positioned(
            top: 12,
            right: 12,
            child: CourseLevelBadge(level: course.level!),
          ),
      ],
    );
  }

  Widget _placeholder({bool showLoading = false}) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)]),
      ),
      child: Center(
        child: showLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}

class _OrganizationRow extends StatelessWidget {
  final String name;
  final String? image;

  const _OrganizationRow({required this.name, this.image});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasImage = image != null && image!.isNotEmpty;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), color: colors.surfaceContainerHighest),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Image.network(image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.apartment_rounded, size: 12, color: colors.onSurfaceVariant))
              : Icon(Icons.apartment_rounded, size: 12, color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final CourseEntity course;

  const _MetaRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final xp = course.completionXp;
    final chapters = course.chaptersCount;
    final level = course.level;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (level != null) CourseLevelBadge(level: level),
        if (xp != null) CourseMetaChip(icon: Icons.bolt_rounded, label: '+$xp XP', color: const Color(0xffB4780F)),
        if (chapters != null) CourseMetaChip(icon: Icons.menu_book_rounded, label: chapters == 1 ? 'فصل واحد' : '$chapters فصول', color: colors.primary),
      ],
    );
  }
}


class _ProgressSection extends StatelessWidget {
  final double progress;
  final bool isCompleted;

  const _ProgressSection({required this.progress, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('التقدم', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.onSurfaceVariant)),
            Text(
              isCompleted ? '100%' : '${progress.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isCompleted ? const Color(0xff2E7D53) : colors.primary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (progress / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(isCompleted ? const Color(0xff2E7D53) : colors.primary),
          ),
        ),
      ],
    );
  }
}