import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';

/// Service for managing media player functionality
class MediaPlayerService {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  final StreamController<MediaPlayerState> _stateController =
      StreamController<MediaPlayerState>.broadcast();

  MediaPlayerState _currentState = const MediaPlayerState();
  Timer? _positionTimer;
  bool _isDisposed = false;

  /// Stream of media player state changes
  Stream<MediaPlayerState> get stateStream => _stateController.stream;

  /// Current media player state
  MediaPlayerState get currentState => _currentState;

  /// Initialize media player with source
  Future<void> initialize({
    required MediaSource source,
    MediaPlayerConfig? config,
  }) async {
    try {
      Logger.info('Initializing media player with source: ${source.url}');

      // Dispose previous controllers
      await dispose();

      // Create controllers based on media type
      if (source.mediaType == MediaType.video) {
        await _initializeVideoPlayer(source, config);
      } else {
        await _initializeAudioPlayer(source, config);
      }

      // Set up listeners
      _setupListeners();

      // Start position timer
      _startPositionTimer();

      Logger.info('Media player initialized successfully');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();

      _updateState(
        _currentState.copyWith(error: appError.message, isInitialized: false),
      );

      rethrow;
    }
  }

  /// Initialize video player
  Future<void> _initializeVideoPlayer(
    MediaSource source,
    MediaPlayerConfig? config,
  ) async {
    // Create video controller based on source type
    switch (source.type) {
      case MediaSourceType.network:
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(source.url),
          httpHeaders: source.headers ?? {},
        );
        break;
      case MediaSourceType.file:
        _videoController = VideoPlayerController.file(
          File(source.url),
        );
        break;
      case MediaSourceType.asset:
        _videoController = VideoPlayerController.asset(source.url);
        break;
    }

    // Initialize controller
    await _videoController!.initialize();

    // Apply configuration
    final effectiveConfig = config ?? const MediaPlayerConfig();
    await _applyVideoConfiguration(effectiveConfig);

    // Update state
    _updateState(
      _currentState.copyWith(
        videoController: _videoController,
        mediaType: MediaType.video,
        title: source.title,
        artist: source.artist,
        album: source.album,
        thumbnail: source.thumbnail,
        isInitialized: true,
        error: null,
      ),
    );
  }

  /// Initialize audio player
  Future<void> _initializeAudioPlayer(
    MediaSource source,
    MediaPlayerConfig? config,
  ) async {
    _audioPlayer = AudioPlayer();

    // Set audio source based on source type
    switch (source.type) {
      case MediaSourceType.network:
        await _audioPlayer!.setUrl(source.url, headers: source.headers);
        break;
      case MediaSourceType.file:
        await _audioPlayer!.setFilePath(source.url);
        break;
      case MediaSourceType.asset:
        await _audioPlayer!.setAsset(source.url);
        break;
    }

    // Apply configuration
    final effectiveConfig = config ?? const MediaPlayerConfig();
    await _applyAudioConfiguration(effectiveConfig);

    // Update state
    _updateState(
      _currentState.copyWith(
        audioPlayer: _audioPlayer,
        mediaType: MediaType.audio,
        title: source.title,
        artist: source.artist,
        album: source.album,
        thumbnail: source.thumbnail,
        isInitialized: true,
        error: null,
      ),
    );
  }

  /// Apply video player configuration
  Future<void> _applyVideoConfiguration(MediaPlayerConfig config) async {
    if (_videoController == null) return;

    await _videoController!.setVolume(config.volume);
    await _videoController!.setPlaybackSpeed(config.playbackSpeed);
    await _videoController!.setLooping(config.looping);

    if (config.startAt != null) {
      await _videoController!.seekTo(config.startAt!);
    }
  }

  /// Apply audio player configuration
  Future<void> _applyAudioConfiguration(MediaPlayerConfig config) async {
    if (_audioPlayer == null) return;

    await _audioPlayer!.setVolume(config.volume);
    await _audioPlayer!.setSpeed(config.playbackSpeed);
    await _audioPlayer!.setLoopMode(
      config.looping ? LoopMode.one : LoopMode.off,
    );

    if (config.startAt != null) {
      await _audioPlayer!.seek(config.startAt!);
    }
  }

  /// Set up media player listeners
  void _setupListeners() {
    if (_videoController != null) {
      _videoController!.addListener(_onVideoStateChanged);
    }

    if (_audioPlayer != null) {
      _audioPlayer!.playerStateStream.listen(_onAudioStateChanged);
      _audioPlayer!.positionStream.listen(_onAudioPositionChanged);
      _audioPlayer!.durationStream.listen(_onAudioDurationChanged);
    }
  }

  /// Handle video player state changes
  void _onVideoStateChanged() {
    if (_isDisposed || _videoController == null) return;

    final controller = _videoController!;

    _updateState(
      _currentState.copyWith(
        isPlaying: controller.value.isPlaying,
        isBuffering: controller.value.isBuffering,
        position: controller.value.position,
        duration: controller.value.duration,
        volume: controller.value.volume,
        playbackSpeed: controller.value.playbackSpeed,
      ),
    );
  }

  /// Handle audio player state changes
  void _onAudioStateChanged(PlayerState playerState) {
    if (_isDisposed || _audioPlayer == null) return;

    _updateState(
      _currentState.copyWith(
        isPlaying: playerState.playing,
        isBuffering: playerState.processingState == ProcessingState.loading,
      ),
    );
  }

  /// Handle audio position changes
  void _onAudioPositionChanged(Duration position) {
    if (_isDisposed || _audioPlayer == null) return;

    _updateState(_currentState.copyWith(position: position));
  }

  /// Handle audio duration changes
  void _onAudioDurationChanged(Duration? duration) {
    if (_isDisposed || _audioPlayer == null || duration == null) return;

    _updateState(_currentState.copyWith(duration: duration));
  }

  /// Start position update timer
  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (_videoController != null && _videoController!.value.isPlaying) {
        _updateState(
          _currentState.copyWith(position: _videoController!.value.position),
        );
      }
    });
  }

  /// Update player state
  void _updateState(MediaPlayerState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Play media
  Future<void> play() async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.play();
      } else if (_audioPlayer != null) {
        await _audioPlayer!.play();
      }
      Logger.debug('Media playback started');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Pause media
  Future<void> pause() async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.pause();
      } else if (_audioPlayer != null) {
        await _audioPlayer!.pause();
      }
      Logger.debug('Media playback paused');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_currentState.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.seekTo(position);
      } else if (_audioPlayer != null) {
        await _audioPlayer!.seek(position);
      }
      Logger.debug('Seeked to: ${position.inSeconds}s');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.setVolume(volume.clamp(0.0, 1.0));
      } else if (_audioPlayer != null) {
        await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
      }
      Logger.debug('Volume set to: $volume');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.setPlaybackSpeed(speed);
      } else if (_audioPlayer != null) {
        await _audioPlayer!.setSpeed(speed);
      }
      Logger.debug('Playback speed set to: $speed');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Toggle mute/unmute
  Future<void> toggleMute() async {
    if (_currentState.isMuted) {
      await setVolume(1.0);
    } else {
      await setVolume(0.0);
    }
  }

  /// Set looping
  Future<void> setLooping(bool looping) async {
    if (!_currentState.isInitialized) return;

    try {
      if (_videoController != null) {
        await _videoController!.setLooping(looping);
      } else if (_audioPlayer != null) {
        await _audioPlayer!.setLoopMode(looping ? LoopMode.one : LoopMode.off);
      }
      Logger.debug('Looping set to: $looping');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      _updateState(_currentState.copyWith(error: appError.message));
    }
  }

  /// Skip forward by duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _currentState.position + duration;
    final maxPosition = _currentState.duration;

    if (newPosition <= maxPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(maxPosition);
    }
  }

  /// Skip backward by duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _currentState.position - duration;
    const minPosition = Duration.zero;

    if (newPosition >= minPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(minPosition);
    }
  }

  /// Get video aspect ratio
  double? get aspectRatio {
    if (_videoController == null || !_currentState.isInitialized) return null;
    return _videoController!.value.aspectRatio;
  }

  /// Get video size
  Size? get videoSize {
    if (_videoController == null || !_currentState.isInitialized) return null;
    return _videoController!.value.size;
  }

  /// Check if media is ready to play
  bool get isReadyToPlay {
    return _currentState.isInitialized &&
        !_currentState.isBuffering &&
        _currentState.error == null;
  }

  /// Dispose media player
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _positionTimer?.cancel();

    if (_videoController != null) {
      _videoController!.removeListener(_onVideoStateChanged);
      await _videoController!.dispose();
      _videoController = null;
    }

    if (_audioPlayer != null) {
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    _updateState(const MediaPlayerState());

    if (!_stateController.isClosed) {
      await _stateController.close();
    }

    Logger.info('Media player disposed');
  }
}
