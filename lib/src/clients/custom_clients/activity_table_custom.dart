import 'package:flutter/material.dart';

class ActivityTableWidget extends StatefulWidget {
  final List<Map<String, String>> activityData;

  const ActivityTableWidget({super.key, required this.activityData});

  @override
  _ActivityTableWidgetState createState() => _ActivityTableWidgetState();
}

class _ActivityTableWidgetState extends State<ActivityTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.activityData.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      date: row['date'] ?? '',
                      hour: row['hour'] ?? '',
                      bonos: row['bonos'] ?? '',
                      points: row['points'] ?? '',
                      ekal: row['ekal'] ?? '',
                    ),
                    const SizedBox(height: 5),
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
        buildCell('FECHA'),
        buildCell('HORA'),
        buildCell('BONOS'),
        buildCell('PUNTOS'),
        buildCell('E-KAL'),
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
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String date;
  final String hour;
  final String bonos;
  final String points;
  final String ekal;

  const DataRowWidget({
    super.key,
    required this.date,
    required this.hour,
    required this.bonos,
    required this.points,
    required this.ekal,
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
          buildCell(widget.hour),
          buildCell(widget.bonos),
          buildCell(widget.points),
          buildCell(widget.ekal),
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
          textAlign: TextAlign.center, // Alineación centrada
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
