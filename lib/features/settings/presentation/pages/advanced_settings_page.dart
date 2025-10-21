import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:widmate/app/src/app_widget.dart';
import 'package:widmate/features/downloads/domain/services/batch_download_service.dart';
import 'package:widmate/features/clipboard/services/clipboard_monitor_service.dart';
import 'package:widmate/features/settings/presentation/controllers/settings_controller.dart';

class AdvancedSettingsPage extends ConsumerStatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  ConsumerState<AdvancedSettingsPage> createState() =>
      _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends ConsumerState<AdvancedSettingsPage> {
  // Controller for custom download location
  final TextEditingController _downloadLocationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the custom download location controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsControllerProvider);
      if (settings != null) {
        _downloadLocationController.text = settings.downloadPath;
      }
    });
  }

  @override
  void dispose() {
    _downloadLocationController.dispose();
    super.dispose();
  }

  // Save settings to preferences
  Future<void> _saveSettings() async {
    final settings = ref.read(settingsControllerProvider);
    if (settings == null) return;

    // Update batch download service
    final batchService = ref.read(batchDownloadServiceProvider);
    batchService.setMaxConcurrentDownloads(settings.maxConcurrentDownloads);

    // Update clipboard monitor service
    final clipboardService = ClipboardMonitorService();
    if (settings.autoDetectClipboard) {
      clipboardService.setCheckInterval(
        const Duration(seconds: 5),
      ); // Default interval
    } else {
      clipboardService.stop();
    }

    // Save custom download location if it's changed
    if (settings.downloadPath != _downloadLocationController.text) {
      ref
          .read(settingsControllerProvider.notifier)
          .setDownloadPath(_downloadLocationController.text);
    }

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);

    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Settings')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're on a small screen
          final isSmallScreen =
              constraints.maxWidth < ResponsiveBreakpoints.tablet;

          // Create the settings list
          final settingsList = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(theme, 'Download Settings'),
              _buildSliderSetting(
                title: 'Max Concurrent Downloads',
                value: settings.maxConcurrentDownloads.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setMaxConcurrentDownloads(value.round());
                },
                valueDisplay: settings.maxConcurrentDownloads.toString(),
              ),
              _buildDropdownSetting<String>(
                title: 'Download Quality',
                value: settings.defaultQuality,
                items: const ['Low', 'Medium', 'High', 'Best'],
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .setDefaultQuality(value);
                  }
                },
              ),
              _buildSwitchSetting(
                title: 'Enable Background Downloads',
                subtitle: 'Continue downloads when app is closed',
                value: settings.backgroundDownloadsEnabled,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setBackgroundDownloadsEnabled(value);
                },
              ),
              _buildSwitchSetting(
                title: 'Background Download Notifications',
                subtitle: 'Show notifications for background downloads',
                value: settings.backgroundDownloadNotifications,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setBackgroundDownloadNotifications(value);
                },
              ),
              _buildDownloadLocationSetting(theme),

              _buildSwitchSetting(
                title: 'Save Subtitles',
                subtitle: 'Download subtitles when available',
                value: settings.saveSubtitles,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setSaveSubtitles(value);
                },
              ),
              _buildSwitchSetting(
                title: 'Save Metadata',
                subtitle: 'Save video information like title, author, etc.',
                value: settings.saveMetadata,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setSaveMetadata(value);
                },
              ),
              _buildSectionHeader(theme, 'System Integration'),
              _buildSwitchSetting(
                title: 'Clipboard Monitoring',
                subtitle: 'Detect video links in clipboard',
                value: settings.autoDetectClipboard,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setAutoDetectClipboard(value);
                },
              ),

              // Clipboard check interval setting - not available in current AppSettings model
              // _buildSliderSetting(
              //   title: 'Clipboard Check Interval',
              //   value: 5.0,
              //   min: 1,
              //   max: 10,
              //   divisions: 9,
              //   onChanged: settings.autoDetectClipboard ? (value) {
              //     // Not implemented in current settings model
              //   } : null,
              //   valueDisplay: '5 seconds',
              // ),
              _buildSectionHeader(theme, 'Media Playback'),

              _buildSwitchSetting(
                title: 'Auto-Play Videos',
                subtitle: 'Automatically play videos when opened',
                value: settings.autoPlayVideos,
                onChanged: (value) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setAutoPlayVideos(value);
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Settings'),
                      content: const Text(
                        'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // Reset settings to defaults
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .resetToDefaults();
                    _downloadLocationController.text = '';

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings reset to defaults'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Reset to Defaults'),
              ),
            ],
          );

          // For larger screens, center the content with a max width
          if (!isSmallScreen) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: settingsList,
              ),
            );
          }

          // For small screens, use the full width
          return settingsList;
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double>? onChanged,
    required String valueDisplay,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                Text(
                  valueDisplay,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting<T>({
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            DropdownButton<T>(
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(item.toString()),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadLocationSetting(ThemeData theme) {
    final settings = ref.watch(settingsControllerProvider);
    if (settings == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Download Location'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _downloadLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Download Path',
                      hintText: 'Enter custom download path',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Update the download path when text changes
                      ref
                          .read(settingsControllerProvider.notifier)
                          .setDownloadPath(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () async {
                    try {
                      // Open folder picker
                      final String? selectedDirectory = await FilePicker.platform
                          .getDirectoryPath();

                      if (selectedDirectory != null) {
                        // Update the text field
                        _downloadLocationController.text = selectedDirectory;

                        // Update the settings
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setDownloadPath(selectedDirectory);

                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Download location updated to: $selectedDirectory',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Show error message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error selecting folder: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
