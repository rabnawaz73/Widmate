import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';
import 'package:widmate/features/media/domain/providers/media_player_provider.dart';
import 'package:widmate/features/media/presentation/widgets/media_player_widget.dart';

class MediaLibraryPage extends ConsumerStatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  ConsumerState<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends ConsumerState<MediaLibraryPage> {
  bool _isGridView = true;
  String _searchTerm = '';
  MediaType _mediaType = MediaType.video;
  bool _isDownloaded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaFilesAsync = ref.watch(
      _isDownloaded
          ? (_mediaType == MediaType.video
              ? downloadedVideosProvider
              : downloadedAudiosProvider)
          : (_mediaType == MediaType.video
              ? deviceVideosProvider
              : deviceAudiosProvider),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(theme, colorScheme),
          _buildSearchBar(theme, colorScheme),
          Expanded(
            child: mediaFilesAsync.when(
              data: (mediaFiles) {
                final filteredFiles = mediaFiles
                    .where((file) => file.title!
                        .toLowerCase()
                        .contains(_searchTerm.toLowerCase()))
                    .toList();
                return _isGridView
                    ? _buildMediaGrid(filteredFiles)
                    : _buildMediaList(filteredFiles);
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('Downloaded'),
            selected: _isDownloaded,
            onSelected: (selected) {
              setState(() {
                _isDownloaded = selected;
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Device'),
            selected: !_isDownloaded,
            onSelected: (selected) {
              setState(() {
                _isDownloaded = !selected;
              });
            },
          ),
          const SizedBox(width: 16),
          ChoiceChip(
            label: const Text('Videos'),
            selected: _mediaType == MediaType.video,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _mediaType = MediaType.video;
                });
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Audios'),
            selected: _mediaType == MediaType.audio,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _mediaType = MediaType.audio;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search media...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid(List<MediaFile> mediaFiles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return _buildMediaGridItem(mediaFile);
      },
    );
  }

  Widget _buildMediaList(List<MediaFile> mediaFiles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final mediaFile = mediaFiles[index];
        return _buildMediaListItem(mediaFile);
      },
    );
  }

  Widget _buildMediaGridItem(MediaFile mediaFile) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildMediaThumbnail(mediaFile),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mediaFile.title ?? mediaFile.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareMedia(mediaFile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaListItem(MediaFile mediaFile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildMediaThumbnail(mediaFile),
        title: Text(
          mediaFile.title ?? mediaFile.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(mediaFile.formattedDuration),
        trailing: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareMedia(mediaFile),
        ),
        onTap: () => _playMedia(mediaFile),
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaFile mediaFile) {
    if (mediaFile.thumbnail != null) {
      return Image.network(
        mediaFile.thumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            _buildDefaultThumbnail(mediaFile.type),
      );
    }
    return _buildDefaultThumbnail(mediaFile.type);
  }

  Widget _buildDefaultThumbnail(MediaType type) {
    return Container(
      color: Colors.grey[800],
      child: Icon(
        type == MediaType.video ? Icons.video_library : Icons.audio_file,
        color: Colors.white54,
        size: 48,
      ),
    );
  }

  void _playMedia(MediaFile mediaFile) {
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

  void _shareMedia(MediaFile mediaFile) {
    Share.shareXFiles([XFile(mediaFile.path)], text: mediaFile.title);
  }
}

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
