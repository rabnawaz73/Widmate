import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharedContentService {
  // Singleton instance
  static final SharedContentService _instance = SharedContentService._internal();
  
  factory SharedContentService() {
    return _instance;
  }
  
  SharedContentService._internal();
  
  // Callback for when a URL is shared to the app
  Function(String url)? onUrlShared;
  
  // Register a handler for shared URLs
  void registerUrlHandler(Function(String url) handler) {
    onUrlShared = handler;
  }
  
  // Initialize the service to listen for shared content
  Future<void> init() async {
    debugPrint('SharedContentService initialized');
    try {
      final initialText = await ReceiveSharingIntent.getInitialText();
      if (initialText != null && initialText.isNotEmpty) {
        _handleSharedText(initialText);
      }
      ReceiveSharingIntent.getTextStream().listen((String text) {
        if (text.isNotEmpty) {
          _handleSharedText(text);
        }
      }, onError: (e) {
        debugPrint('ReceiveSharingIntent error: $e');
      });
    } catch (e) {
      debugPrint('ReceiveSharingIntent init failed: $e');
    }
  }
  
  @pragma('vm:never-inline')
  void _handleSharedText(String text) {
    if (_isValidUrl(text)) {
      if (onUrlShared != null) {
        onUrlShared!(text);
      }
    }
  }
  
  bool _isValidUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }
}
