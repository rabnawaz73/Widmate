import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/widgets/error_boundary.dart';
import 'package:widmate/features/media/domain/models/media_player_state.dart';
import 'package:widmate/features/media/domain/providers/media_player_provider.dart';

/// Main media player widget
class MediaPlayerWidget extends ConsumerStatefulWidget {
  final MediaSource source;
  final MediaPlayerConfig? config;
  final bool showControls;
  final bool allowFullscreen;
  final Widget? placeholder;
  final Widget? errorWidget;

  const MediaPlayerWidget({
    super.key,
    required this.source,
    this.config,
    this.showControls = true,
    this.allowFullscreen = true,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<MediaPlayerWidget> createState() => _MediaPlayerWidgetState();
}

class _MediaPlayerWidgetState extends ConsumerState<MediaPlayerWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final actions = ref.read(mediaPlayerActionsProvider);
      await actions.initialize(source: widget.source, config: widget.config);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      Logger.error('Failed to initialize media player', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currentMediaPlayerStateProvider);
    final actions = ref.watch(mediaPlayerActionsProvider);

    return ErrorBoundary(
      errorBuilder: (error, onRetry) =>
          widget.errorWidget ?? _buildErrorWidget(error, onRetry),
      child: Container(
        color: Colors.black,
        child: _buildMediaPlayer(state, actions),
      ),
    );
  }

  Widget _buildMediaPlayer(MediaPlayerState state, MediaPlayerActions actions) {
    if (!_isInitialized || (!state.isInitialized && state.error == null)) {
      return widget.placeholder ?? _buildLoadingWidget();
    }

    if (state.error != null) {
      return _buildErrorWidget(
        UnknownError(message: state.error!.toString()),
        () => _initializePlayer(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Media player
        _buildMediaContent(state),

        // Controls overlay
        if (widget.showControls)
          MediaPlayerControls(
            state: state,
            actions: actions,
            allowFullscreen: widget.allowFullscreen,
          ),
      ],
    );
  }

  Widget _buildMediaContent(MediaPlayerState state) {
    if (state.mediaType == MediaType.video && state.videoController != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: state.videoController!.value.aspectRatio,
          child: VideoPlayer(state.videoController!),
        ),
      );
    } else if (state.mediaType == MediaType.audio) {
      return _buildAudioVisualizer(state);
    } else {
      return _buildLoadingWidget();
    }
  }

  Widget _buildAudioVisualizer(MediaPlayerState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[900]!, Colors.blue[900]!, Colors.indigo[900]!],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art or thumbnail
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(26),
              border: Border.all(
                color: Colors.white.withAlpha(77),
                width: 2,
              ),
            ),
            child: state.thumbnail != null
                ? ClipOval(
                    child: Image.network(
                      state.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAudioIcon(),
                    ),
                  )
                : _buildDefaultAudioIcon(),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            state.displayTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Artist
          Text(
            state.displayArtist,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Album
          Text(
            state.displayAlbum,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAudioIcon() {
    return const Icon(Icons.music_note, color: Colors.white54, size: 80);
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Loading media...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AppError error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load media',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Don't dispose here as the provider manages the lifecycle
    super.dispose();
  }
}

/// Media player controls overlay
class MediaPlayerControls extends StatefulWidget {
  final MediaPlayerState state;
  final MediaPlayerActions actions;
  final bool allowFullscreen;

  const MediaPlayerControls({
    super.key,
    required this.state,
    required this.actions,
    this.allowFullscreen = true,
  });

  @override
  State<MediaPlayerControls> createState() => _MediaPlayerControlsState();
}

class _MediaPlayerControlsState extends State<MediaPlayerControls> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onTap() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: AppConstants.animationDuration,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(179),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withAlpha(179),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top controls
              _buildTopControls(),

              // Center play button
              Expanded(child: Center(child: _buildCenterControls())),

              // Bottom controls
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Title
          Expanded(
            child: Text(
              widget.state.displayTitle,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Fullscreen button (only for video)
          if (widget.allowFullscreen &&
              widget.state.mediaType == MediaType.video)
            IconButton(
              onPressed: _toggleFullscreen,
              icon: const Icon(Icons.fullscreen, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    if (widget.state.isBuffering) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return IconButton(
      onPressed: widget.actions.togglePlayPause,
      icon: Icon(
        widget.state.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 64,
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildProgressBar(),

          const SizedBox(height: 8),

          // Bottom row controls
          Row(
            children: [
              // Play/pause button
              IconButton(
                onPressed: widget.actions.togglePlayPause,
                icon: Icon(
                  widget.state.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),

              // Time display
              Text(
                '${widget.state.formattedPosition} / ${widget.state.formattedDuration}',
                style: const TextStyle(color: Colors.white),
              ),

              const Spacer(),

              // Volume button
              IconButton(
                onPressed: widget.actions.toggleMute,
                icon: Icon(
                  widget.state.volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
              ),

              // Speed button
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, color: Colors.white),
                onSelected: widget.actions.setPlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white30,
        thumbColor: Colors.white,
        overlayColor: Colors.white24,
      ),
      child: Slider(
        value: widget.state.progress,
        onChanged: (value) {
          final position = Duration(
            milliseconds:
                (value * widget.state.duration.inMilliseconds).round(),
          );
          widget.actions.seekTo(position);
        },
      ),
    );
  }

  void _toggleFullscreen() {
    // Implement fullscreen toggle
    // This would typically involve changing the app's orientation
    // and hiding the system UI
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }
}
