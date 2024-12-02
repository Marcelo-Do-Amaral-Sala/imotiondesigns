import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final double progress; // El progreso de 1.0 a 0.0 (completo a vacío)
  final double strokeHeight; // Altura de la barra

  LinePainter({required this.progress, required this.strokeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300 // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = Colors.lightGreenAccent.shade400 // Color verde para el relleno
      ..style = PaintingStyle.fill;

    // Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
      backgroundPaint,
    );

    // Dibuja el progreso (barra verde)
    double progressWidth = size.width * progress; // Calcula el ancho basado en el progreso
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el progreso cambia
  }
}

class LinePainter2 extends CustomPainter {
  final double progress; // El progreso de 1.0 a 0.0 (completo a vacío)
  final double strokeHeight; // Altura de la barra

  LinePainter2({required this.progress, required this.strokeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300 // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = Colors.red// Color verde para el relleno
      ..style = PaintingStyle.fill;

    // Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
      backgroundPaint,
    );

    // Dibuja el progreso (barra verde)
    double progressWidth = size.width * progress; // Calcula el ancho basado en el progreso
    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el progreso cambia
  }
}
