import 'dart:async';

import 'package:flutter/material.dart';

class IndividualTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> programData; // Mantener el tipo como dynamic
  final Function(Map<String, dynamic>)
      onRowTap; // Callback con el tipo correcto

  const IndividualTableWidget(
      {super.key, required this.programData, required this.onRowTap});

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
                      image: row['image'] ?? '',
                      name: row['name'] ?? '',
                      frequency: (row['frequency'] is int)
                          ? row['frequency']
                          : int.tryParse(row['frequency'].toString()) ?? 0,
                      pulse: (row['pulse'] is int)
                          ? row['pulse']
                          : int.tryParse(row['pulse'].toString()) ?? 0,
                      rampa: (row['rampa'] is int)
                          ? row['rampa']
                          : int.tryParse(row['rampa'].toString()) ?? 0,
                      contraction: (row['contraction'] is int)
                          ? row['contraction']
                          : int.tryParse(row['contraction'].toString()) ?? 0,
                      pause: (row['pause'] is int)
                          ? row['pause']
                          : int.tryParse(row['pause'].toString()) ?? 0,
                      onTap: () {
                        widget.onRowTap(row); // Pasar el mapa completo
                      },
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
  final String? image; // Ruta de la imagen
  final String name;
  final int frequency;
  final int pulse;
  final int rampa;
  final int contraction;
  final int pause;
  final VoidCallback onTap;

  const DataRowWidget({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
    required this.frequency,
    required this.pulse,
    required this.rampa,
    required this.contraction,
    required this.pause,
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
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          isPressed = true;
        });

        _timer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              isPressed = false;
            });
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isPressed ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildImageCell(widget.image),
            // Mostrar la imagen si existe
            buildCell(widget.name, isNameColumn: true),
            // Estilo especial solo para la columna de nombre
            buildCell(widget.frequency.toString()),
            buildCell(widget.pulse.toString()),
            buildCell(widget.rampa.toString()),
            buildCell(widget.contraction.toString()),
            buildCell(widget.pause.toString()),
          ],
        ),
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
