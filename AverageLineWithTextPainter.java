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
      ..color = Colors.grey.shade300 // Color de fondo de la barra
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = const Color(0xFF2be4f3) // Color único de la barra de progreso
      ..style = PaintingStyle.fill;

    double cornerRadius = strokeHeight / 2; // Esquinas redondeadas suaves (no necesarias para el fondo y progreso con punta)

    // Dibuja el fondo de la barra con la misma forma de punta
    Path backgroundPath = Path()
      ..moveTo(0, size.height / 2 - strokeHeight / 2) // Comienza desde el borde izquierdo
      ..lineTo(size.width * average, size.height / 2 - strokeHeight / 2) // Dibuja la base del fondo hasta el ancho calculado

      // Punta (flecha) del fondo
      ..lineTo(size.width * average + 10, size.height / 2) // Dibuja la punta hacia el centro
      ..lineTo(size.width * average, size.height / 2 + strokeHeight / 2) // Baja al final de la barra

      ..lineTo(0, size.height / 2 + strokeHeight / 2) // Dibuja el borde inferior de la barra

      ..close(); // Cierra la forma

    // Dibuja el fondo de la barra
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Dibuja el progreso con punta (igual que el fondo)
    double progressWidth = size.width * average; // Calcula el ancho según el promedio
    progressWidth = progressWidth.clamp(0.0, size.width); // Asegura que no se exceda

    // Dibuja el fondo del progreso (barra con fondo normal)
    Path progressPath = Path()
      ..moveTo(0, size.height / 2 - strokeHeight / 2) // Comienza desde el borde izquierdo
      ..lineTo(progressWidth, size.height / 2 - strokeHeight / 2) // Dibuja el progreso hasta la posición deseada

      // Punta (flecha)
      ..lineTo(progressWidth + 10, size.height / 2) // Dibuja la punta hacia el centro
      ..lineTo(progressWidth, size.height / 2 + strokeHeight / 2) // Vuelve al final de la barra

      ..lineTo(0, size.height / 2 + strokeHeight / 2) // Dibuja el borde inferior de la barra

      ..close(); // Cierra la forma

    // Dibuja la barra de progreso con punta
    canvas.drawPath(progressPath, progressPaint);

    // Dibuja el porcentaje en el centro de la barra
    String percentageText = "${(average * 100).toStringAsFixed(0)}%";
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

    // Calcula la posición para centrar el texto
    double textX = (progressWidth - textPainter.width) / 2;
    double textY = (size.height - textPainter.height) / 2;

    // Dibuja el texto en la barra
    textPainter.paint(canvas, Offset(textX, textY));

    // Añadir una sombra difusa debajo de la barra
    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            0, size.height / 2 - strokeHeight / 2, size.width, strokeHeight),
        Radius.circular(cornerRadius),
      ),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Siempre repinta cuando el promedio cambia
  }
}
