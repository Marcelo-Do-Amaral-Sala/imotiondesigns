
import 'package:flutter/material.dart';

class SubprogramTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subprogramData; // Datos de los subprogramas

  const SubprogramTableWidget({super.key, required this.subprogramData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado de la tabla
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: subprogramData.asMap().entries.map((entry) {
                int index = entry.key; // Índice de la lista
                Map<String, dynamic> subprograma = entry.value;

                return Column(
                  children: [
                    DataRowWidget(
                      orden: (index + 1).toString(), // Índice (empezando desde 1)
                      nombre: subprograma['nombre'] ?? 'N/A',
                      // Manejo de duracionTotal y ajuste como valores double
                      duracion: (subprograma['duracion'] is double)
                          ? subprograma['duracion']
                          : double.tryParse(subprograma['duracion'].toString()) ?? 0.0,
                      ajuste: (subprograma['ajuste'] is double)
                          ? subprograma['ajuste']
                          : double.tryParse(subprograma['ajuste'].toString()) ?? 0.0,
                    ),
                    const SizedBox(height: 10), // Espaciado entre filas
                  ],
                );
              }).toList(),
            ),
          ),
        )

      ],
    );
  }

  Widget buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCell('ORDEN'),
        buildCell('PROGRAMA'),
        buildCell('DURACIÓN'),
        buildCell('AJUSTE'),
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
                  ? const Color.fromARGB(255, 3, 236, 244) // Color específico para la columna de nombre
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

class DataRowWidget extends StatelessWidget {
  final String orden;
  final String nombre;
  final double duracion;
  final double ajuste;

  const DataRowWidget({
    super.key,
    required this.orden,
    required this.nombre,
    required this.duracion,
    required this.ajuste,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCell(orden),
          buildCell(nombre, isNameColumn: true),
          buildCell(duracion.toString()),
          buildCell(ajuste.toString()),
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
                ? const Color.fromARGB(255, 3, 236, 244) // Color para la columna de nombre
                : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold, // Ajuste del tamaño del texto
          ),
        ),
      ),
    );
  }
}