import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/widgets/course_progress_bar.dart';
import '../../domain/entities/roadmap_entity.dart';

class RoadmapCard extends StatelessWidget {
  final RoadmapEntity roadmap;
  final VoidCallback onTap;
  final bool showProgress;

  const RoadmapCard({
    super.key,
    required this.roadmap,
    required this.onTap,
    this.showProgress = false,
  });

  int get _completedCourses => roadmap.items
      .where((item) => item.course.isCompleted)
      .length;

  int get _enrolledCourses => roadmap.items
      .where((item) => item.course.enrollment != null && !item.course.isCompleted)
      .length;

  int get _totalCourses => roadmap.items.length;

  double get _roadmapProgress => _totalCourses == 0
      ? 0
      : (_completedCourses / _totalCourses) * 100;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
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
                      child: Icon(
                        Icons.map_outlined,
                        color: colors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roadmap.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                            ),
                          ),
                          if (roadmap.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              roadmap.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalCourses ${_totalCourses == 1 ? 'كورس' : 'كورسات'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                    if (roadmap.isFollowing) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff2E7D53).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'متابَع',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff2E7D53),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (showProgress && _totalCourses > 0) ...[
                  const SizedBox(height: 12),
                  CourseProgressCard(
                    progress: _roadmapProgress,
                    isCompleted: _completedCourses == _totalCourses &&
                        _totalCourses > 0,
                    onContinue: onTap,
                  ),
                ],

                if (showProgress && _enrolledCourses > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$_enrolledCourses ${_enrolledCourses == 1 ? 'كورس قيد التقدم' : 'كورسات قيد التقدم'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}