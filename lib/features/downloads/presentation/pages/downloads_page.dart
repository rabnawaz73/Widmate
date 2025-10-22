import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widmate/app/src/theme/color_palette.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/presentation/controllers/download_controller.dart';
import 'package:widmate/app/src/responsive/responsive_wrapper.dart';

/// Downloads Page - VidMate Style
/// Shows active downloads at top, divider, and completed downloads below
class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage>
    with TickerProviderStateMixin {
  late final AnimationController _progressController;
  String _sortBy = 'date';
  bool _showAllFormats = true;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _pauseDownload(String id) async {
    final download = ref
        .read(downloadControllerProvider)
        .value
        ?.firstWhere((d) => d.id == id);
    if (download != null) {
      if (download.status == DownloadStatus.downloading) {
        await ref.read(downloadControllerProvider.notifier).pauseDownload(id);
      } else if (download.status == DownloadStatus.paused) {
        await ref.read(downloadControllerProvider.notifier).resumeDownload(id);
      }
    }
  }

  void _cancelDownload(String id) async {
    await ref.read(downloadControllerProvider.notifier).cancelDownload(id);
  }

  void _retryDownload(String id) async {
    await ref.read(downloadControllerProvider.notifier).retryDownload(id);
  }

  void _shareDownload(DownloadItem download) async {
    try {
      if (download.filePath.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(download.filePath)],
            subject: 'Check out this video: ${download.title}',
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not available for sharing'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showHistoryFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter & Sort',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Download Date')),
                DropdownMenuItem(value: 'title', child: Text('Title')),
                DropdownMenuItem(value: 'size', child: Text('File Size')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show all formats'),
              subtitle: const Text('Include different quality versions'),
              value: _showAllFormats,
              onChanged: (value) {
                setState(() {
                  _showAllFormats = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DownloadItem> _getSortedCompletedDownloads(
    List<DownloadItem> downloads,
  ) {
    final sorted = List<DownloadItem>.from(downloads);

    switch (_sortBy) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'size':
        sorted.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
        break;
      case 'date':
      default:
        sorted.sort(
          (a, b) =>
              b.completedAt?.compareTo(a.completedAt ?? DateTime(1970)) ?? 0,
        );
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadControllerProvider);
    final stats = ref.watch(downloadStatsProvider);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          IconButton(
            onPressed: () => _showHistoryFilterOptions(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: downloadState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (downloads) => downloads.isEmpty
            ? _buildEmptyState(context)
            : _buildUnifiedDownloadsView(context, downloads, stats),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.download, size: 80, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No Downloads Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start downloading videos and they will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // Navigate to home or add URL page
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedDownloadsView(
    BuildContext context,
    List<DownloadItem> downloads,
    DownloadStats stats,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Separate active and completed downloads
    final activeDownloads = downloads
        .where(
          (d) =>
              d.status == DownloadStatus.downloading ||
              d.status == DownloadStatus.paused ||
              d.status == DownloadStatus.queued ||
              d.status == DownloadStatus.failed,
        )
        .toList();

    final completedDownloads =
        downloads.where((d) => d.status == DownloadStatus.completed).toList();
    final sortedCompletedDownloads = _getSortedCompletedDownloads(
      completedDownloads,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Header
          _buildStatsHeader(context, stats, colorScheme, theme),
          const SizedBox(height: 20),

          // Active Downloads Section
          if (activeDownloads.isNotEmpty) ...[
            _buildActiveDownloadsHeader(
              context,
              activeDownloads,
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildDownloadsList(context, activeDownloads, isActive: true),
            const SizedBox(height: 20),
          ],

          // Divider (only if both sections have content)
          if (activeDownloads.isNotEmpty && completedDownloads.isNotEmpty)
            _buildVidMateDivider(context, colorScheme, theme),

          // Completed Downloads Section
          if (completedDownloads.isNotEmpty) ...[
            _buildCompletedDownloadsHeader(
              context,
              completedDownloads,
              colorScheme,
              theme,
            ),
            const SizedBox(height: 12),
            _buildDownloadsList(
              context,
              sortedCompletedDownloads,
              isActive: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    DownloadStats stats,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Active',
            stats.active.toString(),
            Icons.download,
            colorScheme.primary,
          ),
          _buildStatItem(
            context,
            'Queued',
            stats.queued.toString(),
            Icons.queue,
            colorScheme.secondary,
          ),
          _buildStatItem(
            context,
            'Completed',
            stats.completed.toString(),
            Icons.check_circle,
            colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ColorPalette.withOpacityPreset(
              theme.colorScheme.onPrimaryContainer,
              OpacityPreset.medium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveDownloadsHeader(
    BuildContext context,
    List<DownloadItem> activeDownloads,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.download, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Active Downloads (${activeDownloads.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (activeDownloads.any(
            (d) => d.status == DownloadStatus.downloading,
          ))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Downloading',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedDownloadsHeader(
    BuildContext context,
    List<DownloadItem> completedDownloads,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.tertiary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Completed Downloads (${completedDownloads.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showHistoryFilterOptions(context),
            icon: const Icon(Icons.filter_list, size: 16),
            label: const Text('Filter'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.tertiary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVidMateDivider(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.outline.withAlpha(77),
                    colorScheme.primary.withAlpha(128),
                    colorScheme.outline.withAlpha(77),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withAlpha(77)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.outline.withAlpha(77),
                    colorScheme.primary.withAlpha(128),
                    colorScheme.outline.withAlpha(77),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList(
    BuildContext context,
    List<DownloadItem> downloads, {
    required bool isActive,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        return _buildDownloadCard(
          context,
          downloads[index],
          isActive: isActive,
        );
      },
    );
  }

  Widget _buildDownloadCard(
    BuildContext context,
    DownloadItem download, {
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with thumbnail and title
            Row(
              children: [
                // Thumbnail
                Container(
                  width: 80,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildThumbnail(download),
                  ),
                ),
                const SizedBox(width: 12),

                // Title and URL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        download.url,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Action buttons
                if (isActive) ...[
                  IconButton(
                    onPressed: () => _pauseDownload(download.id),
                    icon: Icon(
                      download.status == DownloadStatus.downloading
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    tooltip: download.status == DownloadStatus.downloading
                        ? 'Pause'
                        : 'Resume',
                  ),
                  IconButton(
                    onPressed: () => _cancelDownload(download.id),
                    icon: const Icon(Icons.cancel),
                    tooltip: 'Cancel',
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () => _shareDownload(download),
                    icon: const Icon(Icons.share),
                    tooltip: 'Share',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'share':
                          _shareDownload(download);
                          break;
                        case 'delete':
                          _cancelDownload(download.id);
                          break;
                        case 'retry':
                          _retryDownload(download.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'retry',
                        child: Row(
                          children: [
                            Icon(Icons.refresh),
                            SizedBox(width: 8),
                            Text('Retry'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar (for active downloads)
            if (isActive && download.status == DownloadStatus.downloading) ...[
              LinearProgressIndicator(
                value: download.progress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(download.progress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_formatBytes(download.downloadedBytes)} / ${_formatBytes(download.totalBytes)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Speed: ${_formatBytes(download.speed)}/s',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  Text(
                    'ETA: ${_formatDuration(download.eta)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ] else if (isActive) ...[
              // Status for paused/failed/queued
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    download.status,
                    colorScheme,
                  ).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(download.status),
                      color: _getStatusColor(download.status, colorScheme),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(download.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(download.status, colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // File info for completed downloads
              Row(
                children: [
                  Icon(Icons.video_file, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    _formatBytes(download.totalBytes),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    download.completedAt != null
                        ? _formatDate(download.completedAt!)
                        : 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(DownloadItem download) {
    if (download.thumbnailUrl != null && download.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        download.thumbnailUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildThumbnailPlaceholder(download),
      );
    }
    return _buildThumbnailPlaceholder(download);
  }

  Widget _buildThumbnailPlaceholder(DownloadItem download) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.video_library, color: Colors.grey[600], size: 24),
      ),
    );
  }

  Color _getStatusColor(DownloadStatus status, ColorScheme colorScheme) {
    switch (status) {
      case DownloadStatus.downloading:
        return colorScheme.primary;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.queued:
        return colorScheme.secondary;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.canceled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.queued:
        return Icons.queue;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.canceled:
        return Icons.cancel;
    }
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.canceled:
        return 'Canceled';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(0)}m';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
