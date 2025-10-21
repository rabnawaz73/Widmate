import 'package:flutter/material.dart';
import 'package:widmate/core/services/video_download_service.dart';

class PlaylistSelectionWidget extends StatefulWidget {
  final VideoInfo playlistInfo;
  final Function(List<int> selectedIndices) onSelectionChanged;
  final Function(String playlistItems) onDownloadRequested;

  const PlaylistSelectionWidget({
    super.key,
    required this.playlistInfo,
    required this.onSelectionChanged,
    required this.onDownloadRequested,
  });

  @override
  State<PlaylistSelectionWidget> createState() =>
      _PlaylistSelectionWidgetState();
}

class _PlaylistSelectionWidgetState extends State<PlaylistSelectionWidget> {
  final Set<int> _selectedIndices = <int>{};
  bool _selectAll = false;
  String _rangeText = '';
  bool _isRangeMode = false;

  @override
  void initState() {
    super.initState();
    // Select all by default
    _selectAll = true;
    _selectedIndices.addAll(
      List.generate(
        widget.playlistInfo.playlistEntries.length,
        (index) => index,
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedIndices.addAll(
          List.generate(
            widget.playlistInfo.playlistEntries.length,
            (index) => index,
          ),
        );
      } else {
        _selectedIndices.clear();
      }
      widget.onSelectionChanged(_selectedIndices.toList());
    });
  }

  void _toggleItem(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        _selectAll = false;
      } else {
        _selectedIndices.add(index);
        if (_selectedIndices.length ==
            widget.playlistInfo.playlistEntries.length) {
          _selectAll = true;
        }
      }
      widget.onSelectionChanged(_selectedIndices.toList());
    });
  }

  void _selectRange() {
    if (_rangeText.isEmpty) return;

    try {
      final parts = _rangeText.split('-');
      if (parts.length == 2) {
        final start =
            int.parse(parts[0].trim()) - 1; // Convert to 0-based index
        final end = int.parse(parts[1].trim()) - 1;

        if (start >= 0 &&
            end < widget.playlistInfo.playlistEntries.length &&
            start <= end) {
          setState(() {
            _selectedIndices.clear();
            for (int i = start; i <= end; i++) {
              _selectedIndices.add(i);
            }
            _selectAll = _selectedIndices.length ==
                widget.playlistInfo.playlistEntries.length;
            widget.onSelectionChanged(_selectedIndices.toList());
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid range format. Use "1-10" or "1,3,5"'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectSpecific() {
    if (_rangeText.isEmpty) return;

    try {
      final parts = _rangeText.split(',');
      setState(() {
        _selectedIndices.clear();
        for (final part in parts) {
          final index = int.parse(part.trim()) - 1; // Convert to 0-based index
          if (index >= 0 &&
              index < widget.playlistInfo.playlistEntries.length) {
            _selectedIndices.add(index);
          }
        }
        _selectAll = _selectedIndices.length ==
            widget.playlistInfo.playlistEntries.length;
        widget.onSelectionChanged(_selectedIndices.toList());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid format. Use "1,3,5" or "1-10"'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return 'Unknown';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _getPlaylistItemsString() {
    if (_selectedIndices.isEmpty) return '';

    final sortedIndices = _selectedIndices.toList()..sort();

    // Check if it's a continuous range
    bool isContinuous = true;
    for (int i = 1; i < sortedIndices.length; i++) {
      if (sortedIndices[i] != sortedIndices[i - 1] + 1) {
        isContinuous = false;
        break;
      }
    }

    if (isContinuous && sortedIndices.length > 1) {
      // Convert to 1-based for yt-dlp
      return '${sortedIndices.first + 1}-${sortedIndices.last + 1}';
    } else {
      // Convert to 1-based for yt-dlp
      return sortedIndices.map((i) => i + 1).join(',');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entries = widget.playlistInfo.playlistEntries;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playlist header
            Row(
              children: [
                Icon(Icons.playlist_play, color: colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.playlistInfo.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${entries.length} videos • ${_selectedIndices.length} selected',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Selection controls
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Select All'),
                    value: _selectAll,
                    onChanged: (_) => _toggleSelectAll(),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isRangeMode = !_isRangeMode;
                        _rangeText = '';
                      });
                    },
                    icon: Icon(_isRangeMode ? Icons.checklist : Icons.edit),
                    label: Text(_isRangeMode ? 'Done' : 'Custom'),
                  ),
                ),
              ],
            ),

            // Custom selection input
            if (_isRangeMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter range (1-10) or items (1,3,5)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) => _rangeText = value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _rangeText.contains('-')
                        ? _selectRange
                        : _selectSpecific,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Playlist items list
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isSelected = _selectedIndices.contains(index);

                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _toggleItem(index),
                      title: Text(
                        entry.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          if (entry.duration != null) ...[
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(entry.duration),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            '#${entry.index}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      secondary: entry.thumbnail != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                entry.thumbnail!,
                                width: 60,
                                height: 34,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 34,
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.video_library,
                                    color: colorScheme.outline,
                                    size: 20,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 34,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.video_library,
                                color: colorScheme.outline,
                                size: 20,
                              ),
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Download buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedIndices.isEmpty
                        ? null
                        : () {
                            final playlistItems = _getPlaylistItemsString();
                            widget.onDownloadRequested(playlistItems);
                          },
                    icon: const Icon(Icons.download),
                    label: Text(
                      'Download Selected (${_selectedIndices.length})',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onDownloadRequested(
                        '',
                      ); // Empty string means download all
                    },
                    icon: const Icon(Icons.download_for_offline),
                    label: const Text('Download All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
