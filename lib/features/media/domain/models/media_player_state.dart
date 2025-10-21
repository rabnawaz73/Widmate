import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

/// Media type enumeration
enum MediaType { video, audio }

/// Media player state management
class MediaPlayerState {
  final VideoPlayerController? videoController;
  final AudioPlayer? audioPlayer;
  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double volume;
  final double playbackSpeed;
  final bool isFullscreen;
  final bool isMuted;
  final String? error;
  final MediaType mediaType;
  final String? title;
  final String? artist;
  final String? album;
  final String? thumbnail;

  const MediaPlayerState({
    this.videoController,
    this.audioPlayer,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.isFullscreen = false,
    this.isMuted = false,
    this.error,
    this.mediaType = MediaType.video,
    this.title,
    this.artist,
    this.album,
    this.thumbnail,
  });

  MediaPlayerState copyWith({
    VideoPlayerController? videoController,
    AudioPlayer? audioPlayer,
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? volume,
    double? playbackSpeed,
    bool? isFullscreen,
    bool? isMuted,
    String? error,
    MediaType? mediaType,
    String? title,
    String? artist,
    String? album,
    String? thumbnail,
  }) {
    return MediaPlayerState(
      videoController: videoController ?? this.videoController,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isMuted: isMuted ?? this.isMuted,
      error: error ?? this.error,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  /// Get progress as a percentage (0.0 to 1.0)
  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime {
    return duration - position;
  }

  /// Check if media is at the end
  bool get isAtEnd {
    return position >= duration && duration.inMilliseconds > 0;
  }

  /// Get formatted position string
  String get formattedPosition {
    return _formatDuration(position);
  }

  /// Get formatted duration string
  String get formattedDuration {
    return _formatDuration(duration);
  }

  /// Get formatted remaining time string
  String get formattedRemainingTime {
    return _formatDuration(remainingTime);
  }

  /// Get display title
  String get displayTitle {
    return title ?? 'Unknown ${mediaType.name}';
  }

  /// Get display artist
  String get displayArtist {
    return artist ?? 'Unknown Artist';
  }

  /// Get display album
  String get displayAlbum {
    return album ?? 'Unknown Album';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

/// Media source types
enum MediaSourceType { network, file, asset }

/// Media source model
class MediaSource {
  final String url;
  final MediaSourceType type;
  final MediaType mediaType;
  final String? title;
  final String? artist;
  final String? album;
  final String? thumbnail;
  final Map<String, String>? headers;

  const MediaSource({
    required this.url,
    required this.type,
    required this.mediaType,
    this.title,
    this.artist,
    this.album,
    this.thumbnail,
    this.headers,
  });

  /// Create network media source
  factory MediaSource.network(
    String url, {
    required MediaType mediaType,
    String? title,
    String? artist,
    String? album,
    String? thumbnail,
    Map<String, String>? headers,
  }) {
    return MediaSource(
      url: url,
      type: MediaSourceType.network,
      mediaType: mediaType,
      title: title,
      artist: artist,
      album: album,
      thumbnail: thumbnail,
      headers: headers,
    );
  }

  /// Create file media source
  factory MediaSource.file(
    String filePath, {
    required MediaType mediaType,
    String? title,
    String? artist,
    String? album,
    String? thumbnail,
  }) {
    return MediaSource(
      url: filePath,
      type: MediaSourceType.file,
      mediaType: mediaType,
      title: title,
      artist: artist,
      album: album,
      thumbnail: thumbnail,
    );
  }

  /// Create asset media source
  factory MediaSource.asset(
    String assetPath, {
    required MediaType mediaType,
    String? title,
    String? artist,
    String? album,
    String? thumbnail,
  }) {
    return MediaSource(
      url: assetPath,
      type: MediaSourceType.asset,
      mediaType: mediaType,
      title: title,
      artist: artist,
      album: album,
      thumbnail: thumbnail,
    );
  }
}

/// Media file information
class MediaFile {
  final String path;
  final String name;
  final MediaType type;
  final int size;
  final Duration? duration;
  final String? title;
  final String? artist;
  final String? album;
  final String? thumbnail;
  final DateTime dateAdded;
  final DateTime dateModified;

  const MediaFile({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    this.duration,
    this.title,
    this.artist,
    this.album,
    this.thumbnail,
    required this.dateAdded,
    required this.dateModified,
  });

  /// Get file extension
  String get extension {
    return name.split('.').last.toLowerCase();
  }

  /// Get file size in human readable format
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get formatted duration
  String get formattedDuration {
    if (duration == null) return 'Unknown';
    return _formatDuration(duration!);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }
}

/// Media player configuration
class MediaPlayerConfig {
  final bool autoPlay;
  final bool looping;
  final double volume;
  final double playbackSpeed;
  final bool showControls;
  final bool allowFullscreen;
  final bool allowPictureInPicture;
  final bool enableBackgroundPlayback;
  final Duration? startAt;

  const MediaPlayerConfig({
    this.autoPlay = false,
    this.looping = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.showControls = true,
    this.allowFullscreen = true,
    this.allowPictureInPicture = true,
    this.enableBackgroundPlayback = true,
    this.startAt,
  });

  MediaPlayerConfig copyWith({
    bool? autoPlay,
    bool? looping,
    double? volume,
    double? playbackSpeed,
    bool? showControls,
    bool? allowFullscreen,
    bool? allowPictureInPicture,
    bool? enableBackgroundPlayback,
    Duration? startAt,
  }) {
    return MediaPlayerConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      looping: looping ?? this.looping,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      showControls: showControls ?? this.showControls,
      allowFullscreen: allowFullscreen ?? this.allowFullscreen,
      allowPictureInPicture:
          allowPictureInPicture ?? this.allowPictureInPicture,
      enableBackgroundPlayback:
          enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      startAt: startAt ?? this.startAt,
    );
  }
}
