import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart'
    as model;
import 'package:widmate/features/downloads/domain/models/download_events.dart'
    as model;
import 'package:widmate/features/downloads/data/repositories/download_repository.dart';
import 'package:widmate/app/src/services/notification_service.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/services/video_download_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';
import 'package:widmate/core/providers/video_download_provider.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final downloadRepository = ref.watch(downloadRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final videoDownloadService = ref.watch(videoDownloadServiceProvider);
  return DownloadService(
      downloadRepository, notificationService, videoDownloadService);
});

// Download events are imported from models

class DownloadService {
  final DownloadRepository _downloadRepository;
  final NotificationService _notificationService;
  final VideoDownloadService _videoDownloadService;
  final Map<String, dynamic> _activeDownloads = {};
  final _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;
  final _downloadEventsController =
      StreamController<model.DownloadEvent>.broadcast();

  Stream<model.DownloadEvent> get downloadEvents =>
      _downloadEventsController.stream;

  DownloadService(this._downloadRepository, this._notificationService,
      this._videoDownloadService);

  // Get all downloads
  Future<List<model.DownloadItem>> getAllDownloads() async {
    return await _downloadRepository.getAllDownloads();
  }

  // Get active downloads
  Future<List<model.DownloadItem>> getActiveDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where(
          (download) =>
              download.status == model.DownloadStatus.downloading ||
              download.status == model.DownloadStatus.queued,
        )
        .toList();
  }

  // Get completed downloads
  Future<List<model.DownloadItem>> getCompletedDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where((download) => download.status == model.DownloadStatus.completed)
        .toList();
  }

  // Get failed downloads
  Future<List<model.DownloadItem>> getFailedDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where((download) => download.status == model.DownloadStatus.failed)
        .toList();
  }

  // Add a download with existing download ID from backend
  Future<model.DownloadItem> addDownloadWithId({
    required String url,
    required String title,
    String? thumbnailUrl,
    required model.DownloadPlatform platform,
    required String downloadId,
  }) async {
    // Create download directory if it doesn't exist
    final baseDir = await _getDownloadDirectory();
    final platformDir = Directory(
      '${baseDir.path}/${_getPlatformFolder(platform)}',
    );
    if (!await platformDir.exists()) {
      await platformDir.create(recursive: true);
    }

    // Generate a safe filename
    final safeTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final fileName =
        '$safeTitle.mp4'; // Default to mp4, can be changed based on content type
    final filePath = '${platformDir.path}/$fileName';

    // Create download item
    final downloadItem = model.DownloadItem(
      id: downloadId, // Use the provided download ID from backend
      url: url,
      title: title,
      thumbnailUrl: thumbnailUrl,
      platform: platform,
      filePath: filePath,
      fileName: fileName,
      totalBytes: 0,
      downloadedBytes: 0,
      progress: 0.0,
      speed: 0,
      eta: 0,
      status: model.DownloadStatus.queued,
      createdAt: DateTime.now(),
    );

    // Save to repository
    await _downloadRepository.saveDownload(downloadItem);

    // Process queue
    _processQueue();

    return downloadItem;
  }

  // Process download queue
  Future<void> _processQueue() async {
    // Get all queued downloads
    final downloads = await _downloadRepository.getAllDownloads();
    final queuedDownloads = downloads
        .where((download) => download.status == model.DownloadStatus.queued)
        .toList();

    // Get current active downloads count
    final activeDownloads = downloads
        .where(
            (download) => download.status == model.DownloadStatus.downloading)
        .toList();

    // Start downloads if we have capacity
    for (final download in queuedDownloads) {
      if (activeDownloads.length < _maxConcurrentDownloads) {
        _startDownloadProcess(download);
      } else {
        break; // We've reached max concurrent downloads
      }
    }
  }

  int _parseSpeed(String? speedStr) {
    if (speedStr == null || speedStr.toLowerCase() == 'na') return 0;
    try {
      // e.g., "1.23MiB/s", "512.4KiB/s", "10.0B/s"
      final sanitized = speedStr.replaceAll('/s', '').trim();
      final valueStr = sanitized.replaceAll(RegExp(r'[a-zA-Z]'), '').trim();
      final unit = sanitized.replaceAll(RegExp(r'[0-9.\\s]'), '').toUpperCase();

      final value = double.parse(valueStr);

      if (unit.startsWith('K')) {
        return (value * 1024).toInt();
      } else if (unit.startsWith('M')) {
        return (value * 1024 * 1024).toInt();
      } else if (unit.startsWith('G')) {
        return (value * 1024 * 1024 * 1024).toInt();
      } else {
        // B for Bytes
        return value.toInt();
      }
    } catch (e) {
      Logger.warning('Could not parse speed: $speedStr', e);
      return 0;
    }
  }

  int _parseEta(String? etaStr) {
    if (etaStr == null || etaStr.toLowerCase() == 'unknown') return 0;
    try {
      // e.g., "01:23:45", "23:45", "45"
      final parts = etaStr.split(':').map(int.parse).toList().reversed.toList();
      int seconds = 0;
      if (parts.isNotEmpty) seconds += parts[0]; // seconds
      if (parts.length > 1) seconds += parts[1] * 60; // minutes
      if (parts.length > 2) seconds += parts[2] * 3600; // hours
      return seconds;
    } catch (e) {
      Logger.warning('Could not parse ETA: $etaStr', e);
      return 0;
    }
  }

  // Start actual download process
  Future<void> _startDownloadProcess(model.DownloadItem download) async {
    // Update status to downloading
    var updatedDownload =
        download.copyWith(status: model.DownloadStatus.downloading);
    await _downloadRepository.updateDownload(updatedDownload);

    // Show download started notification
    await _notificationService.showDownloadStarted(updatedDownload);

    final timer =
        Timer.periodic(AppConstants.progressUpdateInterval, (timer) async {
      // If download is no longer active (e.g. paused/cancelled), stop polling
      if (!_activeDownloads.containsKey(download.id)) {
        timer.cancel();
        return;
      }

      try {
        final status =
            await _videoDownloadService.getDownloadStatus(download.id);

        // Update download item with new status
        updatedDownload = updatedDownload.copyWith(
          progress: status.progress,
          speed: _parseSpeed(status.speed),
          eta: _parseEta(status.eta),
          downloadedBytes: status.downloadedBytes,
          totalBytes: status.totalBytes,
        );

        if (status.isDownloading) {
          await _downloadRepository.updateDownload(updatedDownload);
          await _notificationService.updateDownloadProgress(updatedDownload);
        } else if (status.isCompleted) {
          timer.cancel();
          _activeDownloads.remove(download.id);

          // Download the file from backend to device storage
          final finalPath = await _videoDownloadService.downloadFile(
              download.id, status.filename ?? download.fileName);

          updatedDownload = updatedDownload.copyWith(
            status: model.DownloadStatus.completed,
            progress: 1.0,
            filePath: finalPath,
            fileName: status.filename ?? download.fileName,
            completedAt: () => DateTime.now(),
          );
          await _downloadRepository.updateDownload(updatedDownload);
          await _notificationService.showDownloadCompleted(updatedDownload);
          _downloadEventsController.add(
            model.DownloadCompletedEvent(download.id, finalPath),
          );
          _processQueue();
        } else if (status.isFailed) {
          timer.cancel();
          _activeDownloads.remove(download.id);
          updatedDownload = updatedDownload.copyWith(
            status: model.DownloadStatus.failed,
            error: () => status.error ?? 'Unknown error',
          );
          await _downloadRepository.updateDownload(updatedDownload);
          await _notificationService.showDownloadFailed(updatedDownload);
          _downloadEventsController.add(
            model.DownloadFailedEvent(
                download.id, status.error ?? 'Unknown error'),
          );
          _processQueue();
        } else if (status.isCancelled) {
          timer.cancel();
          _activeDownloads.remove(download.id);
          // The cancelDownload method handles the rest.
        }
      } catch (e, stack) {
        timer.cancel();
        _activeDownloads.remove(download.id);
        final appError = ErrorFactory.fromException(e, stack);
        appError.log();

        updatedDownload = updatedDownload.copyWith(
          status: model.DownloadStatus.failed,
          error: () => appError.message,
        );
        await _downloadRepository.updateDownload(updatedDownload);
        await _notificationService.showDownloadFailed(updatedDownload);
        _downloadEventsController.add(
          model.DownloadFailedEvent(download.id, appError.message),
        );
        _processQueue();
      }
    });

    _activeDownloads[download.id] = timer;
  }

  // Pause download
  Future<void> pauseDownload(String downloadId) async {
    // Cancel the download process
    _activeDownloads[downloadId]?.cancel();
    _activeDownloads.remove(downloadId);

    // Update status
    final download = await _downloadRepository.getDownloadById(downloadId);
    if (download != null) {
      final updatedDownload =
          download.copyWith(status: model.DownloadStatus.paused);
      await _downloadRepository.updateDownload(updatedDownload);

      // Cancel notification
      await _notificationService.cancelNotification(
        updatedDownload.id.hashCode,
      );
    }

    // Process queue for next download
    _processQueue();
  }

  // Resume download
  Future<void> resumeDownload(String downloadId) async {
    final download = await _downloadRepository.getDownloadById(downloadId);
    if (download != null) {
      final updatedDownload =
          download.copyWith(status: model.DownloadStatus.queued);
      await _downloadRepository.updateDownload(updatedDownload);
      _processQueue();
    }
  }

  // Cancel download
  Future<void> cancelDownload(String downloadId) async {
    // Cancel the download process
    _activeDownloads[downloadId]?.cancel();
    _activeDownloads.remove(downloadId);

    // Update status
    final download = await _downloadRepository.getDownloadById(downloadId);
    if (download != null) {
      final updatedDownload = download.copyWith(
        status: model.DownloadStatus.canceled,
      );
      await _downloadRepository.updateDownload(updatedDownload);

      // Cancel notification
      await _notificationService.cancelNotification(
        updatedDownload.id.hashCode,
      );

      // Delete the partial file
      try {
        final file = File(download.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
    }

    // Process queue for next download
    _processQueue();
  }

  // Retry failed download
  Future<void> retryDownload(String downloadId) async {
    final download = await _downloadRepository.getDownloadById(downloadId);
    if (download != null) {
      final updatedDownload = download.copyWith(
        status: model.DownloadStatus.queued,
        downloadedBytes: 0,
        progress: 0.0,
        speed: 0,
        eta: 0,
        error: () => null,
      );
      await _downloadRepository.updateDownload(updatedDownload);
      _processQueue();
    }
  }

  // Delete download
  Future<void> deleteDownload(String downloadId) async {
    // Cancel if active
    _activeDownloads[downloadId]?.cancel();
    _activeDownloads.remove(downloadId);

    // Get download info
    final download = await _downloadRepository.getDownloadById(downloadId);
    if (download != null) {
      // Delete the file if it exists
      try {
        final file = File(download.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }

      // Remove from repository
      await _downloadRepository.deleteDownload(downloadId);
    }
  }

  // Clear all completed downloads
  Future<void> clearCompletedDownloads() async {
    final completedDownloads = await getCompletedDownloads();
    for (final download in completedDownloads) {
      await _downloadRepository.deleteDownload(download.id);
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    // Cancel all active downloads
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();

    // Delete all downloads
    await _downloadRepository.deleteAllDownloads();
  }

  // Update max concurrent downloads
  void updateMaxConcurrentDownloads(int maxConcurrentDownloads) {
    // Update the value
    // This would typically be stored in settings
    // For now, we'll just update the local variable
    // _maxConcurrentDownloads = maxConcurrentDownloads;

    // Process queue to start new downloads if capacity increased
    _processQueue();
  }

  // Helper method to get download directory
  Future<Directory> _getDownloadDirectory() async {
    // This would typically come from settings
    // For now, we'll use the app's documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${appDocDir.path}/WidMate');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  // Helper method to get platform folder name
  String _getPlatformFolder(model.DownloadPlatform platform) {
    switch (platform) {
      case model.DownloadPlatform.youtube:
        return 'YouTube';
      case model.DownloadPlatform.tiktok:
        return 'TikTok';
      case model.DownloadPlatform.instagram:
        return 'Instagram';
      case model.DownloadPlatform.facebook:
        return 'Facebook';
      case model.DownloadPlatform.other:
        return 'Other';
    }
  }

  // Add a download from URL with validation
  Future<void> addDownloadFromUrl(String url) async {
    try {
      // Validate URL
      final urlValidation = ValidationUtils.validateUrl(url);
      if (!urlValidation.isValid) {
        throw ValidationError(message: urlValidation.error!);
      }

      Logger.info('Adding download from URL: $url');

      // Generate a unique ID
      final downloadId = const Uuid().v4();

      // Determine platform from URL
      final platform = _determinePlatformFromUrl(url);

      // Create a title from URL
      final title = _generateTitleFromUrl(url);

      // Create download item
      final downloadItem = model.DownloadItem(
        id: downloadId,
        title: title,
        url: url,
        platform: platform,
        filePath: '', // Will be set when download completes
        fileName: _generateFileNameFromUrl(url),
        status: model.DownloadStatus.queued,
        progress: 0.0,
        downloadedBytes: 0,
        totalBytes: 0,
        speed: 0,
        eta: 0,
        createdAt: DateTime.now(),
      );

      // Add to repository
      await _downloadRepository.saveDownload(downloadItem);

      // Process queue
      _processQueue();

      Logger.info('Successfully added download from URL: $url');
    } catch (e, stackTrace) {
      final appError = ErrorFactory.fromException(e, stackTrace);
      appError.log();
      rethrow;
    }
  }

  // Determine platform from URL
  model.DownloadPlatform _determinePlatformFromUrl(String url) {
    url = url.toLowerCase();
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return model.DownloadPlatform.youtube;
    } else if (url.contains('tiktok.com')) {
      return model.DownloadPlatform.tiktok;
    } else if (url.contains('instagram.com')) {
      return model.DownloadPlatform.instagram;
    } else if (url.contains('facebook.com') || url.contains('fb.com')) {
      return model.DownloadPlatform.facebook;
    } else {
      return model.DownloadPlatform.other;
    }
  }

  // Generate title from URL
  String _generateTitleFromUrl(String url) {
    // Extract title from URL
    // This is a simple implementation, could be improved
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last.replaceAll('-', ' ').replaceAll('_', ' ');
      }
    } catch (e) {
      debugPrint('Error parsing URL: $e');
    }
    return 'Download from ${url.split('/')[2]}';
  }

  // Generate filename from URL
  String _generateFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        // If it has an extension, use it; otherwise add .mp4
        if (lastSegment.contains('.')) {
          return lastSegment;
        } else {
          return '${lastSegment.replaceAll('-', '_').replaceAll(' ', '_')}.mp4';
        }
      }
    } catch (e) {
      debugPrint('Error parsing URL for filename: $e');
    }
    return 'download_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  // Dispose method to clean up resources
  void dispose() {
    for (final subscription in _activeDownloads.values) {
      subscription.cancel();
    }
    _activeDownloads.clear();
  }
}
