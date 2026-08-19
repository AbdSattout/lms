import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/certificate_entity.dart';

class CertificateCard extends StatelessWidget {
  final CertificateEntity certificate;

  const CertificateCard({super.key, required this.certificate});

  String get _gradeLabel {
    return switch (certificate.grade?.toUpperCase()) {
      'A' || 'A+' => 'ممتاز',
      'B' || 'B+' => 'جيد جداً',
      'C' || 'C+' => 'جيد',
      'D' || 'D+' => 'مقبول',
      _ => certificate.grade ?? '—',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xffF2C94C).withOpacity(0.12),
            const Color(0xff2E7D53).withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffF2C94C).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xffF2C94C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Color(0xffB7791F), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(certificate.courseName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colors.onSurface)),
                    if (certificate.organizationName != null) ...[
                      const SizedBox(height: 2),
                      Text(certificate.organizationName!, style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'الدرجة',
                  value: _gradeLabel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  label: 'النسبة',
                  value: '${certificate.finalQuizPercentage}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoChip(
                  label: 'النتيجة',
                  value: '${certificate.finalQuizScore}/${certificate.finalQuizTotal}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.code_rounded, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    certificate.certificateCode,
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant, fontFamily: 'monospace'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xffB7791F))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}