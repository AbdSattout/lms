import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/certificate_entity.dart';

class CertificateViewerPage extends StatelessWidget {
  final CertificateEntity certificate;

  const CertificateViewerPage({super.key, required this.certificate});

  Future<void> _openPdf(BuildContext context) async {
    if (!certificate.hasPdf) return;

    final uri = Uri.parse(certificate.pdfUrl!);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح ملف PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('الشهادة', style: TextStyle(color: Colors.white)),
          actions: [
            if (certificate.hasPdf)
              IconButton(
                onPressed: () => _openPdf(context),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                tooltip: 'تحميل PDF',
              ),
          ],
        ),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: certificate.hasPreview
                ? Image.network(
              certificate.previewUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  'تعذر تحميل الشهادة',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            )
                : Center(
              child: Text(
                'معاينة الشهادة غير متاحة',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}