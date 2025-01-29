import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IMCGaugePainter extends CustomPainter {
  final double imcValue; // Valor del IMC para posicionar el indicador

  IMCGaugePainter({required this.imcValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Pintura del contorno grisáceo
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey
      ..strokeWidth = 80; // Grosor del contorno

    // Pintura del arco principal
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70; // Grosor del arco principal

    // Colores de las categorías (basados en la imagen)
    final colors = [
      Colors.blue, // Peso bajo
      Colors.green, // Peso normal
      Colors.yellowAccent, // Sobrepeso
      Colors.orange, // Obesidad leve
      Colors.red, // Obesidad media
      Colors.red[900]!, // Obesidad mórbida
    ];

    // Rangos de IMC y sus límites (basados en la imagen)
    final ranges = [
      {'min': 0.0, 'max': 18.5}, // Peso bajo
      {'min': 18.5, 'max': 25}, // Peso normal
      {'min': 25, 'max': 30}, // Sobrepeso
      {'min': 30, 'max': 35}, // Obesidad leve
      {'min': 35, 'max': 40}, // Obesidad media
      {'min': 40, 'max': 100}, // Obesidad mórbida
    ];

    // Etiquetas de texto para los rangos
    final labels = [
      '<18.5',
      '18.5-25',
      '25-30',
      '30-35',
      '35-40',
      '>40',
    ];

    final startAngle = pi; // Inicia a 180 grados
    final sweepAngle = pi; // Longitud total del arco
    final segmentAngle = sweepAngle / ranges.length; // Ángulo de cada franja

    // Dibuja el contorno grisáceo
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(width / 2, height),
        width: width,
        height: height * 2,
      ),
      startAngle,
      sweepAngle,
      false,
      borderPaint,
    );

    double currentAngle = startAngle;

    for (int i = 0; i < ranges.length; i++) {
      // Pintar el arco del rango
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(width / 2, height),
          width: width,
          height: height * 2,
        ),
        currentAngle,
        segmentAngle,
        false,
        paint,
      );

// Posicionar el texto en la parte superior de la franja
      final textAngle = currentAngle + segmentAngle / 2;
      final textRadius = height * 1.15; // Aumentar el radio para subir el texto

// Calcular la posición exacta del texto en la parte superior del arco
      final textX = width / 2 + cos(textAngle) * textRadius;
      final textY = height + sin(textAngle) * textRadius;

// Guardar el estado del canvas
      canvas.save();

// Mover el canvas al punto donde irá el texto
      canvas.translate(textX, textY);

// NO ROTAR el canvas para que el texto quede horizontal

// Dibujar el texto centrado en la posición
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        -textPainter.width / 1.8, // Centrar horizontalmente
        -textPainter.height / 2.5, // Ajustar verticalmente para alinearlo bien
      );
      textPainter.paint(canvas, textOffset);

// Restaurar el estado del canvas
      canvas.restore();



      // Avanzar al siguiente segmento
      currentAngle += segmentAngle;
    }

    // Indicador con forma de flecha precisa
    final indicatorPaint = Paint()..color = Colors.black;

    // Calcular el ángulo exacto del indicador según el IMC
    double calculateIndicatorAngle(double imc) {
      for (int i = 0; i < ranges.length; i++) {
        final range = ranges[i];
        if (imc >= range['min']! && imc <= range['max']!) {
          final normalizedValue =
              (imc - range['min']!) / (range['max']! - range['min']!);
          return startAngle + i * segmentAngle + normalizedValue * segmentAngle;
        }
      }
      return startAngle; // Valor por defecto si el IMC no está en el rango
    }

    final indicatorAngle = calculateIndicatorAngle(imcValue);

    final indicatorLength = height * 0.85; // Longitud de la flecha
    final arrowWidth = 6.0; // Ancho reducido para mayor precisión

    // Puntos de la flecha precisa
    final tip = Offset(
      width / 2 + cos(indicatorAngle) * indicatorLength,
      height + sin(indicatorAngle) * indicatorLength,
    );
    final left = Offset(
      width / 2 + cos(indicatorAngle - pi / 2) * arrowWidth,
      height + sin(indicatorAngle - pi / 2) * arrowWidth,
    );
    final right = Offset(
      width / 2 + cos(indicatorAngle + pi / 2) * arrowWidth,
      height + sin(indicatorAngle + pi / 2) * arrowWidth,
    );

    // Dibuja la flecha precisa
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(path, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
