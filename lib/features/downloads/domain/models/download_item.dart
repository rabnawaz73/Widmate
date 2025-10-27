import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:widmate/core/models/download_models.dart' as backend_models; // Alias for backend models

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  canceled
}

enum DownloadPlatform {
  youtube,
  tiktok,
  instagram,
  facebook,
  other
}

class DownloadItem {
  final String id;
  final String url;
  final String title;
  final String? thumbnailUrl;
  final DownloadPlatform platform;
  final String? filePath; // Made nullable
  final String? fileName; // Made nullable
  final int? totalBytes; // Made nullable
  final int downloadedBytes;
  final double progress;
  final String? speed; // Changed to String?
  final String? eta; // Changed to String?
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;
  
  // Helper methods for formatting values
  String getFormattedFileSize() {
    return _formatBytes(totalBytes ?? 0);
  }
  
  String getFormattedDownloadedSize() {
    return _formatBytes(downloadedBytes);
  }
  
  String getFormattedSpeed() {
    return speed != null ? '$speed/s' : '0 B/s';
  }
  
  String getFormattedETA() {
    return eta ?? 'Calculating...';
  }
  
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  DownloadItem({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.platform,
    this.filePath,
    this.fileName,
    this.totalBytes,
    required this.downloadedBytes,
    required this.progress,
    this.speed,
    this.eta,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.error,
    required this.url,
  });

  // Factory constructor to create DownloadItem from backend_models.DownloadStatus
  factory DownloadItem.fromBackendDownloadStatus(backend_models.DownloadStatus backendStatus, {required String url, String? title, String? thumbnailUrl, DownloadPlatform? platform}) {
    DownloadStatus mappedStatus;
    switch (backendStatus.status) {
      case 'pending':
        mappedStatus = DownloadStatus.queued;
        break;
      case 'downloading':
        mappedStatus = DownloadStatus.downloading;
        break;
      case 'completed':
        mappedStatus = DownloadStatus.completed;
        break;
      case 'failed':
        mappedStatus = DownloadStatus.failed;
        break;
      case 'cancelled':
        mappedStatus = DownloadStatus.canceled;
        break;
      default:
        mappedStatus = DownloadStatus.queued; // Default or handle unknown status
    }

    return DownloadItem(
      id: backendStatus.id,
      url: url, // Assuming url is always present in backendStatus
      title: title ?? 'Unknown Title',
      thumbnailUrl: thumbnailUrl,
      platform: platform ?? DownloadPlatform.other,
      filePath: backendStatus.filename, // Backend filename maps to filePath
      fileName: backendStatus.filename?.split('/').last,
      totalBytes: backendStatus.totalBytes,
      downloadedBytes: backendStatus.downloadedBytes,
      progress: backendStatus.progress / 100.0, // Convert percentage to 0.0-1.0
      speed: backendStatus.speed,
      eta: backendStatus.eta,
      status: mappedStatus,
      createdAt: backendStatus.createdAt,
      completedAt: backendStatus.updatedAt, // Using updatedAt as completedAt for simplicity
      error: backendStatus.error,
    );
  }

  DownloadItem copyWith({
    String? id,
    String? title,
    ValueGetter<String?>? thumbnailUrl,
    DownloadPlatform? platform,
    ValueGetter<String?>? filePath,
    ValueGetter<String?>? fileName,
    ValueGetter<int?>? totalBytes,
    int? downloadedBytes,
    double? progress,
    ValueGetter<String?>? speed,
    ValueGetter<String?>? eta,
    DownloadStatus? status,
    DateTime? createdAt,
    ValueGetter<DateTime?>? completedAt,
    ValueGetter<String?>? error,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl != null ? thumbnailUrl() : this.thumbnailUrl,
      platform: platform ?? this.platform,
      filePath: filePath != null ? filePath() : this.filePath,
      fileName: fileName != null ? fileName() : this.fileName,
      totalBytes: totalBytes != null ? totalBytes() : this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      progress: progress ?? this.progress,
      speed: speed != null ? speed() : this.speed,
      eta: eta != null ? eta() : this.eta,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
      error: error != null ? error() : this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'platform': platform.toString().split('.').last,
      'filePath': filePath,
      'fileName': fileName,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'progress': progress,
      'speed': speed,
      'eta': eta,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'error': error,
    };
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      platform: DownloadPlatform.values.firstWhere(
        (e) => e.toString().split('.').last == json['platform'],
        orElse: () => DownloadPlatform.other,
      ),
      filePath: json['filePath'],
      fileName: json['fileName'],
      totalBytes: json['totalBytes'],
      downloadedBytes: json['downloadedBytes'],
      progress: json['progress'],
      speed: json['speed'],
      eta: json['eta'],
      status: DownloadStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DownloadStatus.failed,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      error: json['error'],
    );
  }

  // Helper method to get platform folder name
  String get platformFolderName {
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

  // Helper method to get formatted file size
  String get formattedFileSize {
    if (totalBytes == null || totalBytes! <= 0) return '0 B';
    
    final suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(totalBytes!) / log(1024)).floor();
    return '${(totalBytes! / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper method to get formatted downloaded size
  String get formattedDownloadedSize {
    if (downloadedBytes <= 0) return '0 B';
    
    final suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(downloadedBytes) / log(1024)).floor();
    return '${(downloadedBytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper method to get formatted speed
  String get formattedSpeed {
    return speed ?? '0 B/s';
  }

  // Helper method to get formatted ETA
  String get formattedEta {
    return eta ?? '0s';
  }

  String get fileExtension {
    if (fileName != null && fileName!.contains('.')) {
      return fileName!.split('.').last;
    }
    return 'mp4'; // Default extension
  }
}