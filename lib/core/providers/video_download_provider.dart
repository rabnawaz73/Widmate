import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/core/services/video_download_service.dart';

/// Provider for the video download service
final videoDownloadServiceProvider = Provider<VideoDownloadService>((ref) {
  return VideoDownloadService();
});

/// Provider for checking server status
final serverStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(videoDownloadServiceProvider);
  return await service.isServerRunning();
});

/// Provider for video information
final videoInfoProvider = FutureProvider.family<VideoInfo?, String>((ref, url) async {
  if (url.isEmpty) return null;
  
  final service = ref.read(videoDownloadServiceProvider);
  try {
    return await service.getVideoInfo(url);
  } catch (e) {
    rethrow;
  }
});

/// Provider for playlist information
final playlistInfoProvider = FutureProvider.family<VideoInfo?, String>((ref, url) async {
  if (url.isEmpty) return null;
  
  final service = ref.read(videoDownloadServiceProvider);
  try {
    return await service.getVideoInfo(url, playlistInfo: true);
  } catch (e) {
    rethrow;
  }
});

/// Provider for all downloads list
final downloadsListProvider = FutureProvider<List<DownloadStatus>>((ref) async {
  final service = ref.read(videoDownloadServiceProvider);
  try {
    return await service.getAllDownloads();
  } catch (e) {
    return [];
  }
});

/// Provider for individual download status
final downloadStatusProvider = FutureProvider.family<DownloadStatus?, String>((ref, downloadId) async {
  if (downloadId.isEmpty) return null;
  
  final service = ref.read(videoDownloadServiceProvider);
  try {
    return await service.getDownloadStatus(downloadId);
  } catch (e) {
    return null;
  }
});

/// Provider for system statistics
final systemStatsProvider = FutureProvider<SystemStats?>((ref) async {
  final service = ref.read(videoDownloadServiceProvider);
  try {
    return await service.getSystemStats();
  } catch (e) {
    return null;
  }
});

/// Provider for download events
final downloadEventsProvider = StreamProvider<DownloadEvent>((ref) {
  final service = ref.watch(videoDownloadServiceProvider);
  return service.downloadEvents;
});

/// State notifier for managing download operations
class DownloadManagerNotifier extends Notifier<DownloadManagerState> {
  late VideoDownloadService _service;
  
  @override
  DownloadManagerState build() {
    _service = ref.read(videoDownloadServiceProvider);
    return const DownloadManagerState();
  }
  
  /// Start a new download
  Future<String?> startDownload({
    required String url,
    String? formatId,
    String quality = '720p',
    String? playlistItems,
    bool audioOnly = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _service.startDownload(
        url: url,
        formatId: formatId,
        quality: quality,
        playlistItems: playlistItems,
        audioOnly: audioOnly,
      );
      
      state = state.copyWith(
        isLoading: false,
        activeDownloads: [...state.activeDownloads, response.downloadId],
      );
      
      return response.downloadId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }
  
  /// Cancel a download
  Future<bool> cancelDownload(String downloadId) async {
    try {
      await _service.cancelDownload(downloadId);
      
      state = state.copyWith(
        activeDownloads: state.activeDownloads
            .where((id) => id != downloadId)
            .toList(),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  /// Clear completed downloads
  Future<void> clearDownloads() async {
    try {
      await _service.clearDownloads();
      state = state.copyWith(activeDownloads: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// Remove download from active list
  void removeDownload(String downloadId) {
    state = state.copyWith(
      activeDownloads: state.activeDownloads
          .where((id) => id != downloadId)
          .toList(),
    );
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// State class for download manager
class DownloadManagerState {
  final bool isLoading;
  final String? error;
  final List<String> activeDownloads;
  
  const DownloadManagerState({
    this.isLoading = false,
    this.error,
    this.activeDownloads = const [],
  });
  
  DownloadManagerState copyWith({
    bool? isLoading,
    String? error,
    List<String>? activeDownloads,
  }) {
    return DownloadManagerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeDownloads: activeDownloads ?? this.activeDownloads,
    );
  }
}

/// Provider for download manager
final downloadManagerProvider = NotifierProvider<DownloadManagerNotifier, DownloadManagerState>(
  DownloadManagerNotifier.new,
);

/// Provider for supported platforms
final supportedPlatformsProvider = Provider<List<SupportedPlatform>>((ref) {
  return [
    SupportedPlatform(
      name: 'YouTube',
      icon: 'youtube',
      domains: ['youtube.com', 'youtu.be', 'm.youtube.com'],
      supportsPlaylists: true,
      supportsAudio: true,
      maxQuality: '4K',
    ),
    SupportedPlatform(
      name: 'TikTok',
      icon: 'tiktok',
      domains: ['tiktok.com', 'vm.tiktok.com'],
      supportsPlaylists: false,
      supportsAudio: true,
      maxQuality: '1080p',
    ),
    SupportedPlatform(
      name: 'Instagram',
      icon: 'instagram',
      domains: ['instagram.com', 'instagr.am'],
      supportsPlaylists: false,
      supportsAudio: true,
      maxQuality: '1080p',
    ),
    SupportedPlatform(
      name: 'Facebook',
      icon: 'facebook',
      domains: ['facebook.com', 'fb.watch', 'm.facebook.com'],
      supportsPlaylists: false,
      supportsAudio: true,
      maxQuality: '1080p',
    ),
  ];
});

/// Model for supported platforms
class SupportedPlatform {
  final String name;
  final String icon;
  final List<String> domains;
  final bool supportsPlaylists;
  final bool supportsAudio;
  final String maxQuality;
  
  SupportedPlatform({
    required this.name,
    required this.icon,
    required this.domains,
    required this.supportsPlaylists,
    required this.supportsAudio,
    required this.maxQuality,
  });
  
  /// Check if URL belongs to this platform
  bool isSupported(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    
    return domains.any((domain) => 
      uri.host.contains(domain) || uri.host.endsWith(domain)
    );
  }
}

/// Provider to detect platform from URL
final platformDetectorProvider = Provider.family<SupportedPlatform?, String>((ref, url) {
  final platforms = ref.read(supportedPlatformsProvider);
  
  for (final platform in platforms) {
    if (platform.isSupported(url)) {
      return platform;
    }
  }
  
  return null;
});