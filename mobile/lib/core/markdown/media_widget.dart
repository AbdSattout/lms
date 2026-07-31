import 'package:flutter/material.dart';
import 'media_reference.dart';

/// TODO: no endpoint yet to resolve {orgId, courseId?, mediaId} -> an
/// actual file URL + type. Once available, swap this placeholder for a
/// real fetch (FutureBuilder/bloc) and branch on the resolved kind:
///   image -> Image.network(url)
///   video -> a video player (e.g. video_player/chewie package)
///   file  -> icon + filename + open/download button
class MediaWidget extends StatelessWidget {
  final MediaReference reference;
  const MediaWidget({super.key, required this.reference});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          Icon(Icons.perm_media_outlined, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reference.isCourseMedia
                  ? 'وسائط الكورس #${reference.mediaId} (بانتظار الـ endpoint)'
                  : 'وسائط المنشور #${reference.mediaId} (بانتظار الـ endpoint)',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}