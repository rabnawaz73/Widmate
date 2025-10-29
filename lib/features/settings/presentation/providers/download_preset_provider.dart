import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widmate/features/settings/domain/models/download_preset.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final downloadPresetProvider =
    StateNotifierProvider<DownloadPresetNotifier, List<DownloadPreset>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return DownloadPresetNotifier(prefs);
  },
);

class DownloadPresetNotifier extends StateNotifier<List<DownloadPreset>> {
  final SharedPreferences _prefs;

  DownloadPresetNotifier(this._prefs) : super([]) {
    _loadPresets();
  }

  void _loadPresets() {
    final presetsJson = _prefs.getString('download_presets');
    if (presetsJson != null) {
      final presetsList = jsonDecode(presetsJson) as List;
      state = presetsList
          .map((json) => DownloadPreset.fromJson(json))
          .toList();
    } else {
      state = [
        const DownloadPreset(name: 'Default (720p)', quality: '720p', audioOnly: false),
        const DownloadPreset(name: 'Audio Only (128k)', quality: '128k', audioOnly: true),
      ];
    }
  }

  Future<void> _savePresets() async {
    final presetsJson = jsonEncode(state.map((p) => p.toJson()).toList());
    await _prefs.setString('download_presets', presetsJson);
  }

  Future<void> addPreset(DownloadPreset preset) async {
    state = [...state, preset];
    await _savePresets();
  }

  Future<void> updatePreset(int index, DownloadPreset preset) async {
    final updatedPresets = List.of(state);
    updatedPresets[index] = preset;
    state = updatedPresets;
    await _savePresets();
  }

  Future<void> deletePreset(int index) async {
    final updatedPresets = List.of(state);
    updatedPresets.removeAt(index);
    state = updatedPresets;
    await _savePresets();
  }
}
