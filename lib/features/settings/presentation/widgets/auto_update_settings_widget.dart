import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/auto_update_service.dart';

class AutoUpdateSettingsWidget extends ConsumerStatefulWidget {
  const AutoUpdateSettingsWidget({super.key});

  @override
  ConsumerState<AutoUpdateSettingsWidget> createState() =>
      _AutoUpdateSettingsWidgetState();
}

class _AutoUpdateSettingsWidgetState
    extends ConsumerState<AutoUpdateSettingsWidget> {
  bool _isConfiguring = false;

  @override
  Widget build(BuildContext context) {
    final autoUpdateState = ref.watch(autoUpdateNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-Update Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isConfiguring)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            autoUpdateState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorWidget(error.toString()),
              data: (status) =>
                  _buildSettingsContent(status, theme, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(height: 8),
          const Text(
            'Failed to load auto-update settings',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () =>
                ref.read(autoUpdateNotifierProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(
      AutoUpdateStatus status, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Auto-update enabled toggle
        SwitchListTile(
          title: const Text('Enable Auto-Updates'),
          subtitle:
              const Text('Automatically check for and install yt-dlp updates'),
          value: status.autoUpdateEnabled,
          onChanged: _isConfiguring
              ? null
              : (value) => _updateSetting('enabled', value),
          secondary: Icon(
            Icons.update,
            color: status.autoUpdateEnabled
                ? colorScheme.primary
                : colorScheme.outline,
          ),
        ),

        if (status.autoUpdateEnabled) ...[
          const Divider(),

          // Check interval setting
          ListTile(
            title: const Text('Check Interval'),
            subtitle: Text(
                'Check for updates every ${status.checkIntervalHours.toInt()} hours'),
            leading: const Icon(Icons.schedule),
            trailing: DropdownButton<int>(
              value: status.checkIntervalHours.toInt(),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 hour')),
                DropdownMenuItem(value: 6, child: Text('6 hours')),
                DropdownMenuItem(value: 12, child: Text('12 hours')),
                DropdownMenuItem(value: 24, child: Text('24 hours')),
                DropdownMenuItem(value: 48, child: Text('48 hours')),
                DropdownMenuItem(value: 168, child: Text('1 week')),
              ],
              onChanged: _isConfiguring
                  ? null
                  : (value) {
                      if (value != null) {
                        _updateSetting('checkIntervalHours', value);
                      }
                    },
            ),
          ),

          const Divider(),

          // Update on startup
          SwitchListTile(
            title: const Text('Update on Startup'),
            subtitle: const Text('Check for updates when the app starts'),
            value: status.updateStatus.status != 'idle' || true, // Placeholder
            onChanged: _isConfiguring
                ? null
                : (value) => _updateSetting('updateOnStartup', value),
            secondary: const Icon(Icons.play_arrow),
          ),

          // Silent updates
          SwitchListTile(
            title: const Text('Silent Updates'),
            subtitle: const Text(
                'Install updates automatically without notification'),
            value: false, // Placeholder - would need to get from status
            onChanged: _isConfiguring
                ? null
                : (value) => _updateSetting('silentUpdates', value),
            secondary: const Icon(Icons.notifications_off),
          ),

          // Notify on updates
          SwitchListTile(
            title: const Text('Update Notifications'),
            subtitle:
                const Text('Show notifications when updates are available'),
            value: true, // Placeholder - would need to get from status
            onChanged: _isConfiguring
                ? null
                : (value) => _updateSetting('notifyOnUpdate', value),
            secondary: const Icon(Icons.notifications),
          ),
        ],

        const Divider(),

        // Update status section
        _buildUpdateStatusSection(status, theme, colorScheme),

        const SizedBox(height: 16),

        // Action buttons
        _buildActionButtons(status, theme, colorScheme),
      ],
    );
  }

  Widget _buildUpdateStatusSection(
      AutoUpdateStatus status, ThemeData theme, ColorScheme colorScheme) {
    final updateStatus = status.updateStatus;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getStatusIcon(updateStatus.status),
                color: _getStatusColor(updateStatus.status, colorScheme),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  updateStatus.message.isNotEmpty
                      ? updateStatus.message
                      : 'No updates available',
                  style: TextStyle(
                    color: _getStatusColor(updateStatus.status, colorScheme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (updateStatus.isUpdating) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: updateStatus.progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(updateStatus.status, colorScheme),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(updateStatus.progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
          if (updateStatus.error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${updateStatus.error}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
          if (status.lastCheck != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last check: ${_formatTimestamp(status.lastCheck!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
          if (status.nextCheck != null) ...[
            Text(
              'Next check: ${_formatTimestamp(status.nextCheck!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      AutoUpdateStatus status, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isConfiguring ? null : () => _forceCheck(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Check Now'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConfiguring || !status.autoUpdateEnabled
                ? null
                : () => _forceUpdate(),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Update Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'checking':
        return Icons.search;
      case 'updating':
        return Icons.download;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'checking':
        return Colors.blue;
      case 'updating':
        return colorScheme.primary;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return colorScheme.outline;
    }
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      _isConfiguring = true;
    });

    try {
      final notifier = ref.read(autoUpdateNotifierProvider.notifier);

      switch (key) {
        case 'enabled':
          await notifier.configure(enabled: value as bool);
          break;
        case 'checkIntervalHours':
          await notifier.configure(checkIntervalHours: value as int);
          break;
        case 'updateOnStartup':
          await notifier.configure(updateOnStartup: value as bool);
          break;
        case 'silentUpdates':
          await notifier.configure(silentUpdates: value as bool);
          break;
        case 'notifyOnUpdate':
          await notifier.configure(notifyOnUpdate: value as bool);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setting updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfiguring = false;
        });
      }
    }
  }

  Future<void> _forceCheck() async {
    setState(() {
      _isConfiguring = true;
    });

    try {
      await ref.read(autoUpdateNotifierProvider.notifier).forceCheck();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update check triggered'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check for updates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfiguring = false;
        });
      }
    }
  }

  Future<void> _forceUpdate() async {
    setState(() {
      _isConfiguring = true;
    });

    try {
      await ref.read(autoUpdateNotifierProvider.notifier).forceUpdate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfiguring = false;
        });
      }
    }
  }
}
