import 'package:flutter/material.dart';

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
        const SizedBox(height: 10),
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
                          ? const Color.fromARGB(255, 46, 46, 46) // Color para filas impares
                          : Colors.transparent, // Color para filas pares
                    ),
                    const SizedBox(height: 5),
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
        buildCell('VALOR CALCULADO'),
        buildCell('REFERENCIA'),
        buildCell('RESULTADO'),
      ],
    );
  }

  Widget buildCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, // Cambia el color según tu diseño
            fontWeight: FontWeight.bold,
            fontSize: 12, // Tamaño de fuente personalizado
          ),
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
