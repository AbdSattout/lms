import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'media_reference.dart';
import 'media_widget.dart';

class MarkdownContentView extends StatelessWidget {
  final String content;
  const MarkdownContentView({super.key, required this.content});

  static final md.ExtensionSet _extensionSet = md.ExtensionSet(
    [...md.ExtensionSet.gitHubFlavored.blockSyntaxes, LatexBlockSyntax()],
    [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes, LatexInlineSyntax()],
  );

  static final md.Document _document = md.Document(extensionSet: _extensionSet);

  static final Map<String, MarkdownElementBuilder> _builders = {
    'latex': _LatexElementBuilder(),
  };

  static final RegExp _inlineLatexPattern = RegExp(
    r'\$|\\\(|\\\[|\\ce\{|\\pu\{',
  );

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
        final children = <Widget>[];
        for (final block in blocks) {
          if (children.isNotEmpty) {
            children.add(const SizedBox(height: 12));
          }
          children.add(_buildBlockWidget(context, block));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      }).toList(),
    );
  }

  Widget _buildBlockWidget(BuildContext context, String block) {
    if (_isPlainParagraph(block) && block.contains('\n')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: block
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => _buildLineWidget(context, line))
            .toList(),
      );
    }
    return _buildLineWidget(context, block);
  }

  Widget _buildLineWidget(BuildContext context, String text) {
    final trimmed = text.trim();
    final isDisplayBlock =
        trimmed.startsWith(r'$$') || trimmed.startsWith(r'\[');
    final useInlineRenderer =
        !isDisplayBlock && _inlineLatexPattern.hasMatch(text);
    return SizedBox(
      width: double.infinity,
      child: Directionality(
        textDirection: _detectDirection(text),
        child: useInlineRenderer
            ? _buildInlineLatexLine(context, text)
            : _buildMarkdownBody(text),
      ),
    );
  }

  Widget _buildMarkdownBody(String text) {
    return MarkdownBody(
      data: text,
      shrinkWrap: true,
      fitContent: false,
      selectable: false,
      softLineBreak: true,
      builders: _builders,
      extensionSet: _extensionSet,
    );
  }

  Widget _buildInlineLatexLine(BuildContext context, String text) {
    final nodes = md.InlineParser(text, _document).parse();
    final style = DefaultTextStyle.of(context).style;
    return RichText(
      text: TextSpan(
        style: style,
        children: nodes.map((n) => _buildInlineSpan(context, n)).toList(),
      ),
    );
  }

  InlineSpan _buildInlineSpan(BuildContext context, md.Node node) {
    if (node is! md.Element) {
      return TextSpan(text: node.textContent);
    }
    switch (node.tag) {
      case 'latex':
        final isDisplay = node.attributes['MathStyle'] == 'display';
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            node.textContent,
            mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
            textStyle: DefaultTextStyle.of(context).style,
          ),
        );
      case 'em':
        return TextSpan(
          style: const TextStyle(fontStyle: FontStyle.italic),
          children: _childSpans(context, node),
        );
      case 'strong':
        return TextSpan(
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: _childSpans(context, node),
        );
      case 'del':
        return TextSpan(
          style: const TextStyle(decoration: TextDecoration.lineThrough),
          children: _childSpans(context, node),
        );
      case 'a':
        return TextSpan(
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          children: _childSpans(context, node),
        );
      case 'code':
        return TextSpan(
          style: const TextStyle(fontFamily: 'monospace'),
          children: _childSpans(context, node),
        );
      default:
        return TextSpan(children: _childSpans(context, node));
    }
  }

  List<InlineSpan> _childSpans(BuildContext context, md.Element node) {
    return (node.children ?? const [])
        .map((c) => _buildInlineSpan(context, c))
        .toList();
  }
}

bool _isPlainParagraph(String block) {
  for (final line in block.split('\n')) {
    final t = line.trim();
    if (t.isEmpty) continue;
    if (t.startsWith('#')) return false;
    if (t.startsWith('- ') || t.startsWith('* ') || t.startsWith('+ ')) {
      return false;
    }
    if (RegExp(r'^\d+[.)] ').hasMatch(t)) return false;
    if (t.startsWith('>')) return false;
    if (t.startsWith('`') || t.startsWith('~~~')) return false;
    if (t.startsWith(r'$$') || t.startsWith(r'\[')) return false;
    if (t.startsWith('|')) return false;
  }
  return true;
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

class _LatexElementBuilder extends LatexElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String text = element.textContent;
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final MathStyle mathStyle = element.attributes['MathStyle'] == 'display'
        ? MathStyle.display
        : MathStyle.text;

    if (mathStyle == MathStyle.display) {
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.antiAlias,
          child: Math.tex(text, mathStyle: mathStyle),
        ),
      );
    }
    return Math.tex(text, mathStyle: mathStyle);
  }
}
