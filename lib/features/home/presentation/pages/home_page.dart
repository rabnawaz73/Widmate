import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/providers/video_download_provider.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/presentation/controllers/download_controller.dart';
import 'package:widmate/features/home/presentation/widgets/playlist_selection_widget.dart';

import 'package:widmate/features/settings/presentation/providers/download_preset_provider.dart';
import 'package:widmate/features/settings/domain/models/download_preset.dart';
import 'package:widmate/core/models/download_models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  late final AnimationController _bannerController;
  late final PageController _pageController;
  int _currentPlatform = 0;

  VideoInfo? _videoInfo;
  bool _isLoading = false;
  String? _selectedFormatId;
  bool _audioOnly = false;
  String _selectedQuality = '720p';
  DownloadPreset? _selectedPreset;

  static final List<Map<String, dynamic>> _supportedPlatforms = [
    {
      'name': 'YouTube',
      'icon': Icons.play_circle_fill,
      'color': const Color(0xFFFF0000),
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
      ),
    },
    {
      'name': 'TikTok',
      'icon': Icons.music_note,
      'color': const Color(0xFF000000),
      'gradient': const LinearGradient(
        colors: [Color(0xFF000000), Color(0xFF333333)],
      ),
    },
    {
      'name': 'Instagram',
      'icon': Icons.camera_alt,
      'color': const Color(0xFFE4405F),
      'gradient': const LinearGradient(
        colors: [Color(0xFFE4405F), Color(0xFFFD1D1D), Color(0xFFFFDC80)],
      ),
    },
    {
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': const Color(0xFF1877F2),
      'gradient': const LinearGradient(
        colors: [Color(0xFF1877F2), Color(0xFF42A5F5)],
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _pageController = PageController();

    // Auto-scroll platforms
    _bannerController.addListener(() {
      if (_bannerController.value == 1.0) {
        setState(() {
          _currentPlatform =
              (_currentPlatform + 1) % _supportedPlatforms.length;
        });
        _pageController.animateToPage(
          _currentPlatform,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _pageController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _detectClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        setState(() {
          _urlController.text = clipboardData.text!;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link detected from clipboard!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Fetch video info when URL is pasted
          await _fetchVideoInfo(clipboardData.text!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access clipboard'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fetchVideoInfo(String url) async {
    if (url.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _videoInfo = null;
    });

    try {
      // Check if it's a playlist by fetching playlist info
      final videoInfo = await ref
          .read(videoDownloadServiceProvider)
          .getVideoInfo(
            url,
            playlistInfo: true, // Enable playlist detection
          );
      setState(() {
        _videoInfo = videoInfo;
        _isLoading = false;

        // Set default format if available (only for single videos)
        if (!videoInfo.isPlaylist && videoInfo.formats.isNotEmpty) {
          // Find a good default format (720p if available)
          final defaultFormat = videoInfo.formats.firstWhere(
            (format) => format.resolution == '720p',
            orElse: () => videoInfo.formats.first,
          );
          _selectedFormatId = defaultFormat.formatId;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching video info: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startBatchDownload(List<String> urls) async {
    final validUrls = urls.where((url) => url.trim().isNotEmpty).toList();

    if (validUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid URLs found.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int downloadCount = 0;
    for (final url in validUrls) {
      try {
        final videoInfo = await ref.read(videoDownloadServiceProvider).getVideoInfo(
              url,
              playlistInfo: true,
            );

        if (videoInfo.isPlaylist) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playlists are not supported in batch mode and will be skipped.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          continue; // Skip playlists
        }
        _startDownload(url: url);
        downloadCount++;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process URL $url: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Batch download started for $downloadCount videos.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Clear the input field after starting the downloads
    _urlController.clear();
  }

  void _startDownload({String? url}) async {
    final urlToDownload = url ?? _urlController.text.trim();
    if (urlToDownload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid URL'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // If it's a single download, fetch video info first
    if (url == null) {
      if (_videoInfo == null) {
        await _fetchVideoInfo(urlToDownload);
        if (_videoInfo == null) return; // Exit if fetch failed
      }
    } else {
      // For batch downloads, we fetch info for each URL individually
      await _fetchVideoInfo(urlToDownload);
      if (_videoInfo == null) return;
    }

    try {
      final downloadService = ref.read(videoDownloadServiceProvider);
      final downloadController = ref.read(downloadControllerProvider.notifier);

      final response = await downloadService.startDownload(
        url: urlToDownload,
        formatId: _selectedFormatId,
        quality: _selectedQuality,
        audioOnly: _audioOnly,
      );

      await downloadController.addDownload(
        url: urlToDownload,
        title: _videoInfo!.title,
        thumbnailUrl: _videoInfo!.thumbnail,
        platform: DownloadPlatform.youtube, // This should be dynamic
        downloadId: response.downloadId,
      );

      // For single downloads, show a confirmation and clear the UI
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Download started! Check the Downloads page for progress.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _videoInfo = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start download for $urlToDownload: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startPlaylistDownload(String playlistItems) async {
    if (_videoInfo == null || !_videoInfo!.isPlaylist) return;

    try {
      final downloadService = ref.read(videoDownloadServiceProvider);
      final downloadController = ref.read(downloadControllerProvider.notifier);

      // Start playlist download
      final response = await downloadService.startDownload(
        url: _urlController.text,
        quality: _selectedQuality,
        audioOnly: _audioOnly,
        playlistItems: playlistItems.isEmpty ? null : playlistItems,
      );

      // Add to download controller to track progress
      await downloadController.addDownload(
        url: _urlController.text,
        title: _videoInfo!.title,
        thumbnailUrl: _videoInfo!.thumbnail,
        platform: DownloadPlatform.youtube,
        downloadId: response.downloadId,
      );

      final itemCount = playlistItems.isEmpty
          ? _videoInfo!.playlistCount
          : playlistItems.split(',').length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist download started! $itemCount videos queued.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear video info to reset the UI
      setState(() {
        _videoInfo = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start playlist download: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return _buildDesktopLayout(context);
        } else if (constraints.maxWidth >= 900) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Section
              _buildWelcomeSection(theme, colorScheme),
              const SizedBox(height: 24),

              // URL Input Section
              _buildUrlInputSection(theme, colorScheme),
              const SizedBox(height: 24),

              // Video Info Display
              if (_videoInfo != null)
                _buildVideoInfoSection(theme, colorScheme),

              // Supported Platforms
              _buildSupportedPlatformsSection(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - URL Input and Quick Actions
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Section
                    Card(
                      elevation: 0,
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to WidMate',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Download videos from your favorite platforms',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onPrimaryContainer.withAlpha(
                                  204,
                                ), // 0.8 opacity
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // URL Input Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Enter Video URL',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _urlController,
                              decoration: InputDecoration(
                                hintText: 'Paste your video URL here...',
                                prefixIcon: const Icon(Icons.link),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () =>
                                          _fetchVideoInfo(_urlController.text),
                                      tooltip: 'Fetch video info',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.content_paste),
                                      onPressed: _detectClipboard,
                                      tooltip: 'Paste from clipboard',
                                    ),
                                  ],
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                              ),
                              maxLines: 2,
                              minLines: 1,
                              onSubmitted: _fetchVideoInfo,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : _startDownload,
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.download),
                                    label: Text(
                                      _isLoading ? 'Fetching...' : 'Download',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: _detectClipboard,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.content_paste),
                                        SizedBox(width: 8),
                                        Text('Detect'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Video Info Display for Tablet
                    if (_videoInfo != null && !_videoInfo!.isPlaylist) ...[
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.video_library,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Video Information',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_videoInfo!.thumbnail != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _videoInfo!.thumbnail!,
                                        width: 120,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 120,
                                                  height: 68,
                                                  color: colorScheme
                                                      .surfaceContainerHighest,
                                                  child: Icon(
                                                    Icons.video_library,
                                                    color: colorScheme.outline,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _videoInfo!.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_videoInfo!.uploader != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            _videoInfo!.uploader!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.outline,
                                                ),
                                          ),
                                        ],
                                        if (_videoInfo!.duration != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: colorScheme.outline,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDuration(
                                                  _videoInfo!.duration!,
                                                ),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.outline,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_videoInfo!.formats.isNotEmpty)
                        _buildFormatSelectionCard(theme, colorScheme),
                    ],

                    // Playlist Selection for Tablet
                    if (_videoInfo != null && _videoInfo!.isPlaylist) ...[
                      const SizedBox(height: 20),
                      PlaylistSelectionWidget(
                        playlistInfo: _videoInfo!,
                        onSelectionChanged: (selectedIndices) {
                          // Handle selection change if needed
                        },
                        onDownloadRequested: _startPlaylistDownload,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column - Platforms and Quick Actions
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Supported Platforms
                    Text(
                      'Supported Platforms',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Platform Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: _supportedPlatforms.length,
                      itemBuilder: (context, index) {
                        final platform = _supportedPlatforms[index];
                        return Container(
                          decoration: BoxDecoration(
                            gradient: platform['gradient'],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (platform['color'] as Color).withAlpha(
                                  77,
                                ), // 0.3 opacity
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  platform['icon'],
                                  size: 28,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  platform['name'],
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Footer space
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to WidMate',
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'The ultimate video downloader for all your favorite platforms. Download videos from YouTube, TikTok, Instagram, Facebook and more with just a few clicks.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer.withAlpha(
                                  204,
                                ), // 0.8 opacity
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Desktop URL Input
                            Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _urlController,
                                    decoration: InputDecoration(
                                      hintText: 'Paste your video URL here...',
                                      prefixIcon: const Icon(Icons.link),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.content_paste),
                                        onPressed: _detectClipboard,
                                        tooltip: 'Paste from clipboard',
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface,
                                    ),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 20),
                                  if (_videoInfo != null &&
                                      !_videoInfo!.isPlaylist &&
                                      _videoInfo!.formats.isNotEmpty) ...[
                                    _buildFormatSelectionCard(theme, colorScheme),
                                    const SizedBox(height: 20),
                                  ],
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: _isLoading
                                              ? null
                                              : _startDownload,
                                          icon: _isLoading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Icon(Icons.download),
                                          label: Text(
                                            _isLoading
                                                ? 'Fetching...'
                                                : 'Download Now',
                                          ),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      FilledButton.tonal(
                                        onPressed: _detectClipboard,
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.content_paste),
                                            SizedBox(width: 8),
                                            Text('Auto Detect'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),

                      // Platform Showcase
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              'Supported Platforms',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.1,
                                  ),
                              itemCount: _supportedPlatforms.length,
                              itemBuilder: (context, index) {
                                final platform = _supportedPlatforms[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: platform['gradient'],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (platform['color'] as Color)
                                            .withAlpha(102), // 0.4 opacity
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          platform['icon'],
                                          size: 32,
                                          color: colorScheme.onPrimary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          platform['name'],
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: colorScheme.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Features Section
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.speed,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Fast Downloads',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Download videos at maximum speed with our optimized download engine.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(
                                    179,
                                  ), // 0.7 opacity converted to alpha (255 * 0.7 = 179)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.high_quality,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'High Quality',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Download videos in the highest quality available, up to 4K resolution.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(
                                    179,
                                  ), // 0.7 opacity converted to alpha (255 * 0.7 = 179)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.security,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Safe & Secure',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your privacy is protected. We don\'t store your data or track your activity.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(
                                    179,
                                  ), // 0.7 opacity converted to alpha (255 * 0.7 = 179)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to WidMate',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Download videos from your favorite platforms',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInputSection(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Video URL(s)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Paste one or more video URLs, one per line...',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _fetchVideoInfo(_urlController.text),
                      tooltip: 'Fetch video info',
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _detectClipboard,
                      tooltip: 'Paste from clipboard',
                    ),
                  ],
                ),
                border: const OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 5,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (_isLoading) return;

                final urls = _urlController.text
                    .split('\n')
                    .where((url) => url.trim().isNotEmpty)
                    .toList();

                if (urls.length > 1) {
                  _startBatchDownload(urls);
                } else {
                  _startDownload();
                }
              },
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isLoading ? 'Fetching...' : 'Download',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfoSection(ThemeData theme, ColorScheme colorScheme) {
    if (_videoInfo == null) {
      return const SizedBox.shrink();
    }

    if (_videoInfo!.isPlaylist) {
      return PlaylistSelectionWidget(
        playlistInfo: _videoInfo!,
        onSelectionChanged: (selectedIndices) {
          // Handle selection change if needed
        },
        onDownloadRequested: _startPlaylistDownload,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.video_library,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Video Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPresetDropdown(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_videoInfo!.thumbnail != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _videoInfo!.thumbnail!,
                      width: 120,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 68,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.video_library,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _videoInfo!.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_videoInfo!.uploader != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _videoInfo!.uploader!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                      if (_videoInfo!.duration != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(
                                _videoInfo!.duration!,
                              ),
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
              ],
            ),
            const SizedBox(height: 16),
            if (_videoInfo!.formats.isNotEmpty)
              _buildFormatSelectionCard(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedPlatformsSection(
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supported Platforms',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _supportedPlatforms.length,
            onPageChanged: (index) {
              setState(() {
                _currentPlatform = index;
              });
            },
            itemBuilder: (context, index) {
              final platform = _supportedPlatforms[index];
              return AnimatedBuilder(
                animation: _bannerController,
                builder: (context, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: platform['gradient'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (platform['color'] as Color).withAlpha(
                            77,
                          ), // 0.3 opacity
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            platform['icon'],
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            platform['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _supportedPlatforms.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPlatform == index
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(77), // 0.3 opacity
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetDropdown() {
    final presets = ref.watch(downloadPresetProvider);
    return DropdownButtonFormField<DownloadPreset>(
      value: _selectedPreset,
      onChanged: (DownloadPreset? newValue) {
        setState(() {
          _selectedPreset = newValue;
          _applyPreset(newValue);
        });
      },
      items: presets.map((preset) {
        return DropdownMenuItem(
          value: preset,
          child: Text(preset.name),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Select Preset',
        border: OutlineInputBorder(),
      ),
    );
  }

  void _applyPreset(DownloadPreset? preset) {
    if (preset == null) {
      return;
    }
    setState(() {
      _selectedQuality = preset.quality;
      _audioOnly = preset.audioOnly;
    });
  }

  Widget _buildFormatSelectionCard(ThemeData theme, ColorScheme colorScheme) {
    final videoFormats = _videoInfo!.formats
        .where((f) => f.vcodec != null && f.vcodec != 'none')
        .toList();
    final audioFormats = _videoInfo!.formats
        .where((f) => f.acodec != null && f.acodec != 'none' && (f.vcodec == null || f.vcodec == 'none'))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Options',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (videoFormats.isNotEmpty) ...[
              Text(
                'Video',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...videoFormats.map((format) => RadioListTile<String>(
                    title: Text(
                        '${format.resolution} - ${format.ext.toUpperCase()}'),
                    subtitle: Text(
                        '${(format.filesize ?? 0 / (1024 * 1024)).toStringAsFixed(2)} MB'),
                    value: format.formatId,
                    groupValue: _selectedFormatId,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormatId = value;
                        _audioOnly = false;
                      });
                    },
                  )),
            ],
            if (audioFormats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Audio Only',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...audioFormats.map((format) => RadioListTile<String>(
                    title: Text(
                        '${format.audioBitrate}kbps - ${format.ext.toUpperCase()}'),
                    subtitle: Text(
                        '${(format.filesize ?? 0 / (1024 * 1024)).toStringAsFixed(2)} MB'),
                    value: format.formatId,
                    groupValue: _selectedFormatId,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormatId = value;
                        _audioOnly = true;
                      });
                    },
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
