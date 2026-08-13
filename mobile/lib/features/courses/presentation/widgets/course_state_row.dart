import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';

class CourseStatsRow extends StatelessWidget {
  final CourseEntity course;
  const CourseStatsRow({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final level = course.level?.toUpperCase() ?? '—';
    final levelLabel = level == 'MEDIUM'
        ? 'متوسط'
        : level == 'EASY'
        ? 'سهل'
        : level == 'HARD'
        ? 'صعب'
        : '—';
    final xp = course.completionXp?.toString() ?? '—';
    final chapters = course.chaptersCount?.toString() ?? '—';

    return Row(
      children: [
        Expanded(child: _StatPill(icon: Icons.speed_rounded, label: 'المستوى', value: levelLabel)),
        const SizedBox(width: 10),
        Expanded(child: _StatPill(icon: Icons.bolt_rounded, label: 'XP', value: xp)),
        const SizedBox(width: 10),
        Expanded(child: _StatPill(icon: Icons.menu_book_rounded, label: 'الفصول', value: chapters)),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: colors.onSurface)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}