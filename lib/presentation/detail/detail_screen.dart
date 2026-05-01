import 'package:flutter/material.dart';
import '../../data/models/page_model.dart';
import '../../data/repositories/search_repository.dart';
import '../widgets/highlight_text.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.summary,
    required this.keywords,
  });

  final PageSummary summary;
  final List<String> keywords;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _repo = SearchRepository();
  final _scrollCtrl = ScrollController();

  PageModel? _fullPage;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFull();
  }

  Future<void> _loadFull() async {
    try {
      final page = await _repo.fetchFullPage(widget.summary.url);
      if (mounted) setState(() { _fullPage = page; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final kws = widget.keywords;
    final summary = widget.summary;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── Collapsible AppBar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
              title: Text(
                summary.title.isEmpty ? '(No title)' : summary.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3451E0).withAlpha(200),
                      cs.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── URL banner ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, size: 16,
                      color: cs.primary.withAlpha(200)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.url,
                      style: tt.bodySmall!.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w500),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Keyword chips ───────────────────────────────────────────────
          if (kws.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: kws
                      .where((k) => k.trim().isNotEmpty)
                      .map((k) => _KeywordChip(keyword: k))
                      .toList(),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: Divider(height: 1,
                color: cs.surfaceContainerHighest, indent: 16, endIndent: 16),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Content area ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
            sliver: SliverToBoxAdapter(
              child: _buildContent(cs, tt, kws),
            ),
          ),
        ],
      ),
      floatingActionButton: _ScrollTopFab(scrollController: _scrollCtrl),
    );
  }

  Widget _buildContent(ColorScheme cs, TextTheme tt, List<String> kws) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  color: Color(0xFF4F6BFF), strokeWidth: 2.5),
              SizedBox(height: 16),
              Text('Loading full content…',
                  style: TextStyle(color: Color(0xFF8B8FA8))),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text('Failed to load content.',
            style: TextStyle(color: cs.error)),
      );
    }

    final content = _fullPage?.content ?? '';
    if (content.isEmpty) {
      return Center(
        child: Text('No content available.',
            style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
      );
    }

    return HighlightText(
      text: content,
      keywords: kws,
      baseStyle: tt.bodyMedium!.copyWith(
        color: cs.onSurface.withAlpha(210),
        height: 1.75,
        fontSize: 15,
      ),
    );
  }
}

// ── Keyword chip ────────────────────────────────────────────────────────────
class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.keyword});
  final String keyword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE500).withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE500).withAlpha(120)),
      ),
      child: Text(keyword,
          style: const TextStyle(
              color: Color(0xFFFFE500), fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Scroll-to-top FAB ───────────────────────────────────────────────────────
class _ScrollTopFab extends StatefulWidget {
  const _ScrollTopFab({required this.scrollController});
  final ScrollController scrollController;

  @override
  State<_ScrollTopFab> createState() => _ScrollTopFabState();
}

class _ScrollTopFabState extends State<_ScrollTopFab> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final show = widget.scrollController.offset > 300;
    if (show != _visible) setState(() => _visible = show);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.small(
        onPressed: () => widget.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        ),
        backgroundColor: const Color(0xFF4F6BFF),
        child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
      ),
    );
  }
}
