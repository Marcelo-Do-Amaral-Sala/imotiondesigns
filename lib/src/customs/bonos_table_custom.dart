import 'package:flutter/material.dart';

class BonosTableWidget extends StatefulWidget {
  final List<Map<String, String>> bonosData;
  final bool showHour; // Parámetro para mostrar u ocultar la columna "HORA"

  const BonosTableWidget(
      {super.key, required this.bonosData, this.showHour = true});

  @override
  _BonosTableWidgetState createState() => _BonosTableWidgetState();
}

class _BonosTableWidgetState extends State<BonosTableWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildHeaderRow(),
          const SizedBox(height: 5),
          ...widget.bonosData.map((row) {
            return Column(
              children: [
                DataRowWidget(
                  date: row['date'] ?? '',
                  hour: widget.showHour ? (row['hour'] ?? '') : '',
                  quantity: row['quantity'] ?? '',
                  showHour: widget.showHour, // Pasar el estado de showHour
                ),
                const SizedBox(height: 2),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildCell('FECHA'),
        if (widget.showHour) buildCell('HORA'), // Condicional para la hora
        buildCell('CANTIDAD'), // Reemplazar BONOS por CANTIDAD
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
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String date;
  final String hour;
  final String quantity;
  final bool showHour; // Parámetro para mostrar u ocultar la columna "HORA"

  const DataRowWidget({
    super.key,
    required this.date,
    required this.hour,
    required this.quantity,
    required this.showHour, // Recibir el estado de showHour
  });

  @override
  _DataRowWidgetState createState() => _DataRowWidgetState();
}

class _DataRowWidgetState extends State<DataRowWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCell(widget.date),
          if (widget.showHour)
            buildCell(widget.hour), // Condicional para la hora
          buildCell(widget.quantity),
        ],
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
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
