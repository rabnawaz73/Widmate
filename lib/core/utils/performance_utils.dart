import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:widmate/core/constants/app_constants.dart';
import 'package:widmate/core/services/logger_service.dart';

/// Performance optimization utilities
class PerformanceUtils {
  PerformanceUtils._();

  /// Debounce function calls to prevent excessive execution
  static Timer? _debounceTimer;

  static void debounce(
    VoidCallback callback, {
    Duration delay = AppConstants.debounceDelay,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleCall;

  static bool throttle(
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleCall == null ||
        now.difference(_lastThrottleCall!) > interval) {
      _lastThrottleCall = now;
      callback();
      return true;
    }
    return false;
  }

  /// Measure execution time of a function
  static Future<T> measureTime<T>(
    Future<T> Function() function, {
    String? operationName,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();

      if (operationName != null) {
        Logger.debug('$operationName took ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      Logger.error(
        '$operationName failed after ${stopwatch.elapsedMilliseconds}ms',
        e,
      );
      rethrow;
    }
  }

  /// Check if we're in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Check if we're in release mode
  static bool get isReleaseMode => kReleaseMode;

  /// Get memory usage (approximate)
  static int get memoryUsage {
    // This is a simplified implementation
    // In a real app, you'd use platform-specific APIs
    return 0;
  }

  /// Check if device has low memory
  static bool get hasLowMemory {
    // This would typically check device memory
    // For now, return false
    return false;
  }

  /// Optimize list operations
  static List<T> optimizeList<T>(List<T> list) {
    // Remove duplicates while preserving order
    final seen = <T>{};
    return list.where((item) => seen.add(item)).toList();
  }

  /// Batch operations to reduce overhead
  static Future<List<T>> batchOperations<T>(
    List<Future<T> Function()> operations, {
    int batchSize = 5,
  }) async {
    final results = <T>[];

    for (int i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((operation) => operation()),
      );
      results.addAll(batchResults);
    }

    return results;
  }

  /// Cache with TTL (Time To Live)
  static final Map<String, _CacheItem> _cache = {};

  static T? getCached<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (DateTime.now().isAfter(item.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return item.data as T?;
  }

  static void setCached<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = _CacheItem(
      data,
      DateTime.now().add(ttl ?? AppConstants.cacheExpiration),
    );
  }

  static void clearCache() {
    _cache.clear();
  }

  /// Memory-efficient string operations
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Efficient number formatting
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }

  /// Check if operation should be skipped due to performance
  static bool shouldSkipOperation() {
    return hasLowMemory;
  }
}

/// Cache item with expiration
class _CacheItem {
  final dynamic data;
  final DateTime expiresAt;

  _CacheItem(this.data, this.expiresAt);
}

/// Performance monitoring
class PerformanceMonitor {
  static final Map<String, List<int>> _operationTimes = {};

  static void recordOperation(String operation, int milliseconds) {
    _operationTimes.putIfAbsent(operation, () => []).add(milliseconds);
  }

  static double getAverageTime(String operation) {
    final times = _operationTimes[operation];
    if (times == null || times.isEmpty) return 0.0;

    return times.reduce((a, b) => a + b) / times.length;
  }

  static void clearMetrics() {
    _operationTimes.clear();
  }
}
