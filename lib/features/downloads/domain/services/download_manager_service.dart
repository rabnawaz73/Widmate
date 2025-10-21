import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/app/src/services/error_handler_service.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';

class DownloadManagerService {
  final EventBus _eventBus;
  final ErrorHandlerService _errorHandler;
  final Map<String, bool> _activeDownloads = {};

  DownloadManagerService(this._eventBus, this._errorHandler);

  void startDownload(String id, String url) {
    if (_activeDownloads[id] == true) {
      _errorHandler.handleError(AppError('Download already in progress'));
      return;
    }

    _activeDownloads[id] = true;
    _eventBus.emit(DownloadStartedEvent(id, url));
  }

  void cancelDownload(String id) {
    _activeDownloads.remove(id);
    _eventBus.emit(DownloadCanceledEvent(id));
  }

  void onProgress(String id, double progress) {
    _eventBus.emit(DownloadProgressEvent(id, progress, 0, 0));
  }

  void onComplete(String id, String filePath) {
    _activeDownloads.remove(id);
    _eventBus.emit(DownloadCompletedEvent(id, filePath));
  }

  void onError(String id, String error) {
    _activeDownloads.remove(id);
    _eventBus.emit(DownloadFailedEvent(id, error));
  }

  // Get all downloads (placeholder implementation)
  Future<List<dynamic>> getAllDownloads() async {
    // This should be implemented to return actual downloads
    // For now, return empty list
    return [];
  }

  // Add download with ID
  Future<void> addDownloadWithId({
    required String url,
    required String title,
    String? thumbnailUrl,
    required String platform,
    required String downloadId,
  }) async {
    // Implementation for adding download
  }

  // Pause download
  Future<void> pauseDownload(String id) async {
    // Implementation for pausing download
  }

  // Resume download
  Future<void> resumeDownload(String id) async {
    // Implementation for resuming download
  }

  // Retry download
  Future<void> retryDownload(String id) async {
    // Implementation for retrying download
  }

  // Delete download
  Future<void> deleteDownload(String id) async {
    // Implementation for deleting download
  }

  // Clear completed downloads
  Future<void> clearCompletedDownloads() async {
    // Implementation for clearing completed downloads
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    // Implementation for clearing all downloads
  }
}

final downloadManagerProvider = Provider<DownloadManagerService>((ref) {
  final eventBus = ref.watch(eventBusProvider);
  final errorHandler = ref.watch(errorHandlerProvider);
  return DownloadManagerService(eventBus, errorHandler);
});