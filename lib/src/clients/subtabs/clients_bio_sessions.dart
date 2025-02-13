import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/clients/custom_clients/bio_session_table.dart';
import 'package:path/path.dart';

import '../../../utils/translation_utils.dart';

class BioSessionSubTab extends StatefulWidget {
  final List<Map<String, String>> bioimpedanceData;
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic>? selectedClientData;

  const BioSessionSubTab({
    Key? key,
    required this.bioimpedanceData,
    required this.onClientTap,
    required this.selectedClientData,
  }) : super(key: key);

  @override
  _BioSessionSubTabState createState() => _BioSessionSubTabState();
}

class _BioSessionSubTabState extends State<BioSessionSubTab> {
  bool useSides = false;
  double numberOfFeatures = 6;
  bool _showBioSubTab = false;
  bool _showEvolutionSubTab = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.selectedClientData != null) {
                  Map<String, String> clientData = widget.selectedClientData!
                      .map((key, value) => MapEntry(key, value.toString()));
                  widget.onClientTap(clientData);
                  setState(() {
                    _showBioSubTab = true;
                    _showEvolutionSubTab = false;
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                height: screenHeight * 0.08,
                width: screenWidth * 0.08,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/back.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: screenWidth,
              padding: EdgeInsets.only(
                  bottom: screenHeight * 0.02,
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: BioSessionTableWidget(
                        bioimpedanceData: widget.bioimpedanceData,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircunferenciasWidget(),
                            SpiderChart(data: [90, 75, 90, 60, 85]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class SpiderChart extends StatelessWidget {
  final List<int> data;

  SpiderChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 0.25,
          MediaQuery.of(context).size.height * 0.25),
      painter: SpiderChartPainter(data,context),
    );
  }
}

class SpiderChartPainter extends CustomPainter {
  final List<int> data;
  final BuildContext context;

  SpiderChartPainter(this.data, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final int numAxes = data.length;
    final double radius = size.width / 2;

    // El centro del gráfico
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Ángulos de los ejes
    final double angleStep = 2 * pi / numAxes;

    // Dibujar los ejes
    for (int i = 0; i < numAxes; i++) {
      final double angle = angleStep * i;
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Dibujar las áreas (polígono)
    Path path = Path();
    for (int i = 0; i < numAxes; i++) {
      final double angle = angleStep * i;
      final int value = data[i];
      final double x = center.dx + (radius * (value / 100)) * cos(angle);
      final double y = center.dy + (radius * (value / 100)) * sin(angle);

      if (i == 0) {
        path.moveTo(x, y); // Iniciar el camino en el primer punto
      } else {
        path.lineTo(x, y); // Conectar los puntos
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    List<Color> circleColors = [
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
      Colors.transparent,
    ];

    // Dibujar los círculos de referencia
    const int levels = 6;
    for (int i = 1; i <= levels; i++) {
      double levelRadius = (size.width / 2) - (i * 25); // Radio decreciente
      // Usar un color diferente para cada círculo de referencia
      Paint circlePaint = Paint()
        ..color = circleColors[i - 1]
        ..style = PaintingStyle
            .stroke; // Aseguramos que sea solo un borde, no relleno

      canvas.drawCircle(center, levelRadius, circlePaint);
    }

    List<String> labelsText = [
      tr(context, "Hidratación sin grasa").toUpperCase(),
      tr(context, "Equilibrio hídrico").toUpperCase(),
      tr(context, "Imc").toUpperCase(),
      tr(context, "Masa grasa").toUpperCase(),
      tr(context, "Músculo").toUpperCase(),
      tr(context, "Esqueleto").toUpperCase(),
    ];

    // Dibujar las etiquetas
    for (int i = 0; i < numAxes; i++) {
      final double angle = angleStep * i;
      final double x = center.dx + (radius + 20) * cos(angle);
      final double y = center.dy + (radius + 20) * sin(angle);

      // Asignar la etiqueta de acuerdo al eje (i)
      String label = labelsText[i % labelsText.length];

      // Calcular el ángulo de la tangente (perpendicular al eje)
      double tangentAngle = angle + pi / 2; // 90 grados en radianes (π/2)

      // Configurar el estilo del texto
      TextSpan span = TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
        text: label,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // Dibujar el texto, centrado y rotado
      canvas.save();
      canvas.translate(x, y); // Mover al centro de la etiqueta
      canvas.rotate(tangentAngle); // Rotar el texto para que sea perpendicular
      tp.paint(
          canvas, Offset(-tp.width / 2, -tp.height / 2)); // Dibujar el texto
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CircunferenciasWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 0.25,
          MediaQuery.of(context).size.height * 0.25),
      painter: CircunferenciasPainter(),
    );
  }
}

class CircunferenciasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    // Lista de colores para las circunferencias
    List<Color> colores = [
      Colors.red,
      Colors.orange,
      Colors.lightGreenAccent,
      Colors.green,
      Colors.blue,
      Colors.white,
    ];

    // Dibujar 6 circunferencias con radios decrecientes
    for (int i = 0; i < colores.length; i++) {
      paint.color = colores[i];
      double radius = (size.width / 2) - (i * 25); // Radio decreciente
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // No es necesario repintar constantemente
  }
}
