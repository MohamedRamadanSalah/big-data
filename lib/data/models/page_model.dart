/// Lightweight model used in search result lists.
/// Only carries the first [snippetLength] characters of content —
/// avoids pulling the entire (potentially huge) page content into RAM
/// for every result row.
class PageSummary {
  final String url;
  final String title;
  final String snippetContent; // truncated content, max ~600 chars

  const PageSummary({
    required this.url,
    required this.title,
    required this.snippetContent,
  });

  factory PageSummary.fromMap(Map<String, dynamic> map) {
    return PageSummary(
      url: (map['url'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      snippetContent: (map['snippet'] as String?) ?? '',
    );
  }

  /// Returns the best snippet around the first keyword match.
  String snippet(List<String> keywords, {int radius = 200}) {
    final text = snippetContent;
    if (text.isEmpty) return '';

    final lower = text.toLowerCase();
    int bestIndex = -1;

    for (final kw in keywords) {
      final idx = lower.indexOf(kw.toLowerCase());
      if (idx != -1 && (bestIndex == -1 || idx < bestIndex)) {
        bestIndex = idx;
      }
    }

    if (bestIndex == -1) {
      return text.length > radius * 2
          ? '${text.substring(0, radius * 2)}…'
          : text;
    }

    final start = (bestIndex - radius).clamp(0, text.length);
    final end = (bestIndex + radius).clamp(0, text.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix${text.substring(start, end)}$suffix';
  }
}

/// Full model used only on the detail screen.
/// Loaded on-demand when the user taps a result.
class PageModel {
  final String url;
  final String title;
  final String content;

  const PageModel({
    required this.url,
    required this.title,
    required this.content,
  });

  factory PageModel.fromMap(Map<String, dynamic> map) {
    return PageModel(
      url: (map['url'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
    );
  }
}
