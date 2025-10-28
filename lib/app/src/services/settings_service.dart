import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsService {
  static const String _baseUrlKey = 'baseUrl';
  static const String _defaultBaseUrl = 'http://127.0.0.1:8000';

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  Future<void> setBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, baseUrl);
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});
