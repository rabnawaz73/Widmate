import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final bus = ref.watch(eventBusProvider);
  return NotificationService(bus);
});

class NotificationService {
  final EventBus eventBus;
  final _notifications = FlutterLocalNotificationsPlugin();

  NotificationService(this.eventBus) {
    _initialize();
  }

  Future<void> _initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      eventBus.emit(NotificationClickEvent(response.payload!));
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool ongoing = false,
    int? progress,
    String channelId = 'downloads_channel',
    String channelName = 'Downloads',
    String channelDescription = 'Download progress notifications',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: ongoing,
      icon: '@mipmap/ic_launcher',
      showProgress: progress != null,
      maxProgress: 100,
      progress: progress ?? 0,
    );

    await _notifications.show(
      0,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  // Download-specific notification methods
  Future<void> showDownloadStarted(DownloadItem download) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      download.id.hashCode,
      'Download Started',
      'Downloading ${download.title}',
      notificationDetails,
      payload: download.id,
    );
  }

  Future<void> updateDownloadProgress(DownloadItem download) async {
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      showWhen: false,
      maxProgress: 100,
      progress: (download.progress * 100).round(),
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      download.id.hashCode,
      'Downloading ${download.title}',
      '${(download.progress * 100).round()}% - ${download.formattedSpeed} - ${download.formattedEta} remaining',
      notificationDetails,
      payload: download.id,
    );
  }

  Future<void> showDownloadCompleted(DownloadItem download) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      download.id.hashCode,
      'Download Completed',
      download.title,
      notificationDetails,
      payload: download.id,
    );
  }

  Future<void> showDownloadFailed(DownloadItem download) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      download.id.hashCode,
      'Download Failed',
      'Failed to download ${download.title}',
      notificationDetails,
      payload: download.id,
    );
  }

  Future<void> cancelDownloadNotification(DownloadItem download) async {
    await _notifications.cancel(download.id.hashCode);
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Media Player notification methods
  Future<void> showMediaPlayerNotification({
    required String title,
    required String body,
    String? payload,
    bool isPlaying = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'media_player_channel',
      'Media Player',
      channelDescription: 'Media playback notifications',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      actions: [
        const AndroidNotificationAction(
          'previous',
          'Previous',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_previous'),
        ),
        AndroidNotificationAction(
          isPlaying ? 'pause' : 'play',
          isPlaying ? 'Pause' : 'Play',
          icon: DrawableResourceAndroidBitmap(
            isPlaying ? '@drawable/ic_pause' : '@drawable/ic_play_arrow',
          ),
        ),
        const AndroidNotificationAction(
          'next',
          'Next',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_next'),
        ),
        const AndroidNotificationAction(
          'close',
          'Close',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_close'),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1000, // Media player notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelMediaPlayerNotification() async {
    await _notifications.cancel(1000);
  }
}
