import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/providers/search_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;
  final Function(String)? onSearch;

  const SearchBarWidget({
    super.key,
    this.isExpanded = false,
    this.onToggle,
    this.onSearch,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch?.call(query);
      ref.read(searchHistoryProvider.notifier).addSearch(query);
      _focusNode.unfocus();
    }
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchStateProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchState = ref.watch(searchStateProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isExpanded ? 300 : 40,
      child: widget.isExpanded
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search videos...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: theme.textTheme.bodyMedium,
                      onSubmitted: (_) => _performSearch(),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  if (_isSearching || searchState.isLoading) ...[
                    if (searchState.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: _clearSearch,
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          size: 18,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    onPressed: _performSearch,
                    icon: Icon(
                      Icons.search,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            )
          : IconButton(
              onPressed: widget.onToggle,
              icon: Icon(Icons.search, color: colorScheme.onSurface),
              tooltip: 'Search videos',
            ),
    );
  }
}
