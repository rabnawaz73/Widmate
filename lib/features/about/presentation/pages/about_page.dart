import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widmate/app/src/responsive/responsive_breakpoints.dart';
import 'package:widmate/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/widgets/app_icon_widget.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPackageInfo();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildTechChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch $url', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error launching URL: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard');
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'WidMate Privacy Policy\n\n'
            'Last updated: December 2024\n\n'
            '1. Information We Collect\n'
            '• Downloaded video URLs and metadata\n'
            '• App usage statistics and crash reports\n'
            '• Device information for compatibility\n\n'
            '2. How We Use Your Information\n'
            '• To provide download services\n'
            '• To improve app performance\n'
            '• To provide customer support\n\n'
            '3. Data Storage\n'
            '• All data is stored locally on your device\n'
            '• We do not collect personal information\n'
            '• Downloaded videos remain on your device\n\n'
            '4. Third-Party Services\n'
            '• We use yt-dlp for video downloading\n'
            '• No data is shared with third parties\n\n'
            '5. Your Rights\n'
            '• You can delete all data anytime\n'
            '• You control what you download\n'
            '• No account registration required\n\n'
            'For questions, contact us at privacy@widmate.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'WidMate Terms of Service\n\n'
            'Last updated: December 2024\n\n'
            '1. Acceptance of Terms\n'
            'By using WidMate, you agree to these terms.\n\n'
            '2. Use of Service\n'
            '• Download only content you have rights to\n'
            '• Respect platform terms of service\n'
            '• Use for personal, non-commercial purposes\n\n'
            '3. Prohibited Uses\n'
            '• Copyright infringement\n'
            '• Commercial redistribution\n'
            '• Illegal activities\n\n'
            '4. Disclaimer\n'
            '• Use at your own risk\n'
            '• We are not responsible for downloaded content\n'
            '• Service provided "as is"\n\n'
            '5. Limitation of Liability\n'
            '• We are not liable for any damages\n'
            '• Use third-party services at your own risk\n\n'
            '6. Changes to Terms\n'
            '• We may update these terms\n'
            '• Continued use constitutes acceptance\n\n'
            'For questions, contact us at legal@widmate.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'WidMate',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const AppIconWidget(
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(settingsControllerProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // App Icon with Animation
                Hero(
                  tag: 'app_icon',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha(76),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.video_library,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Name and Version
                Text(
                  'WidMate',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Video Downloader',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface.withAlpha(178),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Version ${_packageInfo?.version ?? '1.0.0'} (Build ${_packageInfo?.buildNumber ?? '1'})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),

                const SizedBox(height: 32),

                // App Statistics
                _buildAppStatistics(context, settings),

                const SizedBox(height: 24),

                // Description Card
                _buildDescriptionCard(context, colorScheme, theme),

                const SizedBox(height: 24),

                // How It Works Section
                _buildHowItWorksSection(context, colorScheme, theme),

                const SizedBox(height: 24),

                // Features Grid
                _buildFeaturesGrid(context),

                const SizedBox(height: 24),

                // Media Player Features
                _buildMediaPlayerFeatures(context, colorScheme, theme),

                const SizedBox(height: 24),

                // Technology Stack
                _buildTechnologyCard(context, colorScheme, theme),

                const SizedBox(height: 24),

                // Contact and Links
                _buildContactCard(context, colorScheme, theme),

                const SizedBox(height: 24),

                // Legal Links
                _buildLegalLinks(context),

                const SizedBox(height: 16),

                // Copyright
                _buildCopyright(context, colorScheme, theme),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppStatistics(BuildContext context, AppSettings? settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.analytics, size: 32, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'App Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Downloads',
                  '0',
                  Icons.download,
                  colorScheme.primary,
                ),
                _buildStatItem(
                  'Media Files',
                  '0',
                  Icons.library_music,
                  colorScheme.secondary,
                ),
                _buildStatItem(
                  'Platforms',
                  '4',
                  Icons.public,
                  colorScheme.tertiary,
                ),
                _buildStatItem(
                  'Storage',
                  '0 MB',
                  Icons.storage,
                  colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 32, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'About WidMate',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'WidMate is a powerful and user-friendly video downloader and media player that supports multiple platforms including YouTube, TikTok, Instagram, and Facebook. Download your favorite videos in high quality, play them with our built-in media player, and enjoy advanced features like background downloading, progress notifications, and background audio playback.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTechChip('Open Source', Icons.code, colorScheme.primary),
                const SizedBox(width: 8),
                _buildTechChip(
                  'Privacy First',
                  Icons.security,
                  colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                _buildTechChip('No Ads', Icons.block, colorScheme.tertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, size: 32, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'How It Works',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Follow this step-by-step guide to get the most out of WidMate:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Basic Download
            _buildHowToStep(
              context,
              '1',
              'Download Single Videos',
              'Paste any video URL in the home screen and tap download',
              Icons.download,
              colorScheme.primary,
              [
                'Go to the Home tab',
                'Paste a video URL (YouTube, TikTok, Instagram, etc.)',
                'Select your preferred quality (4K, 1080p, HD, etc.)',
                'Choose audio-only or video+audio',
                'Tap the download button',
                'Monitor progress in the Downloads tab',
              ],
            ),

            const SizedBox(height: 24),

            // Step 2: Search and Download
            _buildHowToStep(
              context,
              '2',
              'Search and Download',
              'Use the search feature to find videos without leaving the app',
              Icons.search,
              colorScheme.secondary,
              [
                'Go to the Search tab',
                'Type your search query (song name, artist, topic)',
                'Browse through search results with thumbnails',
                'Tap the download button on any video you like',
                'The video will be added to your downloads queue',
                'View progress in the Downloads tab',
              ],
            ),

            const SizedBox(height: 24),

            // Step 3: Playlist Downloads
            _buildHowToStep(
              context,
              '3',
              'Download Playlists',
              'Download entire playlists or select specific videos',
              Icons.playlist_play,
              colorScheme.tertiary,
              [
                'Paste a playlist URL in the home screen',
                'Wait for playlist analysis to complete',
                'Select individual videos or download all',
                'Choose quality settings for the entire playlist',
                'Monitor overall progress in Downloads tab',
                'Each video downloads independently',
              ],
            ),

            const SizedBox(height: 24),

            // Step 4: Background Downloads
            _buildHowToStep(
              context,
              '4',
              'Background Downloads',
              'Continue downloading even when the app is minimized',
              Icons.download_for_offline,
              colorScheme.primary,
              [
                'Enable background downloads in Settings',
                'Start your downloads as usual',
                'Minimize the app or switch to another app',
                'Downloads continue in the background',
                'Receive notifications for progress updates',
                'Check Downloads tab when you return',
              ],
            ),

            const SizedBox(height: 24),

            // Step 5: Media Player
            _buildHowToStep(
              context,
              '5',
              'Play Your Media',
              'Enjoy your downloaded videos and audio with our built-in player',
              Icons.play_circle,
              colorScheme.primary,
              [
                'Go to the Media tab',
                'Browse your downloaded videos and audios',
                'Access device videos and audio files',
                'Tap any media to play it instantly',
                'Use full-screen controls for videos',
                'Enjoy background audio playback',
                'Control playback from notifications',
              ],
            ),

            const SizedBox(height: 24),

            // Step 6: Settings and Customization
            _buildHowToStep(
              context,
              '6',
              'Customize Settings',
              'Personalize your download and playback experience',
              Icons.settings,
              colorScheme.secondary,
              [
                'Go to Settings tab',
                'Choose your download folder location',
                'Set maximum concurrent downloads (1-5)',
                'Select default video quality',
                'Enable/disable notifications',
                'Configure auto-update settings',
              ],
            ),

            const SizedBox(height: 20),

            // Tips and Troubleshooting
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pro Tips & Troubleshooting',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    context,
                    '💡',
                    'For best results, use stable internet connection',
                  ),
                  _buildTipItem(
                    context,
                    '💡',
                    'Some videos may be region-restricted or private',
                  ),
                  _buildTipItem(
                    context,
                    '💡',
                    'Check Downloads tab if a download seems stuck',
                  ),
                  _buildTipItem(
                    context,
                    '💡',
                    'Use Search tab to discover new content easily',
                  ),
                  _buildTipItem(
                    context,
                    '💡',
                    'Enable background downloads for large playlists',
                  ),
                  _buildTipItem(
                    context,
                    '💡',
                    'Check Settings for storage and quality options',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToStep(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> steps,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String emoji, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPlayerFeatures(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle, size: 32, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Media Player Features',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Enjoy a complete media experience with our built-in player:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Media Player Features List
            _buildMediaFeature(
              context,
              'Video Playback',
              'Watch your downloaded videos in full-screen with custom controls',
              Icons.video_library,
              colorScheme.primary,
            ),
            const SizedBox(height: 16),

            _buildMediaFeature(
              context,
              'Audio Playback',
              'Listen to music with beautiful visualizer and album art',
              Icons.audiotrack,
              colorScheme.secondary,
            ),
            const SizedBox(height: 16),

            _buildMediaFeature(
              context,
              'Background Playback',
              'Continue listening to audio even when the app is closed',
              Icons.download_for_offline,
              colorScheme.tertiary,
            ),
            const SizedBox(height: 16),

            _buildMediaFeature(
              context,
              'Device Media Access',
              'Play videos and audio files from your device storage',
              Icons.library_music,
              colorScheme.primary,
            ),
            const SizedBox(height: 16),

            _buildMediaFeature(
              context,
              'Notification Controls',
              'Control playback directly from notification panel',
              Icons.notifications_active,
              colorScheme.secondary,
            ),
            const SizedBox(height: 16),

            _buildMediaFeature(
              context,
              'Multiple Formats',
              'Support for MP4, MKV, AVI, MP3, FLAC, and more',
              Icons.format_list_bulleted,
              colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaFeature(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {
        'title': 'Multi-Platform',
        'subtitle': 'YouTube, TikTok, Instagram, Facebook',
        'icon': Icons.public,
        'color': Colors.red,
      },
      {
        'title': 'High Quality',
        'subtitle': 'Download in 4K, 1080p, HD, and more',
        'icon': Icons.high_quality,
        'color': Colors.blue,
      },
      {
        'title': 'Media Player',
        'subtitle': 'Built-in video and audio player',
        'icon': Icons.play_circle,
        'color': Colors.purple,
      },
      {
        'title': 'Background Playback',
        'subtitle': 'Continue audio when app is closed',
        'icon': Icons.audiotrack,
        'color': Colors.indigo,
      },
      {
        'title': 'Device Media Access',
        'subtitle': 'Play videos and audio from your device',
        'icon': Icons.library_music,
        'color': Colors.orange,
      },
      {
        'title': 'Background Downloads',
        'subtitle': 'Continue downloads in background',
        'icon': Icons.download,
        'color': Colors.green,
      },
      {
        'title': 'Progress Tracking',
        'subtitle': 'Real-time download progress',
        'icon': Icons.track_changes,
        'color': Colors.amber,
      },
      {
        'title': 'Smart Notifications',
        'subtitle': 'Get notified when downloads complete',
        'icon': Icons.notifications,
        'color': Colors.pink,
      },
      {
        'title': 'Clipboard Monitor',
        'subtitle': 'Auto-detect video links',
        'icon': Icons.content_copy,
        'color': Colors.teal,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 1.2;

        if (constraints.maxWidth < ResponsiveBreakpoints.mobile) {
          crossAxisCount = 1;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          crossAxisCount = 3;
          childAspectRatio = 1.3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 32,
                      color: feature['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['subtitle'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(153),
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTechnologyCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.code, size: 32, color: colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'Built with Modern Technology',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'WidMate is built using Flutter, Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildTechChip('Flutter', Icons.flutter_dash, Colors.blue),
                _buildTechChip('Dart', Icons.code, Colors.blue.shade700),
                _buildTechChip('Material 3', Icons.palette, Colors.purple),
                _buildTechChip('Riverpod', Icons.settings, Colors.orange),
                _buildTechChip('yt-dlp', Icons.video_library, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.contact_support, size: 32, color: colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              'Get in Touch',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Have questions, suggestions, or found a bug? We\'d love to hear from you!',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ResponsiveBreakpoints.mobile) {
                  return Column(
                    children: [
                      _buildContactButton(
                        icon: Icons.email,
                        label: 'Email Support',
                        url: 'mailto:support@widmate.app',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildContactButton(
                        icon: Icons.code,
                        label: 'GitHub',
                        url: 'https://github.com/widmate/widmate',
                        color: Colors.black,
                      ),
                      const SizedBox(height: 12),
                      _buildContactButton(
                        icon: Icons.web,
                        label: 'Website',
                        url: 'https://widmate.app',
                        color: Colors.green,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactButton(
                        icon: Icons.email,
                        label: 'Email',
                        url: 'mailto:support@widmate.app',
                        color: Colors.blue,
                      ),
                      _buildContactButton(
                        icon: Icons.code,
                        label: 'GitHub',
                        url: 'https://github.com/widmate/widmate',
                        color: Colors.black,
                      ),
                      _buildContactButton(
                        icon: Icons.web,
                        label: 'Website',
                        url: 'https://widmate.app',
                        color: Colors.green,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard('support@widmate.app'),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy email',
                ),
                IconButton(
                  onPressed: () =>
                      _launchUrl('https://twitter.com/widmate_app'),
                  icon: const Icon(Icons.alternate_email),
                  tooltip: 'Twitter',
                ),
                IconButton(
                  onPressed: () => _launchUrl('https://discord.gg/widmate'),
                  icon: const Icon(Icons.chat),
                  tooltip: 'Discord',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < ResponsiveBreakpoints.mobile) {
          return Column(
            children: [
              TextButton(
                onPressed: () => _showPrivacyPolicy(context),
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () => _showTermsOfService(context),
                child: const Text('Terms of Service'),
              ),
              TextButton(
                onPressed: () => _showLicenses(context),
                child: const Text('Open Source Licenses'),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => _showPrivacyPolicy(context),
              child: const Text('Privacy Policy'),
            ),
            TextButton(
              onPressed: () => _showTermsOfService(context),
              child: const Text('Terms of Service'),
            ),
            TextButton(
              onPressed: () => _showLicenses(context),
              child: const Text('Licenses'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCopyright(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          '© 2024 WidMate. All rights reserved.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withAlpha(128),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Made with ❤️ using Flutter',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withAlpha(128),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${_packageInfo?.version ?? '1.0.0'} • Build ${_packageInfo?.buildNumber ?? '1'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withAlpha(100),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
