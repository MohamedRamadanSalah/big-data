import 'package:flutter/material.dart';

/// Renders [text] with every occurrence of each keyword in [keywords]
/// highlighted with a yellow background.
///
/// Matching is always case-insensitive.
class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.keywords,
    this.baseStyle,
    this.highlightColor = const Color(0xFFFFE500),
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  final String text;
  final List<String> keywords;
  final TextStyle? baseStyle;
  final Color highlightColor;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final spans = _buildSpans(context);
    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  List<TextSpan> _buildSpans(BuildContext context) {
    final base = baseStyle ?? DefaultTextStyle.of(context).style;

    final activeKeywords =
        keywords.where((k) => k.trim().isNotEmpty).toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    if (activeKeywords.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: base)];
    }

    // Build a single regex that matches any of the keywords (case-insensitive).
    // Using \S* around the keyword ensures we match the entire word containing the keyword.
    // This prevents breaking ligatures in cursive scripts like Bengali or Arabic!
    final pattern = activeKeywords
        .map((k) => r'\S*' + RegExp.escape(k.trim()) + r'\S*')
        .join('|');
    final regex = RegExp(pattern, caseSensitive: false);

    final spans = <TextSpan>[];
    int cursor = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, match.start),
          style: base,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: base.copyWith(
          backgroundColor: highlightColor,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ));
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }

    return spans;
  }
}
