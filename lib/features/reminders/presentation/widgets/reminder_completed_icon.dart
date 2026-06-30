import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Ícone de concluído do Figma `15:8056` — círculo com check em outline.
class ReminderCompletedIcon extends StatelessWidget {
  const ReminderCompletedIcon({
    this.size = 20,
    this.color = AppColors.success,
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ReminderCompletedIconPainter(color: color),
    );
  }
}

class _ReminderCompletedIconPainter extends CustomPainter {
  _ReminderCompletedIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 20;
    final stroke = 1.66667 * scale;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      _circlePath(scale),
      paint,
    );
    canvas.drawPath(
      _checkPath(scale),
      paint,
    );
  }

  Path _circlePath(double scale) {
    return Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(10 * scale, 10 * scale),
          radius: 8.33333 * scale,
        ),
      );
  }

  Path _checkPath(double scale) {
    return Path()
      ..moveTo(7.5 * scale, 10 * scale)
      ..lineTo(9.16667 * scale, 11.66667 * scale)
      ..lineTo(12.5 * scale, 8.33325 * scale);
  }

  @override
  bool shouldRepaint(covariant _ReminderCompletedIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
