import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widmate/features/settings/presentation/controllers/settings_controller.dart';

class SettingsExportService {
  /// Export settings to a JSON file
  Future<String?> exportSettings(AppSettings settings) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/widmate_settings_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      final settingsJson = {
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'settings': {
          'downloadPath': settings.downloadPath,
          'maxConcurrentDownloads': settings.maxConcurrentDownloads,
          'showNotifications': settings.showNotifications,
          'autoDetectClipboard': settings.autoDetectClipboard,
          'defaultQuality': settings.defaultQuality,
          'backgroundDownloadsEnabled': settings.backgroundDownloadsEnabled,
          'backgroundDownloadNotifications':
              settings.backgroundDownloadNotifications,
          'saveSubtitles': settings.saveSubtitles,
          'saveMetadata': settings.saveMetadata,
          'autoPlayVideos': settings.autoPlayVideos,
        },
      };

      await file.writeAsString(jsonEncode(settingsJson));
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Import settings from a JSON file
  Future<AppSettings?> importSettings(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      // Validate version
      final version = jsonData['version'] as String?;
      if (version == null) return null;

      final settingsData = jsonData['settings'] as Map<String, dynamic>?;
      if (settingsData == null) return null;

      return AppSettings(
        downloadPath:
            settingsData['downloadPath'] as String? ??
            '/storage/emulated/0/Download/WidMate',
        maxConcurrentDownloads:
            settingsData['maxConcurrentDownloads'] as int? ?? 3,
        showNotifications: settingsData['showNotifications'] as bool? ?? true,
        autoDetectClipboard:
            settingsData['autoDetectClipboard'] as bool? ?? true,
        defaultQuality: settingsData['defaultQuality'] as String? ?? 'HD',
        backgroundDownloadsEnabled:
            settingsData['backgroundDownloadsEnabled'] as bool? ?? true,
        backgroundDownloadNotifications:
            settingsData['backgroundDownloadNotifications'] as bool? ?? true,
        saveSubtitles: settingsData['saveSubtitles'] as bool? ?? false,
        saveMetadata: settingsData['saveMetadata'] as bool? ?? true,
        autoPlayVideos: settingsData['autoPlayVideos'] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Pick a settings file for import
  Future<String?> pickSettingsFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get the default export directory
  Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
