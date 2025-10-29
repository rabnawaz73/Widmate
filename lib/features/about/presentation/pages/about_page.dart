import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/widgets/app_icon_widget.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('About WidMate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            AppIconWidget(size: 120, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'WidMate',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${_packageInfo?.version ?? '1.0.0'} (Build ${_packageInfo?.buildNumber ?? '1'})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 32),
            _buildAboutCard(theme, colorScheme),
            const SizedBox(height: 24),
            _buildLinksCard(theme, colorScheme),
            const SizedBox(height: 24),
            _buildLegalSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'About WidMate',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'WidMate is a powerful and user-friendly video downloader and media player that supports multiple platforms. Download your favorite videos in high quality and enjoy them offline.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Links',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildLinkButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  url: 'https://github.com/widmate/widmate',
                ),
                _buildLinkButton(
                  icon: Icons.web,
                  label: 'Website',
                  url: 'https://widmate.app',
                ),
                _buildLinkButton(
                  icon: Icons.email,
                  label: 'Contact',
                  url: 'mailto:support@widmate.app',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _launchUrl(url),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
}
