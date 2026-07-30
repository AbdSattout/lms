class MediaReference {
  final String orgId;
  final String? courseId;
  final String mediaId;
  final bool isCourseMedia;

  const MediaReference({
    required this.orgId,
    this.courseId,
    required this.mediaId,
    required this.isCourseMedia,
  });

  static MediaReference? tryParse(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('::media')) return null;

    final rest = trimmed.substring('::media'.length).trim();
    final parts = rest.split('/');

    if (parts.length == 2) {
      return MediaReference(orgId: parts[0], mediaId: parts[1], isCourseMedia: false);
    }
    if (parts.length == 3) {
      return MediaReference(
        orgId: parts[0],
        courseId: parts[1],
        mediaId: parts[2],
        isCourseMedia: true,
      );
    }
    return null;
  }
}

sealed class ContentSegment {}

class MarkdownSegment extends ContentSegment {
  final String text;
  MarkdownSegment(this.text);
}

class MediaSegment extends ContentSegment {
  final MediaReference reference;
  MediaSegment(this.reference);
}

List<ContentSegment> parseContentSegments(String content) {
  final lines = content.split('\n');
  final segments = <ContentSegment>[];
  final buffer = StringBuffer();

  void flush() {
    if (buffer.toString().trim().isNotEmpty) {
      segments.add(MarkdownSegment(buffer.toString()));
    }
    buffer.clear();
  }

  for (final line in lines) {
    final ref = MediaReference.tryParse(line);
    if (ref != null) {
      flush();
      segments.add(MediaSegment(ref));
    } else {
      buffer.writeln(line);
    }
  }
  flush();

  return segments;
}