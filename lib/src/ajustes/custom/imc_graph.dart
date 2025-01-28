import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IMCGaugePainter extends CustomPainter {
  final double imcValue; // Valor del IMC para posicionar la barra indicadora

  IMCGaugePainter({required this.imcValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70;

    final width = size.width;
    final height = size.height;

    // Define los colores para las categorías
    final colors = [
      Colors.purple,    // Desnutrición
      Colors.blue,      // Bajo peso
      Colors.green,     // Normal
      Colors.yellow,    // Sobrepeso
      Colors.orange,    // Obesidad
      Colors.red,       // Obesidad marcada
      Colors.red[900]!, // Obesidad mórbida
    ];

    // Define los rangos de IMC
    final ranges = [
      '<16',
      '17-20',
      '21-24',
      '25-29',
      '30-34',
      '35-39',
      '>40'
    ];

    final startAngle = pi; // Inicia en 180 grados (semicírculo)
    final sweepAngle = pi; // Longitud total del arco

    // Dibuja las franjas de colores
    for (int i = 0; i < colors.length; i++) {
      final rangeSweep = sweepAngle / colors.length; // Dividir el arco en partes iguales
      paint.color = colors[i];

      // Dibuja el arco
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(width / 2, height),
          width: width,
          height: height * 2,
        ),
        startAngle + i * rangeSweep,
        rangeSweep,
        false,
        paint,
      );

      // Calcular posición del texto en la tangente de la franja
      final textAngle = startAngle + (i + 0.5) * rangeSweep;
      final textRadius = height * 1.2; // Radio para colocar el texto fuera del arco
      final textOffset = Offset(
        width / 2 + cos(textAngle) * textRadius, // Coordenada X
        height + sin(textAngle) * textRadius,   // Coordenada Y
      );

      // Dibujar el texto (baremo)
      final textPainter = TextPainter(
        text: TextSpan(
          text: ranges[i],
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black, // Color del texto
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Ajustar la posición del texto para centrarlo en su tangente
      final adjustedOffset = Offset(
        textOffset.dx - textPainter.width / 2,  // Centrar horizontalmente
        textOffset.dy - textPainter.height / 2, // Centrar verticalmente
      );

      textPainter.paint(canvas, adjustedOffset);
    }

    // Dibujar el indicador (barra)
    final indicatorPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    // Normalización del IMC para el indicador
    final normalizedIMC = imcValue.clamp(16, 40); // Asegurar IMC dentro del rango
    final indicatorAngle = startAngle +
        ((normalizedIMC - 16) / (40 - 16)) * sweepAngle; // Rango de 16 a 40

    final indicatorLength = height;
    final indicatorStart = Offset(
      width / 2 + cos(indicatorAngle) * indicatorLength * 0.1,
      height + sin(indicatorAngle) * indicatorLength * 0.1,
    );
    final indicatorEnd = Offset(
      width / 2 + cos(indicatorAngle) * indicatorLength,
      height + sin(indicatorAngle) * indicatorLength,
    );

    canvas.drawLine(indicatorStart, indicatorEnd, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
