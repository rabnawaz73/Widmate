import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_models.freezed.dart';
part 'download_models.g.dart';

@freezed
class VideoInfoRequest with _$VideoInfoRequest {
  const factory VideoInfoRequest({
    required String url,
    @Default(false) bool playlistInfo,
  }) = _VideoInfoRequest;

  factory VideoInfoRequest.fromJson(Map<String, dynamic> json) => _$VideoInfoRequestFromJson(json);
}

@freezed
class DownloadRequest with _$DownloadRequest {
  const factory DownloadRequest({
    required String url,
    String? formatId,
    @Default('720p') String quality,
    String? playlistItems,
    @Default(false) bool audioOnly,
    String? outputPath,
  }) = _DownloadRequest;

  factory DownloadRequest.fromJson(Map<String, dynamic> json) => _$DownloadRequestFromJson(json);
}

@freezed
class DownloadStatus with _$DownloadStatus {
  const factory DownloadStatus({
    required String id,
    required String status, // pending, downloading, completed, failed, cancelled
    @Default(0.0) double progress,
    String? speed,
    String? eta,
    @Default(0) int downloadedBytes,
    int? totalBytes,
    String? filename,
    String? error,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DownloadStatus;

  factory DownloadStatus.fromJson(Map<String, dynamic> json) => _$DownloadStatusFromJson(json);
}

extension DownloadStatusGetters on DownloadStatus {
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isDownloading => status == 'downloading';
  bool get isCancelled => status == 'cancelled';
}

@freezed
class FormatInfo with _$FormatInfo {
  const factory FormatInfo({
    required String formatId,
    required String ext,
    required String resolution,
    double? fps,
    int? filesize,
    String? quality,
    String? vcodec,
    String? acodec,
  }) = _FormatInfo;

  factory FormatInfo.fromJson(Map<String, dynamic> json) => _$FormatInfoFromJson(json);
}

@freezed
class PlaylistEntry with _$PlaylistEntry {
  const factory PlaylistEntry({
    required int index,
    required String id,
    required String title,
    int? duration,
    String? thumbnail,
    required String url,
  }) = _PlaylistEntry;

  factory PlaylistEntry.fromJson(Map<String, dynamic> json) => _$PlaylistEntryFromJson(json);
}

@freezed
class VideoInfo with _$VideoInfo {
  const factory VideoInfo({
    required String id,
    required String title,
    String? description,
    int? duration,
    String? thumbnail,
    String? uploader,
    String? uploadDate,
    int? viewCount,
    @Default([]) List<FormatInfo> formats,
    @Default(false) bool isPlaylist,
    int? playlistCount,
    @Default([]) List<PlaylistEntry> playlistEntries,
  }) = _VideoInfo;

  factory VideoInfo.fromJson(Map<String, dynamic> json) => _$VideoInfoFromJson(json);
}

@freezed
class DownloadResponse with _$DownloadResponse {
  const factory DownloadResponse({
    required String downloadId,
    required String status,
    required String message,
  }) = _DownloadResponse;

  factory DownloadResponse.fromJson(Map<String, dynamic> json) => _$DownloadResponseFromJson(json);
}

@freezed
class DiskUsage with _$DiskUsage {
  const factory DiskUsage({
    required int total,
    required int used,
    required int free,
  }) = _DiskUsage;

  factory DiskUsage.fromJson(Map<String, dynamic> json) => _$DiskUsageFromJson(json);
}

@freezed
class SystemStats with _$SystemStats {
  const factory SystemStats({
    required double cpuPercent,
    required double memoryPercent,
    required DiskUsage diskUsage,
    required int activeDownloads,
    required int totalDownloads,
  }) = _SystemStats;

  factory SystemStats.fromJson(Map<String, dynamic> json) => _$SystemStatsFromJson(json);
}
