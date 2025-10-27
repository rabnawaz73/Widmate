import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/settings/domain/models/download_preset.dart';
import 'package:widmate/features/settings/presentation/providers/download_preset_provider.dart';

class DownloadPresetSettingsWidget extends ConsumerWidget {
  const DownloadPresetSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(downloadPresetProvider);

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.save),
        title: const Text('Download Presets'),
        subtitle: const Text('Create and manage download profiles'),
        children: [
          ...presets.map(
            (preset) => ListTile(
              title: Text(preset.name),
              subtitle: Text('${preset.quality}, ${preset.audioOnly ? 'Audio Only' : 'Video'}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  ref.read(downloadPresetProvider.notifier).deletePreset(preset.name);
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Preset'),
            onTap: () => _showAddPresetDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showAddPresetDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String quality = '720p';
    bool audioOnly = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Download Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Preset Name'),
            ),
            DropdownButtonFormField<String>(
              initialValue: quality,
              decoration: const InputDecoration(labelText: 'Quality'),
              items: ['1080p', '720p', '480p', '360p']
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  quality = value;
                }
              },
            ),
            SwitchListTile(
              title: const Text('Audio Only'),
              value: audioOnly,
              onChanged: (value) {
                audioOnly = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              if (name.isNotEmpty) {
                ref.read(downloadPresetProvider.notifier).addPreset(
                      DownloadPreset(
                        name: name,
                        quality: quality,
                        audioOnly: audioOnly,
                      ),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
