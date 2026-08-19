import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
        final blocks = _splitMarkdownBlocks(text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: blocks.map((block) {
            final direction = _detectDirection(block);
            return Directionality(
              textDirection: direction,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: MarkdownBody(
                  data: block,
                  shrinkWrap: true,
                  selectable: false,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

List<String> _splitMarkdownBlocks(String markdown) {
  final lines = markdown.split('\n');
  final blocks = <String>[];
  final buffer = StringBuffer();
  var inFence = false;

  void flush() {
    if (buffer.toString().trim().isNotEmpty) {
      blocks.add(buffer.toString());
    }
    buffer.clear();
  }

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
      inFence = !inFence;
      buffer.writeln(line);
      continue;
    }
    if (trimmed.isEmpty && !inFence) {
      flush();
    } else if (!inFence && _isHeadingLine(trimmed)) {
      flush();
      buffer.writeln(line);
      flush();
    } else {
      buffer.writeln(line);
    }
  }
  flush();

  return blocks;
}

bool _isHeadingLine(String trimmed) {
  if (!trimmed.startsWith('#')) return false;
  return trimmed.length == 1 ||
      (trimmed.length > 1 && trimmed[1] == ' ' || trimmed[1] == '#');
}

TextDirection _detectDirection(String text) {
  for (final rune in text.runes) {
    if (_isStrongRtl(rune)) return TextDirection.rtl;
    if (_isStrongLtr(rune)) return TextDirection.ltr;
  }
  return TextDirection.rtl;
}

bool _isStrongRtl(int rune) {
  if (rune >= 0x0590 && rune <= 0x08FF) return true;
  if (rune >= 0xFB1D && rune <= 0xFDFD) return true;
  if (rune >= 0xFE70 && rune <= 0xFEFC) return true;
  return false;
}

bool _isStrongLtr(int rune) {
  return (rune >= 0x0041 && rune <= 0x005A) ||
      (rune >= 0x0061 && rune <= 0x007A);
}
