import 'package:audio_service/audio_service.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/features/media/domain/services/background_media_service.dart';

/// Initialize background media service
class BackgroundMediaInitializer {
  static BackgroundMediaService? _backgroundService;

  /// Initialize background media service
  static Future<void> initialize() async {
    try {
      Logger.info('Initializing background media service');

      await AudioService.init(
        builder: () => BackgroundMediaService(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.widmate.media',
          androidNotificationChannelName: 'WidMate Media',
          androidNotificationChannelDescription: 'Media playback notifications',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'drawable/ic_notification',
        ),
      );

      _backgroundService = BackgroundMediaService();
      Logger.info('Background media service initialized successfully');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to initialize background media service',
        e,
        stackTrace,
      );
    }
  }

  /// Get background media service instance
  static BackgroundMediaService? get instance => _backgroundService;

  /// Dispose background media service
  static Future<void> dispose() async {
    try {
      if (_backgroundService != null) {
        await _backgroundService!.onTaskRemoved();
        _backgroundService = null;
      }
      Logger.info('Background media service disposed');
    } catch (e, stackTrace) {
      Logger.error('Failed to dispose background media service', e, stackTrace);
    }
  }
}
