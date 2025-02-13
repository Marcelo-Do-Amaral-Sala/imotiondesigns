import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IMCLinearGaugePainter extends CustomPainter {
  final double imcValue;

  IMCLinearGaugePainter({required this.imcValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 1.5; // Aumentar el largo
    final height = size.height * 0.9;

    // Pintura del contorno
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = width * 0.005; // Borde más fino

    // Pintura del fondo de la barra
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey[300]!;

    // Colores de las categorías
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.yellowAccent,
      Colors.orange,
    ];

    // Rango de valores IMC
    final imcRanges = [
      0.0,    // Inicio
      18.5,   // Bajo peso
      25.0,   // Normal
      30.0,   // Sobrepeso
      40.0,   // Obesidad
    ];

    // Cantidad de segmentos
    final numSegments = colors.length;
    final segmentWidth = width / numSegments;

    // Dibujar el fondo de la barra
    final barRect = Rect.fromLTWH(0, height / 3, width, height / 3);
    canvas.drawRect(barRect, backgroundPaint);

    double currentX = 0;
    for (int i = 0; i < numSegments; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];

      final segmentRect = Rect.fromLTWH(currentX, height / 3, segmentWidth, height / 3);
      canvas.drawRect(segmentRect, paint);

      currentX += segmentWidth;
    }

    // Dibujar el contorno de la barra
    canvas.drawRect(barRect, borderPaint);

    // Calcular la posición del indicador según el IMC
    double indicatorX = 0.0;
    if (imcValue < imcRanges[1]) {
      indicatorX = 0;
    } else if (imcValue > imcRanges.last) {
      indicatorX = width - 5;
    } else {
      for (int i = 0; i < imcRanges.length - 1; i++) {
        if (imcValue >= imcRanges[i] && imcValue < imcRanges[i + 1]) {
          double rangeStart = imcRanges[i];
          double rangeEnd = imcRanges[i + 1];
          double segmentStartX = (i * segmentWidth);
          double segmentEndX = ((i + 1) * segmentWidth);
          indicatorX = segmentStartX + ((imcValue - rangeStart) / (rangeEnd - rangeStart)) * (segmentEndX - segmentStartX);
          break;
        }
      }
    }

    // Pintura para el indicador del IMC
    final indicatorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    // Dibujar el indicador en la posición calculada
    canvas.drawLine(
      Offset(indicatorX, height / height*0.01),
      Offset(indicatorX, height / 1.5),
      indicatorPaint..strokeWidth = width*0.01,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CircleFillPainter extends CustomPainter {
  final double progress;

  CircleFillPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint fillPaint = Paint()
      ..color = const Color(0xFF2be4f3)
      ..style = PaintingStyle.fill;

    final double radius = size.width / 2;
    Offset center = size.center(Offset.zero);

    // Dibujar el círculo de fondo
    canvas.drawCircle(center, radius, strokePaint);

    // Dibujar la parte rellena del progreso
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, -pi / 2, sweepAngle, true, fillPaint);

    if (progress >= 1.0) {
      // Dibujar icono de tick cuando el progreso sea 100%
      final Paint tickPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final double tickSize = radius * 0.8; // Tamaño del tick en relación al radio del círculo

      // Coordenadas del tick (✓), centrado dentro del círculo
      Offset start = Offset(center.dx - tickSize * 0.3, center.dy + tickSize * 0.1);
      Offset mid = Offset(center.dx - tickSize * 0.1, center.dy + tickSize * 0.3);
      Offset end = Offset(center.dx + tickSize * 0.3, center.dy - tickSize * 0.2);

      // Dibujar el tick
      Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(end.dx, end.dy);

      canvas.drawPath(path, tickPaint);
    } else {
      // Mostrar porcentaje mientras no haya terminado
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${(progress * 100).toInt()}%",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CircleFillPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}





