// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoInfoRequestImpl _$$VideoInfoRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$VideoInfoRequestImpl(
      url: json['url'] as String,
      playlistInfo: json['playlistInfo'] as bool? ?? false,
    );

Map<String, dynamic> _$$VideoInfoRequestImplToJson(
        _$VideoInfoRequestImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'playlistInfo': instance.playlistInfo,
    };

_$DownloadRequestImpl _$$DownloadRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadRequestImpl(
      url: json['url'] as String,
      formatId: json['formatId'] as String?,
      quality: json['quality'] as String? ?? '720p',
      playlistItems: json['playlistItems'] as String?,
      audioOnly: json['audioOnly'] as bool? ?? false,
      outputPath: json['outputPath'] as String?,
    );

Map<String, dynamic> _$$DownloadRequestImplToJson(
        _$DownloadRequestImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'formatId': instance.formatId,
      'quality': instance.quality,
      'playlistItems': instance.playlistItems,
      'audioOnly': instance.audioOnly,
      'outputPath': instance.outputPath,
    };

_$DownloadStatusImpl _$$DownloadStatusImplFromJson(Map<String, dynamic> json) =>
    _$DownloadStatusImpl(
      id: json['id'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      speed: json['speed'] as String?,
      eta: json['eta'] as String?,
      downloadedBytes: (json['downloadedBytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['totalBytes'] as num?)?.toInt(),
      filename: json['filename'] as String?,
      error: json['error'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DownloadStatusImplToJson(
        _$DownloadStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'progress': instance.progress,
      'speed': instance.speed,
      'eta': instance.eta,
      'downloadedBytes': instance.downloadedBytes,
      'totalBytes': instance.totalBytes,
      'filename': instance.filename,
      'error': instance.error,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$FormatInfoImpl _$$FormatInfoImplFromJson(Map<String, dynamic> json) =>
    _$FormatInfoImpl(
      formatId: json['formatId'] as String,
      ext: json['ext'] as String,
      resolution: json['resolution'] as String,
      fps: (json['fps'] as num?)?.toDouble(),
      filesize: (json['filesize'] as num?)?.toInt(),
      quality: json['quality'] as String?,
      vcodec: json['vcodec'] as String?,
      acodec: json['acodec'] as String?,
    );

Map<String, dynamic> _$$FormatInfoImplToJson(_$FormatInfoImpl instance) =>
    <String, dynamic>{
      'formatId': instance.formatId,
      'ext': instance.ext,
      'resolution': instance.resolution,
      'fps': instance.fps,
      'filesize': instance.filesize,
      'quality': instance.quality,
      'vcodec': instance.vcodec,
      'acodec': instance.acodec,
    };

_$PlaylistEntryImpl _$$PlaylistEntryImplFromJson(Map<String, dynamic> json) =>
    _$PlaylistEntryImpl(
      index: (json['index'] as num).toInt(),
      id: json['id'] as String,
      title: json['title'] as String,
      duration: (json['duration'] as num?)?.toInt(),
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$PlaylistEntryImplToJson(_$PlaylistEntryImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration,
      'thumbnail': instance.thumbnail,
      'url': instance.url,
    };

_$VideoInfoImpl _$$VideoInfoImplFromJson(Map<String, dynamic> json) =>
    _$VideoInfoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      thumbnail: json['thumbnail'] as String?,
      uploader: json['uploader'] as String?,
      uploadDate: json['uploadDate'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt(),
      formats: (json['formats'] as List<dynamic>?)
              ?.map((e) => FormatInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isPlaylist: json['isPlaylist'] as bool? ?? false,
      playlistCount: (json['playlistCount'] as num?)?.toInt(),
      playlistEntries: (json['playlistEntries'] as List<dynamic>?)
              ?.map((e) => PlaylistEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VideoInfoImplToJson(_$VideoInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'thumbnail': instance.thumbnail,
      'uploader': instance.uploader,
      'uploadDate': instance.uploadDate,
      'viewCount': instance.viewCount,
      'formats': instance.formats,
      'isPlaylist': instance.isPlaylist,
      'playlistCount': instance.playlistCount,
      'playlistEntries': instance.playlistEntries,
    };

_$DownloadResponseImpl _$$DownloadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadResponseImpl(
      downloadId: json['downloadId'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$DownloadResponseImplToJson(
        _$DownloadResponseImpl instance) =>
    <String, dynamic>{
      'downloadId': instance.downloadId,
      'status': instance.status,
      'message': instance.message,
    };

_$DiskUsageImpl _$$DiskUsageImplFromJson(Map<String, dynamic> json) =>
    _$DiskUsageImpl(
      total: (json['total'] as num).toInt(),
      used: (json['used'] as num).toInt(),
      free: (json['free'] as num).toInt(),
    );

Map<String, dynamic> _$$DiskUsageImplToJson(_$DiskUsageImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'used': instance.used,
      'free': instance.free,
    };

_$SystemStatsImpl _$$SystemStatsImplFromJson(Map<String, dynamic> json) =>
    _$SystemStatsImpl(
      cpuPercent: (json['cpuPercent'] as num).toDouble(),
      memoryPercent: (json['memoryPercent'] as num).toDouble(),
      diskUsage: DiskUsage.fromJson(json['diskUsage'] as Map<String, dynamic>),
      activeDownloads: (json['activeDownloads'] as num).toInt(),
      totalDownloads: (json['totalDownloads'] as num).toInt(),
    );

Map<String, dynamic> _$$SystemStatsImplToJson(_$SystemStatsImpl instance) =>
    <String, dynamic>{
      'cpuPercent': instance.cpuPercent,
      'memoryPercent': instance.memoryPercent,
      'diskUsage': instance.diskUsage,
      'activeDownloads': instance.activeDownloads,
      'totalDownloads': instance.totalDownloads,
    };
