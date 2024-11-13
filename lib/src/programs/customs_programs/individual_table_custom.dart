import 'dart:async';

import 'package:flutter/material.dart';

class IndividualTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> programData; // Mantener el tipo como dynamic

  const IndividualTableWidget({super.key, required this.programData});

  @override
  _IndividualTableWidgetState createState() => _IndividualTableWidgetState();
}

class _IndividualTableWidgetState extends State<IndividualTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.programData.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      imagen: row['imagen'] ?? '',
                      nombre: row['nombre'] ?? '',
                      frecuencia: (row['frecuencia'] is int)
                          ? row['frecuencia']
                          : int.tryParse(row['frecuencia'].toString()) ?? 0,
                      pulso: (row['pulso'] is int)
                          ? row['pulso']
                          : int.tryParse(row['pulso'].toString()) ?? 0,
                      rampa: (row['rampa'] is int)
                          ? row['rampa']
                          : int.tryParse(row['rampa'].toString()) ?? 0,
                      contraccion: (row['contraccion'] is int)
                          ? row['contraccion']
                          : int.tryParse(row['contraccion'].toString()) ?? 0,
                      pausa: (row['pausa'] is int)
                          ? row['pausa']
                          : int.tryParse(row['pausa'].toString()) ?? 0,
                    ),
                    const SizedBox(height: 10), // Espaciado entre filas
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCell(''),
        buildCell('NOMBRE'),
        buildCell('FRECUENCIA (Hz)'),
        buildCell('PULSO (ms)'),
        buildCell('RAMPA'),
        buildCell('CONTRACCIÓN'),
        buildCell('PAUSA'),
      ],
    );
  }

  Widget buildCell(String text, {bool isNameColumn = false}) {
    return Expanded(
      child: Container(
        height: 40, // Establecemos una altura fija para las celdas
        padding: const EdgeInsets.all(2.0),
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
              fontSize: 15, // Ajuste del tamaño de la fuente
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
  final int frecuencia;
  final int pulso;
  final int rampa;
  final int contraccion;
  final int pausa;

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
          buildCell(widget.frecuencia.toString()),
          buildCell(widget.pulso.toString()),
          buildCell(widget.rampa.toString()),
          buildCell(widget.contraccion.toString()),
          buildCell(widget.pausa.toString()),
        ],
      ),
    );
  }

  Widget buildCell(String text, {bool isNameColumn = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
          style: TextStyle(
            color: isNameColumn
                ? const Color.fromARGB(255, 3, 236, 244)
                : Colors.white, // Texto negro solo para la columna de nombre
            fontSize: 15,
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
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          imagePath,
          width: 100, // Tamaño de la imagen
          height: 100, // Tamaño de la imagen
          fit: BoxFit.contain, // Asegurarse que la imagen se ajuste
        ),
      ),
    );
  }
}
