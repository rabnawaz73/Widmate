import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';

/// Background media service for playing audio/video in background
class BackgroundMediaService extends BaseAudioHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<MediaPlayerState> _stateController =
      StreamController<MediaPlayerState>.broadcast();

  MediaPlayerState _currentState = const MediaPlayerState();
  MediaSource? _currentSource;
  Timer? _positionTimer;

  /// Stream of media player state changes
  Stream<MediaPlayerState> get stateStream => _stateController.stream;

  /// Current media player state
  MediaPlayerState get currentState => _currentState;

  Future<void> onPlay() async {
    try {
      await _audioPlayer.play();
      _updateState(_currentState.copyWith(isPlaying: true));
      Logger.info('Background playback started');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  Future<void> onPause() async {
    try {
      await _audioPlayer.pause();
      _updateState(_currentState.copyWith(isPlaying: false));
      Logger.info('Background playback paused');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  Future<void> onStop() async {
    try {
      await _audioPlayer.stop();
      _updateState(
        _currentState.copyWith(isPlaying: false, position: Duration.zero),
      );
      Logger.info('Background playback stopped');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  Future<void> onSeekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _updateState(_currentState.copyWith(position: position));
      Logger.info('Seeked to: ${position.inSeconds}s');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  Future<void> onSkipToNext() async {
    // Implement skip to next if you have a playlist
    Logger.info('Skip to next requested');
  }

  Future<void> onSkipToPrevious() async {
    // Implement skip to previous if you have a playlist
    Logger.info('Skip to previous requested');
  }

  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) async {
    // Implement repeat mode
    Logger.info('Repeat mode set to: $repeatMode');
  }

  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // Implement shuffle mode
    Logger.info('Shuffle mode set to: $shuffleMode');
  }

  Future<void> onSetSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      _updateState(_currentState.copyWith(playbackSpeed: speed));
      Logger.info('Playback speed set to: $speed');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  Future<void> onSetVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      _updateState(_currentState.copyWith(volume: volume));
      Logger.info('Volume set to: $volume');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
    }
  }

  /// Initialize media source
  Future<void> initializeMedia(MediaSource source) async {
    try {
      Logger.info('Initializing background media: ${source.url}');

      _currentSource = source;

      // Set up audio player
      await _audioPlayer.setFilePath(source.url);

      // Set up listeners
      _setupListeners();

      // Start position timer
      _startPositionTimer();

      // Update state
      _updateState(
        _currentState.copyWith(
          mediaType: source.mediaType,
          title: source.title,
          artist: source.artist,
          album: source.album,
          thumbnail: source.thumbnail,
          isInitialized: true,
          error: null,
        ),
      );

      // Update media item for notification
      await _updateMediaItem();

      Logger.info('Background media initialized successfully');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();

      _updateState(
        _currentState.copyWith(error: appError.message, isInitialized: false),
      );
    }
  }

  /// Set up audio player listeners
  void _setupListeners() {
    _audioPlayer.playerStateStream.listen((playerState) {
      _updateState(
        _currentState.copyWith(
          isPlaying: playerState.playing,
          isBuffering: playerState.processingState == ProcessingState.loading,
        ),
      );
    });

    _audioPlayer.positionStream.listen((position) {
      _updateState(_currentState.copyWith(position: position));
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _updateState(_currentState.copyWith(duration: duration));
      }
    });
  }

  /// Start position update timer
  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_audioPlayer.playing) {
        _updateState(_currentState.copyWith(position: _audioPlayer.position));
      }
    });
  }

  /// Update media item for notification
  Future<void> _updateMediaItem() async {
    if (_currentSource == null) return;

    MediaItem(
      id: _currentSource!.url,
      title:
          _currentSource!.title ?? 'Unknown ${_currentSource!.mediaType.name}',
      artist: _currentSource!.artist ?? 'Unknown Artist',
      album: _currentSource!.album ?? 'Unknown Album',
      duration: _audioPlayer.duration,
      artUri: _currentSource!.thumbnail != null
          ? Uri.parse(_currentSource!.thumbnail!)
          : null,
      playable: true,
    );
  }

  /// Update player state
  void _updateState(MediaPlayerState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  /// Play media
  @override
  Future<void> play() async {
    await onPlay();
  }

  /// Pause media
  @override
  Future<void> pause() async {
    await onPause();
  }

  /// Stop media
  @override
  Future<void> stop() async {
    await onStop();
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await onSeekTo(position);
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await onSetVolume(volume);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    await onSetSpeed(speed);
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_currentState.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Skip forward
  Future<void> skipForward(Duration duration) async {
    final newPosition = _currentState.position + duration;
    final maxPosition = _currentState.duration;

    if (newPosition <= maxPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(maxPosition);
    }
  }

  /// Skip backward
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _currentState.position - duration;
    const minPosition = Duration.zero;

    if (newPosition >= minPosition) {
      await seekTo(newPosition);
    } else {
      await seekTo(minPosition);
    }
  }

  /// Dispose service
  @override
  Future<void> onTaskRemoved() async {
    await _audioPlayer.dispose();
    _positionTimer?.cancel();
    await _stateController.close();
    Logger.info('Background media service disposed');
  }
}
