import 'package:flutter/material.dart';
import 'package:widmate/core/constants/icon_colors.dart';

/// WidMate App Icon Implementation
class WidMateIcon {
  WidMateIcon._();

  /// Get the app icon as a widget
  static Widget getAppIcon({
    double size = 64.0,
    Color? backgroundColor,
    bool showGradient = true,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: showGradient ? WidMateIconColors.primaryGradient : null,
        color: backgroundColor,
        border: Border.all(
          color: WidMateIconColors.white,
          width: size * 0.02,
        ),
      ),
      child: CustomPaint(
        painter: WidMateIconPainter(size: size),
      ),
    );
  }

  /// Get the app icon as PNG
  static Widget getAppIconPng({
    double size = 64.0,
    Color? color,
  }) {
    return Image.asset(
      'assets/icons/app_icon.png',
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }

  /// Get the app icon for different contexts
  static Widget getContextualIcon({
    required BuildContext context,
    double size = 64.0,
    bool isDark = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return getAppIcon(
      size: size,
      backgroundColor:
          isDarkMode ? WidMateIconColors.grey900 : WidMateIconColors.white,
      showGradient: true,
    );
  }
}

/// Custom painter for the WidMate app icon
class WidMateIconPainter extends CustomPainter {
  final double size;

  WidMateIconPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint();
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // Draw background circle
    paint.color = WidMateIconColors.primaryStart;
    canvas.drawCircle(center, radius, paint);

    // Draw play button (triangle)
    final playPath = Path();
    final playSize = size * 0.3;
    final playLeft = center.dx - playSize * 0.6;
    final playTop = center.dy - playSize * 0.5;
    final playBottom = center.dy + playSize * 0.5;
    final playRight = center.dx + playSize * 0.4;

    playPath.moveTo(playLeft, playTop);
    playPath.lineTo(playRight, center.dy);
    playPath.lineTo(playLeft, playBottom);
    playPath.close();

    paint.color = WidMateIconColors.playStart;
    canvas.drawPath(playPath, paint);

    // Draw download arrow
    final arrowSize = size * 0.15;
    final arrowX = center.dx + playSize * 0.8;
    final arrowY = center.dy;

    paint.color = WidMateIconColors.downloadStart;
    paint.strokeWidth = size * 0.03;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    // Arrow lines
    canvas.drawLine(
      Offset(arrowX, arrowY - arrowSize),
      Offset(arrowX, arrowY + arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(arrowX - arrowSize * 0.5, arrowY - arrowSize * 0.5),
      Offset(arrowX, arrowY - arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(arrowX + arrowSize * 0.5, arrowY - arrowSize * 0.5),
      Offset(arrowX, arrowY - arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(arrowX - arrowSize * 0.5, arrowY + arrowSize * 0.5),
      Offset(arrowX, arrowY + arrowSize),
      paint,
    );
    canvas.drawLine(
      Offset(arrowX + arrowSize * 0.5, arrowY + arrowSize * 0.5),
      Offset(arrowX, arrowY + arrowSize),
      paint,
    );

    // Draw audio waves
    final waveY = center.dy + size * 0.25;
    final waveX = center.dx - size * 0.3;
    final waveWidth = size * 0.2;

    paint.color = WidMateIconColors.white70;
    paint.strokeWidth = size * 0.02;

    // Wave 1
    canvas.drawLine(
      Offset(waveX, waveY),
      Offset(waveX + waveWidth, waveY - size * 0.05),
      paint,
    );
    canvas.drawLine(
      Offset(waveX + waveWidth, waveY - size * 0.05),
      Offset(waveX + waveWidth * 2, waveY + size * 0.05),
      paint,
    );

    // Wave 2
    paint.color = WidMateIconColors.white54;
    canvas.drawLine(
      Offset(waveX, waveY + size * 0.05),
      Offset(waveX + waveWidth, waveY),
      paint,
    );
    canvas.drawLine(
      Offset(waveX + waveWidth, waveY),
      Offset(waveX + waveWidth * 2, waveY + size * 0.1),
      paint,
    );

    // Wave 3
    paint.color = WidMateIconColors.white30;
    canvas.drawLine(
      Offset(waveX, waveY + size * 0.1),
      Offset(waveX + waveWidth, waveY + size * 0.05),
      paint,
    );
    canvas.drawLine(
      Offset(waveX + waveWidth, waveY + size * 0.05),
      Offset(waveX + waveWidth * 2, waveY + size * 0.15),
      paint,
    );

    // Draw video frame corners
    final cornerSize = size * 0.02;
    paint.color = WidMateIconColors.white70;
    paint.style = PaintingStyle.fill;

    // Top-left corner
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - size * 0.35,
        center.dy - size * 0.35,
        cornerSize,
        cornerSize,
      ),
      paint,
    );

    // Top-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + size * 0.33,
        center.dy - size * 0.35,
        cornerSize,
        cornerSize,
      ),
      paint,
    );

    // Bottom-left corner
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - size * 0.35,
        center.dy + size * 0.33,
        cornerSize,
        cornerSize,
      ),
      paint,
    );

    // Bottom-right corner
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + size * 0.33,
        center.dy + size * 0.33,
        cornerSize,
        cornerSize,
      ),
      paint,
    );

    // Draw "W" initial
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'W',
        style: TextStyle(
          color: WidMateIconColors.white,
          fontSize: size * 0.15,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + size * 0.25,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
