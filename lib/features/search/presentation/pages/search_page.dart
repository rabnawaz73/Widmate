import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/providers/search_provider.dart';
import 'package:widmate/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:widmate/features/search/presentation/widgets/search_results_widget.dart';
import 'package:widmate/features/search/presentation/widgets/search_history_widget.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  bool _isSearchExpanded = false;

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  void _performSearch(String query) {
    ref.read(searchStateProvider.notifier).search(query);
  }

  void _clearHistory() {
    ref.read(searchHistoryProvider.notifier).clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBarWidget(
                isExpanded: _isSearchExpanded,
                onToggle: _toggleSearch,
                onSearch: _performSearch,
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Search History (when not searching)
                    if (!searchState.isLoading && !searchState.hasResults)
                      SearchHistoryWidget(
                        onSearch: _performSearch,
                        onClear: _clearHistory,
                      ),

                    // Search Results
                    const SearchResultsWidget(),

                    // Empty state when no search performed
                    if (!searchState.isLoading &&
                        !searchState.hasResults &&
                        !searchState.hasError &&
                        searchState.query.isEmpty)
                      _buildEmptyState(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: colorScheme.outline.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for Videos',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and download videos from YouTube\nusing the search bar above',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Search Tips',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Use specific keywords for better results\n'
                  '• Try different search terms if no results\n'
                  '• Search for playlists, channels, or topics',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
