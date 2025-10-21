import 'package:flutter/foundation.dart';
import 'dart:math';

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
  final String filePath;
  final String fileName;
  final int totalBytes;
  final int downloadedBytes;
  final double progress;
  final int speed; // bytes per second
  final int eta; // seconds
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? error;
  
  // Helper methods for formatting values
  String getFormattedFileSize() {
    return _formatBytes(totalBytes);
  }
  
  String getFormattedDownloadedSize() {
    return _formatBytes(downloadedBytes);
  }
  
  String getFormattedSpeed() {
    return '${_formatBytes(speed)}/s';
  }
  
  String getFormattedETA() {
    if (eta <= 0) return 'Calculating...';
    
    final hours = eta ~/ 3600;
    final minutes = (eta % 3600) ~/ 60;
    final seconds = eta % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  DownloadItem({
    required this.id,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    required this.platform,
    required this.filePath,
    required this.fileName,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.progress,
    required this.speed,
    required this.eta,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.error,
  });

  DownloadItem copyWith({
    String? id,
    String? url,
    String? title,
    ValueGetter<String?>? thumbnailUrl,
    DownloadPlatform? platform,
    String? filePath,
    String? fileName,
    int? totalBytes,
    int? downloadedBytes,
    double? progress,
    int? speed,
    int? eta,
    DownloadStatus? status,
    DateTime? createdAt,
    ValueGetter<DateTime?>? completedAt,
    ValueGetter<String?>? error,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl != null ? thumbnailUrl() : this.thumbnailUrl,
      platform: platform ?? this.platform,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
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
    if (totalBytes == 0) return '0 B';
    
    final suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(totalBytes) / log(1024)).floor();
    return '${(totalBytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper method to get formatted downloaded size
  String get formattedDownloadedSize {
    if (downloadedBytes == 0) return '0 B';
    
    final suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(downloadedBytes) / log(1024)).floor();
    return '${(downloadedBytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper method to get formatted speed
  String get formattedSpeed {
    if (speed == 0) return '0 B/s';
    
    final suffixes = ['B/s', 'KB/s', 'MB/s', 'GB/s', 'TB/s'];
    final i = (log(speed) / log(1024)).floor();
    return '${(speed / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Helper method to get formatted ETA
  String get formattedEta {
    if (eta == 0) return '0s';
    
    final hours = eta ~/ 3600;
    final minutes = (eta % 3600) ~/ 60;
    final seconds = eta % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}