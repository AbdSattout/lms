import 'package:flutter/material.dart';

class CourseProgressCard extends StatelessWidget {
  final double progress;
  final bool isCompleted;
  final VoidCallback onContinue;

  const CourseProgressCard({
    super.key,
    required this.progress,
    required this.isCompleted,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompleted ? 'مكتمل 🎉' : 'تقدمك في الكورس',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
              ),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(isCompleted ? const Color(0xff2E7D53) : colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}