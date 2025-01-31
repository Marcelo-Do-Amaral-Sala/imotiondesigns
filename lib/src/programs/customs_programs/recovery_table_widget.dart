import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';

class RecoveryTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> programData; // Mantener el tipo como dynamic

  const RecoveryTableWidget({super.key, required this.programData});

  @override
  _RecoveryTableWidgetState createState() => _RecoveryTableWidgetState();
}

class _RecoveryTableWidgetState extends State<RecoveryTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(context), // Encabezado fijo
        SizedBox(height: MediaQuery.of(context).size.height*0.01),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.programData.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      imagen: row['imagen'] ?? '',
                      nombre: row['nombre'] ?? '',
                      frecuencia: (row['frecuencia'] is double)
                          ? row['frecuencia']
                          : double.tryParse(row['frecuencia'].toString()) ?? 0.0,
                      pulso: (row['pulso'] is double)
                          ? row['pulso']
                          : double.tryParse(row['pulso'].toString()) ?? 0.0,
                      rampa: (row['rampa'] is double)
                          ? row['rampa']
                          : double.tryParse(row['rampa'].toString()) ?? 0.0,
                      contraccion: (row['contraccion'] is double)
                          ? row['contraccion']
                          : double.tryParse(row['contraccion'].toString()) ?? 0.0,
                      pausa: (row['pausa'] is double)
                          ? row['pausa']
                          : double.tryParse(row['pausa'].toString()) ?? 0.0,
                    ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.01),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCell(context, ''),
        buildCell(context,
          tr(context, 'Nombre').toUpperCase(),
        ),
        buildCell(context,
          tr(context, 'Frecuencia (Hz)').toUpperCase(),
        ),
        buildCell(context,
          tr(context, 'Pulso (ms)').toUpperCase(),
        ),
        buildCell(context,
          tr(context, 'Rampa').toUpperCase(),
        ),
        buildCell(context,
          tr(context, 'Contracción').toUpperCase(),
        ),
        buildCell(context,
          tr(context, 'Pausa').toUpperCase(),
        ),
      ],
    );
  }

  Widget buildCell(BuildContext context, String text, {bool isNameColumn = false}) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height *0.04,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.002,
          vertical: MediaQuery.of(context).size.height * 0.002,
        ),
        child: Align(
          alignment: Alignment.topCenter, // Alineamos el texto arriba
          child: Text(
            text,
            textAlign: TextAlign.center, // Alineación horizontal centrada
            style: TextStyle(
              color: isNameColumn
                  ? const Color.fromARGB(255, 3, 236,
                  244) // Color específico para la columna de nombre
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp, // Ajuste del tamaño de la fuente
            ),
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String? imagen; // Ruta de la imagen
  final String nombre;
  final double frecuencia;
  final double pulso;
  final double rampa;
  final double contraccion;
  final double pausa;

  const DataRowWidget({
    super.key,
    required this.imagen,
    required this.nombre,
    required this.frecuencia,
    required this.pulso,
    required this.rampa,
    required this.contraccion,
    required this.pausa,
  });

  @override
  _DataRowWidgetState createState() => _DataRowWidgetState();
}

class _DataRowWidgetState extends State<DataRowWidget> {
  bool isPressed = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPressed ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildImageCell(widget.imagen),
          // Mostrar la imagen si existe
          buildCell(widget.nombre, isNameColumn: true),
          // Estilo especial solo para la columna de nombre
          buildCell(formatNumber(widget.frecuencia)),
          buildCell(formatNumber(widget.pulso)),
          buildCell(formatNumber(widget.rampa)),
          buildCell(formatNumber(widget.contraccion)),
          buildCell(formatNumber(widget.pausa)),
        ],
      ),
    );
  }

  Widget buildCell(String text, {bool isNameColumn = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
          style: TextStyle(
            color: isNameColumn
                ? const Color.fromARGB(
                255, 3, 236, 244) // Color para la columna de nombre
                : Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold, // Ajuste del tamaño del texto
          ),
        ),
      ),
    );
  }

  Widget buildImageCell(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return buildCell(''); // Si no hay imagen, dejar vacío
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.001,
          vertical: MediaQuery.of(context).size.height * 0.001,
        ),
        child: Image.asset(
          imagePath,
          height: MediaQuery.of(context).size.height * 0.15, // Tamaño de la imagen
          fit: BoxFit.contain, // Asegurarse que la imagen se ajuste
        ),
      ),
    );
  }

  // Función para formatear los números, eliminando decimales si es un número entero
  String formatNumber(double value) {
    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}

