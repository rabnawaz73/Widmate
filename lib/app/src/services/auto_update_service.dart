import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Auto-updater service for managing yt-dlp updates
class AutoUpdateService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  
  /// Get auto-updater status
  static Future<AutoUpdateStatus> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auto-updater/status'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AutoUpdateStatus.fromJson(data);
      } else {
        throw Exception('Failed to get auto-updater status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting auto-updater status: $e');
    }
  }
  
  /// Configure auto-updater settings
  static Future<void> configure({
    bool? enabled,
    int? checkIntervalHours,
    bool? notifyOnUpdate,
    bool? updateOnStartup,
    bool? silentUpdates,
  }) async {
    try {
      final config = <String, dynamic>{};
      if (enabled != null) config['enabled'] = enabled;
      if (checkIntervalHours != null) config['check_interval_hours'] = checkIntervalHours;
      if (notifyOnUpdate != null) config['notify_on_update'] = notifyOnUpdate;
      if (updateOnStartup != null) config['update_on_startup'] = updateOnStartup;
      if (silentUpdates != null) config['silent_updates'] = silentUpdates;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auto-updater/configure'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(config),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to configure auto-updater: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error configuring auto-updater: $e');
    }
  }
  
  /// Force an immediate update check
  static Future<void> forceCheck() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auto-updater/check'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to trigger update check: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error triggering update check: $e');
    }
  }
  
  /// Force an immediate update
  static Future<void> forceUpdate() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auto-updater/update'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to trigger update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error triggering update: $e');
    }
  }
}

/// Auto-updater status model
class AutoUpdateStatus {
  final bool isRunning;
  final bool autoUpdateEnabled;
  final double checkIntervalHours;
  final int? lastCheck;
  final int? nextCheck;
  final UpdateStatus updateStatus;
  
  AutoUpdateStatus({
    required this.isRunning,
    required this.autoUpdateEnabled,
    required this.checkIntervalHours,
    this.lastCheck,
    this.nextCheck,
    required this.updateStatus,
  });
  
  factory AutoUpdateStatus.fromJson(Map<String, dynamic> json) {
    return AutoUpdateStatus(
      isRunning: json['is_running'] ?? false,
      autoUpdateEnabled: json['auto_update_enabled'] ?? false,
      checkIntervalHours: (json['check_interval_hours'] ?? 24).toDouble(),
      lastCheck: json['last_check'],
      nextCheck: json['next_check'],
      updateStatus: UpdateStatus.fromJson(json['update_status'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'is_running': isRunning,
      'auto_update_enabled': autoUpdateEnabled,
      'check_interval_hours': checkIntervalHours,
      'last_check': lastCheck,
      'next_check': nextCheck,
      'update_status': updateStatus.toJson(),
    };
  }
}

/// Update status model
class UpdateStatus {
  final String status; // idle, checking, updating, completed, failed
  final double progress;
  final String message;
  final String? error;
  final String? lastUpdate;
  final String? nextCheck;
  
  UpdateStatus({
    required this.status,
    required this.progress,
    required this.message,
    this.error,
    this.lastUpdate,
    this.nextCheck,
  });
  
  factory UpdateStatus.fromJson(Map<String, dynamic> json) {
    return UpdateStatus(
      status: json['status'] ?? 'idle',
      progress: (json['progress'] ?? 0.0).toDouble(),
      message: json['message'] ?? '',
      error: json['error'],
      lastUpdate: json['last_update'],
      nextCheck: json['next_check'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'progress': progress,
      'message': message,
      'error': error,
      'last_update': lastUpdate,
      'next_check': nextCheck,
    };
  }
  
  bool get isIdle => status == 'idle';
  bool get isChecking => status == 'checking';
  bool get isUpdating => status == 'updating';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

/// Auto-updater provider
final autoUpdateStatusProvider = FutureProvider<AutoUpdateStatus>((ref) async {
  return await AutoUpdateService.getStatus();
});

/// Auto-updater notifier for managing state
class AutoUpdateNotifier extends StateNotifier<AsyncValue<AutoUpdateStatus>> {
  AutoUpdateNotifier() : super(const AsyncValue.loading()) {
    _loadStatus();
  }
  
  Timer? _refreshTimer;
  
  void _loadStatus() async {
    try {
      final status = await AutoUpdateService.getStatus();
      state = AsyncValue.data(status);
      
      // Set up periodic refresh if updating
      if (status.updateStatus.isUpdating) {
        _startRefreshTimer();
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadStatus();
    });
  }
  
  void stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _loadStatus();
  }
  
  Future<void> configure({
    bool? enabled,
    int? checkIntervalHours,
    bool? notifyOnUpdate,
    bool? updateOnStartup,
    bool? silentUpdates,
  }) async {
    try {
      await AutoUpdateService.configure(
        enabled: enabled,
        checkIntervalHours: checkIntervalHours,
        notifyOnUpdate: notifyOnUpdate,
        updateOnStartup: updateOnStartup,
        silentUpdates: silentUpdates,
      );
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> forceCheck() async {
    try {
      await AutoUpdateService.forceCheck();
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> forceUpdate() async {
    try {
      await AutoUpdateService.forceUpdate();
      _startRefreshTimer(); // Start monitoring the update
      await refresh();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final autoUpdateNotifierProvider = StateNotifierProvider<AutoUpdateNotifier, AsyncValue<AutoUpdateStatus>>((ref) {
  return AutoUpdateNotifier();
});
