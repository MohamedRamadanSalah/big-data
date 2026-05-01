import 'dart:async';
import '../../../data/models/page_model.dart';
import '../../../data/repositories/search_repository.dart';

enum SearchStatus { idle, loading, done, error }

class SearchController {
  SearchController({SearchRepository? repo})
      : _repo = repo ?? SearchRepository();

  final SearchRepository _repo;

  final _statusCtrl = StreamController<SearchStatus>.broadcast();
  final _resultsCtrl = StreamController<List<PageSummary>>.broadcast();

  Stream<SearchStatus> get statusStream => _statusCtrl.stream;
  Stream<List<PageSummary>> get resultsStream => _resultsCtrl.stream;

  List<PageSummary> _results = [];
  List<PageSummary> get results => _results;

  String _lastQuery = '';
  String get lastQuery => _lastQuery;

  Timer? _debounce;

  void onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _run(query));
  }

  Future<void> _run(String query) async {
    _lastQuery = query;
    if (query.trim().length < 2) {
      _results = [];
      _resultsCtrl.add(_results);
      _statusCtrl.add(SearchStatus.idle);
      return;
    }

    _statusCtrl.add(SearchStatus.loading);
    try {
      _results = await _repo.search(query);
      _resultsCtrl.add(_results);
      _statusCtrl.add(SearchStatus.done);
    } catch (e) {
      print('[SearchController] ERROR: $e');
      _results = [];
      _resultsCtrl.add(_results);
      _statusCtrl.add(SearchStatus.error);
    }
  }

  void dispose() {
    _debounce?.cancel();
    _statusCtrl.close();
    _resultsCtrl.close();
  }
}
