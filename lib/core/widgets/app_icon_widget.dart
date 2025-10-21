import 'package:flutter/material.dart';
import 'package:widmate/core/widgets/icon_implementation.dart';

/// A widget that displays the WidMate app icon
class AppIconWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final BoxFit fit;

  const AppIconWidget({
    super.key,
    this.size = 64.0,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: WidMateIcon.getAppIcon(
        size: size,
        backgroundColor: color,
      ),
    );
  }
}

/// A simple app icon widget for small sizes (like notifications)
class AppIconSmall extends StatelessWidget {
  final double size;
  final Color? color;

  const AppIconSmall({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: color != null
              ? [color!, color!.withValues(alpha: 0.8)]
              : [
                  const Color(0xFF8B5CF6), // Purple
                  const Color(0xFF7C3AED), // Darker purple
                ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
