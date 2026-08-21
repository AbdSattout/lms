import 'package:flutter/material.dart';

import '../../domain/entities/course_entity.dart';

class CourseFaqSection extends StatelessWidget {
  final List<CourseFaqEntity> faqs;

  const CourseFaqSection({super.key, required this.faqs});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 13, color: colors.primary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'هذه الأسئلة مُولّدة بالذكاء الاصطناعي',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          ...faqs.map((faq) => _FaqTile(faq: faq)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final CourseFaqEntity faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        collapsedShape: const RoundedRectangleBorder(),
        shape: const RoundedRectangleBorder(),
        iconColor: colors.primary,
        collapsedIconColor: colors.onSurfaceVariant,
        title: Text(
          faq.question,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            height: 1.4,
          ),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              faq.answer,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
