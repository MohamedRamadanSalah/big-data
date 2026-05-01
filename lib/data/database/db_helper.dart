import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../models/page_model.dart';

class DbHelper {
  static const _dbAssetName = 'search_data.db';

  static const _snippetChars = 600;

  static Database? _db;
  static String? _realDbDir;

  // ── singleton ─────────────────────────────────────────────────────────────
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Future<void> initFfi() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    _realDbDir = await getDatabasesPath();

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // first-launch DB copy with progress 
  static const _channel =
      MethodChannel('com.example.flutter_big_data/asset_copier');

  /// Copies the asset DB to writable storage if needed.
  static Future<void> ensureDatabase({
    void Function(double progress)? onProgress,
  }) async {
    final dbDir = _realDbDir!;
    final dbPath = p.join(dbDir, _dbAssetName);

    final dir = Directory(dbDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    if (File(dbPath).existsSync()) {
      onProgress?.call(1.0);
      return;
    }

    onProgress?.call(0.1); 

    if (Platform.isAndroid) {
      await _channel.invokeMethod('copyAssetDatabase', {
        'assetName': 'assets/$_dbAssetName',
        'destPath': dbPath,
      });
    } else {
      // iOS / other fallback
      final data = await rootBundle.load('assets/$_dbAssetName');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    onProgress?.call(1.0);
  }

  // ── lazy DB accessor ──────────────────────────────────────────────────────
  Future<Database> get db async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dbDir = _realDbDir!;
    final dbPath = p.join(dbDir, _dbAssetName);
    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(readOnly: true),
    );
  }

  String _buildFtsQuery(String raw) {
    // Step 1: Normalize smart/curly quotes from mobile keyboards.
    String input = raw;
    input = input.replaceAll('\u201c', '"'); 
    input = input.replaceAll('\u201d', '"');
    input = input.replaceAll('\u2018', "'"); 
    input = input.replaceAll('\u2019', "'");

    // Step 2: Extract exact-phrase queries (text inside "...")
    final phraseRe = RegExp(r'"([^"]+)"');
    final phrases = <String>[];
    for (final m in phraseRe.allMatches(input)) {
      final phrase = m.group(1)!.trim();
      if (phrase.isNotEmpty) {
        phrases.add('"$phrase"'); // FTS5 exact phrase
      }
    }

    // Step 3: Remove the quoted parts, split remaining into individual words
    final leftover = input.replaceAll(phraseRe, ' ').trim();
    final words = leftover
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && w.length >= 2)
        .toList();

    // Step 4: Build FTS5 tokens — each word gets a prefix wildcard *
    final wordTokens = words.map((w) {
      // Remove any stray quote characters
      final clean = w.replaceAll('"', '');
      if (clean.isEmpty) return '';
      return '$clean*'; // prefix match: "med" → med*
    }).where((t) => t.isNotEmpty);

    final all = [...phrases, ...wordTokens];
    if (all.isEmpty) return '';
    return all.join(' AND ');
  }

  // ── search (lightweight: only snippet, not full content) ──────────────────
  /// Returns up to [limit] results with truncated content for list display.
  /// Full content is fetched separately via [fetchFullPage].
  Future<List<PageSummary>> search(String query, {int limit = 30}) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final ftsQuery = _buildFtsQuery(q);
    if (ftsQuery.isEmpty) return [];

    final database = await db;

    try {
      final rows = await database.rawQuery(
        '''
        SELECT
          url,
          title,
          SUBSTR(content, 1, $_snippetChars) AS snippet
        FROM pages
        WHERE pages MATCH ?
        ORDER BY bm25(pages, 0.0, 100.0, 1.0) ASC, LENGTH(title) ASC
        LIMIT ?
        ''',
        [ftsQuery, limit],
      );
      return rows
          .map(PageSummary.fromMap)
          .where((p) =>
              p.title.trim().isNotEmpty &&
              p.title.trim().toLowerCase() != 'no title')
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ── full page load (used only on detail screen) ───────────────────────────
  /// Fetches the full content for a single page by its URL.
  Future<PageModel?> fetchFullPage(String url) async {
    final database = await db;
    try {
      final rows = await database.rawQuery(
        'SELECT url, title, content FROM pages WHERE url = ? LIMIT 1',
        [url],
      );
      if (rows.isEmpty) return null;
      return PageModel.fromMap(rows.first);
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
