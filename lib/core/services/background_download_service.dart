import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';

/// Background download service that handles downloads when app is minimized
class BackgroundDownloadService {
  static const MethodChannel _channel = MethodChannel('background_download');
  static const EventChannel _eventChannel = EventChannel(
    'background_download_events',
  );

  static BackgroundDownloadService? _instance;
  static BackgroundDownloadService get instance =>
      _instance ??= BackgroundDownloadService._();

  BackgroundDownloadService._();

  StreamSubscription<dynamic>? _eventSubscription;
  final StreamController<DownloadEvent> _downloadEventsController =
      StreamController<DownloadEvent>.broadcast();

  /// Stream of download events from background service
  Stream<DownloadEvent> get downloadEvents => _downloadEventsController.stream;

  /// Initialize the background download service
  Future<void> initialize() async {
    try {
      // Start listening to background download events
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleBackgroundEvent,
        onError: (error) {
          debugPrint('Background download event error: $error');
        },
      );

      debugPrint('Background download service initialized');
    } catch (e) {
      debugPrint('Failed to initialize background download service: $e');
    }
  }

  /// Handle events from background service
  void _handleBackgroundEvent(dynamic event) {
    try {
      if (event is Map<String, dynamic>) {
        final eventType = event['type'] as String?;
        final downloadId = event['downloadId'] as String?;

        if (downloadId == null) return;

        switch (eventType) {
          case 'progress':
            _downloadEventsController.add(
              DownloadProgressEvent(
                downloadId,
                event['progress'] as double? ?? 0.0,
                event['downloadedBytes'] as int? ?? 0,
                event['totalBytes'] as int? ?? 0,
              ),
            );
            break;
          case 'completed':
            _downloadEventsController.add(
              DownloadCompletedEvent(
                downloadId,
                event['filePath'] as String? ?? '',
              ),
            );
            break;
          case 'failed':
            _downloadEventsController.add(
              DownloadFailedEvent(
                downloadId,
                event['error'] as String? ?? 'Unknown error',
              ),
            );
            break;
          case 'paused':
            _downloadEventsController.add(DownloadPausedEvent(downloadId));
            break;
          case 'resumed':
            _downloadEventsController.add(DownloadResumedEvent(downloadId));
            break;
        }
      }
    } catch (e) {
      debugPrint('Error handling background event: $e');
    }
  }

  /// Start a background download
  Future<void> startBackgroundDownload(DownloadItem download) async {
    try {
      await _channel.invokeMethod('startDownload', {
        'id': download.id,
        'url': download.url,
        'title': download.title,
        'fileName': download.fileName ?? '${download.title}.mp4',
        'filePath': download.filePath ?? '',
        'platform': download.platform.toString().split('.').last,
      });
    } catch (e) {
      debugPrint('Failed to start background download: $e');
      _downloadEventsController.add(
        DownloadFailedEvent(download.id, e.toString()),
      );
    }
  }

  /// Pause a background download
  Future<void> pauseBackgroundDownload(String downloadId) async {
    try {
      await _channel.invokeMethod('pauseDownload', {'downloadId': downloadId});
    } catch (e) {
      debugPrint('Failed to pause background download: $e');
    }
  }

  /// Resume a background download
  Future<void> resumeBackgroundDownload(String downloadId) async {
    try {
      await _channel.invokeMethod('resumeDownload', {'downloadId': downloadId});
    } catch (e) {
      debugPrint('Failed to resume background download: $e');
    }
  }

  /// Cancel a background download
  Future<void> cancelBackgroundDownload(String downloadId) async {
    try {
      await _channel.invokeMethod('cancelDownload', {'downloadId': downloadId});
    } catch (e) {
      debugPrint('Failed to cancel background download: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _eventSubscription?.cancel();
    _downloadEventsController.close();
  }
}

/// Provider for BackgroundDownloadService
final backgroundDownloadServiceProvider = Provider<BackgroundDownloadService>((
  ref,
) {
  return BackgroundDownloadService.instance;
});
