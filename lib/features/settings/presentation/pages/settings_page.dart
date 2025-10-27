import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widmate/app/src/responsive/responsive_utils.dart';
import 'package:widmate/app/src/responsive/responsive_wrapper.dart';
import 'package:widmate/features/settings/presentation/controllers/settings_controller.dart';
import 'package:widmate/app/src/services/settings_export_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:widmate/features/downloads/domain/services/download_service.dart';
import 'package:widmate/app/src/providers/app_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.isMobile(context)
            ? const EdgeInsets.all(16.0)
            : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(context, 'Appearance', Icons.palette, [
                  _buildThemeCard(context, colorScheme),
                  const SizedBox(height: 12),
                  _buildLayoutCard(context, colorScheme),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'Downloads', Icons.download, [
                  _buildActionCard(
                    context,
                    'Download Location',
                    'Change where your files are saved',
                    Icons.folder,
                    () => _selectDownloadFolder(),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context,
                    'Max Concurrent Downloads',
                    'Set the number of parallel downloads',
                    Icons.speed,
                    () => _showConcurrentDownloadsDialog(context),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    context,
                    'Default Quality',
                    'Choose the default video quality',
                    Icons.high_quality,
                    () => _showQualityDialog(context),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'General', Icons.settings, [
                  _buildSwitchCard(
                    context,
                    'Auto-Detect Clipboard',
                    'Automatically detect video links in clipboard',
                    Icons.content_paste,
                    ref.watch(settingsControllerProvider)?.autoDetectClipboard ?? false,
                    (value) => ref.read(settingsControllerProvider.notifier).setAutoDetectClipboard(value),
                  ),
                  const SizedBox(height: 12),
                  _buildSwitchCard(
                    context,
                    'Show Notifications',
                    'Get notified about download progress',
                    Icons.notifications,
                    ref.watch(settingsControllerProvider)?.showNotifications ?? true,
                    (value) => ref.read(settingsControllerProvider.notifier).setShowNotifications(value),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildStorageSettings(context, colorScheme),
                const SizedBox(height: 24),
                _buildSupportSettings(context, colorScheme),
                const SizedBox(height: 24),
                _buildAppInfo(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildStorageSettings(BuildContext context, ColorScheme colorScheme) {
    return _buildSection(context, 'Storage & Data', Icons.storage, [
      _buildActionCard(
        context,
        'Clear Cache',
        'Delete temporary files to free up space',
        Icons.cleaning_services,
        () => _showClearCacheDialog(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Clear Download History',
        'Remove all download history records',
        Icons.history,
        () => _showClearHistoryDialog(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Export Settings',
        'Export your settings to a file',
        Icons.upload_file,
        () => _exportSettings(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Import Settings',
        'Import settings from a file',
        Icons.file_download,
        () => _importSettings(context),
      ),
    ]);
  }

  Widget _buildSupportSettings(BuildContext context, ColorScheme colorScheme) {
    return _buildSection(context, 'Support & Feedback', Icons.support, [
      _buildActionCard(
        context,
        'Report a Bug',
        'Help us improve by reporting issues',
        Icons.bug_report,
        () => _reportBug(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Rate the App',
        'If you enjoy using this app, please rate it',
        Icons.star,
        () => _rateApp(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Contact Support',
        'Get help with any issues',
        Icons.contact_support,
        () => _contactSupport(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Privacy Policy',
        'Read our privacy policy',
        Icons.privacy_tip,
        () => _showPrivacyPolicy(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Terms of Service',
        'Read our terms of service',
        Icons.description,
        () => _showTermsOfService(context),
      ),
      const SizedBox(height: 12),
      _buildActionCard(
        context,
        'Open Source Licenses',
        'View licenses for open source software',
        Icons.source,
        () => _showLicenses(context),
      ),
    ]);
  }

  Widget _buildAppInfo(BuildContext context, ColorScheme colorScheme) {
    return _buildSection(context, 'App Information', Icons.info, [
      _buildInfoCard(
        context,
        'Version',
        _packageInfo?.version ?? '1.0.0',
        Icons.info_outline,
      ),
      const SizedBox(height: 12),
      _buildInfoCard(
        context,
        'Build Number',
        _packageInfo?.buildNumber ?? '1',
        Icons.build,
      ),
      const SizedBox(height: 12),
      _buildInfoCard(
        context,
        'Package Name',
        _packageInfo?.packageName ?? 'com.example.widmate',
        Icons.android,
      ),
    ]);
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSwitchCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, ColorScheme colorScheme) {
    final currentTheme = ref.watch(themeModeProvider);

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.palette),
        title: const Text('Theme'),
        subtitle: Text(_getThemeName(currentTheme)),
        children: [
          RadioMenuButton<ThemeMode>(            value: ThemeMode.system,            groupValue: currentTheme,            onChanged: (value) {              if (value != null) {                ref.read(themeModeProvider.notifier).state = value;              }            },            child: const Text('System'),          ),
          RadioMenuButton<ThemeMode>(            value: ThemeMode.light,            groupValue: currentTheme,            onChanged: (value) {              if (value != null) {                ref.read(themeModeProvider.notifier).state = value;              }            },            child: const Text('Light'),          ),
          RadioMenuButton<ThemeMode>(            value: ThemeMode.dark,            groupValue: currentTheme,            onChanged: (value) {              if (value != null) {                ref.read(themeModeProvider.notifier).state = value;              }            },            child: const Text('Dark'),          ),
        ],
      ),
    );
  }

  Widget _buildLayoutCard(BuildContext context, ColorScheme colorScheme) {
    final currentLayout = ref.watch(layoutProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layout', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Comfortable'),
              value: 'Comfortable',
              groupValue: currentLayout,
              onChanged: (value) {
                if (value != null) {
                  ref.read(layoutProvider.notifier).state = value;
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Compact'),
              value: 'Compact',
              groupValue: currentLayout,
              onChanged: (value) {
                if (value != null) {
                  ref.read(layoutProvider.notifier).state = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  // Dialog methods
  void _selectDownloadFolder() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        await ref
            .read(settingsControllerProvider.notifier)
            .setDownloadPath(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download folder updated to: $result')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set download folder: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _showConcurrentDownloadsDialog(BuildContext context) {
    final currentValue =
        ref.read(settingsControllerProvider)?.maxConcurrentDownloads ?? 3;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Max Concurrent Downloads'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select the maximum number of concurrent downloads:'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(
                5,
                (index) => ChoiceChip(
                  label: Text('${index + 1}'),
                  selected: currentValue == index + 1,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setMaxConcurrentDownloads(index + 1);
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Max downloads set to ${index + 1}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final qualities = [
      '4K',
      '1080p',
      'HD',
      'SD',
      'Auto',
      '720p',
      '480p',
      '360p',
    ];
    final currentQuality =
        ref.read(settingsControllerProvider)?.defaultQuality ?? 'HD';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Default Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities
              .map(
                (quality) => ListTile(
                  title: Text(
                    quality == '4K'
                        ? '4K (2160p)'
                        : quality == '1080p'
                            ? '1080p (Full HD)'
                            : quality == 'HD'
                                ? 'HD (720p)'
                                : quality == 'SD'
                                    ? 'SD (480p)'
                                    : quality,
                  ),
                  leading: Icon(
                    currentQuality == quality
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: currentQuality == quality
                        ? Theme.of(dialogContext).colorScheme.primary
                        : null,
                  ),
                  onTap: () {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setDefaultQuality(quality);
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Default quality set to $quality'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will delete all temporary files and free up storage space. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Implement cache clearing
              await DefaultCacheManager().emptyCache();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Download History'),
        content: const Text(
          'This will remove all download history records. Downloaded files will not be deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Implement history clearing
              await ref.read(downloadServiceProvider).clearCompletedDownloads();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download history cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSettings(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final settings = ref.read(settingsControllerProvider);
      if (settings == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No settings to export'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final exportService = SettingsExportService();
      final filePath = await exportService.exportSettings(settings);

      if (filePath != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Settings exported to: $filePath'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _launchUrl('file://$filePath'),
            ),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to export settings'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error exporting settings: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _importSettings(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final exportService = SettingsExportService();
      final filePath = await exportService.pickSettingsFile();

      if (filePath == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final settings = await exportService.importSettings(filePath);
      if (settings != null) {
        // Apply imported settings
        final controller = ref.read(settingsControllerProvider.notifier);
        await controller.setDownloadPath(settings.downloadPath);
        await controller.setMaxConcurrentDownloads(
          settings.maxConcurrentDownloads,
        );
        await controller.setShowNotifications(settings.showNotifications);
        await controller.setAutoDetectClipboard(settings.autoDetectClipboard);
        await controller.setDefaultQuality(settings.defaultQuality);
        await controller.setBackgroundDownloadsEnabled(
          settings.backgroundDownloadsEnabled,
        );
        await controller.setBackgroundDownloadNotifications(
          settings.backgroundDownloadNotifications,
        );
        await controller.setSaveSubtitles(settings.saveSubtitles);
        await controller.setSaveMetadata(settings.saveMetadata);
        await controller.setAutoPlayVideos(settings.autoPlayVideos);

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Settings imported successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to import settings - invalid file format'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error importing settings: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _reportBug(BuildContext context) {
    _launchUrl(
      'mailto:support@widmate.app?subject=Bug Report&body=Please describe the bug you encountered:',
    );
  }

  void _rateApp(BuildContext context) {
    _launchUrl(
      'https://play.google.com/store/apps/details?id=com.example.widmate',
    );
  }

  void _contactSupport(BuildContext context) {
    _launchUrl(
      'mailto:support@widmate.app?subject=Support Request&body=Please describe your issue:',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _launchUrl('https://widmate.app/privacy');
  }

  void _showTermsOfService(BuildContext context) {
    _launchUrl('https://widmate.app/terms');
  }

  void _showLicenses(BuildContext context) {
    final theme = Theme.of(context);
    showLicensePage(
      context: context,
      applicationName: 'WidMate',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.video_library,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
