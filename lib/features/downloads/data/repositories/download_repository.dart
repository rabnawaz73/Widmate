import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widmate/features/downloads/domain/models/download_item.dart';
import 'package:widmate/main.dart';

final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPreferencesDownloadRepository(prefs);
});

abstract class DownloadRepository {
  Future<List<DownloadItem>> getAllDownloads();
  Future<DownloadItem?> getDownloadById(String id);
  Future<void> saveDownload(DownloadItem download);
  Future<void> updateDownload(DownloadItem download);
  Future<void> deleteDownload(String id);
  Future<void> deleteAllDownloads();
}

class SharedPreferencesDownloadRepository implements DownloadRepository {
  static const String _downloadsKey = 'downloads';
  final SharedPreferences _prefs;

  SharedPreferencesDownloadRepository(this._prefs);

  @override
  Future<List<DownloadItem>> getAllDownloads() async {
    final downloadsJson = _prefs.getStringList(_downloadsKey) ?? [];

    return downloadsJson
        .map((json) => DownloadItem.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<DownloadItem?> getDownloadById(String id) async {
    final downloads = await getAllDownloads();
    try {
      return downloads.firstWhere((download) => download.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDownload(DownloadItem download) async {
    final downloads = await getAllDownloads();

    // Add new download
    downloads.add(download);

    // Save to shared preferences
    await _saveDownloads(downloads);
  }

  @override
  Future<void> updateDownload(DownloadItem download) async {
    final downloads = await getAllDownloads();

    // Find and update download
    final index = downloads.indexWhere((d) => d.id == download.id);
    if (index != -1) {
      downloads[index] = download;

      // Save to shared preferences
      await _saveDownloads(downloads);
    }
  }

  @override
  Future<void> deleteDownload(String id) async {
    final downloads = await getAllDownloads();

    // Remove download
    downloads.removeWhere((download) => download.id == id);

    // Save to shared preferences
    await _saveDownloads(downloads);
  }

  @override
  Future<void> deleteAllDownloads() async {
    await _prefs.remove(_downloadsKey);
  }

  // Helper method to save downloads to shared preferences
  Future<void> _saveDownloads(List<DownloadItem> downloads) async {
    final downloadsJson = downloads
        .map((download) => jsonEncode(download.toJson()))
        .toList();

    await _prefs.setStringList(_downloadsKey, downloadsJson);
  }
}
