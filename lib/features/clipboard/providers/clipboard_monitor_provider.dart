import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/clipboard/services/clipboard_monitor_service.dart';

// Provider for the clipboard monitor service
final clipboardMonitorServiceProvider = Provider<ClipboardMonitorService>((ref) {
  final service = ClipboardMonitorService();
  
  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});