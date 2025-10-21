import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Settings model
class AppSettings {
  final String downloadPath;
  final int maxConcurrentDownloads;
  final bool showNotifications;
  final bool autoDetectClipboard;
  final String defaultQuality;
  final bool backgroundDownloadsEnabled;
  final bool backgroundDownloadNotifications;
  final bool saveSubtitles;
  final bool saveMetadata;
  final bool autoPlayVideos;

  const AppSettings({
    this.downloadPath = '/storage/emulated/0/Download/WidMate',
    this.maxConcurrentDownloads = 3,
    this.showNotifications = true,
    this.autoDetectClipboard = true,
    this.defaultQuality = 'HD',
    this.backgroundDownloadsEnabled = true,
    this.backgroundDownloadNotifications = true,
    this.saveSubtitles = false,
    this.saveMetadata = true,
    this.autoPlayVideos = false,
  });

  AppSettings copyWith({
    String? downloadPath,
    int? maxConcurrentDownloads,
    bool? showNotifications,
    bool? autoDetectClipboard,
    String? defaultQuality,
    bool? backgroundDownloadsEnabled,
    bool? backgroundDownloadNotifications,
    bool? saveSubtitles,
    bool? saveMetadata,
    bool? autoPlayVideos,
  }) {
    return AppSettings(
      downloadPath: downloadPath ?? this.downloadPath,
      maxConcurrentDownloads:
          maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      showNotifications: showNotifications ?? this.showNotifications,
      autoDetectClipboard: autoDetectClipboard ?? this.autoDetectClipboard,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      backgroundDownloadsEnabled:
          backgroundDownloadsEnabled ?? this.backgroundDownloadsEnabled,
      backgroundDownloadNotifications:
          backgroundDownloadNotifications ??
          this.backgroundDownloadNotifications,
      saveSubtitles: saveSubtitles ?? this.saveSubtitles,
      saveMetadata: saveMetadata ?? this.saveMetadata,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
    );
  }
}

// Settings controller provider
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings?>((ref) {
      return SettingsController();
    });

// Settings controller
class SettingsController extends StateNotifier<AppSettings?> {
  SharedPreferences? _prefs;

  SettingsController() : super(null) {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  // Keys for shared preferences
  static const String _downloadPathKey = 'download_path';
  static const String _maxConcurrentDownloadsKey = 'max_concurrent_downloads';
  static const String _showNotificationsKey = 'show_notifications';
  static const String _autoDetectClipboardKey = 'auto_detect_clipboard';
  static const String _defaultQualityKey = 'default_quality';
  static const String _backgroundDownloadsEnabledKey =
      'background_downloads_enabled';
  static const String _backgroundDownloadNotificationsKey =
      'background_download_notifications';
  static const String _saveSubtitlesKey = 'save_subtitles';
  static const String _saveMetadataKey = 'save_metadata';
  static const String _autoPlayVideosKey = 'auto_play_videos';

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    try {
      state = AppSettings(
        downloadPath:
            _prefs!.getString(_downloadPathKey) ??
            '/storage/emulated/0/Download/WidMate',
        maxConcurrentDownloads: _prefs!.getInt(_maxConcurrentDownloadsKey) ?? 3,
        showNotifications: _prefs!.getBool(_showNotificationsKey) ?? true,
        autoDetectClipboard: _prefs!.getBool(_autoDetectClipboardKey) ?? true,
        defaultQuality: _prefs!.getString(_defaultQualityKey) ?? 'HD',
        backgroundDownloadsEnabled:
            _prefs!.getBool(_backgroundDownloadsEnabledKey) ?? true,
        backgroundDownloadNotifications:
            _prefs!.getBool(_backgroundDownloadNotificationsKey) ?? true,
        saveSubtitles: _prefs!.getBool(_saveSubtitlesKey) ?? false,
        saveMetadata: _prefs!.getBool(_saveMetadataKey) ?? true,
        autoPlayVideos: _prefs!.getBool(_autoPlayVideosKey) ?? false,
      );
    } catch (e) {
      // Set default settings if loading fails
      state = const AppSettings();
    }
  }

  // Set download path
  Future<void> setDownloadPath(String path) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setString(_downloadPathKey, path);
      state = state!.copyWith(downloadPath: path);
    } catch (e) {
      // Handle error
    }
  }

  // Set max concurrent downloads
  Future<void> setMaxConcurrentDownloads(int count) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setInt(_maxConcurrentDownloadsKey, count);
      state = state!.copyWith(maxConcurrentDownloads: count);
    } catch (e) {
      // Handle error
    }
  }

  // Set show notifications
  Future<void> setShowNotifications(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_showNotificationsKey, value);
      state = state!.copyWith(showNotifications: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set auto detect clipboard
  Future<void> setAutoDetectClipboard(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_autoDetectClipboardKey, value);
      state = state!.copyWith(autoDetectClipboard: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set default quality
  Future<void> setDefaultQuality(String quality) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setString(_defaultQualityKey, quality);
      state = state!.copyWith(defaultQuality: quality);
    } catch (e) {
      // Handle error
    }
  }

  // Set background downloads enabled
  Future<void> setBackgroundDownloadsEnabled(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_backgroundDownloadsEnabledKey, value);
      state = state!.copyWith(backgroundDownloadsEnabled: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set background download notifications
  Future<void> setBackgroundDownloadNotifications(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_backgroundDownloadNotificationsKey, value);
      state = state!.copyWith(backgroundDownloadNotifications: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set save subtitles
  Future<void> setSaveSubtitles(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_saveSubtitlesKey, value);
      state = state!.copyWith(saveSubtitles: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set save metadata
  Future<void> setSaveMetadata(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_saveMetadataKey, value);
      state = state!.copyWith(saveMetadata: value);
    } catch (e) {
      // Handle error
    }
  }

  // Set auto play videos
  Future<void> setAutoPlayVideos(bool value) async {
    if (state == null || _prefs == null) return;

    try {
      await _prefs!.setBool(_autoPlayVideosKey, value);
      state = state!.copyWith(autoPlayVideos: value);
    } catch (e) {
      // Handle error
    }
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    if (_prefs == null) return;

    try {
      // Clear all settings
      await _prefs!.clear();

      // Set to default values
      state = const AppSettings();
    } catch (e) {
      // Handle error
    }
  }
}