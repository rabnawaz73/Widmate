import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/errors/app_errors.dart';
import 'package:widmate/core/services/logger_service.dart';
import 'package:widmate/core/utils/validation_utils.dart';
import 'package:widmate/core/models/download_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

/// Service class for communicating with the WidMate backend API
class VideoDownloadService {
  static const Duration _timeout = AppConstants.apiTimeout;

  final http.Client _client = http.Client();
  final _downloadEventsController = StreamController<DownloadEvent>.broadcast();
  WebSocketChannel? _wsChannel;

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

      final headers = {'Content-Type': 'application/json'};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .post(
            Uri.parse('${AppConstants.baseUrl}/info'),
            headers: headers,
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

  VideoDownloadService() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      final uri = Uri.parse(AppConstants.baseUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUri = Uri(
        scheme: scheme,
        userInfo: uri.userInfo,
        host: uri.host,
        port: uri.port,
        path: '/ws',
      );
      _wsChannel = WebSocketChannel.connect(wsUri);
      _wsChannel!.stream.listen((message) {
        try {
          final data = json.decode(message is String ? message : utf8.decode(message));
          final id = data['id'] as String?;
          final status = data['status'] as String?;
          final progress = (data['progress'] is num) ? (data['progress'] as num).toDouble() : 0.0;
          final downloadedBytes = (data['downloaded_bytes'] is num) ? (data['downloaded_bytes'] as num).toInt() : 0;
          final totalBytes = (data['total_bytes'] is num) ? (data['total_bytes'] as num).toInt() : 0;
          if (id == null) return;
          if (status == 'downloading') {
            _downloadEventsController.add(
              DownloadProgressEvent(id, progress, downloadedBytes, totalBytes),
            );
          } else if (status == 'completed') {
            final filename = data['filename'] as String? ?? '';
            _downloadEventsController.add(
              DownloadCompletedEvent(filename),
            );
          } else if (status == 'failed') {
            final error = data['error'] as String? ?? 'Unknown error';
            _downloadEventsController.add(
              DownloadFailedEvent(error),
            );
          }
        } catch (_) {}
      }, onError: (e) {
        Logger.error('WebSocket error: $e');
      });
    } catch (e) {
      Logger.error('Failed to connect WebSocket: $e');
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
      final headers = {'Content-Type': 'application/json'};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .post(
            Uri.parse('${AppConstants.baseUrl}/download'),
            headers: headers,
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/status/$downloadId'), headers: headers)
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .delete(Uri.parse('${AppConstants.baseUrl}/download/$downloadId'), headers: headers)
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/downloads'), headers: headers)
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/file/$downloadId'),
        headers: headers,
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .delete(Uri.parse('${AppConstants.baseUrl}/downloads'), headers: headers)
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
      final headers = <String, String>{};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}/system/stats'), headers: headers)
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
          .get(Uri.parse('${AppConstants.baseUrl}/'))
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
    try {
      _wsChannel?.sink.close(ws_status.goingAway);
    } catch (_) {}
  }
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
