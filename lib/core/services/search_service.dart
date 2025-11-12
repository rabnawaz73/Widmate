import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:widmate/core/constants/app_constants.dart';

class SearchService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Search for videos using yt-dlp
  Future<SearchResponse> searchVideos(String query, {int limit = 10}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/search'),
            headers: headers,
            body: json.encode({'query': query, 'limit': limit}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SearchResponse.fromJson(data);
      } else if (response.statusCode == 429) {
        throw SearchException(
          'Rate limit exceeded. Please wait a moment before searching again.',
        );
      } else {
        throw SearchException('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SearchException) rethrow;
      throw SearchException('Network error: ${e.toString()}');
    }
  }
}

class SearchResponse {
  final String query;
  final List<SearchResult> results;
  final int total;
  final double searchTime;

  SearchResponse({
    required this.query,
    required this.results,
    required this.total,
    required this.searchTime,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      query: json['query'] ?? '',
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => SearchResult.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      searchTime: (json['search_time'] ?? 0.0).toDouble(),
    );
  }
}

class SearchResult {
  final String id;
  final String title;
  final String description;
  final int? duration;
  final String? thumbnail;
  final String? uploader;
  final String? uploadDate;
  final int? viewCount;
  final String url;
  final String webpageUrl;

  SearchResult({
    required this.id,
    required this.title,
    required this.description,
    this.duration,
    this.thumbnail,
    this.uploader,
    this.uploadDate,
    this.viewCount,
    required this.url,
    required this.webpageUrl,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown',
      description: json['description'] ?? '',
      duration: json['duration'],
      thumbnail: json['thumbnail'],
      uploader: json['uploader'],
      uploadDate: json['upload_date'],
      viewCount: json['view_count'],
      url: json['url'] ?? '',
      webpageUrl: json['webpage_url'] ?? json['url'] ?? '',
    );
  }

  /// Format duration in a human-readable format
  String getFormattedDuration() {
    if (duration == null) return 'Unknown';

    final totalSeconds = duration!;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format view count in a human-readable format
  String getFormattedViewCount() {
    if (viewCount == null) return 'Unknown views';

    final count = viewCount!;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$count views';
    }
  }

  /// Format upload date
  String getFormattedUploadDate() {
    if (uploadDate == null) return 'Unknown date';

    try {
      // YouTube upload date format: YYYYMMDD
      if (uploadDate!.length == 8) {
        final year = uploadDate!.substring(0, 4);
        final month = uploadDate!.substring(4, 6);
        final day = uploadDate!.substring(6, 8);
        return '$day/$month/$year';
      }
      return uploadDate!;
    } catch (e) {
      return uploadDate!;
    }
  }
}

class SearchException implements Exception {
  final String message;
  SearchException(this.message);

  @override
  String toString() => 'SearchException: $message';
}
