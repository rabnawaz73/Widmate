import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/presentation/controllers/download_controller.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final bus = ref.watch(eventBusProvider);
  return NotificationService(bus, ref.container);
});

class NotificationService {
  final EventBus eventBus;
  final ProviderContainer container;
  final _notifications = FlutterLocalNotificationsPlugin();

  NotificationService(this.eventBus, this.container) {
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

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestPermission();
    } catch (_) {}
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final downloadId = response.payload!;
      if (response.actionId == 'pause') {
        container.read(downloadControllerProvider.notifier).pauseDownload(downloadId);
      } else if (response.actionId == 'cancel') {
        container.read(downloadControllerProvider.notifier).cancelDownload(downloadId);
      } else {
        eventBus.emit(NotificationClickEvent(downloadId));
      }
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
    final thumbnailPath = await _downloadThumbnail(download.thumbnailUrl);
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      largeIcon: thumbnailPath != null ? FilePathAndroidBitmap(thumbnailPath) : null,
      showWhen: false,
      maxProgress: 100,
      progress: (download.progress * 100).round(),
      ongoing: true,
      autoCancel: false,
      actions: [
        const AndroidNotificationAction('pause', 'Pause'),
        const AndroidNotificationAction('cancel', 'Cancel'),
      ],
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      download.id.hashCode,
      download.title,
      '${(download.progress * 100).round()}% - ${download.formattedSpeed} - ${download.formattedEta} remaining',
      notificationDetails,
      payload: download.id,
    );
  }

  Future<void> showDownloadCompleted(DownloadItem download) async {
    final thumbnailPath = await _downloadThumbnail(download.thumbnailUrl);
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: thumbnailPath != null ? FilePathAndroidBitmap(thumbnailPath) : null,
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

  Future<String?> _downloadThumbnail(String? url) async {
    if (url == null) return null;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/${url.hashCode}.png';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }
    } catch (e) {
      print('Error downloading thumbnail: $e');
    }
    return null;
  }

  void showError(String message) {
    eventBus.emit(ShowErrorEvent(message));
  }
}
