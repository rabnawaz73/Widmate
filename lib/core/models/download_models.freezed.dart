// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoInfoRequest _$VideoInfoRequestFromJson(Map<String, dynamic> json) {
  return _VideoInfoRequest.fromJson(json);
}

/// @nodoc
mixin _$VideoInfoRequest {
  String get url => throw _privateConstructorUsedError;
  bool get playlistInfo => throw _privateConstructorUsedError;

  /// Serializes this VideoInfoRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoInfoRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoInfoRequestCopyWith<VideoInfoRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoInfoRequestCopyWith<$Res> {
  factory $VideoInfoRequestCopyWith(
          VideoInfoRequest value, $Res Function(VideoInfoRequest) then) =
      _$VideoInfoRequestCopyWithImpl<$Res, VideoInfoRequest>;
  @useResult
  $Res call({String url, bool playlistInfo});
}

/// @nodoc
class _$VideoInfoRequestCopyWithImpl<$Res, $Val extends VideoInfoRequest>
    implements $VideoInfoRequestCopyWith<$Res> {
  _$VideoInfoRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoInfoRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? playlistInfo = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      playlistInfo: null == playlistInfo
          ? _value.playlistInfo
          : playlistInfo // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoInfoRequestImplCopyWith<$Res>
    implements $VideoInfoRequestCopyWith<$Res> {
  factory _$$VideoInfoRequestImplCopyWith(_$VideoInfoRequestImpl value,
          $Res Function(_$VideoInfoRequestImpl) then) =
      __$$VideoInfoRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, bool playlistInfo});
}

/// @nodoc
class __$$VideoInfoRequestImplCopyWithImpl<$Res>
    extends _$VideoInfoRequestCopyWithImpl<$Res, _$VideoInfoRequestImpl>
    implements _$$VideoInfoRequestImplCopyWith<$Res> {
  __$$VideoInfoRequestImplCopyWithImpl(_$VideoInfoRequestImpl _value,
      $Res Function(_$VideoInfoRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoInfoRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? playlistInfo = null,
  }) {
    return _then(_$VideoInfoRequestImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      playlistInfo: null == playlistInfo
          ? _value.playlistInfo
          : playlistInfo // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoInfoRequestImpl implements _VideoInfoRequest {
  const _$VideoInfoRequestImpl({required this.url, this.playlistInfo = false});

  factory _$VideoInfoRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoInfoRequestImplFromJson(json);

  @override
  final String url;
  @override
  @JsonKey()
  final bool playlistInfo;

  @override
  String toString() {
    return 'VideoInfoRequest(url: $url, playlistInfo: $playlistInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoInfoRequestImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.playlistInfo, playlistInfo) ||
                other.playlistInfo == playlistInfo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, playlistInfo);

  /// Create a copy of VideoInfoRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoInfoRequestImplCopyWith<_$VideoInfoRequestImpl> get copyWith =>
      __$$VideoInfoRequestImplCopyWithImpl<_$VideoInfoRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoInfoRequestImplToJson(
      this,
    );
  }
}

abstract class _VideoInfoRequest implements VideoInfoRequest {
  const factory _VideoInfoRequest(
      {required final String url,
      final bool playlistInfo}) = _$VideoInfoRequestImpl;

  factory _VideoInfoRequest.fromJson(Map<String, dynamic> json) =
      _$VideoInfoRequestImpl.fromJson;

  @override
  String get url;
  @override
  bool get playlistInfo;

  /// Create a copy of VideoInfoRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoInfoRequestImplCopyWith<_$VideoInfoRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadRequest _$DownloadRequestFromJson(Map<String, dynamic> json) {
  return _DownloadRequest.fromJson(json);
}

/// @nodoc
mixin _$DownloadRequest {
  String get url => throw _privateConstructorUsedError;
  String? get formatId => throw _privateConstructorUsedError;
  String get quality => throw _privateConstructorUsedError;
  String? get playlistItems => throw _privateConstructorUsedError;
  bool get audioOnly => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;

  /// Serializes this DownloadRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadRequestCopyWith<DownloadRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadRequestCopyWith<$Res> {
  factory $DownloadRequestCopyWith(
          DownloadRequest value, $Res Function(DownloadRequest) then) =
      _$DownloadRequestCopyWithImpl<$Res, DownloadRequest>;
  @useResult
  $Res call(
      {String url,
      String? formatId,
      String quality,
      String? playlistItems,
      bool audioOnly,
      String? outputPath});
}

/// @nodoc
class _$DownloadRequestCopyWithImpl<$Res, $Val extends DownloadRequest>
    implements $DownloadRequestCopyWith<$Res> {
  _$DownloadRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? formatId = freezed,
    Object? quality = null,
    Object? playlistItems = freezed,
    Object? audioOnly = null,
    Object? outputPath = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      formatId: freezed == formatId
          ? _value.formatId
          : formatId // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      playlistItems: freezed == playlistItems
          ? _value.playlistItems
          : playlistItems // ignore: cast_nullable_to_non_nullable
              as String?,
      audioOnly: null == audioOnly
          ? _value.audioOnly
          : audioOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadRequestImplCopyWith<$Res>
    implements $DownloadRequestCopyWith<$Res> {
  factory _$$DownloadRequestImplCopyWith(_$DownloadRequestImpl value,
          $Res Function(_$DownloadRequestImpl) then) =
      __$$DownloadRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      String? formatId,
      String quality,
      String? playlistItems,
      bool audioOnly,
      String? outputPath});
}

/// @nodoc
class __$$DownloadRequestImplCopyWithImpl<$Res>
    extends _$DownloadRequestCopyWithImpl<$Res, _$DownloadRequestImpl>
    implements _$$DownloadRequestImplCopyWith<$Res> {
  __$$DownloadRequestImplCopyWithImpl(
      _$DownloadRequestImpl _value, $Res Function(_$DownloadRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? formatId = freezed,
    Object? quality = null,
    Object? playlistItems = freezed,
    Object? audioOnly = null,
    Object? outputPath = freezed,
  }) {
    return _then(_$DownloadRequestImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      formatId: freezed == formatId
          ? _value.formatId
          : formatId // ignore: cast_nullable_to_non_nullable
              as String?,
      quality: null == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String,
      playlistItems: freezed == playlistItems
          ? _value.playlistItems
          : playlistItems // ignore: cast_nullable_to_non_nullable
              as String?,
      audioOnly: null == audioOnly
          ? _value.audioOnly
          : audioOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadRequestImpl implements _DownloadRequest {
  const _$DownloadRequestImpl(
      {required this.url,
      this.formatId,
      this.quality = '720p',
      this.playlistItems,
      this.audioOnly = false,
      this.outputPath});

  factory _$DownloadRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadRequestImplFromJson(json);

  @override
  final String url;
  @override
  final String? formatId;
  @override
  @JsonKey()
  final String quality;
  @override
  final String? playlistItems;
  @override
  @JsonKey()
  final bool audioOnly;
  @override
  final String? outputPath;

  @override
  String toString() {
    return 'DownloadRequest(url: $url, formatId: $formatId, quality: $quality, playlistItems: $playlistItems, audioOnly: $audioOnly, outputPath: $outputPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadRequestImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.formatId, formatId) ||
                other.formatId == formatId) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.playlistItems, playlistItems) ||
                other.playlistItems == playlistItems) &&
            (identical(other.audioOnly, audioOnly) ||
                other.audioOnly == audioOnly) &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, formatId, quality,
      playlistItems, audioOnly, outputPath);

  /// Create a copy of DownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadRequestImplCopyWith<_$DownloadRequestImpl> get copyWith =>
      __$$DownloadRequestImplCopyWithImpl<_$DownloadRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadRequestImplToJson(
      this,
    );
  }
}

abstract class _DownloadRequest implements DownloadRequest {
  const factory _DownloadRequest(
      {required final String url,
      final String? formatId,
      final String quality,
      final String? playlistItems,
      final bool audioOnly,
      final String? outputPath}) = _$DownloadRequestImpl;

  factory _DownloadRequest.fromJson(Map<String, dynamic> json) =
      _$DownloadRequestImpl.fromJson;

  @override
  String get url;
  @override
  String? get formatId;
  @override
  String get quality;
  @override
  String? get playlistItems;
  @override
  bool get audioOnly;
  @override
  String? get outputPath;

  /// Create a copy of DownloadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadRequestImplCopyWith<_$DownloadRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadStatus _$DownloadStatusFromJson(Map<String, dynamic> json) {
  return _DownloadStatus.fromJson(json);
}

/// @nodoc
mixin _$DownloadStatus {
  String get id => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, downloading, completed, failed, cancelled
  double get progress => throw _privateConstructorUsedError;
  String? get speed => throw _privateConstructorUsedError;
  String? get eta => throw _privateConstructorUsedError;
  int get downloadedBytes => throw _privateConstructorUsedError;
  int? get totalBytes => throw _privateConstructorUsedError;
  String? get filename => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DownloadStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadStatusCopyWith<DownloadStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadStatusCopyWith<$Res> {
  factory $DownloadStatusCopyWith(
          DownloadStatus value, $Res Function(DownloadStatus) then) =
      _$DownloadStatusCopyWithImpl<$Res, DownloadStatus>;
  @useResult
  $Res call(
      {String id,
      String status,
      double progress,
      String? speed,
      String? eta,
      int downloadedBytes,
      int? totalBytes,
      String? filename,
      String? error,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$DownloadStatusCopyWithImpl<$Res, $Val extends DownloadStatus>
    implements $DownloadStatusCopyWith<$Res> {
  _$DownloadStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? progress = null,
    Object? speed = freezed,
    Object? eta = freezed,
    Object? downloadedBytes = null,
    Object? totalBytes = freezed,
    Object? filename = freezed,
    Object? error = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as String?,
      eta: freezed == eta
          ? _value.eta
          : eta // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: freezed == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadStatusImplCopyWith<$Res>
    implements $DownloadStatusCopyWith<$Res> {
  factory _$$DownloadStatusImplCopyWith(_$DownloadStatusImpl value,
          $Res Function(_$DownloadStatusImpl) then) =
      __$$DownloadStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String status,
      double progress,
      String? speed,
      String? eta,
      int downloadedBytes,
      int? totalBytes,
      String? filename,
      String? error,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$DownloadStatusImplCopyWithImpl<$Res>
    extends _$DownloadStatusCopyWithImpl<$Res, _$DownloadStatusImpl>
    implements _$$DownloadStatusImplCopyWith<$Res> {
  __$$DownloadStatusImplCopyWithImpl(
      _$DownloadStatusImpl _value, $Res Function(_$DownloadStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? progress = null,
    Object? speed = freezed,
    Object? eta = freezed,
    Object? downloadedBytes = null,
    Object? totalBytes = freezed,
    Object? filename = freezed,
    Object? error = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$DownloadStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      speed: freezed == speed
          ? _value.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as String?,
      eta: freezed == eta
          ? _value.eta
          : eta // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadedBytes: null == downloadedBytes
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: freezed == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      filename: freezed == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadStatusImpl implements _DownloadStatus {
  const _$DownloadStatusImpl(
      {required this.id,
      required this.status,
      this.progress = 0.0,
      this.speed,
      this.eta,
      this.downloadedBytes = 0,
      this.totalBytes,
      this.filename,
      this.error,
      required this.createdAt,
      required this.updatedAt});

  factory _$DownloadStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadStatusImplFromJson(json);

  @override
  final String id;
  @override
  final String status;
// pending, downloading, completed, failed, cancelled
  @override
  @JsonKey()
  final double progress;
  @override
  final String? speed;
  @override
  final String? eta;
  @override
  @JsonKey()
  final int downloadedBytes;
  @override
  final int? totalBytes;
  @override
  final String? filename;
  @override
  final String? error;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'DownloadStatus(id: $id, status: $status, progress: $progress, speed: $speed, eta: $eta, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes, filename: $filename, error: $error, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.eta, eta) || other.eta == eta) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, progress, speed, eta,
      downloadedBytes, totalBytes, filename, error, createdAt, updatedAt);

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadStatusImplCopyWith<_$DownloadStatusImpl> get copyWith =>
      __$$DownloadStatusImplCopyWithImpl<_$DownloadStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadStatusImplToJson(
      this,
    );
  }
}

abstract class _DownloadStatus implements DownloadStatus {
  const factory _DownloadStatus(
      {required final String id,
      required final String status,
      final double progress,
      final String? speed,
      final String? eta,
      final int downloadedBytes,
      final int? totalBytes,
      final String? filename,
      final String? error,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$DownloadStatusImpl;

  factory _DownloadStatus.fromJson(Map<String, dynamic> json) =
      _$DownloadStatusImpl.fromJson;

  @override
  String get id;
  @override
  String get status; // pending, downloading, completed, failed, cancelled
  @override
  double get progress;
  @override
  String? get speed;
  @override
  String? get eta;
  @override
  int get downloadedBytes;
  @override
  int? get totalBytes;
  @override
  String? get filename;
  @override
  String? get error;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of DownloadStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadStatusImplCopyWith<_$DownloadStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FormatInfo _$FormatInfoFromJson(Map<String, dynamic> json) {
  return _FormatInfo.fromJson(json);
}

/// @nodoc
mixin _$FormatInfo {
  String get formatId => throw _privateConstructorUsedError;
  String get ext => throw _privateConstructorUsedError;
  String get resolution => throw _privateConstructorUsedError;
  double? get fps => throw _privateConstructorUsedError;
  int? get filesize => throw _privateConstructorUsedError;
  String? get quality => throw _privateConstructorUsedError;
  String? get vcodec => throw _privateConstructorUsedError;
  String? get acodec => throw _privateConstructorUsedError;

  /// Serializes this FormatInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FormatInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FormatInfoCopyWith<FormatInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FormatInfoCopyWith<$Res> {
  factory $FormatInfoCopyWith(
          FormatInfo value, $Res Function(FormatInfo) then) =
      _$FormatInfoCopyWithImpl<$Res, FormatInfo>;
  @useResult
  $Res call(
      {String formatId,
      String ext,
      String resolution,
      double? fps,
      int? filesize,
      String? quality,
      String? vcodec,
      String? acodec});
}

/// @nodoc
class _$FormatInfoCopyWithImpl<$Res, $Val extends FormatInfo>
    implements $FormatInfoCopyWith<$Res> {
  _$FormatInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FormatInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatId = null,
    Object? ext = null,
    Object? resolution = null,
    Object? fps = freezed,
    Object? filesize = freezed,
    Object? quality = freezed,
    Object? vcodec = freezed,
    Object? acodec = freezed,
  }) {
    return _then(_value.copyWith(
      formatId: null == formatId
          ? _value.formatId
          : formatId // ignore: cast_nullable_to_non_nullable
              as String,
      ext: null == ext
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: null == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      fps: freezed == fps
          ? _value.fps
          : fps // ignore: cast_nullable_to_non_nullable
              as double?,
      filesize: freezed == filesize
          ? _value.filesize
          : filesize // ignore: cast_nullable_to_non_nullable
              as int?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String?,
      vcodec: freezed == vcodec
          ? _value.vcodec
          : vcodec // ignore: cast_nullable_to_non_nullable
              as String?,
      acodec: freezed == acodec
          ? _value.acodec
          : acodec // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FormatInfoImplCopyWith<$Res>
    implements $FormatInfoCopyWith<$Res> {
  factory _$$FormatInfoImplCopyWith(
          _$FormatInfoImpl value, $Res Function(_$FormatInfoImpl) then) =
      __$$FormatInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String formatId,
      String ext,
      String resolution,
      double? fps,
      int? filesize,
      String? quality,
      String? vcodec,
      String? acodec});
}

/// @nodoc
class __$$FormatInfoImplCopyWithImpl<$Res>
    extends _$FormatInfoCopyWithImpl<$Res, _$FormatInfoImpl>
    implements _$$FormatInfoImplCopyWith<$Res> {
  __$$FormatInfoImplCopyWithImpl(
      _$FormatInfoImpl _value, $Res Function(_$FormatInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of FormatInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formatId = null,
    Object? ext = null,
    Object? resolution = null,
    Object? fps = freezed,
    Object? filesize = freezed,
    Object? quality = freezed,
    Object? vcodec = freezed,
    Object? acodec = freezed,
  }) {
    return _then(_$FormatInfoImpl(
      formatId: null == formatId
          ? _value.formatId
          : formatId // ignore: cast_nullable_to_non_nullable
              as String,
      ext: null == ext
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: null == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String,
      fps: freezed == fps
          ? _value.fps
          : fps // ignore: cast_nullable_to_non_nullable
              as double?,
      filesize: freezed == filesize
          ? _value.filesize
          : filesize // ignore: cast_nullable_to_non_nullable
              as int?,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as String?,
      vcodec: freezed == vcodec
          ? _value.vcodec
          : vcodec // ignore: cast_nullable_to_non_nullable
              as String?,
      acodec: freezed == acodec
          ? _value.acodec
          : acodec // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FormatInfoImpl implements _FormatInfo {
  const _$FormatInfoImpl(
      {required this.formatId,
      required this.ext,
      required this.resolution,
      this.fps,
      this.filesize,
      this.quality,
      this.vcodec,
      this.acodec});

  factory _$FormatInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FormatInfoImplFromJson(json);

  @override
  final String formatId;
  @override
  final String ext;
  @override
  final String resolution;
  @override
  final double? fps;
  @override
  final int? filesize;
  @override
  final String? quality;
  @override
  final String? vcodec;
  @override
  final String? acodec;

  @override
  String toString() {
    return 'FormatInfo(formatId: $formatId, ext: $ext, resolution: $resolution, fps: $fps, filesize: $filesize, quality: $quality, vcodec: $vcodec, acodec: $acodec)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FormatInfoImpl &&
            (identical(other.formatId, formatId) ||
                other.formatId == formatId) &&
            (identical(other.ext, ext) || other.ext == ext) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.fps, fps) || other.fps == fps) &&
            (identical(other.filesize, filesize) ||
                other.filesize == filesize) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.vcodec, vcodec) || other.vcodec == vcodec) &&
            (identical(other.acodec, acodec) || other.acodec == acodec));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, formatId, ext, resolution, fps,
      filesize, quality, vcodec, acodec);

  /// Create a copy of FormatInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FormatInfoImplCopyWith<_$FormatInfoImpl> get copyWith =>
      __$$FormatInfoImplCopyWithImpl<_$FormatInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FormatInfoImplToJson(
      this,
    );
  }
}

abstract class _FormatInfo implements FormatInfo {
  const factory _FormatInfo(
      {required final String formatId,
      required final String ext,
      required final String resolution,
      final double? fps,
      final int? filesize,
      final String? quality,
      final String? vcodec,
      final String? acodec}) = _$FormatInfoImpl;

  factory _FormatInfo.fromJson(Map<String, dynamic> json) =
      _$FormatInfoImpl.fromJson;

  @override
  String get formatId;
  @override
  String get ext;
  @override
  String get resolution;
  @override
  double? get fps;
  @override
  int? get filesize;
  @override
  String? get quality;
  @override
  String? get vcodec;
  @override
  String? get acodec;

  /// Create a copy of FormatInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FormatInfoImplCopyWith<_$FormatInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaylistEntry _$PlaylistEntryFromJson(Map<String, dynamic> json) {
  return _PlaylistEntry.fromJson(json);
}

/// @nodoc
mixin _$PlaylistEntry {
  int get index => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;

  /// Serializes this PlaylistEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaylistEntryCopyWith<PlaylistEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaylistEntryCopyWith<$Res> {
  factory $PlaylistEntryCopyWith(
          PlaylistEntry value, $Res Function(PlaylistEntry) then) =
      _$PlaylistEntryCopyWithImpl<$Res, PlaylistEntry>;
  @useResult
  $Res call(
      {int index,
      String id,
      String title,
      int? duration,
      String? thumbnail,
      String url});
}

/// @nodoc
class _$PlaylistEntryCopyWithImpl<$Res, $Val extends PlaylistEntry>
    implements $PlaylistEntryCopyWith<$Res> {
  _$PlaylistEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? id = null,
    Object? title = null,
    Object? duration = freezed,
    Object? thumbnail = freezed,
    Object? url = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaylistEntryImplCopyWith<$Res>
    implements $PlaylistEntryCopyWith<$Res> {
  factory _$$PlaylistEntryImplCopyWith(
          _$PlaylistEntryImpl value, $Res Function(_$PlaylistEntryImpl) then) =
      __$$PlaylistEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index,
      String id,
      String title,
      int? duration,
      String? thumbnail,
      String url});
}

/// @nodoc
class __$$PlaylistEntryImplCopyWithImpl<$Res>
    extends _$PlaylistEntryCopyWithImpl<$Res, _$PlaylistEntryImpl>
    implements _$$PlaylistEntryImplCopyWith<$Res> {
  __$$PlaylistEntryImplCopyWithImpl(
      _$PlaylistEntryImpl _value, $Res Function(_$PlaylistEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? id = null,
    Object? title = null,
    Object? duration = freezed,
    Object? thumbnail = freezed,
    Object? url = null,
  }) {
    return _then(_$PlaylistEntryImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaylistEntryImpl implements _PlaylistEntry {
  const _$PlaylistEntryImpl(
      {required this.index,
      required this.id,
      required this.title,
      this.duration,
      this.thumbnail,
      required this.url});

  factory _$PlaylistEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaylistEntryImplFromJson(json);

  @override
  final int index;
  @override
  final String id;
  @override
  final String title;
  @override
  final int? duration;
  @override
  final String? thumbnail;
  @override
  final String url;

  @override
  String toString() {
    return 'PlaylistEntry(index: $index, id: $id, title: $title, duration: $duration, thumbnail: $thumbnail, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaylistEntryImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, index, id, title, duration, thumbnail, url);

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaylistEntryImplCopyWith<_$PlaylistEntryImpl> get copyWith =>
      __$$PlaylistEntryImplCopyWithImpl<_$PlaylistEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaylistEntryImplToJson(
      this,
    );
  }
}

abstract class _PlaylistEntry implements PlaylistEntry {
  const factory _PlaylistEntry(
      {required final int index,
      required final String id,
      required final String title,
      final int? duration,
      final String? thumbnail,
      required final String url}) = _$PlaylistEntryImpl;

  factory _PlaylistEntry.fromJson(Map<String, dynamic> json) =
      _$PlaylistEntryImpl.fromJson;

  @override
  int get index;
  @override
  String get id;
  @override
  String get title;
  @override
  int? get duration;
  @override
  String? get thumbnail;
  @override
  String get url;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaylistEntryImplCopyWith<_$PlaylistEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) {
  return _VideoInfo.fromJson(json);
}

/// @nodoc
mixin _$VideoInfo {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  String? get uploader => throw _privateConstructorUsedError;
  String? get uploadDate => throw _privateConstructorUsedError;
  int? get viewCount => throw _privateConstructorUsedError;
  List<FormatInfo> get formats => throw _privateConstructorUsedError;
  bool get isPlaylist => throw _privateConstructorUsedError;
  int? get playlistCount => throw _privateConstructorUsedError;
  List<PlaylistEntry> get playlistEntries => throw _privateConstructorUsedError;

  /// Serializes this VideoInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoInfoCopyWith<VideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoInfoCopyWith<$Res> {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) then) =
      _$VideoInfoCopyWithImpl<$Res, VideoInfo>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      int? duration,
      String? thumbnail,
      String? uploader,
      String? uploadDate,
      int? viewCount,
      List<FormatInfo> formats,
      bool isPlaylist,
      int? playlistCount,
      List<PlaylistEntry> playlistEntries});
}

/// @nodoc
class _$VideoInfoCopyWithImpl<$Res, $Val extends VideoInfo>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? duration = freezed,
    Object? thumbnail = freezed,
    Object? uploader = freezed,
    Object? uploadDate = freezed,
    Object? viewCount = freezed,
    Object? formats = null,
    Object? isPlaylist = null,
    Object? playlistCount = freezed,
    Object? playlistEntries = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      uploader: freezed == uploader
          ? _value.uploader
          : uploader // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadDate: freezed == uploadDate
          ? _value.uploadDate
          : uploadDate // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      formats: null == formats
          ? _value.formats
          : formats // ignore: cast_nullable_to_non_nullable
              as List<FormatInfo>,
      isPlaylist: null == isPlaylist
          ? _value.isPlaylist
          : isPlaylist // ignore: cast_nullable_to_non_nullable
              as bool,
      playlistCount: freezed == playlistCount
          ? _value.playlistCount
          : playlistCount // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistEntries: null == playlistEntries
          ? _value.playlistEntries
          : playlistEntries // ignore: cast_nullable_to_non_nullable
              as List<PlaylistEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoInfoImplCopyWith<$Res>
    implements $VideoInfoCopyWith<$Res> {
  factory _$$VideoInfoImplCopyWith(
          _$VideoInfoImpl value, $Res Function(_$VideoInfoImpl) then) =
      __$$VideoInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      int? duration,
      String? thumbnail,
      String? uploader,
      String? uploadDate,
      int? viewCount,
      List<FormatInfo> formats,
      bool isPlaylist,
      int? playlistCount,
      List<PlaylistEntry> playlistEntries});
}

/// @nodoc
class __$$VideoInfoImplCopyWithImpl<$Res>
    extends _$VideoInfoCopyWithImpl<$Res, _$VideoInfoImpl>
    implements _$$VideoInfoImplCopyWith<$Res> {
  __$$VideoInfoImplCopyWithImpl(
      _$VideoInfoImpl _value, $Res Function(_$VideoInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? duration = freezed,
    Object? thumbnail = freezed,
    Object? uploader = freezed,
    Object? uploadDate = freezed,
    Object? viewCount = freezed,
    Object? formats = null,
    Object? isPlaylist = null,
    Object? playlistCount = freezed,
    Object? playlistEntries = null,
  }) {
    return _then(_$VideoInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      uploader: freezed == uploader
          ? _value.uploader
          : uploader // ignore: cast_nullable_to_non_nullable
              as String?,
      uploadDate: freezed == uploadDate
          ? _value.uploadDate
          : uploadDate // ignore: cast_nullable_to_non_nullable
              as String?,
      viewCount: freezed == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int?,
      formats: null == formats
          ? _value._formats
          : formats // ignore: cast_nullable_to_non_nullable
              as List<FormatInfo>,
      isPlaylist: null == isPlaylist
          ? _value.isPlaylist
          : isPlaylist // ignore: cast_nullable_to_non_nullable
              as bool,
      playlistCount: freezed == playlistCount
          ? _value.playlistCount
          : playlistCount // ignore: cast_nullable_to_non_nullable
              as int?,
      playlistEntries: null == playlistEntries
          ? _value._playlistEntries
          : playlistEntries // ignore: cast_nullable_to_non_nullable
              as List<PlaylistEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoInfoImpl implements _VideoInfo {
  const _$VideoInfoImpl(
      {required this.id,
      required this.title,
      this.description,
      this.duration,
      this.thumbnail,
      this.uploader,
      this.uploadDate,
      this.viewCount,
      final List<FormatInfo> formats = const [],
      this.isPlaylist = false,
      this.playlistCount,
      final List<PlaylistEntry> playlistEntries = const []})
      : _formats = formats,
        _playlistEntries = playlistEntries;

  factory _$VideoInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final int? duration;
  @override
  final String? thumbnail;
  @override
  final String? uploader;
  @override
  final String? uploadDate;
  @override
  final int? viewCount;
  final List<FormatInfo> _formats;
  @override
  @JsonKey()
  List<FormatInfo> get formats {
    if (_formats is EqualUnmodifiableListView) return _formats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_formats);
  }

  @override
  @JsonKey()
  final bool isPlaylist;
  @override
  final int? playlistCount;
  final List<PlaylistEntry> _playlistEntries;
  @override
  @JsonKey()
  List<PlaylistEntry> get playlistEntries {
    if (_playlistEntries is EqualUnmodifiableListView) return _playlistEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playlistEntries);
  }

  @override
  String toString() {
    return 'VideoInfo(id: $id, title: $title, description: $description, duration: $duration, thumbnail: $thumbnail, uploader: $uploader, uploadDate: $uploadDate, viewCount: $viewCount, formats: $formats, isPlaylist: $isPlaylist, playlistCount: $playlistCount, playlistEntries: $playlistEntries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.uploader, uploader) ||
                other.uploader == uploader) &&
            (identical(other.uploadDate, uploadDate) ||
                other.uploadDate == uploadDate) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            const DeepCollectionEquality().equals(other._formats, _formats) &&
            (identical(other.isPlaylist, isPlaylist) ||
                other.isPlaylist == isPlaylist) &&
            (identical(other.playlistCount, playlistCount) ||
                other.playlistCount == playlistCount) &&
            const DeepCollectionEquality()
                .equals(other._playlistEntries, _playlistEntries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      duration,
      thumbnail,
      uploader,
      uploadDate,
      viewCount,
      const DeepCollectionEquality().hash(_formats),
      isPlaylist,
      playlistCount,
      const DeepCollectionEquality().hash(_playlistEntries));

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      __$$VideoInfoImplCopyWithImpl<_$VideoInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoInfoImplToJson(
      this,
    );
  }
}

abstract class _VideoInfo implements VideoInfo {
  const factory _VideoInfo(
      {required final String id,
      required final String title,
      final String? description,
      final int? duration,
      final String? thumbnail,
      final String? uploader,
      final String? uploadDate,
      final int? viewCount,
      final List<FormatInfo> formats,
      final bool isPlaylist,
      final int? playlistCount,
      final List<PlaylistEntry> playlistEntries}) = _$VideoInfoImpl;

  factory _VideoInfo.fromJson(Map<String, dynamic> json) =
      _$VideoInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  int? get duration;
  @override
  String? get thumbnail;
  @override
  String? get uploader;
  @override
  String? get uploadDate;
  @override
  int? get viewCount;
  @override
  List<FormatInfo> get formats;
  @override
  bool get isPlaylist;
  @override
  int? get playlistCount;
  @override
  List<PlaylistEntry> get playlistEntries;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadResponse _$DownloadResponseFromJson(Map<String, dynamic> json) {
  return _DownloadResponse.fromJson(json);
}

/// @nodoc
mixin _$DownloadResponse {
  String get downloadId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this DownloadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadResponseCopyWith<DownloadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadResponseCopyWith<$Res> {
  factory $DownloadResponseCopyWith(
          DownloadResponse value, $Res Function(DownloadResponse) then) =
      _$DownloadResponseCopyWithImpl<$Res, DownloadResponse>;
  @useResult
  $Res call({String downloadId, String status, String message});
}

/// @nodoc
class _$DownloadResponseCopyWithImpl<$Res, $Val extends DownloadResponse>
    implements $DownloadResponseCopyWith<$Res> {
  _$DownloadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloadId = null,
    Object? status = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      downloadId: null == downloadId
          ? _value.downloadId
          : downloadId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadResponseImplCopyWith<$Res>
    implements $DownloadResponseCopyWith<$Res> {
  factory _$$DownloadResponseImplCopyWith(_$DownloadResponseImpl value,
          $Res Function(_$DownloadResponseImpl) then) =
      __$$DownloadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String downloadId, String status, String message});
}

/// @nodoc
class __$$DownloadResponseImplCopyWithImpl<$Res>
    extends _$DownloadResponseCopyWithImpl<$Res, _$DownloadResponseImpl>
    implements _$$DownloadResponseImplCopyWith<$Res> {
  __$$DownloadResponseImplCopyWithImpl(_$DownloadResponseImpl _value,
      $Res Function(_$DownloadResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloadId = null,
    Object? status = null,
    Object? message = null,
  }) {
    return _then(_$DownloadResponseImpl(
      downloadId: null == downloadId
          ? _value.downloadId
          : downloadId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadResponseImpl implements _DownloadResponse {
  const _$DownloadResponseImpl(
      {required this.downloadId, required this.status, required this.message});

  factory _$DownloadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadResponseImplFromJson(json);

  @override
  final String downloadId;
  @override
  final String status;
  @override
  final String message;

  @override
  String toString() {
    return 'DownloadResponse(downloadId: $downloadId, status: $status, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadResponseImpl &&
            (identical(other.downloadId, downloadId) ||
                other.downloadId == downloadId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, downloadId, status, message);

  /// Create a copy of DownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadResponseImplCopyWith<_$DownloadResponseImpl> get copyWith =>
      __$$DownloadResponseImplCopyWithImpl<_$DownloadResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadResponseImplToJson(
      this,
    );
  }
}

abstract class _DownloadResponse implements DownloadResponse {
  const factory _DownloadResponse(
      {required final String downloadId,
      required final String status,
      required final String message}) = _$DownloadResponseImpl;

  factory _DownloadResponse.fromJson(Map<String, dynamic> json) =
      _$DownloadResponseImpl.fromJson;

  @override
  String get downloadId;
  @override
  String get status;
  @override
  String get message;

  /// Create a copy of DownloadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadResponseImplCopyWith<_$DownloadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DiskUsage _$DiskUsageFromJson(Map<String, dynamic> json) {
  return _DiskUsage.fromJson(json);
}

/// @nodoc
mixin _$DiskUsage {
  int get total => throw _privateConstructorUsedError;
  int get used => throw _privateConstructorUsedError;
  int get free => throw _privateConstructorUsedError;

  /// Serializes this DiskUsage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiskUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiskUsageCopyWith<DiskUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiskUsageCopyWith<$Res> {
  factory $DiskUsageCopyWith(DiskUsage value, $Res Function(DiskUsage) then) =
      _$DiskUsageCopyWithImpl<$Res, DiskUsage>;
  @useResult
  $Res call({int total, int used, int free});
}

/// @nodoc
class _$DiskUsageCopyWithImpl<$Res, $Val extends DiskUsage>
    implements $DiskUsageCopyWith<$Res> {
  _$DiskUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiskUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? used = null,
    Object? free = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      free: null == free
          ? _value.free
          : free // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiskUsageImplCopyWith<$Res>
    implements $DiskUsageCopyWith<$Res> {
  factory _$$DiskUsageImplCopyWith(
          _$DiskUsageImpl value, $Res Function(_$DiskUsageImpl) then) =
      __$$DiskUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, int used, int free});
}

/// @nodoc
class __$$DiskUsageImplCopyWithImpl<$Res>
    extends _$DiskUsageCopyWithImpl<$Res, _$DiskUsageImpl>
    implements _$$DiskUsageImplCopyWith<$Res> {
  __$$DiskUsageImplCopyWithImpl(
      _$DiskUsageImpl _value, $Res Function(_$DiskUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiskUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? used = null,
    Object? free = null,
  }) {
    return _then(_$DiskUsageImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      used: null == used
          ? _value.used
          : used // ignore: cast_nullable_to_non_nullable
              as int,
      free: null == free
          ? _value.free
          : free // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiskUsageImpl implements _DiskUsage {
  const _$DiskUsageImpl(
      {required this.total, required this.used, required this.free});

  factory _$DiskUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiskUsageImplFromJson(json);

  @override
  final int total;
  @override
  final int used;
  @override
  final int free;

  @override
  String toString() {
    return 'DiskUsage(total: $total, used: $used, free: $free)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiskUsageImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.free, free) || other.free == free));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, used, free);

  /// Create a copy of DiskUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiskUsageImplCopyWith<_$DiskUsageImpl> get copyWith =>
      __$$DiskUsageImplCopyWithImpl<_$DiskUsageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiskUsageImplToJson(
      this,
    );
  }
}

abstract class _DiskUsage implements DiskUsage {
  const factory _DiskUsage(
      {required final int total,
      required final int used,
      required final int free}) = _$DiskUsageImpl;

  factory _DiskUsage.fromJson(Map<String, dynamic> json) =
      _$DiskUsageImpl.fromJson;

  @override
  int get total;
  @override
  int get used;
  @override
  int get free;

  /// Create a copy of DiskUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiskUsageImplCopyWith<_$DiskUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SystemStats _$SystemStatsFromJson(Map<String, dynamic> json) {
  return _SystemStats.fromJson(json);
}

/// @nodoc
mixin _$SystemStats {
  double get cpuPercent => throw _privateConstructorUsedError;
  double get memoryPercent => throw _privateConstructorUsedError;
  DiskUsage get diskUsage => throw _privateConstructorUsedError;
  int get activeDownloads => throw _privateConstructorUsedError;
  int get totalDownloads => throw _privateConstructorUsedError;

  /// Serializes this SystemStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SystemStatsCopyWith<SystemStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SystemStatsCopyWith<$Res> {
  factory $SystemStatsCopyWith(
          SystemStats value, $Res Function(SystemStats) then) =
      _$SystemStatsCopyWithImpl<$Res, SystemStats>;
  @useResult
  $Res call(
      {double cpuPercent,
      double memoryPercent,
      DiskUsage diskUsage,
      int activeDownloads,
      int totalDownloads});

  $DiskUsageCopyWith<$Res> get diskUsage;
}

/// @nodoc
class _$SystemStatsCopyWithImpl<$Res, $Val extends SystemStats>
    implements $SystemStatsCopyWith<$Res> {
  _$SystemStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPercent = null,
    Object? memoryPercent = null,
    Object? diskUsage = null,
    Object? activeDownloads = null,
    Object? totalDownloads = null,
  }) {
    return _then(_value.copyWith(
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memoryPercent: null == memoryPercent
          ? _value.memoryPercent
          : memoryPercent // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as DiskUsage,
      activeDownloads: null == activeDownloads
          ? _value.activeDownloads
          : activeDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DiskUsageCopyWith<$Res> get diskUsage {
    return $DiskUsageCopyWith<$Res>(_value.diskUsage, (value) {
      return _then(_value.copyWith(diskUsage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SystemStatsImplCopyWith<$Res>
    implements $SystemStatsCopyWith<$Res> {
  factory _$$SystemStatsImplCopyWith(
          _$SystemStatsImpl value, $Res Function(_$SystemStatsImpl) then) =
      __$$SystemStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double cpuPercent,
      double memoryPercent,
      DiskUsage diskUsage,
      int activeDownloads,
      int totalDownloads});

  @override
  $DiskUsageCopyWith<$Res> get diskUsage;
}

/// @nodoc
class __$$SystemStatsImplCopyWithImpl<$Res>
    extends _$SystemStatsCopyWithImpl<$Res, _$SystemStatsImpl>
    implements _$$SystemStatsImplCopyWith<$Res> {
  __$$SystemStatsImplCopyWithImpl(
      _$SystemStatsImpl _value, $Res Function(_$SystemStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPercent = null,
    Object? memoryPercent = null,
    Object? diskUsage = null,
    Object? activeDownloads = null,
    Object? totalDownloads = null,
  }) {
    return _then(_$SystemStatsImpl(
      cpuPercent: null == cpuPercent
          ? _value.cpuPercent
          : cpuPercent // ignore: cast_nullable_to_non_nullable
              as double,
      memoryPercent: null == memoryPercent
          ? _value.memoryPercent
          : memoryPercent // ignore: cast_nullable_to_non_nullable
              as double,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as DiskUsage,
      activeDownloads: null == activeDownloads
          ? _value.activeDownloads
          : activeDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SystemStatsImpl implements _SystemStats {
  const _$SystemStatsImpl(
      {required this.cpuPercent,
      required this.memoryPercent,
      required this.diskUsage,
      required this.activeDownloads,
      required this.totalDownloads});

  factory _$SystemStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SystemStatsImplFromJson(json);

  @override
  final double cpuPercent;
  @override
  final double memoryPercent;
  @override
  final DiskUsage diskUsage;
  @override
  final int activeDownloads;
  @override
  final int totalDownloads;

  @override
  String toString() {
    return 'SystemStats(cpuPercent: $cpuPercent, memoryPercent: $memoryPercent, diskUsage: $diskUsage, activeDownloads: $activeDownloads, totalDownloads: $totalDownloads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SystemStatsImpl &&
            (identical(other.cpuPercent, cpuPercent) ||
                other.cpuPercent == cpuPercent) &&
            (identical(other.memoryPercent, memoryPercent) ||
                other.memoryPercent == memoryPercent) &&
            (identical(other.diskUsage, diskUsage) ||
                other.diskUsage == diskUsage) &&
            (identical(other.activeDownloads, activeDownloads) ||
                other.activeDownloads == activeDownloads) &&
            (identical(other.totalDownloads, totalDownloads) ||
                other.totalDownloads == totalDownloads));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cpuPercent, memoryPercent,
      diskUsage, activeDownloads, totalDownloads);

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SystemStatsImplCopyWith<_$SystemStatsImpl> get copyWith =>
      __$$SystemStatsImplCopyWithImpl<_$SystemStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SystemStatsImplToJson(
      this,
    );
  }
}

abstract class _SystemStats implements SystemStats {
  const factory _SystemStats(
      {required final double cpuPercent,
      required final double memoryPercent,
      required final DiskUsage diskUsage,
      required final int activeDownloads,
      required final int totalDownloads}) = _$SystemStatsImpl;

  factory _SystemStats.fromJson(Map<String, dynamic> json) =
      _$SystemStatsImpl.fromJson;

  @override
  double get cpuPercent;
  @override
  double get memoryPercent;
  @override
  DiskUsage get diskUsage;
  @override
  int get activeDownloads;
  @override
  int get totalDownloads;

  /// Create a copy of SystemStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SystemStatsImplCopyWith<_$SystemStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
