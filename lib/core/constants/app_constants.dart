import 'package:flutter_riverpod/flutter_riverpod.dart';

final baseUrlProvider = StateProvider<String>((ref) {
  // This will be updated by the settings service on app startup
  return 'http://127.0.0.1:8000';
});

/// Core application constants
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'WidMate';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A powerful video downloader app';

  // API Configuration
  static String baseUrl = 'http://127.0.0.1:8000'; // This will be updated on startup
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(minutes: 2);

  // Download Configuration
  static const int maxConcurrentDownloads = 3;
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  static const Duration progressUpdateInterval = Duration(seconds: 1);

  // Storage Configuration
  static const String downloadsFolder = 'WidMate/Downloads';
  static const String cacheFolder = 'WidMate/Cache';
  static const String settingsFolder = 'WidMate/Settings';

  // Notification Configuration
  static const String downloadsChannelId = 'downloads_channel';
  static const String downloadsChannelName = 'Downloads';
  static const String downloadsChannelDescription =
      'Download progress notifications';

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // File Extensions
  static const List<String> videoExtensions = [
    '.mp4',
    '.mkv',
    '.avi',
    '.mov',
    '.wmv',
    '.flv',
  ];
  static const List<String> audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.flac',
    '.m4a',
    '.ogg',
    '.wma',
    '.opus',
  ];

  // Platform Folders
  static const Map<String, String> platformFolders = {
    'youtube': 'YouTube',
    'tiktok': 'TikTok',
    'instagram': 'Instagram',
    'facebook': 'Facebook',
    'other': 'Other',
  };

  // Quality Options
  static const List<String> qualityOptions = [
    '480p',
    '720p',
    '1080p',
    'audio-only',
  ];
  static const String defaultQuality = '720p';

  // Rate Limiting
  static const int maxApiRequestsPerMinute = 30;
  static const int maxSearchRequestsPerMinute = 10;
  static const int maxDownloadRequestsPerMinute = 10;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Error Messages
  static const String networkErrorMessage = 'No internet connection';
  static const String serverErrorMessage = 'Server is not responding';
  static const String unknownErrorMessage = 'An unexpected error occurred';
  static const String downloadFailedMessage =
      'Download failed. Please try again.';
  static const String invalidUrlMessage = 'Please enter a valid URL';

  // Success Messages
  static const String downloadCompletedMessage =
      'Download completed successfully';
  static const String settingsSavedMessage = 'Settings saved successfully';
  static const String cacheClearedMessage = 'Cache cleared successfully';

  // Validation
  static const int minUrlLength = 10;
  static const int maxUrlLength = 2048;
  static const int maxTitleLength = 200;
  static const int maxDescriptionLength = 1000;

  // Performance
  static const int maxSearchResults = 50;
  static const int maxPlaylistItems = 100;
  static const Duration debounceDelay = Duration(milliseconds: 500);
}
