import 'package:flutter/material.dart';

class ColorPalette {
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color tiktokBlack = Color(0xFF000000);
  static const Color instagramPink = Color(0xFFE4405F);
  static const Color facebookBlue = Color(0xFF1877F2);

  static Color withOpacityPreset(Color color, OpacityPreset preset) {
    switch (preset) {
      case OpacityPreset.subtle:
        return color.withAlpha(153);
      case OpacityPreset.medium:
        return color.withAlpha(204);
      case OpacityPreset.strong:
        return color.withAlpha(230);
    }
  }
}

enum OpacityPreset { subtle, medium, strong }
