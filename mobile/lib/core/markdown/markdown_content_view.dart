import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'media_reference.dart';
import 'media_widget.dart';

class MarkdownContentView extends StatelessWidget {
  final String content;
  const MarkdownContentView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final segments = parseContentSegments(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map<Widget>((segment) {
        if (segment is MediaSegment) {
          return MediaWidget(reference: segment.reference);
        }
        final text = (segment as MarkdownSegment).text;
        return MarkdownBody(
          data: text,
          shrinkWrap: true,
          selectable: false,
        );
      }).toList(),
    );
  }
}