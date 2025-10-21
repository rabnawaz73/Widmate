import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';
import 'package:widmate/features/media/domain/providers/media_player_provider.dart';

/// Widget for displaying a list of media files
class MediaFileListWidget extends ConsumerWidget {
  final List<MediaFile> items;
  final String title;
  final VoidCallback? onRefresh;

  const MediaFileListWidget({
    super.key,
    required this.items,
    required this.title,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No $title found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Download some media to see them here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.type == MediaType.video
                  ? Icons.play_circle
                  : Icons.music_note,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            item.title ?? item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              // Play the media item
              final mediaSource = MediaSource.file(
                item.path,
                mediaType: item.type,
                title: item.title ?? item.name,
                artist: item.artist ?? 'Unknown Artist',
                album: item.album ?? 'Unknown Album',
              );
              await ref
                  .read(mediaPlayerActionsProvider)
                  .initialize(source: mediaSource);
              await ref.read(mediaPlayerActionsProvider).play();
            },
          ),
        );
      },
    );
  }
}
