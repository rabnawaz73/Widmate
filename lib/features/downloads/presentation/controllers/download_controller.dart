import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/app/src/services/event_bus.dart';
import 'package:widmate/core/providers/video_download_provider.dart'
    hide downloadManagerProvider;
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';
import 'package:widmate/features/downloads/domain/services/download_manager_service.dart';
import 'package:widmate/core/services/background_download_service.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';

// Provider for download controller
final downloadControllerProvider =
    NotifierProvider<DownloadController, AsyncValue<List<DownloadItem>>>(
  DownloadController.new,
);

// Provider for download stats
final downloadStatsProvider = Provider<DownloadStats>((ref) {
  final downloadState = ref.watch(downloadControllerProvider);

  return downloadState.when(
    data: (downloads) {
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
    },
    loading: () => const DownloadStats(),
    error: (_, __) => const DownloadStats(),
  );
});

// Download state
class DownloadState {
  final Map<String, DownloadItem> downloads;
  final bool isLoading;
  final String? error;

  const DownloadState({
    this.downloads = const {},
    this.isLoading = false,
    this.error,
  });

  DownloadState copyWith({
    Map<String, DownloadItem>? downloads,
    bool? isLoading,
    String? error,
  }) {
    return DownloadState(
      downloads: downloads ?? this.downloads,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Download controller
class DownloadController extends Notifier<AsyncValue<List<DownloadItem>>> {
  late final DownloadManagerService _manager;
  late final EventBus _eventBus;
  late final BackgroundDownloadService _backgroundService;
  Timer? _refreshTimer;

  @override
  AsyncValue<List<DownloadItem>> build() {
    _manager = ref.read(downloadManagerProvider);
    _eventBus = ref.read(eventBusProvider);
    _backgroundService = ref.read(backgroundDownloadServiceProvider);

    // Initialize
    _initializeBackgroundService();
    _startRefreshTimer();
    _loadDownloads();
    _eventBus.on<DownloadEvent>().listen(_handleDownloadEvent);
    _backgroundService.downloadEvents.listen(_handleBackgroundEvent);

    return const AsyncValue.loading();
  }

  // Initialize background download service
  Future<void> _initializeBackgroundService() async {
    try {
      await _backgroundService.initialize();
    } catch (e) {
      // Handle initialization error
    }
  }

  // Handle background download events
  void _handleBackgroundEvent(DownloadEvent event) {
    _eventBus.emit(event);
  }

  // Start refresh timer with optimized interval
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(AppConstants.progressUpdateInterval, (
      timer,
    ) {
      // Only refresh if there are active downloads
      state.whenData((downloads) {
        final hasActiveDownloads = downloads.any(
          (d) =>
              d.status == DownloadStatus.downloading ||
              d.status == DownloadStatus.queued,
        );
        if (hasActiveDownloads) {
          _loadDownloads();
        }
      });
    });
  }

  // Load downloads with error handling
  Future<void> _loadDownloads() async {
    try {
      final downloads = await _manager.getAllDownloads();
      state = AsyncValue.data(downloads.cast<DownloadItem>());
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      state = AsyncValue.error(appError, stack);
    }
  }

  // Handle download events
  void _handleDownloadEvent(DownloadEvent event) {
    state.whenData((downloads) {
      final updatedDownloads = List<DownloadItem>.from(downloads);

      switch (event.runtimeType) {
        case DownloadStartedEvent _:
          _handleStarted(event as DownloadStartedEvent, updatedDownloads);
          break;
        case DownloadProgressEvent _:
          _handleProgress(event as DownloadProgressEvent, updatedDownloads);
          break;
        case DownloadCompletedEvent _:
          _handleCompleted(event as DownloadCompletedEvent, updatedDownloads);
          break;
        case DownloadFailedEvent _:
          _handleFailed(event as DownloadFailedEvent, updatedDownloads);
          break;
      }

      state = AsyncValue.data(updatedDownloads);
    });
  }

  void _handleStarted(
    DownloadStartedEvent event,
    List<DownloadItem> downloads,
  ) {
    downloads.add(
      DownloadItem(
        id: event.downloadId,
        url: event.url,
        title: 'Downloading...',
        platform: DownloadPlatform.other,
        filePath: '',
        fileName: '',
        totalBytes: 0,
        downloadedBytes: 0,
        progress: 0.0,
        speed: 0,
        eta: 0,
        status: DownloadStatus.downloading,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _handleProgress(
    DownloadProgressEvent event,
    List<DownloadItem> downloads,
  ) {
    final index = downloads.indexWhere((d) => d.id == event.downloadId);
    if (index != -1) {
      downloads[index] = downloads[index].copyWith(
        progress: event.progress,
        speed: event.speed,
        eta: event.eta,
      );
    }
  }

  void _handleCompleted(
    DownloadCompletedEvent event,
    List<DownloadItem> downloads,
  ) {
    final index = downloads.indexWhere((d) => d.id == event.downloadId);
    if (index != -1) {
      downloads[index] = downloads[index].copyWith(
        status: DownloadStatus.completed,
        filePath: event.filePath,
        progress: 1.0,
      );
    }
  }

  void _handleFailed(DownloadFailedEvent event, List<DownloadItem> downloads) {
    final index = downloads.indexWhere((d) => d.id == event.downloadId);
    if (index != -1) {
      downloads[index] = downloads[index].copyWith(
        status: DownloadStatus.failed,
        error: () => event.error,
      );
    }
  }

  // Add a new download with download ID from backend
  Future<void> addDownload({
    required String url,
    required String title,
    String? thumbnailUrl,
    required DownloadPlatform platform,
    required String downloadId,
    bool backgroundDownload = true,
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

      // Create download item
      final downloadItem = DownloadItem(
        id: downloadId,
        url: url,
        title: title,
        platform: platform,
        filePath: '',
        fileName: _generateFileNameFromUrl(url),
        totalBytes: 0,
        downloadedBytes: 0,
        progress: 0.0,
        speed: 0,
        eta: 0,
        status: DownloadStatus.queued,
        createdAt: DateTime.now(),
        thumbnailUrl: thumbnailUrl,
      );

      if (backgroundDownload) {
        // Start background download
        await _backgroundService.startBackgroundDownload(downloadItem);
      } else {
        // Use regular download manager
        await _manager.addDownloadWithId(
          url: url,
          title: title,
          thumbnailUrl: thumbnailUrl,
          platform: platform.name,
          downloadId: downloadId,
        );
      }

      await _loadDownloads();
      Logger.info('Successfully added download: $title');
    } catch (e, stack) {
      final appError = ErrorFactory.fromException(e, stack);
      appError.log();
      state = AsyncValue.error(appError, stack);
    }
  }

  // Generate filename from URL
  String _generateFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Pause download
  Future<void> pauseDownload(String downloadId) async {
    final prevState = state;
    try {
      // Try background service first, fallback to regular manager
      try {
        await _backgroundService.pauseBackgroundDownload(downloadId);
      } catch (e) {
        await _manager.pauseDownload(downloadId);
      }

      state.whenData((downloads) {
        final updatedDownloads = List<DownloadItem>.from(downloads);
        final index = updatedDownloads.indexWhere((d) => d.id == downloadId);
        if (index != -1) {
          updatedDownloads[index] = updatedDownloads[index].copyWith(
            status: DownloadStatus.paused,
          );
          state = AsyncValue.data(updatedDownloads);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Resume download
  Future<void> resumeDownload(String downloadId) async {
    final prevState = state;
    try {
      // Try background service first, fallback to regular manager
      try {
        await _backgroundService.resumeBackgroundDownload(downloadId);
      } catch (e) {
        await _manager.resumeDownload(downloadId);
      }

      state.whenData((downloads) {
        final updatedDownloads = List<DownloadItem>.from(downloads);
        final index = updatedDownloads.indexWhere((d) => d.id == downloadId);
        if (index != -1) {
          updatedDownloads[index] = updatedDownloads[index].copyWith(
            status: DownloadStatus.queued,
          );
          state = AsyncValue.data(updatedDownloads);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Cancel download
  Future<void> cancelDownload(String downloadId) async {
    final prevState = state;
    try {
      // Try background service first, fallback to regular manager
      try {
        await _backgroundService.cancelBackgroundDownload(downloadId);
      } catch (e) {
        _manager.cancelDownload(downloadId);
      }

      state.whenData((downloads) {
        final updatedDownloads =
            downloads.where((d) => d.id != downloadId).toList();
        state = AsyncValue.data(updatedDownloads);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Retry download
  Future<void> retryDownload(String downloadId) async {
    final prevState = state;
    try {
      await _manager.retryDownload(downloadId);
      state.whenData((downloads) {
        final updatedDownloads = List<DownloadItem>.from(downloads);
        final index = updatedDownloads.indexWhere((d) => d.id == downloadId);
        if (index != -1) {
          updatedDownloads[index] = updatedDownloads[index].copyWith(
            status: DownloadStatus.queued,
            progress: 0,
            error: null,
          );
          state = AsyncValue.data(updatedDownloads);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Delete download
  Future<void> deleteDownload(String downloadId) async {
    final prevState = state;
    try {
      await _manager.deleteDownload(downloadId);
      state.whenData((downloads) {
        final updatedDownloads =
            downloads.where((d) => d.id != downloadId).toList();
        state = AsyncValue.data(updatedDownloads);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Clear completed downloads
  Future<void> clearCompletedDownloads() async {
    final prevState = state;
    try {
      await _manager.clearCompletedDownloads();
      state.whenData((downloads) {
        final updatedDownloads = downloads
            .where((d) => d.status != DownloadStatus.completed)
            .toList();
        state = AsyncValue.data(updatedDownloads);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      state = prevState;
    }
  }

  // Clear all downloads
  Future<void> clearAllDownloads() async {
    try {
      await _manager.clearAllDownloads();
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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

  void dispose() {
    _refreshTimer?.cancel();
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
