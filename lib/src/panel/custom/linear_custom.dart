import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final double progress2; // El progreso de 1.0 a 0.0 (completo a vacío)
  final double strokeHeight; // Altura de la barra

  LinePainter({required this.progress2, required this.strokeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300 // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = Colors.lightGreenAccent.shade400 // Color verde para el relleno
      ..style = PaintingStyle.fill;

    double cornerRadius =
        strokeHeight / 5; // El radio de las esquinas redondeadas

// Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      backgroundPaint,
    );

// Dibuja el progreso (barra verde)
    double progressWidth =
        size.width * progress2; // Calcula el ancho basado en el progreso
    progressWidth = progressWidth.clamp(
        0.0, size.width); // Asegura que no supere el ancho de la barra

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
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
  final double progress3; // El progreso de 1.0 a 0.0 (completo a vacío)
  final double strokeHeight; // Altura de la barra

  LinePainter2({required this.progress3, required this.strokeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300 // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = Colors.red // Color rojo para el relleno
      ..style = PaintingStyle.fill;

    double cornerRadius =
        strokeHeight / 5; // El radio de las esquinas redondeadas

    // Dibuja la barra de fondo (inicialmente vacía)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      backgroundPaint,
    );

// Dibuja el progreso (barra roja)
    double progressWidth =
        size.width * progress3; // Calcula el ancho basado en el progreso
    progressWidth = progressWidth.clamp(
        0.0, size.width); // Asegura que no supere el ancho de la barra

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, size.height / 2 - strokeHeight / 2, progressWidth, strokeHeight),
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

class AverageLineWithTextPainter extends CustomPainter {
  final double average; // El valor del promedio (de 0.0 a 1.0)
  final double strokeHeight; // Altura de la barra
  final TextStyle textStyle; // Estilo del texto (para el porcentaje)

  AverageLineWithTextPainter({
    required this.average,
    required this.strokeHeight,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.transparent // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = const Color(0xFF2be4f3) // Color único de la barra de progreso
      ..style = PaintingStyle.fill;

    // Dibuja la barra de fondo con una punta (flecha) en el final
    Path backgroundPath = Path()
      ..moveTo(0, size.height / 2 - strokeHeight / 2) // Comienza desde el borde izquierdo
      ..lineTo(size.width, size.height / 2 - strokeHeight / 2) // Dibuja la base del fondo hasta el ancho completo
      ..lineTo(size.width + 10, size.height / 2) // Dibuja la punta hacia el centro
      ..lineTo(size.width, size.height / 2 + strokeHeight / 2) // Baja al final de la barra
      ..lineTo(0, size.height / 2 + strokeHeight / 2) // Dibuja el borde inferior de la barra
      ..close(); // Cierra la forma

    // Dibuja el fondo de la barra
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Dibuja el progreso con la misma forma de punta (flecha)
    double progressWidth = size.width * average; // Calcula el ancho según el promedio
    progressWidth = progressWidth.clamp(0.0, size.width); // Asegura que no se exceda

    // Dibuja el fondo del progreso (barra con fondo normal)
    Path progressPath = Path()
      ..moveTo(0, size.height / 2 - strokeHeight / 2) // Comienza desde el borde izquierdo
      ..lineTo(progressWidth, size.height / 2 - strokeHeight / 2) // Dibuja el progreso hasta el ancho deseado
      ..lineTo(progressWidth + 10, size.height / 2) // Dibuja la punta hacia el centro
      ..lineTo(progressWidth, size.height / 2 + strokeHeight / 2) // Vuelve al final de la barra de progreso
      ..lineTo(0, size.height / 2 + strokeHeight / 2) // Dibuja el borde inferior de la barra
      ..close(); // Cierra la forma

    // Dibuja la barra de progreso con la misma forma de punta
    canvas.drawPath(progressPath, progressPaint);

    // Dibuja el porcentaje en el centro de la barra
    String percentageText = "${(average.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%";
    TextSpan textSpan = TextSpan(
      text: percentageText,
      style: textStyle.copyWith(color: Colors.white), // Texto blanco
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    // La posición del texto debe estar justo a la derecha de la barra de progreso
    double textX = progressWidth + 12;  // Desplazar el texto a la derecha de la barra
    double textY = (size.height - textPainter.height) / 2;

    // Si el porcentaje es 100%, el texto debe salir fuera de la barra
    if (average == 1.0) {
      textX += 10; // Desplazar aún más a la derecha
    }

    // Dibuja el texto en la posición calculada
    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el promedio cambia
  }
}





