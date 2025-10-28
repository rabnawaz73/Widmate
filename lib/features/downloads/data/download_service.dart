import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/models/download_models.dart';

class DownloadService {
  final String _baseUrl = AppConstants.baseUrl;

  Future<VideoInfo> getVideoInfo(String url) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/info'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      return VideoInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load video info: ${response.body}');
    }
  }

  Future<DownloadStatus> startDownload(DownloadRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return DownloadStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start download: ${response.body}');
    }
  }

  Future<DownloadStatus> getDownloadStatus(String downloadId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/status/$downloadId'),
    );

    if (response.statusCode == 200) {
      return DownloadStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get download status: ${response.body}');
    }
  }

  Future<List<DownloadStatus>> listDownloads() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/downloads'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DownloadStatus.fromJson(json)).toList();
    } else {
      throw Exception('Failed to list downloads: ${response.body}');
    }
  }

  Future<Map<String, String>> cancelDownload(String downloadId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/download/$downloadId'),
    );

    if (response.statusCode == 200) {
      return Map<String, String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to cancel download: ${response.body}');
    }
  }

  Future<Map<String, String>> clearDownloads() async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/downloads'),
    );

    if (response.statusCode == 200) {
      return Map<String, String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to clear downloads: ${response.body}');
    }
  }
}
