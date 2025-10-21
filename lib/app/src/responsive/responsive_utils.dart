import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  /// Breakpoints for different device sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if the current device is a mobile device
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the current device is a tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the current device is a desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get the appropriate padding based on device size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get the appropriate font size for headings based on device size
  static double getResponsiveHeadingSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  /// Get the appropriate font size for body text based on device size
  static double getResponsiveBodySize(BuildContext context) {
    if (isMobile(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  /// Get the appropriate icon size based on device size
  static double getResponsiveIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  /// Get the appropriate number of grid columns based on device size
  static int getResponsiveGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Get the appropriate width for a card based on device size
  static double getResponsiveCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return width * 0.9;
    } else if (isTablet(context)) {
      return width * 0.45;
    } else {
      return width * 0.3;
    }
  }

  /// Get the appropriate height for a card based on device size
  static double getResponsiveCardHeight(BuildContext context) {
    if (isMobile(context)) {
      return 180.0;
    } else if (isTablet(context)) {
      return 200.0;
    } else {
      return 220.0;
    }
  }

  /// Get the appropriate spacing between items based on device size
  static double getResponsiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  /// Get a responsive widget based on the device size
  static Widget getResponsiveWidget({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}