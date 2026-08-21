import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/certificate_entity.dart';
import '../pages/certificate_viewer_page.dart';
import 'certificate_preview_image.dart';

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

  Future<void> _openPdf(BuildContext context) async {
    if (!certificate.hasPdf) return;

    final uri = Uri.parse(certificate.pdfUrl!);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        AppToast.show(
          context,
          type: ToastType.error,
          message: 'تعذر تحميل الملف',
        );
      }
    }
  }

  void _openViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CertificateViewerPage(certificate: certificate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Certificate image
          GestureDetector(
            onTap: () => _openViewer(context),
            child: CertificatePreviewImage(previewUrl: certificate.previewUrl),
          ),
          const SizedBox(height: 14),
          // Course + Organization
          Row(
            children: [
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xffF2C94C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${certificate.finalQuizPercentage}% · $_gradeLabel',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xffB7791F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Code
          Row(
            children: [
              Icon(Icons.code_rounded, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 4),
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
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openViewer(context),
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('عرض الشهادة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (certificate.hasPdf) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPdf(context),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('تحميل PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff2E7D53),
                      side: BorderSide(color: const Color(0xff2E7D53).withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}