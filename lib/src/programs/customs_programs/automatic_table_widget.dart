import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/translation_utils.dart';

class SubprogramTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subprogramData; // Datos de los subprogramas

  const SubprogramTableWidget({super.key, required this.subprogramData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(context), // Encabezado de la tabla
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: subprogramData.asMap().entries.map((entry) {
                int index = entry.key; // Índice de la lista
                Map<String, dynamic> subprograma = entry.value;

                return Column(
                  children: [
                    DataRowWidget(
                      orden: (subprograma['orden'] is int)
                          ? subprograma['orden']
                          : int.tryParse(subprograma['orden'].toString()) ?? 0,
                      // Índice (empezando desde 1)
                      nombre: subprograma['nombre'] ?? 'N/A',
                      // Manejo de duracionTotal y ajuste como valores double
                      duracion: (subprograma['duracion'] is double)
                          ? subprograma['duracion']
                          : double.tryParse(
                                  subprograma['duracion'].toString()) ??
                              0.0,
                      ajuste: (subprograma['ajuste'] is double)
                          ? subprograma['ajuste']
                          : double.tryParse(subprograma['ajuste'].toString()) ??
                              0.0,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  ],
                );
              }).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCell(
         context, tr(context, 'Orden').toUpperCase(),
        ),
        buildCell(
          context, tr(context, 'Programa').toUpperCase(),
        ),
        buildCell(
          context, '${tr(context, 'Duración').toUpperCase()} (min)',
        ),
        buildCell(
          context, '${tr(context, 'Ajuste').toUpperCase()} (µs)',
        ),

      ],
    );
  }

  Widget buildCell( BuildContext context, String text, {bool isNameColumn = false}) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height *0.04, // Establecemos una altura fija para las celdas
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

class DataRowWidget extends StatelessWidget {
  final int orden;
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
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCell(context, orden.toString()),
          buildCell(context,nombre, isNameColumn: true),
          buildCell(context,duracion.toString()),
          buildCell(context,ajuste.toString()),
        ],
      ),
    );
  }

  Widget buildCell(BuildContext context, String text, {bool isNameColumn = false}) {
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
}
