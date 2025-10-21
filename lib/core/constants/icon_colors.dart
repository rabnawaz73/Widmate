import 'package:flutter/material.dart';

/// WidMate App Icon Color Palette
class WidMateIconColors {
  WidMateIconColors._();

  // Primary Background Gradient
  static const Color primaryStart = Color(0xFF667eea);
  static const Color primaryEnd = Color(0xFF764ba2);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );

  // Play Button Gradient
  static const Color playStart = Color(0xFFff6b6b);
  static const Color playEnd = Color(0xFFee5a24);
  static const LinearGradient playGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [playStart, playEnd],
  );

  // Download Arrow Gradient
  static const Color downloadStart = Color(0xFF4ecdc4);
  static const Color downloadEnd = Color(0xFF44a08d);
  static const LinearGradient downloadGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [downloadStart, downloadEnd],
  );

  // Accent Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);

  // Background Colors
  static const Color black = Color(0xFF000000);
  static const Color grey900 = Color(0xFF212121);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey700 = Color(0xFF616161);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // App Theme Colors
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryStart,
    onPrimary: white,
    secondary: downloadStart,
    onSecondary: white,
    error: error,
    onError: white,
    surface: white,
    onSurface: black,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryStart,
    onPrimary: white,
    secondary: downloadStart,
    onSecondary: white,
    error: error,
    onError: white,
    surface: grey900,
    onSurface: white,
  );

  // Icon-specific colors
  static const Map<String, Color> iconColors = {
    'play': playStart,
    'download': downloadStart,
    'audio': white70,
    'video': white70,
    'background': primaryStart,
    'accent': white,
  };

  // Gradient definitions for different elements
  static const Map<String, LinearGradient> gradients = {
    'primary': primaryGradient,
    'play': playGradient,
    'download': downloadGradient,
  };
}
