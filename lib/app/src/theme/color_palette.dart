import 'package:flutter/material.dart';

class ColorPalette {
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color tiktokBlack = Color(0xFF000000);
  static const Color instagramPink = Color(0xFFE4405F);
  static const Color facebookBlue = Color(0xFF1877F2);

  static Color withOpacityPreset(Color color, OpacityPreset preset) {
    switch (preset) {
      case OpacityPreset.subtle:
        return color.withOpacity(0.6);
      case OpacityPreset.medium:
        return color.withOpacity(0.8);
      case OpacityPreset.strong:
        return color.withOpacity(0.9);
    }
  }
}

enum OpacityPreset { subtle, medium, strong }
