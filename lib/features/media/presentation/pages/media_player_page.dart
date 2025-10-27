import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

class MediaPlayerPage extends StatefulWidget {
  final String filePath;
  final String title;

  const MediaPlayerPage({super.key, required this.filePath, required this.title});

  @override
  State<MediaPlayerPage> createState() => _MediaPlayerPageState();
}

class _MediaPlayerPageState extends State<MediaPlayerPage> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isAudio = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final file = File(widget.filePath);
    if (!await file.exists()) {
      _showError('File not found: ${widget.filePath}');
      return;
    }

    final fileExtension = widget.filePath.split('.').last.toLowerCase();
    _isAudio = ['mp3', 'wav', 'aac', 'flac', 'ogg'].contains(fileExtension);

    if (_isAudio) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.setFilePath(widget.filePath);
      _audioPlayer!.playerStateStream.listen((playerState) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      });
      _audioPlayer!.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
      _audioPlayer!.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
    } else {
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      _videoController!.addListener(() {
        setState(() {
          _isPlaying = _videoController!.value.isPlaying;
          _duration = _videoController!.value.duration;
          _position = _videoController!.value.position;
        });
      });
    }
    setState(() {});
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.of(context).pop(); // Go back if file not found or error
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isAudio) {
      if (_isPlaying) {
        _audioPlayer?.pause();
      } else {
        _audioPlayer?.play();
      }
    } else {
      if (_isPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isAudio
          ? _buildAudioPlayerUI()
          : _buildVideoPlayerUI(),
    );
  }

  Widget _buildAudioPlayerUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildPlaybackControls(),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerUI() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        _buildPlaybackControls(),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          onPressed: () {
            final newPosition = _position - const Duration(seconds: 10);
            if (_isAudio) {
              _audioPlayer?.seek(newPosition);
            } else {
              _videoController?.seekTo(newPosition);
            }
          },
        ),
        IconButton(
          iconSize: 50,
          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          onPressed: _togglePlayPause,
        ),
        IconButton(
          icon: const Icon(Icons.forward_10),
          onPressed: () {
            final newPosition = _position + const Duration(seconds: 10);
            if (_isAudio) {
              _audioPlayer?.seek(newPosition);
            } else {
              _videoController?.seekTo(newPosition);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(_formatDuration(_position)),
          Expanded(
            child: Slider(
              min: 0.0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble(),
              onChanged: (value) {
                final newPosition = Duration(milliseconds: value.toInt());
                if (_isAudio) {
                  _audioPlayer?.seek(newPosition);
                } else {
                  _videoController?.seekTo(newPosition);
                }
              },
            ),
          ),
          Text(_formatDuration(_duration)),
        ],
      ),
    );
  }
}
