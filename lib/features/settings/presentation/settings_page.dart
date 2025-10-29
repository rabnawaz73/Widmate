import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/settings_service.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/features/settings/presentation/providers/theme_provider.dart';
import 'package:widmate/features/settings/presentation/providers/download_preset_provider.dart';
import 'package:widmate/features/settings/domain/models/download_preset.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController.text = ref.read(baseUrlProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backend URL',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'http://127.0.0.1:8000',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.isAbsolute) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final newUrl = _textController.text;
                    final settingsService = ref.read(settingsServiceProvider);
                    await settingsService.setBaseUrl(newUrl);
                    ref.read(baseUrlProvider.notifier).state = newUrl;
                    AppConstants.baseUrl = newUrl;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 24),
              Text(
                'Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ThemeMode>(
                value: ref.watch(themeProvider),
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    ref.read(themeProvider.notifier).setThemeMode(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Download Presets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ..._buildPresetList(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showPresetDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Preset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPresetList() {
    final presets = ref.watch(downloadPresetProvider);
    return presets.asMap().entries.map((entry) {
      final index = entry.key;
      final preset = entry.value;
      return ListTile(
        title: Text(preset.name),
        subtitle: Text('Quality: ${preset.quality}, Audio Only: ${preset.audioOnly}'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showPresetDialog(index: index, preset: preset),
        ),
      );
    }).toList();
  }

  void _showPresetDialog({int? index, DownloadPreset? preset}) {
    final isEditing = index != null;
    final nameController = TextEditingController(text: preset?.name);
    final qualityController = TextEditingController(text: preset?.quality);
    var audioOnly = preset?.audioOnly ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Preset' : 'Add Preset'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: qualityController,
                    decoration: const InputDecoration(labelText: 'Quality (e.g., 720p, 128k)'),
                  ),
                  CheckboxListTile(
                    title: const Text('Audio Only'),
                    value: audioOnly,
                    onChanged: (value) {
                      setState(() {
                        audioOnly = value ?? false;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPreset = DownloadPreset(
                  name: nameController.text,
                  quality: qualityController.text,
                  audioOnly: audioOnly,
                );
                if (isEditing) {
                  ref.read(downloadPresetProvider.notifier).updatePreset(index, newPreset);
                } else {
                  ref.read(downloadPresetProvider.notifier).addPreset(newPreset);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            if (isEditing)
              TextButton(
                onPressed: () {
                  ref.read(downloadPresetProvider.notifier).deletePreset(index);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
          ],
        );
      },
    );
  }
}
