import 'package:flutter/material.dart';
import '../../data/models/page_model.dart';
import '../detail/detail_screen.dart';
import '../widgets/highlight_text.dart';
import 'search_controller.dart' as sc;
import 'widgets/result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = sc.SearchController();
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();

  List<String> get _keywords {
    final raw = _textCtrl.text.trim();
    if (raw.isEmpty) return [];

    final normalized = raw.replaceAll('“', '"').replaceAll('”', '"');
    final pattern = RegExp(r'"([^"]+)"|(\S+)');
    final matches = pattern.allMatches(normalized);
    
    final keywords = <String>{};
    for (final m in matches) {
      if (m.group(1) != null) {
        final phrase = m.group(1)!.trim();
        if (phrase.isNotEmpty) {
          keywords.add(phrase); // Highlight the full exact phrase
          // Also highlight individual words inside the phrase
          for (final w in phrase.split(RegExp(r'\s+'))) {
            if (w.isNotEmpty) keywords.add(w);
          }
        }
      } else if (m.group(2) != null) {
        final word = m.group(2)!;
        if (word.isNotEmpty) keywords.add(word);
      }
    }
    return keywords.toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _controller.onQueryChanged(value);
  }

  void _clearSearch() {
    _textCtrl.clear();
    _onChanged('');
    _focusNode.requestFocus();
  }

  void _openDetail(PageSummary page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => DetailScreen(
          summary: page,
          keywords: _keywords,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F6BFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.manage_search_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('PageSearch',
                        style: tt.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w800, color: cs.onSurface)),
                  ]),
                  const SizedBox(height: 6),
                  Text('Search your local knowledge base',
                      style: tt.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textCtrl,
                focusNode: _focusNode,
                onChanged: _onChanged,
                style: tt.bodyLarge!.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type keywords…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF4F6BFF)),
                  suffixIcon: _textCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: cs.onSurfaceVariant,
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),

            const SizedBox(height: 12),

            // ── Results ──────────────────────────────────────────────────────
            Expanded(
              child: StreamBuilder<sc.SearchStatus>(
                stream: _controller.statusStream,
                initialData: sc.SearchStatus.idle,
                builder: (context, statusSnap) {
                  final status = statusSnap.data!;

                  if (status == sc.SearchStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4F6BFF), strokeWidth: 2.5),
                    );
                  }

                  if (status == sc.SearchStatus.idle) {
                    return _EmptyState(
                      icon: Icons.search_rounded,
                      title: 'Start searching',
                      subtitle: 'Enter one or more keywords to find pages.',
                    );
                  }

                  if (status == sc.SearchStatus.error) {
                    return _EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Search failed',
                      subtitle: 'Try different keywords.',
                      iconColor: Colors.redAccent,
                    );
                  }

                  // status == done — read results directly from controller
                  final results = _controller.results;

                  if (results.isEmpty) {
                    return _EmptyState(
                      icon: Icons.find_in_page_outlined,
                      title: 'No results found',
                      subtitle: 'Try different or fewer keywords.',
                    );
                  }

                  return Column(
                    children: [
                      _ResultCountBanner(
                        count: results.length,
                        query: _controller.lastQuery,
                        keywords: _keywords,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 4, bottom: 24),
                          itemCount: results.length,
                          itemBuilder: (context, i) => ResultCard(
                            page: results[i],
                            keywords: _keywords,
                            onTap: () => _openDetail(results[i]),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64,
                color: iconColor ?? cs.onSurface.withAlpha(60)),
            const SizedBox(height: 16),
            Text(title,
                style: tt.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withAlpha(180))),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _ResultCountBanner extends StatelessWidget {
  const _ResultCountBanner({
    required this.count,
    required this.query,
    required this.keywords,
  });

  final int count;
  final String query;
  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4F6BFF).withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count ${count == 1 ? 'result' : 'results'}',
                style: tt.labelSmall!.copyWith(
                    color: const Color(0xFF4F6BFF),
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: HighlightText(
              text: 'for "$query"',
              keywords: keywords,
              baseStyle: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
