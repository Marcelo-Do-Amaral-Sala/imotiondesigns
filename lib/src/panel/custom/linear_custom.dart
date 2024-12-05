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

    double cornerRadius = strokeHeight / 5; // El radio de las esquinas redondeadas

    // Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      backgroundPaint,
    );

    // Dibuja el progreso (barra verde)
    double progressWidth = size.width * progress; // Calcula el ancho basado en el progreso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
        Radius.circular(cornerRadius),
      ),
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
      ..color = Colors.red // Color rojo para el relleno
      ..style = PaintingStyle.fill;

    double cornerRadius = strokeHeight / 5; // El radio de las esquinas redondeadas

    // Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      backgroundPaint,
    );

    // Dibuja el progreso (barra roja)
    double progressWidth = size.width * progress; // Calcula el ancho basado en el progreso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el progreso cambia
  }
}
