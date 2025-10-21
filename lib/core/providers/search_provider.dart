import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/services/search_service.dart';

/// Search service provider
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

/// Search state provider
final searchStateProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref.read(searchServiceProvider));
});

/// Search history provider
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      return SearchHistoryNotifier();
    });

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(this._searchService) : super(SearchState.initial());

  /// Perform a search
  Future<void> search(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return;

    state = SearchState.loading(query);

    try {
      final response = await _searchService.searchVideos(query, limit: limit);
      state = SearchState.success(response);
    } catch (e) {
      state = SearchState.error(e.toString());
    }
  }

  /// Clear search results
  void clearSearch() {
    state = SearchState.initial();
  }

  /// Retry last search
  Future<void> retry() async {
    if (state.query.isNotEmpty) {
      await search(state.query);
    }
  }
}

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  /// Add a search query to history
  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    state = state.where((item) => item != query).toList();

    // Add to beginning
    state = [query, ...state];

    // Keep only last 10 searches
    if (state.length > 10) {
      state = state.take(10).toList();
    }
  }

  /// Clear search history
  void clearHistory() {
    state = [];
  }

  /// Remove a specific search from history
  void removeSearch(String query) {
    state = state.where((item) => item != query).toList();
  }
}

class SearchState {
  final bool isLoading;
  final String query;
  final SearchResponse? response;
  final String? error;

  SearchState({
    required this.isLoading,
    required this.query,
    this.response,
    this.error,
  });

  factory SearchState.initial() {
    return SearchState(isLoading: false, query: '');
  }

  factory SearchState.loading(String query) {
    return SearchState(isLoading: true, query: query);
  }

  factory SearchState.success(SearchResponse response) {
    return SearchState(
      isLoading: false,
      query: response.query,
      response: response,
    );
  }

  factory SearchState.error(String error) {
    return SearchState(isLoading: false, query: '', error: error);
  }

  bool get hasResults => response != null && response!.results.isNotEmpty;
  bool get hasError => error != null;
  List<SearchResult> get results => response?.results ?? [];
}
