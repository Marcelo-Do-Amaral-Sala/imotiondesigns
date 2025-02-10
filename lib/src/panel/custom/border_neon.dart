import 'package:flutter/material.dart';

class NeonBorderPainter extends CustomPainter {
  final Color neonColor;
  final double opacity;
  final double screenWidth; // Se pasa el ancho de la pantalla

  NeonBorderPainter({
    required this.neonColor,
    required this.screenWidth,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = neonColor.withOpacity(opacity) // Aplica la opacidad
      ..style = PaintingStyle.stroke
      ..strokeWidth = screenWidth * 0.002 // 🔹 Se ajusta al ancho de pantalla
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0); // Efecto de resplandor

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect roundedRect = RRect.fromRectAndRadius(rect, const Radius.circular(7));

    canvas.drawRRect(roundedRect, paint); // Dibuja el borde con resplandor
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
