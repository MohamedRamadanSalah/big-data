import 'package:flutter/material.dart';
import '../../../data/models/page_model.dart';
import '../../widgets/highlight_text.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.page,
    required this.keywords,
    required this.onTap,
  });

  final PageSummary page;
  final List<String> keywords;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snippet = page.snippet(keywords);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────────
              HighlightText(
                text: page.title.isEmpty ? '(No title)' : page.title,
                keywords: keywords,
                baseStyle: tt.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // ── URL ─────────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.link_rounded,
                      size: 14, color: cs.primary.withAlpha(180)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      page.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Snippet ─────────────────────────────────────────────────
              if (snippet.isNotEmpty)
                HighlightText(
                  text: snippet,
                  keywords: keywords,
                  baseStyle: tt.bodyMedium!.copyWith(
                    color: cs.onSurface.withAlpha(180),
                    height: 1.5,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: cs.onSurface.withAlpha(100)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
