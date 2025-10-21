import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';
import 'package:widmate/features/media/domain/providers/media_player_provider.dart';
import 'package:widmate/features/media/presentation/widgets/media_player_widget.dart';

/// Media library page with tabs for different media types
class MediaLibraryPage extends ConsumerStatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  ConsumerState<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends ConsumerState<MediaLibraryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ref.watch(mediaTabsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: tabs
              .map(
                (tab) =>
                    Tab(icon: Icon(_getTabIcon(tab.type)), text: tab.title),
              )
              .toList(),
        ),
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Downloaded Videos
          MediaFileListWidget(mediaType: MediaType.video, isDownloaded: true),
          // Downloaded Audios
          MediaFileListWidget(mediaType: MediaType.audio, isDownloaded: true),
          // Device Videos
          MediaFileListWidget(mediaType: MediaType.video, isDownloaded: false),
          // Device Audios
          MediaFileListWidget(mediaType: MediaType.audio, isDownloaded: false),
        ],
      ),
    );
  }

  IconData _getTabIcon(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.video_library;
      case MediaType.audio:
        return Icons.audio_file;
    }
  }
}

/// Media file list widget
class MediaFileListWidget extends ConsumerWidget {
  final MediaType mediaType;
  final bool isDownloaded;

  const MediaFileListWidget({
    super.key,
    required this.mediaType,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaFilesAsync = ref.watch(
      isDownloaded
          ? (mediaType == MediaType.video
              ? downloadedVideosProvider
              : downloadedAudiosProvider)
          : (mediaType == MediaType.video
              ? deviceVideosProvider
              : deviceAudiosProvider),
    );

    return mediaFilesAsync.when(
      data: (mediaFiles) => _buildMediaList(context, mediaFiles, ref),
      loading: () => _buildLoadingWidget(),
      error: (error, stackTrace) =>
          _buildErrorWidget(context, error.toString(), ref),
    );
  }

  Widget _buildMediaList(
      BuildContext context, List<MediaFile> mediaFiles, WidgetRef ref) {
    if (mediaFiles.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return _buildMediaItem(context, mediaFile, ref);
      },
    );
  }

  Widget _buildMediaItem(
      BuildContext context, MediaFile mediaFile, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      child: ListTile(
        leading: _buildMediaThumbnail(mediaFile),
        title: Text(
          mediaFile.title ?? mediaFile.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mediaFile.artist != null)
              Text(
                mediaFile.artist!,
                style: const TextStyle(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Text(
                  mediaFile.formattedDuration,
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.white54)),
                const SizedBox(width: 8),
                Text(
                  mediaFile.formattedSize,
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) =>
              _handleMenuAction(context, mediaFile, value, ref),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Play'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _playMedia(context, mediaFile),
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaFile mediaFile) {
    if (mediaFile.thumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          mediaFile.thumbnail!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultThumbnail(mediaFile.type),
        ),
      );
    } else {
      return _buildDefaultThumbnail(mediaFile.type);
    }
  }

  Widget _buildDefaultThumbnail(MediaType type) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        type == MediaType.video ? Icons.video_library : Icons.audio_file,
        color: Colors.white54,
        size: 30,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Loading media files...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load media files',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _refreshMediaFiles(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDownloaded
                ? (mediaType == MediaType.video
                    ? Icons.video_library
                    : Icons.audio_file)
                : (mediaType == MediaType.video
                    ? Icons.video_library
                    : Icons.audio_file),
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isDownloaded
                ? 'No downloaded ${mediaType.name}s found'
                : 'No device ${mediaType.name}s found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDownloaded
                ? 'Download some ${mediaType.name}s to see them here'
                : 'No ${mediaType.name} files found on your device',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playMedia(BuildContext context, MediaFile mediaFile) {
    final mediaSource = MediaSource.file(
      mediaFile.path,
      mediaType: mediaFile.type,
      title: mediaFile.title,
      artist: mediaFile.artist,
      album: mediaFile.album,
      thumbnail: mediaFile.thumbnail,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaPlayerPage(
          source: mediaSource,
          title: mediaFile.title ?? mediaFile.name,
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    MediaFile mediaFile,
    String action,
    WidgetRef ref,
  ) {
    switch (action) {
      case 'play':
        _playMedia(context, mediaFile);
        break;
      case 'info':
        _showMediaInfo(context, mediaFile);
        break;
      case 'delete':
        _deleteMedia(context, mediaFile, ref);
        break;
    }
  }

  void _showMediaInfo(BuildContext context, MediaFile mediaFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Media Info', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', mediaFile.name),
            _buildInfoRow('Title', mediaFile.title ?? 'Unknown'),
            _buildInfoRow('Artist', mediaFile.artist ?? 'Unknown'),
            _buildInfoRow('Album', mediaFile.album ?? 'Unknown'),
            _buildInfoRow('Duration', mediaFile.formattedDuration),
            _buildInfoRow('Size', mediaFile.formattedSize),
            _buildInfoRow('Type', mediaFile.type.name.toUpperCase()),
            _buildInfoRow('Path', mediaFile.path),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteMedia(BuildContext context, MediaFile mediaFile, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Media',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${mediaFile.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDelete(
                  context, ref, mediaFile, isDownloaded, mediaType);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(BuildContext context, WidgetRef ref,
      MediaFile mediaFile, bool isDownloaded, MediaType mediaType) async {
    try {
      final service = ref.read(mediaFileServiceProvider);
      final success = await service.deleteMediaFile(mediaFile.path);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Media deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the media files
        ref.invalidate(
          isDownloaded
              ? (mediaType == MediaType.video
                  ? downloadedVideosProvider
                  : downloadedAudiosProvider)
              : (mediaType == MediaType.video
                  ? deviceVideosProvider
                  : deviceAudiosProvider),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete media'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _refreshMediaFiles(WidgetRef ref) {
    ref.invalidate(
      isDownloaded
          ? (mediaType == MediaType.video
              ? downloadedVideosProvider
              : downloadedAudiosProvider)
          : (mediaType == MediaType.video
              ? deviceVideosProvider
              : deviceAudiosProvider),
    );
  }
}

/// Media player page
class MediaPlayerPage extends StatelessWidget {
  final MediaSource source;
  final String? title;

  const MediaPlayerPage({super.key, required this.source, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: MediaPlayerWidget(
          source: source,
          showControls: true,
          allowFullscreen: true,
        ),
      ),
    );
  }
}
