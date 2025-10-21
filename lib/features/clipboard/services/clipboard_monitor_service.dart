import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardMonitorService {
  // Singleton instance
  static final ClipboardMonitorService _instance = ClipboardMonitorService._internal();
  
  factory ClipboardMonitorService() {
    return _instance;
  }
  
  ClipboardMonitorService._internal();
  
  // Timer for polling the clipboard
  Timer? _clipboardTimer;
  
  // Last detected clipboard content
  String? _lastClipboardContent;
  
  // Callback for when a URL is detected in clipboard
  Function(String url)? onUrlDetected;
  
  // List of supported video platforms
  final List<String> _supportedPlatforms = [
    'youtube.com', 'youtu.be',
    'tiktok.com',
    'instagram.com',
    'facebook.com', 'fb.watch',
    'twitter.com', 'x.com',
  ];
  
  // Initialize the clipboard monitoring service
  void init({Duration checkInterval = const Duration(seconds: 2)}) {
    // Start polling the clipboard
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer.periodic(checkInterval, (_) => _checkClipboard());
    
    // Initial check
    _checkClipboard();
  }
  
  // Stop monitoring the clipboard
  void dispose() {
    stop();
  }
  
  // Stop monitoring the clipboard
  void stop() {
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
  }
  
  // Set the check interval
  void setCheckInterval(Duration interval) {
    // Restart timer with new interval
    if (_clipboardTimer != null) {
      _clipboardTimer!.cancel();
      _clipboardTimer = Timer.periodic(interval, (_) => _checkClipboard());
    }
  }
  
  // Check clipboard for new content
  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text;
      
      // If clipboard is empty or unchanged, do nothing
      if (clipboardText == null || clipboardText.isEmpty || clipboardText == _lastClipboardContent) {
        return;
      }
      
      // Update last clipboard content
      _lastClipboardContent = clipboardText;
      
      // Check if the clipboard content is a supported URL
      if (_isSupportedVideoUrl(clipboardText) && onUrlDetected != null) {
        onUrlDetected!(clipboardText);
      }
    } catch (e) {
      debugPrint('Error checking clipboard: $e');
    }
  }
  
  // Check if the URL is from a supported video platform
  bool _isSupportedVideoUrl(String text) {
    // Basic URL validation
    if (!text.startsWith('http://') && !text.startsWith('https://') && !text.startsWith('www.')) {
      return false;
    }
    
    // Check if URL contains any supported platform domain
    return _supportedPlatforms.any((platform) => text.contains(platform));
  }
  
  // Register a callback for when a URL is detected
  void registerUrlHandler(Function(String url) handler) {
    onUrlDetected = handler;
  }
}