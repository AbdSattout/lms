import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CertificatePreviewImage extends StatelessWidget {
  final String? previewUrl;

  const CertificatePreviewImage({super.key, required this.previewUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (previewUrl == null || previewUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 36, color: colors.onSurfaceVariant),
              const SizedBox(height: 8),
              Text('معاينة الشهادة غير متاحة', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          previewUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            color: colors.surfaceContainerHighest,
            child: Center(
              child: Icon(Icons.broken_image_outlined, size: 36, color: colors.onSurfaceVariant),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: colors.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}