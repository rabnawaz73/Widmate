import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/providers/video_download_provider.dart'
    hide downloadManagerProvider;
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/core/services/video_download_service.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // For jsonEncode/decode
import 'package:widmate/app/src/services/notification_service.dart'; // Import NotificationService

// This is a placeholder provider. In a real app, you would initialize
// SharedPreferences asynchronously and provide it here, likely by overriding
// this provider in your main.dart file.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});

// Provider for download controller
final downloadControllerProvider =
    NotifierProvider<DownloadController, AsyncValue<List<DownloadItem>>>(
  DownloadController.new,
);

// Provider for download stats
final downloadStatsProvider = Provider<DownloadStats>((ref) {
  final downloads = ref.watch(downloadControllerProvider.select((state) => state.valueOrNull ?? []));

  final active =
      downloads.where((d) => d.status == DownloadStatus.downloading).length;
  final queued =
      downloads.where((d) => d.status == DownloadStatus.queued).length;
  final completed =
      downloads.where((d) => d.status == DownloadStatus.completed).length;
  final failed =
      downloads.where((d) => d.status == DownloadStatus.failed).length;
  final total = downloads.length;

  return DownloadStats(
    active: active,
    queued: queued,
    completed: completed,
    failed: failed,
    total: total,
  );
});

// Download controller
class DownloadController extends Notifier<AsyncValue<List<DownloadItem>>> {
  late final VideoDownloadService _downloadService; // Use the new DownloadService
  late final SharedPreferences _prefs; // SharedPreferences instance
  late final NotificationService _notificationService; // NotificationService instance
  Timer? _refreshTimer;
  List<DownloadItem> _previousDownloads = [];

  @override
  AsyncValue<List<DownloadItem>> build() {
    _downloadService = ref.read(videoDownloadServiceProvider); // Get the DownloadService
    _prefs = ref.read(sharedPreferencesProvider); // Get SharedPreferences
    _notificationService = ref.read(notificationServiceProvider); // Get NotificationService

    _loadDownloads(); // Initial load
    _startRefreshTimer(); // Start polling for updates

    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const AsyncValue.loading();
  }

  // Start refresh timer with optimized interval
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(AppConstants.progressUpdateInterval, (timer) async {
      // Only refresh if there are active downloads
      final currentDownloads = state.valueOrNull ?? [];
      final hasActiveDownloads = currentDownloads.any(
        (d) =>
            d.status == DownloadStatus.downloading ||
            d.status == DownloadStatus.queued ||
            d.status == DownloadStatus.paused, // Also refresh paused to check if backend resumed
      );
      if (hasActiveDownloads) {
        await _loadDownloads(); // Reload all downloads to get latest status
      }
    });
  }

  // Load downloads from backend and local storage with error handling
  Future<void> _loadDownloads() async {
    try {
      // Load from backend
      final backendStatuses = await _downloadService.getAllDownloads();
      final List<DownloadItem> downloadsFromBackend = [];

      // Load download URLs from prefs
      final String? savedUrlsJson = _prefs.getString('download_urls');
      final Map<String, String> downloadUrls = savedUrlsJson != null ? Map<String, String>.from(jsonDecode(savedUrlsJson)) : {};

      for (final backendStatus in backendStatuses) {
        // For now, we'll use placeholder title/thumbnail/platform.
        // In a real app, you'd store these with the download or fetch them again.
        downloadsFromBackend.add(DownloadItem.fromBackendDownloadStatus(
          backendStatus,
          url: downloadUrls[backendStatus.id] ?? '',
          title: 'Video ${backendStatus.id.substring(0, 4)}',
          thumbnailUrl: null,
          platform: DownloadPlatform.other,
        ));
      }

      // Load from local storage (completed downloads)
      final String? savedDownloadsJson = _prefs.getString('completed_downloads');
      final List<DownloadItem> localDownloads = [];
      if (savedDownloadsJson != null) {
        final List<dynamic> jsonList = jsonDecode(savedDownloadsJson);
        localDownloads.addAll(jsonList.map((json) => DownloadItem.fromJson(json)));
      }

      // Merge and deduplicate: backend status takes precedence
      final Map<String, DownloadItem> mergedDownloads = {};
      for (final item in localDownloads) {
        mergedDownloads[item.id] = item;
      }
      for (final item in downloadsFromBackend) {
        mergedDownloads[item.id] = item;
      }

      final newDownloads = mergedDownloads.values.toList();
      _updateNotifications(newDownloads);
      _previousDownloads = newDownloads;
      state = AsyncValue.data(newDownloads);
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Save completed downloads to SharedPreferences
  Future<void> _saveDownloadsToPrefs(List<DownloadItem> downloads) async {
    final completed = downloads.where((d) => d.status == DownloadStatus.completed).toList();
    final String jsonString = jsonEncode(completed.map((d) => d.toJson()).toList());
    await _prefs.setString('completed_downloads', jsonString);
  }

  // Add a new download with download ID from backend
  Future<void> addDownload({
    required String url,
    required String title,
    String? thumbnailUrl,
    required DownloadPlatform platform,
    required String downloadId,
  }) async {
    try {
      // Validate inputs
      final urlValidation = ValidationUtils.validateUrl(url);
      if (!urlValidation.isValid) {
        throw ValidationError(message: urlValidation.error!);
      }

      final titleValidation = ValidationUtils.validateTitle(title);
      if (!titleValidation.isValid) {
        throw ValidationError(message: titleValidation.error!);
      }

      Logger.info('Adding download: $title');

      // Save download URL to prefs
      final String? savedUrlsJson = _prefs.getString('download_urls');
      final Map<String, String> downloadUrls = savedUrlsJson != null ? Map<String, String>.from(jsonDecode(savedUrlsJson)) : {};
      downloadUrls[downloadId] = url;
      await _prefs.setString('download_urls', jsonEncode(downloadUrls));

      // Create a temporary DownloadItem for immediate UI feedback
      final tempDownloadItem = DownloadItem(
        id: downloadId,
        url: url,
        title: title,
        platform: platform,
        filePath: null,
        fileName: null,
        totalBytes: null,
        downloadedBytes: 0,
        progress: 0.0,
        speed: null,
        eta: null,
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
        thumbnailUrl: thumbnailUrl,
      );

      state.whenData((downloads) {
        state = AsyncValue.data([...downloads, tempDownloadItem]);
      });

      // The actual download is started via the backend's /download endpoint
      // This method is called AFTER the /download endpoint has been hit
      // So we just need to refresh the list to get the actual status from backend
      await _loadDownloads();
      _notificationService.showDownloadStarted(tempDownloadItem); // Show notification

      Logger.info('Successfully added download: $title');
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Pause download
  Future<void> pauseDownload(String downloadId) async {
    try {
      await _downloadService.cancelDownload(downloadId); // Backend uses cancel for pause/stop
      await _loadDownloads(); // Refresh to get updated status
      final download = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
      if (download != null) {
        _notificationService.cancelDownloadNotification(download); // Cancel ongoing notification
      }
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Resume download (backend doesn't have explicit resume, so we re-queue)
  Future<void> resumeDownload(String downloadId) async {
    // This assumes you can get the original URL and format_id from the DownloadItem
    // For now, this is a placeholder. You might need to store more info in DownloadItem
    final downloadItem = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
    if (downloadItem != null) {
      try {
        // Re-queue the download. This will generate a new downloadId on the backend.
        // You might want to handle this differently, e.g., by having the backend
        // truly resume a cancelled download with the same ID.
        // For now, we'll just start a new one.
        final downloadResponse = await _downloadService.startDownload(
          url: downloadItem.url,
            // You'd need to store formatId/quality in DownloadItem to re-queue accurately
            // For now, using defaults or inferring from original URL
        );
        // Remove old item and add new one
        state.whenData((downloads) {
          final updatedDownloads = downloads.where((d) => d.id != downloadId).toList();
          final tempDownloadItem = DownloadItem(
            id: downloadResponse.downloadId,
            url: downloadItem.url,
            title: downloadItem.title,
            platform: downloadItem.platform,
            filePath: null,
            fileName: null,
            totalBytes: null,
            downloadedBytes: 0,
            progress: 0.0,
            speed: null,
            eta: null,
            status: DownloadStatus.queued,
            createdAt: DateTime.now(),
            thumbnailUrl: downloadItem.thumbnailUrl,
          );
          updatedDownloads.add(tempDownloadItem);
          state = AsyncValue.data(updatedDownloads);
        });
        await _loadDownloads(); // Refresh to get actual status
        _notificationService.showDownloadStarted(downloadItem); // Show notification for resumed download
      } catch (e, stack) {
        final appError = ErrorFactory.fromException(e, stack);
        appError.log();
        state = AsyncValue.error(appError, stack);
      }
    }
  }

  // Cancel download
  Future<void> cancelDownload(String downloadId) async {
    try {
      await _downloadService.cancelDownload(downloadId);
      await _loadDownloads(); // Refresh to get updated status
      final download = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
      if (download != null) {
        _notificationService.cancelDownloadNotification(download); // Cancel ongoing notification
      }
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Retry download
  Future<void> retryDownload(String downloadId) async {
    // Similar to resume, this needs to re-queue the download.
    final downloadItem = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
    if (downloadItem != null) {
      try {
        final downloadResponse = await _downloadService.startDownload(
          url: downloadItem.url,
            // You'd need to store formatId/quality in DownloadItem to re-queue accurately
        );
        state.whenData((downloads) {
          final updatedDownloads = downloads.where((d) => d.id != downloadId).toList();
          final tempDownloadItem = DownloadItem(
            id: downloadResponse.downloadId,
            url: downloadItem.url,
            title: downloadItem.title,
            platform: downloadItem.platform,
            filePath: null,
            fileName: null,
            totalBytes: null,
            downloadedBytes: 0,
            progress: 0.0,
            speed: null,
            eta: null,
            status: DownloadStatus.queued,
            createdAt: DateTime.now(),
            thumbnailUrl: downloadItem.thumbnailUrl,
          );
          updatedDownloads.add(tempDownloadItem);
          state = AsyncValue.data(updatedDownloads);
        });
        await _loadDownloads();
        _notificationService.showDownloadStarted(downloadItem); // Show notification for retried download
      } catch (e, stack) {
        final appError = ErrorFactory.fromException(e, stack);
        appError.log();
        state = AsyncValue.error(appError, stack);
      }
    }
  }

  // Delete download (this will need to delete the file from disk as well)
  Future<void> deleteDownload(String downloadId) async {
    try {
      final downloadItem = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
      if (downloadItem != null && downloadItem.filePath != null) {
        final file = File(downloadItem.filePath!); // Import 'dart:io'
        if (await file.exists()) {
          await file.delete();
          Logger.info('Deleted file: ${downloadItem.filePath}');
        }
      }
      // Remove from local state
      state.whenData((downloads) {
        state = AsyncValue.data(downloads.where((d) => d.id != downloadId).toList());
      });
      // Also remove from SharedPreferences if it was a completed download
      await _saveDownloadsToPrefs(state.valueOrNull ?? []);
      final download = state.valueOrNull?.firstWhere((d) => d.id == downloadId);
      if (download != null) {
        _notificationService.cancelDownloadNotification(download); // Cancel any associated notification
      }
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Clear completed downloads
  Future<void> clearCompletedDownloads() async {
    try {
      await _downloadService.clearDownloads(); // This clears all completed/failed/cancelled on backend
      await _loadDownloads(); // Refresh to get updated list
      _notificationService.cancelAll(); // Cancel all notifications
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError);
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      // For now, this only clears local state and completed downloads from prefs.
      // A full implementation would involve a backend endpoint to clear all downloads
      // and delete all associated files.
      state = const AsyncValue.data([]);
      await _prefs.remove('completed_downloads');
      _notificationService.cancelAll(); // Cancel all notifications
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      _handleError(appError, downloadId: downloadId);
    }
  }

  // Convert SupportedPlatform to download platform
  DownloadPlatform platformToDownloadPlatform(SupportedPlatform platform) {
    switch (platform.name.toLowerCase()) {
      case 'youtube':
        return DownloadPlatform.youtube;
      case 'tiktok':
        return DownloadPlatform.tiktok;
      case 'instagram':
        return DownloadPlatform.instagram;
      case 'facebook':
        return DownloadPlatform.facebook;
      default:
        return DownloadPlatform.other;
    }
  }

  void _updateNotifications(List<DownloadItem> newDownloads) {
    for (final newDownload in newDownloads) {
      final oldDownload = _previousDownloads.firstWhere(
        (d) => d.id == newDownload.id,
        orElse: () => newDownload,
      );

      if (newDownload.status == DownloadStatus.downloading) {
        _notificationService.updateDownloadProgress(newDownload);
      } else if (newDownload.status == DownloadStatus.completed &&
          oldDownload.status != DownloadStatus.completed) {
        _notificationService.showDownloadCompleted(newDownload);
      } else if (newDownload.status == DownloadStatus.failed &&
          oldDownload.status != DownloadStatus.failed) {
        _notificationService.showDownloadFailed(newDownload);
      }
    }
  }

  void _handleError(AppError error, {String? downloadId}) {
    _notificationService.showError(error.message);
    if (downloadId != null) {
      state.whenData((downloads) {
        final index = downloads.indexWhere((d) => d.id == downloadId);
        if (index != -1) {
          final updatedDownloads = List.of(downloads);
          updatedDownloads[index] = updatedDownloads[index].copyWith(
            status: DownloadStatus.failed,
            errorMessage: () => error.message,
          );
          state = AsyncValue.data(updatedDownloads);
        }
      });
    } else {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

// Download stats class
class DownloadStats {
  final int active;
  final int queued;
  final int completed;
  final int failed;
  final int total;

  const DownloadStats({
    this.active = 0,
    this.queued = 0,
    this.completed = 0,
    this.failed = 0,
    this.total = 0,
  });
}
