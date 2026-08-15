import 'package:flutter/material.dart';

class CourseSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const CourseSectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colors.onSurface),
        ),
      ],
    );
  }
}