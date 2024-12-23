import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';

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
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        SizedBox(height: MediaQuery.of(context).size.height * 0.005),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.bonosData.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      date: row['date'] ?? '',
                      hour: widget.showHour ? (row['hour'] ?? '') : '',
                      quantity: row['quantity'] ?? '',
                      showHour: widget.showHour, // Pasar el estado de showHour
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
        buildCell(
          tr(context, 'Fecha').toUpperCase(),
        ),
        if (widget.showHour)
          buildCell(
            tr(context, 'Hora').toUpperCase(),
          ),
        // Condicional para la hora
        buildCell(
          tr(context, 'Cantidad').toUpperCase(),
        ),
        // Reemplazar BONOS por CANTIDAD
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
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
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    );
  }
}
