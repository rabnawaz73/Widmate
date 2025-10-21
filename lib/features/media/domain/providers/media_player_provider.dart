import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/media/domain/services/media_player_service.dart';
import 'package:widmate/features/media/domain/services/media_file_service.dart';
import 'package:widmate/features/media/domain/services/background_media_service.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';

/// Provider for media player service
final mediaPlayerServiceProvider = Provider<MediaPlayerService>((ref) {
  return MediaPlayerService();
});

/// Provider for media file service
final mediaFileServiceProvider = Provider<MediaFileService>((ref) {
  return MediaFileService.instance;
});

/// Provider for background media service
final backgroundMediaServiceProvider = Provider<BackgroundMediaService>((ref) {
  return BackgroundMediaService();
});

/// Provider for media player state
final mediaPlayerStateProvider = StreamProvider<MediaPlayerState>((ref) {
  final service = ref.watch(mediaPlayerServiceProvider);
  return service.stateStream;
});

/// Provider for current media player state
final currentMediaPlayerStateProvider = Provider<MediaPlayerState>((ref) {
  final stateAsync = ref.watch(mediaPlayerStateProvider);
  return stateAsync.when(
    data: (state) => state,
    loading: () => const MediaPlayerState(),
    error: (_, __) => const MediaPlayerState(),
  );
});

/// Provider for media player actions
final mediaPlayerActionsProvider = Provider<MediaPlayerActions>((ref) {
  final service = ref.watch(mediaPlayerServiceProvider);
  return MediaPlayerActions(service);
});

/// Provider for downloaded videos
final downloadedVideosProvider = FutureProvider<List<MediaFile>>((ref) async {
  final service = ref.watch(mediaFileServiceProvider);
  return await service.getDownloadedVideos();
});

/// Provider for downloaded audios
final downloadedAudiosProvider = FutureProvider<List<MediaFile>>((ref) async {
  final service = ref.watch(mediaFileServiceProvider);
  return await service.getDownloadedAudios();
});

/// Provider for device videos
final deviceVideosProvider = FutureProvider<List<MediaFile>>((ref) async {
  final service = ref.watch(mediaFileServiceProvider);
  return await service.getDeviceVideos();
});

/// Provider for device audios
final deviceAudiosProvider = FutureProvider<List<MediaFile>>((ref) async {
  final service = ref.watch(mediaFileServiceProvider);
  return await service.getDeviceAudios();
});

/// Media player actions class
class MediaPlayerActions {
  final MediaPlayerService _service;

  MediaPlayerActions(this._service);

  /// Initialize media player
  Future<void> initialize({
    required MediaSource source,
    MediaPlayerConfig? config,
  }) async {
    await _service.initialize(source: source, config: config);
  }

  /// Play media
  Future<void> play() async {
    await _service.play();
  }

  /// Pause media
  Future<void> pause() async {
    await _service.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _service.seekTo(position);
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await _service.setPlaybackSpeed(speed);
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    await _service.toggleMute();
  }

  /// Set looping
  Future<void> setLooping(bool looping) async {
    await _service.setLooping(looping);
  }

  /// Skip forward
  Future<void> skipForward(Duration duration) async {
    await _service.skipForward(duration);
  }

  /// Skip backward
  Future<void> skipBackward(Duration duration) async {
    await _service.skipBackward(duration);
  }

  /// Dispose media player
  Future<void> dispose() async {
    await _service.dispose();
  }
}

/// Provider for media player configuration
final mediaPlayerConfigProvider = StateProvider<MediaPlayerConfig>((ref) {
  return const MediaPlayerConfig();
});

/// Provider for media source
final mediaSourceProvider = StateProvider<MediaSource?>((ref) {
  return null;
});

/// Provider for media player initialization
final mediaPlayerInitializationProvider = FutureProvider<void>((ref) async {
  final source = ref.watch(mediaSourceProvider);
  final config = ref.watch(mediaPlayerConfigProvider);
  final actions = ref.watch(mediaPlayerActionsProvider);

  if (source != null) {
    await actions.initialize(source: source, config: config);
  }
});

/// Provider for media tabs
final mediaTabsProvider = StateProvider<List<MediaTab>>((ref) {
  return [
    const MediaTab(
      id: 'downloaded_videos',
      title: 'Downloaded Videos',
      type: MediaType.video,
      isDownloaded: true,
    ),
    const MediaTab(
      id: 'downloaded_audios',
      title: 'Downloaded Audios',
      type: MediaType.audio,
      isDownloaded: true,
    ),
    const MediaTab(
      id: 'device_videos',
      title: 'Device Videos',
      type: MediaType.video,
      isDownloaded: false,
    ),
    const MediaTab(
      id: 'device_audios',
      title: 'Device Audios',
      type: MediaType.audio,
      isDownloaded: false,
    ),
  ];
});

/// Provider for selected media tab
final selectedMediaTabProvider = StateProvider<MediaTab?>((ref) {
  final tabs = ref.watch(mediaTabsProvider);
  return tabs.isNotEmpty ? tabs.first : null;
});

/// Media tab model
class MediaTab {
  final String id;
  final String title;
  final MediaType type;
  final bool isDownloaded;

  const MediaTab({
    required this.id,
    required this.title,
    required this.type,
    required this.isDownloaded,
  });
}
