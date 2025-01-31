import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';

class BioSessionTableWidget extends StatefulWidget {
  final List<Map<String, String>> bioimpedanceData;

  const BioSessionTableWidget({Key? key, required this.bioimpedanceData})
      : super(key: key);

  @override
  _BioSessionTableWidgetState createState() => _BioSessionTableWidgetState();
}

class _BioSessionTableWidgetState extends State<BioSessionTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado de columnas
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(widget.bioimpedanceData.length, (index) {
                var row = widget.bioimpedanceData[index];
                return Column(
                  children: [
                    DataRowWidget(
                      feature: row['feature'] ?? '',
                      value: row['value'] ?? '',
                      ref: row['ref'] ?? '',
                      result: row['result'] ?? '',
                      backgroundColor: (index % 2 == 0)
                          ? const Color.fromARGB(
                              255, 46, 46, 46) // Color para filas impares
                          : Colors.transparent, // Color para filas pares
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                  ],
                );
              }),
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
        buildCell(''), // Encabezado de la fila
        buildCell(
          tr(context, 'Valor calculado').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Referencia').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Resultado').toUpperCase(),
        ),
      ],
    );
  }

  Widget buildCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.001, horizontal: MediaQuery.of(context).size.width * 0.001),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String feature; // Encabezado de la fila
  final String value;
  final String ref;
  final String result;
  final Color? backgroundColor; // Nuevo parámetro para el color de fondo

  const DataRowWidget({
    Key? key,
    required this.feature,
    required this.value,
    required this.ref,
    required this.result,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _DataRowWidgetState createState() => _DataRowWidgetState();
}

class _DataRowWidgetState extends State<DataRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor, // Aplicar el color de fondo
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildFeatureCell(widget.feature), // Encabezado de la fila con estilo
          buildCell(widget.value),
          buildCell(widget.ref),
          buildCell(widget.result),
        ],
      ),
    );
  }

  Widget buildFeatureCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01, horizontal: MediaQuery.of(context).size.width * 0.01),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white, // Cambia el color según tu diseño
            fontWeight: FontWeight.bold,
            fontSize: 17.sp, // Tamaño de fuente personalizado
          ),
        ),
      ),
    );
  }

  Widget buildCell(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01, horizontal: MediaQuery.of(context).size.width * 0.01),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
