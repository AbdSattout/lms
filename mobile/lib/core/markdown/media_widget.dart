import 'package:flutter/material.dart';
import '../databases/api/api_consumer.dart';
import '../databases/api/end_points.dart';
import '../services/injection_container.dart';
import '../media/video_player_widget.dart';
import 'media_reference.dart';
import 'package:url_launcher/url_launcher.dart';
class MediaWidget extends StatefulWidget {
  final MediaReference reference;
  const MediaWidget({super.key, required this.reference});

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  String? _url;
  String? _mediaType;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  Future<void> _fetchMedia() async {
    try {
      final api = sl<ApiConsumer>();
      final ref = widget.reference;

      final String path;
      if (ref.isCourseMedia) {
        path = EndPoints.courseMedia(ref.orgId, ref.courseId!, ref.mediaId);
      } else {
        path = EndPoints.postMedia(ref.orgId, ref.mediaId);
      }

      final response = await api.get(path);

      setState(() {
        _url = response['url'] as String?;
        _mediaType = response['type'] as String?;
        _loading = false;
      });
    } catch (e) {
      print('Media error: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loading) {
      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null || _url == null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.broken_image_outlined, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تعذر تحميل الوسائط',
                style: TextStyle(color: colors.error, fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    final type = _mediaType?.toUpperCase() ?? 'IMAGE';

    switch (type) {
      case 'IMAGE':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            _url!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant, size: 40),
              ),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
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
        );

      case 'VIDEO':
        return VideoPlayerWidget(url: _url!);

      case 'FILE':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          child: InkWell(
            onTap: () {
              _openUrl(_url!);
            },
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.insert_drive_file_outlined, color: colors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملف', style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface)),
                      const SizedBox(height: 2),
                      Text('اضغط للتحميل', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(Icons.download_rounded, size: 16, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        );

      default:
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.insert_drive_file_outlined, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ملف', style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface)),
                    const SizedBox(height: 2),
                    Text('اضغط للتحميل', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
        );
    }
  }
}


void _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}