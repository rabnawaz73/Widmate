import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';
import 'package:widmate/features/downloads/data/repositories/download_repository.dart';
import 'package:widmate/app/src/services/notification_service.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final downloadRepository = ref.watch(downloadRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return DownloadService(downloadRepository, notificationService);
});

// Download events are imported from models

class DownloadService {
  final DownloadRepository _downloadRepository;
  final NotificationService _notificationService;
  final Map<String, dynamic> _activeDownloads = {};
  final _maxConcurrentDownloads = AppConstants.maxConcurrentDownloads;
  final _downloadEventsController = StreamController<DownloadEvent>.broadcast();

  Stream<DownloadEvent> get downloadEvents => _downloadEventsController.stream;

  DownloadService(this._downloadRepository, this._notificationService);

  // Get all downloads
  Future<List<DownloadItem>> getAllDownloads() async {
    return await _downloadRepository.getAllDownloads();
  }

  // Get active downloads
  Future<List<DownloadItem>> getActiveDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where(
          (download) =>
              download.status == DownloadStatus.downloading ||
              download.status == DownloadStatus.queued,
        )
        .toList();
  }

  // Get completed downloads
  Future<List<DownloadItem>> getCompletedDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where((download) => download.status == DownloadStatus.completed)
        .toList();
  }

  // Get failed downloads
  Future<List<DownloadItem>> getFailedDownloads() async {
    final downloads = await _downloadRepository.getAllDownloads();
    return downloads
        .where((download) => download.status == DownloadStatus.failed)
        .toList();
  }

  // Add a download with existing download ID from backend
  Future<DownloadItem> addDownloadWithId({
    required String url,
    required String title,
    String? thumbnailUrl,
    required DownloadPlatform platform,
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
    final downloadItem = DownloadItem(
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
      status: DownloadStatus.queued,
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
        .where((download) => download.status == DownloadStatus.queued)
        .toList();

    // Get current active downloads count
    final activeDownloads = downloads
        .where((download) => download.status == DownloadStatus.downloading)
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

  // Start actual download process
  Future<void> _startDownloadProcess(DownloadItem download) async {
    // Update status to downloading
    var updatedDownload = download.copyWith(status: DownloadStatus.downloading);
    await _downloadRepository.updateDownload(updatedDownload);

    // Show download started notification
    await _notificationService.showDownloadStarted(updatedDownload);

    // TODO: Implement actual download logic with HTTP or platform-specific download
    // For now, we'll simulate a download with a timer

    // Simulate download progress
    const totalBytes = 100 * 1024 * 1024; // 100 MB
    var downloadedBytes = 0;
    final startTime = DateTime.now();

    final timer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      // Simulate download progress
      final elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
      if (elapsedSeconds == 0) return; // Avoid division by zero

      // Simulate random download speed between 1-5 MB/s
      final speed =
          (1 + (DateTime.now().millisecondsSinceEpoch % 4)) * 1024 * 1024;
      downloadedBytes += speed ~/ 2; // Because we update every 500ms

      if (downloadedBytes >= totalBytes) {
        downloadedBytes = totalBytes;
        timer.cancel();

        // Update download as completed
        updatedDownload = updatedDownload.copyWith(
          totalBytes: totalBytes,
          downloadedBytes: downloadedBytes,
          progress: 1.0,
          speed: 0,
          eta: 0,
          status: DownloadStatus.completed,
          completedAt: () => DateTime.now(),
        );
        await _downloadRepository.updateDownload(updatedDownload);

        // Show completed notification
        await _notificationService.showDownloadCompleted(updatedDownload);

        // Emit download completed event
        _downloadEventsController.add(
          DownloadCompletedEvent(download.id, download.filePath),
        );

        // Remove from active downloads
        _activeDownloads.remove(download.id)?.cancel();

        // Process queue for next download
        _processQueue();

        return;
      }

      // Calculate progress and ETA
      final progress = downloadedBytes / totalBytes;
      final eta = ((totalBytes - downloadedBytes) / speed).round();

      // Update download item
      updatedDownload = updatedDownload.copyWith(
        totalBytes: totalBytes,
        downloadedBytes: downloadedBytes,
        progress: progress,
        speed: speed,
        eta: eta,
      );
      await _downloadRepository.updateDownload(updatedDownload);

      // Update notification
      await _notificationService.updateDownloadProgress(updatedDownload);
    });

    // Store the timer subscription
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
      final updatedDownload = download.copyWith(status: DownloadStatus.paused);
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
      final updatedDownload = download.copyWith(status: DownloadStatus.queued);
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
        status: DownloadStatus.canceled,
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
        status: DownloadStatus.queued,
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
  String _getPlatformFolder(DownloadPlatform platform) {
    switch (platform) {
      case DownloadPlatform.youtube:
        return 'YouTube';
      case DownloadPlatform.tiktok:
        return 'TikTok';
      case DownloadPlatform.instagram:
        return 'Instagram';
      case DownloadPlatform.facebook:
        return 'Facebook';
      case DownloadPlatform.other:
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
      final downloadItem = DownloadItem(
        id: downloadId,
        title: title,
        url: url,
        platform: platform,
        filePath: '', // Will be set when download completes
        fileName: _generateFileNameFromUrl(url),
        status: DownloadStatus.queued,
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
  DownloadPlatform _determinePlatformFromUrl(String url) {
    url = url.toLowerCase();
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return DownloadPlatform.youtube;
    } else if (url.contains('tiktok.com')) {
      return DownloadPlatform.tiktok;
    } else if (url.contains('instagram.com')) {
      return DownloadPlatform.instagram;
    } else if (url.contains('facebook.com') || url.contains('fb.com')) {
      return DownloadPlatform.facebook;
    } else {
      return DownloadPlatform.other;
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
