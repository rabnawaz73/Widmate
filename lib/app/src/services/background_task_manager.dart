import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/app/src/services/notification_service.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';

class BackgroundTaskManager {
  final EventBus _eventBus;
  final NotificationService _notifications;

  BackgroundTaskManager(this._eventBus, this._notifications) {
    _initialize();
  }

  void _initialize() {
    _eventBus.on<DownloadStartedEvent>().listen(_handleDownloadStarted);
    _eventBus.on<DownloadProgressEvent>().listen(_handleDownloadProgress);
    _eventBus.on<DownloadCompletedEvent>().listen(_handleDownloadCompleted);
    _eventBus.on<DownloadFailedEvent>().listen(_handleDownloadFailed);
  }

  void _handleDownloadStarted(DownloadStartedEvent event) {
    _notifications.showNotification(
      title: 'Download Started',
      body: 'Downloading from ${event.url}',
      ongoing: true,
      progress: 0,
    );
  }

  void _handleDownloadProgress(DownloadProgressEvent event) {
    _notifications.showNotification(
      title: 'Downloading...',
      body: '${(event.progress * 100).round()}% complete',
      ongoing: true,
      progress: (event.progress * 100).round(),
    );
  }

  void _handleDownloadCompleted(DownloadCompletedEvent event) {
    _notifications.showNotification(
      title: 'Download Complete',
      body: 'File saved to ${event.filePath}',
    );
  }

  void _handleDownloadFailed(DownloadFailedEvent event) {
    _notifications.showNotification(
      title: 'Download Failed',
      body: event.error,
    );
  }
}

final backgroundTaskManagerProvider = Provider<BackgroundTaskManager>((ref) {
  final eventBus = ref.watch(eventBusProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return BackgroundTaskManager(eventBus, notifications);
});
