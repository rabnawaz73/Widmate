import 'package:flutter/foundation.dart';

@immutable
class DownloadPreset {
  final String name;
  final String quality;
  final bool audioOnly;

  const DownloadPreset({
    required this.name,
    required this.quality,
    required this.audioOnly,
  });

  DownloadPreset.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        quality = json['quality'] as String,
        audioOnly = json['audioOnly'] as bool;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quality': quality,
        'audioOnly': audioOnly,
      };
}
