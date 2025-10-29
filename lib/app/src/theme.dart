import 'package:flutter/material.dart';

// App theme configuration
class AppTheme {
  // --- Colors ---
  static const Color _primaryColor = Color(0xFFFA5805);
  static const Color _secondaryColor = Color(0xFF3D3D3D);
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _surfaceColor = Color(0xFF1E1E1E);
  static const Color _textColor = Color(0xFFFFFFFF);
  static const Color _secondaryTextColor = Color(0xFFBDBDBD);
  static const Color _errorColor = Color(0xFFCF6679);

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        background: _backgroundColor,
        error: _errorColor,
        onPrimary: _textColor,
        onSecondary: _textColor,
        onSurface: _textColor,
        onBackground: _textColor,
        onError: _textColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _surfaceColor,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: _primaryColor,
          foregroundColor: _textColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _secondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _textColor),
        bodyMedium: TextStyle(color: _secondaryTextColor),
        titleLarge: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // --- Light Theme ---
  // (We can define a light theme here if needed in the future)
  static ThemeData get lightTheme {
    // For now, let's just make it a simple light theme
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
    );
  }

  // Helper method to create a theme based on brightness and seed color
  static ThemeData createTheme(Color seedColor, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return darkTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      );
    } else {
      return lightTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
      );
    }
  }
}
