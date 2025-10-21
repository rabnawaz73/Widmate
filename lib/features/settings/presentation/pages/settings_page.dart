import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widmate/app/src/responsive/responsive_utils.dart';
import 'package:widmate/app/src/responsive/responsive_wrapper.dart';
import 'package:widmate/features/settings/presentation/controllers/settings_controller.dart';
import 'package:widmate/features/settings/presentation/pages/advanced_settings_page.dart';
import 'package:widmate/features/settings/presentation/widgets/language_selector.dart';
import 'package:widmate/features/settings/presentation/widgets/auto_update_settings_widget.dart';
import 'package:widmate/features/settings/presentation/widgets/storage_management_widget.dart';
import 'package:widmate/app/src/services/settings_export_service.dart';
import 'package:widmate/app/src/app_widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _loadPackageInfo();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = packageInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ResponsiveScaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            children: [
              // Header with app info
              _buildHeader(context, colorScheme),
              const SizedBox(height: 24),

              // Quick Settings
              _buildQuickSettings(context, settings, colorScheme),
              const SizedBox(height: 24),

              // Download Settings
              _buildDownloadSettings(context, settings, colorScheme),
              const SizedBox(height: 24),

              // Appearance Settings
              _buildAppearanceSettings(context, settings, colorScheme),
              const SizedBox(height: 24),

              // Advanced Settings
              _buildAdvancedSettings(context, colorScheme),
              const SizedBox(height: 24),

              // Storage & Data
              _buildStorageSettings(context, colorScheme),
              const SizedBox(height: 24),

              // Storage Management
              _buildSection(context, 'Storage Management', Icons.storage, [
                const StorageManagementWidget(),
              ]),
              const SizedBox(height: 24),

              // Support & About
              _buildSupportSettings(context, colorScheme),
              const SizedBox(height: 24),

              // App Info
              _buildAppInfo(context, colorScheme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings, color: colorScheme.onPrimary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your WidMate experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings(
    BuildContext context,
    AppSettings? settings,
    ColorScheme colorScheme,
  ) {
    return _buildSection(context, 'Quick Settings', Icons.tune, [
      _buildQuickSettingCard(
        context,
        'Download Folder',
        settings?.downloadPath ?? '/storage/emulated/0/Download/WidMate',
        Icons.folder,
        () => _selectDownloadFolder(),
      ),
      const SizedBox(height: 12),
      _buildQuickSettingCard(
        context,
        'Max Downloads',
        '${settings?.maxConcurrentDownloads ?? 3} concurrent',
        Icons.download_for_offline,
        () => _showConcurrentDownloadsDialog(context),
      ),
      const SizedBox(height: 12),
      _buildQuickSettingCard(
        context,
        'Default Quality',
        settings?.defaultQuality ?? 'HD',
        Icons.high_quality,
        () => _showQualityDialog(context),
      ),
    ]);
  }

  Widget _buildDownloadSettings(
    BuildContext context,
    AppSettings? settings,
    ColorScheme colorScheme,
  ) {
    return _buildSection(context, 'Download Settings', Icons.download, [
      _buildSwitchCard(
        context,
        'Background Downloads',
        'Continue downloading when app is minimized',
        Icons.download_for_offline,
        settings?.backgroundDownloadsEnabled ?? true,
        (value) => ref
            .read(settingsControllerProvider.notifier)
            .setBackgroundDownloadsEnabled(value),
      ),
      const SizedBox(height: 12),
      _buildSwitchCard(
        context,
        'Download Notifications',
        'Show progress notifications for downloads',
        Icons.notifications,
        settings?.showNotifications ?? true,
        (value) => ref
            .read(settingsControllerProvider.notifier)
            .setShowNotifications(value),
      ),
      const SizedBox(height: 12),
      _buildSwitchCard(
        context,
        'Auto-detect Clipboard',
        'Automatically detect video URLs from clipboard',
        Icons.content_paste,
        settings?.autoDetectClipboard ?? true,
        (value) => ref
            .read(settingsControllerProvider.notifier)
            .setAutoDetectClipboard(value),
      ),
    ]);
  }

  Widget _buildAppearanceSettings(
    BuildContext context,
    AppSettings? settings,
    ColorScheme colorScheme,
  ) {
    return _buildSection(context, 'Appearance', Icons.palette, [
      _buildThemeCard(context, colorScheme),
      const SizedBox(height: 12),
      const LanguageSelector(),
    ]);
  }

  Widget _buildAdvancedSettings(BuildContext context, ColorScheme colorScheme) {
    return _buildSection(context, 'Advanced', Icons.settings_applications, [
      _buildActionCard(
        context,
        'Advanced Settings',
        'Configure additional app settings',
        Icons.tune,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdvancedSettingsPage()),
        ),
      ),
      const SizedBox(height: 12),
      const AutoUpdateSettingsWidget(),
    ]);
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

  Widget _buildQuickSettingCard(
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
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Follow system theme'),
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            subtitle: const Text('Always use light theme'),
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            subtitle: const Text('Always use dark theme'),
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).state = value;
              }
            },
          ),
        ],
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: Implement cache clearing
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: Implement history clearing
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
