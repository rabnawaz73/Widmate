import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  ThemeMode get themeMode => state;

  void _loadTheme() {
    final themeIndex = _prefs.getInt('themeMode') ?? 2;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await _prefs.setInt('themeMode', themeMode.index);
  }
}
