import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/settings/presentation/providers/auto_updater_provider.dart';

class AutoUpdaterSettingsWidget extends ConsumerWidget {
  const AutoUpdaterSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoUpdaterState = ref.watch(autoUpdaterProvider);

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.update),
        title: const Text('Auto Updater'),
        subtitle: const Text('yt-dlp is updated automatically'),
        children: [
          autoUpdaterState.when(
            data: (status) => Column(
              children: [
                ListTile(
                  title: const Text('yt-dlp Version'),
                  subtitle: Text(status['update_status']?['current_version'] ?? 'Unknown'),
                ),
                ListTile(
                  title: const Text('Last Checked'),
                  subtitle: Text(status['last_check'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(status['last_check'] * 1000).toString()
                      : 'Never'),
                ),
                ListTile(
                  title: const Text('Update Status'),
                  subtitle: Text(status['update_status']?['message'] ?? 'Idle'),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }
}
