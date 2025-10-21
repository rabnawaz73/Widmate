import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widmate/features/clipboard/presentation/widgets/clipboard_url_prompt.dart';

// Provider for the clipboard monitor service
final clipboardMonitorServiceProvider = Provider<ClipboardMonitorService>((
  ref,
) {
  return ClipboardMonitorService.instance;
});

/// Manages overlay entries for clipboard URL prompts
class ClipboardOverlayManager {
  final BuildContext context;
  final Ref ref;
  final ClipboardMonitorService clipboardService;

  OverlayEntry? _currentOverlay;

  ClipboardOverlayManager({
    required this.context,
    required this.ref,
    required this.clipboardService,
  }) {
    _initialize();
  }

  void _initialize() {
    // Register URL handler
    clipboardService.registerUrlHandler(_handleUrlDetected);
  }

  void _handleUrlDetected(String url) {
    // Remove any existing overlay
    _removeCurrentOverlay();

    // Create a new overlay entry
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: ClipboardUrlPrompt(url: url, onDismiss: _removeCurrentOverlay),
        ),
      ),
    );

    // Insert the overlay into the overlay context
    Overlay.of(context).insert(overlay);
    _currentOverlay = overlay;

    // Auto-dismiss after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (_currentOverlay == overlay) {
        _removeCurrentOverlay();
      }
    });
  }

  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  void dispose() {
    _removeCurrentOverlay();
  }
}

// Provider for the clipboard overlay manager
final clipboardOverlayManagerProvider =
    Provider.family<ClipboardOverlayManager, BuildContext>((ref, context) {
  final clipboardService = ref.read(clipboardMonitorServiceProvider);

  final manager = ClipboardOverlayManager(
    context: context,
    ref: ref,
    clipboardService: clipboardService,
  );

  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});

class ClipboardMonitorService {
  static final ClipboardMonitorService _instance = ClipboardMonitorService._();
  static ClipboardMonitorService get instance => _instance;

  ClipboardMonitorService._();

  void registerUrlHandler(Function(String) handler) {
    // Implementation
  }
}
