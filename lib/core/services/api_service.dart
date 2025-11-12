import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:widmate/core/constants/app_constants.dart';

class ApiService {

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}$endpoint'),
      headers: AppConstants.apiKey.isNotEmpty ? {'X-API-Key': AppConstants.apiKey} : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final headers = {'Content-Type': 'application/json'};
    if (AppConstants.apiKey.isNotEmpty) headers['X-API-Key'] = AppConstants.apiKey;
    final response = await http.post(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers, body: json.encode(data));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from API: ${response.statusCode}');
    }
  }
}

final apiServiceProvider = Provider((ref) => ApiService());
