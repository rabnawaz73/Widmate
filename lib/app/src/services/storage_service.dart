import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastCleanupKey = 'last_cleanup_timestamp';

  /// Get cache directory
  Future<Directory> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/cache');
  }

  /// Get downloads directory
  Future<Directory> getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/downloads');
  }

  /// Calculate total cache size
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate total downloads size
  Future<int> getDownloadsSize() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (!await downloadsDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in downloadsDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get total app storage usage
  Future<AppStorageInfo> getStorageInfo() async {
    final cacheSize = await getCacheSize();
    final downloadsSize = await getDownloadsSize();
    final totalSize = cacheSize + downloadsSize;

    return AppStorageInfo(
      cacheSize: cacheSize,
      downloadsSize: downloadsSize,
      totalSize: totalSize,
    );
  }

  /// Clear cache
  Future<bool> clearCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }

      // Update last cleanup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastCleanupKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear downloads (optional - usually not recommended)
  Future<bool> clearDownloads() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (await downloadsDir.exists()) {
        await downloadsDir.delete(recursive: true);
        await downloadsDir.create(recursive: true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear old cache files (older than specified days)
  Future<bool> clearOldCache({int olderThanDays = 7}) async {
    try {
      final cacheDir = await getCacheDirectory();
      if (!await cacheDir.exists()) return true;

      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get last cleanup timestamp
  Future<DateTime?> getLastCleanup() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastCleanupKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class AppStorageInfo {
  final int cacheSize;
  final int downloadsSize;
  final int totalSize;

  AppStorageInfo({
    required this.cacheSize,
    required this.downloadsSize,
    required this.totalSize,
  });

  String get formattedCacheSize => StorageService.formatBytes(cacheSize);
  String get formattedDownloadsSize =>
      StorageService.formatBytes(downloadsSize);
  String get formattedTotalSize => StorageService.formatBytes(totalSize);
}
