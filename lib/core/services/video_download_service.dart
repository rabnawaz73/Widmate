import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';

/// Service class for communicating with the WidMate backend API
class VideoDownloadService {
  static const String _baseUrl = AppConstants.baseUrl;
  static const Duration _timeout = AppConstants.apiTimeout;

  final http.Client _client = http.Client();
  final _downloadEventsController = StreamController<DownloadEvent>.broadcast();

  /// Get video information and metadata
  Future<VideoInfo> getVideoInfo(
    String url, {
    bool playlistInfo = false,
  }) async {
    try {
      // Validate URL
      final urlValidation = ValidationUtils.validateUrl(url);
      if (!urlValidation.isValid) {
        throw ValidationError(message: urlValidation.error!);
      }

      Logger.info('Getting video info for: $url');

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/info'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'url': url, 'playlist_info': playlistInfo}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Logger.info('Successfully retrieved video info');
        return VideoInfo.fromJson(data);
      } else {
        final error = json.decode(response.body);
        final errorMessage = error['detail'] ?? 'Unknown error';
        Logger.error('Failed to get video info: $errorMessage');
        throw ServerError(message: 'Failed to get video info: $errorMessage');
      }
    } on SocketException catch (e, stackTrace) {
      Logger.error('Network error getting video info', e, stackTrace);
      throw NetworkError(originalError: e, stackTrace: stackTrace);
    } on http.ClientException catch (e, stackTrace) {
      Logger.error('HTTP client error getting video info', e, stackTrace);
      throw ServerError(originalError: e, stackTrace: stackTrace);
    } on ValidationError {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Unexpected error getting video info', e, stackTrace);
      throw UnknownError(originalError: e, stackTrace: stackTrace);
    }
  }

  /// Start a video download
  Future<DownloadResponse> startDownload({
    required String url,
    String? formatId,
    String quality = '720p',
    String? playlistItems,
    bool audioOnly = false,
    String? outputPath,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/download'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'url': url,
              'format_id': formatId,
              'quality': quality,
              'playlist_items': playlistItems,
              'audio_only': audioOnly,
              'output_path': outputPath,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DownloadResponse.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw VideoDownloadException(
          'Failed to start download: ${error['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to start download: $e');
    }
  }

  /// Get download status and progress
  Future<DownloadStatus> getDownloadStatus(String downloadId) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/status/$downloadId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DownloadStatus.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw VideoDownloadException(
          'Failed to get download status: ${error['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to get download status: $e');
    }
  }

  /// Cancel a download
  Future<void> cancelDownload(String downloadId) async {
    try {
      final response = await _client
          .delete(Uri.parse('$_baseUrl/download/$downloadId'))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw VideoDownloadException(
          'Failed to cancel download: ${error['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to cancel download: $e');
    }
  }

  /// Get list of all downloads
  Future<List<DownloadStatus>> getAllDownloads() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/downloads'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DownloadStatus.fromJson(item)).toList();
      } else {
        throw VideoDownloadException('Failed to get downloads list');
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to get downloads list: $e');
    }
  }

  /// Download completed file to device
  Future<String> downloadFile(String downloadId, String filename) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/file/$downloadId'),
      );

      if (response.statusCode == 200) {
        // Get app documents directory
        final directory = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${directory.path}/WidMate/Downloads');
        await downloadsDir.create(recursive: true);

        // Save file
        final file = File('${downloadsDir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);

        return file.path;
      } else {
        throw VideoDownloadException('Failed to download file');
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to download file: $e');
    }
  }

  /// Clear completed downloads
  Future<void> clearDownloads() async {
    try {
      final response = await _client
          .delete(Uri.parse('$_baseUrl/downloads'))
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw VideoDownloadException('Failed to clear downloads');
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to clear downloads: $e');
    }
  }

  /// Get system statistics
  Future<SystemStats> getSystemStats() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/system/stats'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SystemStats.fromJson(data);
      } else {
        throw VideoDownloadException('Failed to get system stats');
      }
    } catch (e) {
      if (e is VideoDownloadException) rethrow;
      throw VideoDownloadException('Failed to get system stats: $e');
    }
  }

  /// Check if backend server is running
  Future<bool> isServerRunning() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Stream of download events
  Stream<DownloadEvent> get downloadEvents => _downloadEventsController.stream;

  /// Dispose resources
  void dispose() {
    _downloadEventsController.close();
    _client.close();
  }
}

/// Video information model
class VideoInfo {
  final String id;
  final String title;
  final String? description;
  final int? duration;
  final String? thumbnail;
  final String? uploader;
  final String? uploadDate;
  final int? viewCount;
  final List<VideoFormat> formats;
  final bool isPlaylist;
  final int? playlistCount;
  final List<PlaylistEntry> playlistEntries;

  VideoInfo({
    required this.id,
    required this.title,
    this.description,
    this.duration,
    this.thumbnail,
    this.uploader,
    this.uploadDate,
    this.viewCount,
    required this.formats,
    required this.isPlaylist,
    this.playlistCount,
    required this.playlistEntries,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      description: json['description'],
      duration: json['duration'],
      thumbnail: json['thumbnail'],
      uploader: json['uploader'],
      uploadDate: json['upload_date'],
      viewCount: json['view_count'],
      formats: (json['formats'] as List<dynamic>? ?? [])
          .map((f) => VideoFormat.fromJson(f))
          .toList(),
      isPlaylist: json['is_playlist'] ?? false,
      playlistCount: json['playlist_count'],
      playlistEntries: (json['playlist_entries'] as List<dynamic>? ?? [])
          .map((e) => PlaylistEntry.fromJson(e))
          .toList(),
    );
  }

  String get formattedDuration {
    if (duration == null) return 'Unknown';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Video format model
class VideoFormat {
  final String formatId;
  final String ext;
  final String resolution;
  final double? fps;
  final int? filesize;
  final String quality;
  final String vcodec;
  final String acodec;

  VideoFormat({
    required this.formatId,
    required this.ext,
    required this.resolution,
    this.fps,
    this.filesize,
    required this.quality,
    required this.vcodec,
    required this.acodec,
  });

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      formatId: json['format_id'] ?? '',
      ext: json['ext'] ?? '',
      resolution: json['resolution'] ?? '',
      fps: json['fps']?.toDouble(),
      filesize: json['filesize'],
      quality: json['quality'] ?? '',
      vcodec: json['vcodec'] ?? '',
      acodec: json['acodec'] ?? '',
    );
  }

  String get formattedFilesize {
    if (filesize == null) return 'Unknown';
    if (filesize! < 1024 * 1024) {
      return '${(filesize! / 1024).toStringAsFixed(1)} KB';
    } else if (filesize! < 1024 * 1024 * 1024) {
      return '${(filesize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(filesize! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

/// Playlist entry model
class PlaylistEntry {
  final int index;
  final String id;
  final String title;
  final int? duration;
  final String? thumbnail;
  final String url;

  PlaylistEntry({
    required this.index,
    required this.id,
    required this.title,
    this.duration,
    this.thumbnail,
    required this.url,
  });

  factory PlaylistEntry.fromJson(Map<String, dynamic> json) {
    return PlaylistEntry(
      index: json['index'] ?? 0,
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      duration: json['duration'],
      thumbnail: json['thumbnail'],
      url: json['url'] ?? '',
    );
  }
}

/// Download response model
class DownloadResponse {
  final String downloadId;
  final String status;
  final String message;

  DownloadResponse({
    required this.downloadId,
    required this.status,
    required this.message,
  });

  factory DownloadResponse.fromJson(Map<String, dynamic> json) {
    return DownloadResponse(
      downloadId: json['download_id'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

/// Download status model
class DownloadStatus {
  final String id;
  final String status;
  final double progress;
  final String? speed;
  final String? eta;
  final int downloadedBytes;
  final int? totalBytes;
  final String? filename;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;

  DownloadStatus({
    required this.id,
    required this.status,
    required this.progress,
    this.speed,
    this.eta,
    required this.downloadedBytes,
    this.totalBytes,
    this.filename,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DownloadStatus.fromJson(Map<String, dynamic> json) {
    return DownloadStatus(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      speed: json['speed'],
      eta: json['eta'],
      downloadedBytes: json['downloaded_bytes'] ?? 0,
      totalBytes: json['total_bytes'],
      filename: json['filename'],
      error: json['error'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isDownloading => status == 'downloading';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
}

/// System statistics model
class SystemStats {
  final double cpuPercent;
  final double memoryPercent;
  final DiskUsage diskUsage;
  final int activeDownloads;
  final int totalDownloads;

  SystemStats({
    required this.cpuPercent,
    required this.memoryPercent,
    required this.diskUsage,
    required this.activeDownloads,
    required this.totalDownloads,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpuPercent: (json['cpu_percent'] ?? 0.0).toDouble(),
      memoryPercent: (json['memory_percent'] ?? 0.0).toDouble(),
      diskUsage: DiskUsage.fromJson(json['disk_usage'] ?? {}),
      activeDownloads: json['active_downloads'] ?? 0,
      totalDownloads: json['total_downloads'] ?? 0,
    );
  }
}

/// Disk usage model
class DiskUsage {
  final int total;
  final int used;
  final int free;

  DiskUsage({required this.total, required this.used, required this.free});

  factory DiskUsage.fromJson(Map<String, dynamic> json) {
    return DiskUsage(
      total: json['total'] ?? 0,
      used: json['used'] ?? 0,
      free: json['free'] ?? 0,
    );
  }

  double get usedPercent => total > 0 ? (used / total) * 100 : 0;
}

/// Custom exception for video download errors
class VideoDownloadException implements Exception {
  final String message;

  VideoDownloadException(this.message);

  @override
  String toString() => 'VideoDownloadException: $message';
}

/// Download event classes
abstract class DownloadEvent {}

class DownloadCompletedEvent extends DownloadEvent {
  final String filePath;
  DownloadCompletedEvent(this.filePath);
}

class DownloadFailedEvent extends DownloadEvent {
  final String error;
  DownloadFailedEvent(this.error);
}
