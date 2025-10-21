import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/providers/search_provider.dart';

class SearchHistoryWidget extends ConsumerWidget {
  final Function(String) onSearch;
  final VoidCallback? onClear;

  const SearchHistoryWidget({super.key, required this.onSearch, this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (searchHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onClear != null)
                  TextButton(
                    onPressed: onClear,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // History items
          ...searchHistory.map(
            (query) => _SearchHistoryItem(
              query: query,
              onTap: () => onSearch(query),
              onRemove: () =>
                  ref.read(searchHistoryProvider.notifier).removeSearch(query),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHistoryItem extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SearchHistoryItem({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.search, size: 16, color: colorScheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                query,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, size: 16, color: colorScheme.outline),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
