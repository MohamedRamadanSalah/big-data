import '../database/db_helper.dart';
import '../models/page_model.dart';

class SearchRepository {
  final DbHelper _db;

  SearchRepository({DbHelper? db}) : _db = db ?? DbHelper.instance;

  /// Lightweight search — returns summaries with truncated content.
  Future<List<PageSummary>> search(String query, {int limit = 50}) =>
      _db.search(query, limit: limit);

  /// Full page load — called only when the user opens a detail screen.
  Future<PageModel?> fetchFullPage(String url) => _db.fetchFullPage(url);
}
