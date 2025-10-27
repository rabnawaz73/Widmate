import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widmate/features/settings/domain/models/download_preset.dart';

final downloadPresetProvider =
    StateNotifierProvider<DownloadPresetNotifier, List<DownloadPreset>>((ref) {
  return DownloadPresetNotifier();
});

class DownloadPresetNotifier extends StateNotifier<List<DownloadPreset>> {
  DownloadPresetNotifier() : super([]) {
    _loadPresets();
  }

  static const _presetsKey = 'download_presets';

  Future<void> _loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = prefs.getStringList(_presetsKey) ?? [];
    state = presetsJson
        .map((jsonString)
            => DownloadPreset.fromJson(json.decode(jsonString)))
        .toList();
  }

  Future<void> addPreset(DownloadPreset preset) async {
    state = [...state, preset];
    await _savePresets();
  }

  Future<void> deletePreset(String presetName) async {
    state = state.where((preset) => preset.name != presetName).toList();
    await _savePresets();
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    final presetsJson = state.map((preset) => json.encode(preset.toJson())).toList();
    await prefs.setStringList(_presetsKey, presetsJson);
  }
}
