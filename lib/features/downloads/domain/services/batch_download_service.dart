import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:widmate/features/downloads/domain/models/download_events.dart';
import 'package:widmate/features/downloads/domain/services/download_service.dart';

class BatchDownloadService {
  // Singleton instance
  static final BatchDownloadService _instance =
      BatchDownloadService._internal();

  factory BatchDownloadService() {
    return _instance;
  }

  BatchDownloadService._internal();

  // Reference to the download service
  late DownloadService _downloadService;

  // Maximum concurrent downloads
  int _maxConcurrentDownloads = 2;

  // Queue of pending downloads
  final List<String> _pendingUrls = [];

  // Currently active downloads
  final Set<String> _activeDownloadIds = {};

  // Stream controller for batch download events
  final _batchEventController =
      StreamController<BatchDownloadEvent>.broadcast();
  Stream<BatchDownloadEvent> get batchEvents => _batchEventController.stream;

  // Initialize with download service
  void initialize(DownloadService downloadService) {
    _downloadService = downloadService;

    // Listen for download completion events
    _downloadService.downloadEvents.listen((event) {
      if (event is DownloadCompletedEvent) {
        _activeDownloadIds.remove(event.downloadId);
        _processQueue();
      } else if (event is DownloadFailedEvent) {
        _activeDownloadIds.remove(event.downloadId);

        // Remove from active downloads
        // _activeDownloadIds.remove(downloadId);

        // Process next download in queue
        _processQueue();
      }
    });
  }

  // Set maximum concurrent downloads
  void setMaxConcurrentDownloads(int max) {
    _maxConcurrentDownloads = max;
    // Process queue in case we can now start more downloads
    _processQueue();
  }

  // Add a batch of URLs to download
  Future<String> addBatchDownload(
    List<String> urls, {
    String? batchName,
  }) async {
    if (urls.isEmpty) {
      throw Exception('No URLs provided for batch download');
    }

    // Generate batch ID
    final batchId = const Uuid().v4();
    final name =
        batchName ??
        'Batch Download ${DateTime.now().toString().substring(0, 16)}';

    // Add URLs to pending queue
    _pendingUrls.addAll(urls);

    // Emit batch created event
    _batchEventController.add(
      BatchDownloadCreatedEvent(
        batchId: batchId,
        name: name,
        totalUrls: urls.length,
      ),
    );

    // Start processing queue
    _processQueue();

    return batchId;
  }

  // Process the download queue
  void _processQueue() {
    // Check if we can start more downloads
    while (_activeDownloadIds.length < _maxConcurrentDownloads &&
        _pendingUrls.isNotEmpty) {
      final url = _pendingUrls.removeAt(0);
      _startDownload(url);
    }

    // Emit queue status event
    _batchEventController.add(
      BatchQueueStatusEvent(
        activeDownloads: _activeDownloadIds.length,
        pendingDownloads: _pendingUrls.length,
      ),
    );
  }

  // Start a single download
  Future<void> _startDownload(String url) async {
    try {
      await _downloadService.addDownloadFromUrl(url);
      // Generate a temporary ID for tracking
      final downloadId = const Uuid().v4();
      _activeDownloadIds.add(downloadId);
    } catch (e) {
      debugPrint('Error starting download: $e');
      // Process next download in queue
      _processQueue();
    }
  }

  // Pause all active downloads in the batch
  Future<void> pauseAllDownloads() async {
    for (final downloadId in _activeDownloadIds) {
      await _downloadService.pauseDownload(downloadId);
    }
  }

  // Resume all paused downloads in the batch
  Future<void> resumeAllDownloads() async {
    for (final downloadId in _activeDownloadIds) {
      await _downloadService.resumeDownload(downloadId);
    }

    // Process queue in case we can start more downloads
    _processQueue();
  }

  // Cancel all downloads in the batch
  Future<void> cancelAllDownloads() async {
    // Cancel active downloads
    for (final downloadId in _activeDownloadIds.toList()) {
      await _downloadService.cancelDownload(downloadId);
    }

    // Clear pending queue
    _pendingUrls.clear();

    // Emit queue status event
    _batchEventController.add(
      BatchQueueStatusEvent(activeDownloads: 0, pendingDownloads: 0),
    );
  }

  // Dispose resources
  void dispose() {
    _batchEventController.close();
  }
}

// Batch download events
abstract class BatchDownloadEvent {}

class BatchDownloadCreatedEvent extends BatchDownloadEvent {
  final String batchId;
  final String name;
  final int totalUrls;

  BatchDownloadCreatedEvent({
    required this.batchId,
    required this.name,
    required this.totalUrls,
  });
}

class BatchQueueStatusEvent extends BatchDownloadEvent {
  final int activeDownloads;
  final int pendingDownloads;

  BatchQueueStatusEvent({
    required this.activeDownloads,
    required this.pendingDownloads,
  });
}

// Provider for the batch download service
final batchDownloadServiceProvider = Provider<BatchDownloadService>((ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  final batchService = BatchDownloadService();

  // Initialize with download service
  batchService.initialize(downloadService);

  // Dispose when provider is disposed
  ref.onDispose(() {
    batchService.dispose();
  });

  return batchService;
});
