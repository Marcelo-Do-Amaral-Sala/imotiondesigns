import 'package:flutter/material.dart';
import 'dart:math';

class CirclePainter extends CustomPainter {
  final double progress; // El progreso de 0.0 a 1.0
  final double strokeWidth; // El grosor del borde

  CirclePainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = Colors.transparent // Borde de fondo
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint fillPaint = Paint()
      ..color = Colors.lightGreenAccent.shade400 // Color verde para el relleno
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double radius = size.width / 2; // Radio del círculo

    // Dibuja el círculo de fondo
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, circlePaint);

    // Calcula el ángulo máximo que se debe llenar (progreso)
    double angle = 2 * pi * progress;

    // Dibuja el borde verde a medida que avanza el progreso
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius);
    canvas.drawArc(rect, -pi / 2, angle, false, fillPaint); // Comienza desde el ángulo de las 12 en punto
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el progreso cambia
  }
}
