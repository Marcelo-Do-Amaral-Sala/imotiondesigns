import 'dart:async';

import 'package:flutter/material.dart';

class LicenciaTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data; // Mantener el tipo como dynamic
  final Function(Map<String, dynamic>) onRowTap; // Callback con el tipo correcto

  const LicenciaTableWidget({super.key, required this.data, required this.onRowTap});

  @override
  _LicenciaTableWidgetState createState() => _LicenciaTableWidgetState();
}

class _LicenciaTableWidgetState extends State<LicenciaTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        const SizedBox(height: 10), // Espaciado entre encabezado y filas
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.data.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      mci: (row['mci'] is int) ? row['mci'] : int.tryParse(row['mci'].toString()) ?? 0,
                      type: row['type'] ?? '',
                      status: row['status'] ?? '',
                      onTap: () {
                        widget.onRowTap(row); // Pasar el mapa completo
                      },
                    ),
                    const SizedBox(height: 20), // Espaciado entre filas
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
        buildCell('MCI'),
        buildCell('TIPO'),
        buildCell('ESTADO'),
      ],
    );
  }

  Widget buildCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final int? mci; // Cambiar a int
  final String type;
  final String status;
  final VoidCallback onTap;


  const DataRowWidget({
    super.key,
    required this.mci,
    required this.type,
    required this.status, required this.onTap,
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
          border: Border.all(
            color: const Color.fromARGB(255, 3, 236, 244),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildCell(widget.mci.toString()), // Convertir a String solo para mostrar
            buildCell(widget.type),
            buildCell(widget.status),
          ],
        ),
      ),
    );
  }

  Widget buildCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
