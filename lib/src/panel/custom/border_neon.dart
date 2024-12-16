import 'package:flutter/material.dart';

class NeonBorderPainter extends CustomPainter {
  final Color neonColor;

  NeonBorderPainter({required this.neonColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(
          BlurStyle.solid, 2); // Efecto de resplandor hacia afuera

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect roundedRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(7));

    canvas.drawRRect(roundedRect, paint); // Dibuja el borde con resplandor
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
