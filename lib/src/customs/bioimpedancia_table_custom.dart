import 'dart:async';
import 'package:flutter/material.dart';

class BioimpedanciaTableWidget extends StatefulWidget {
  final List<Map<String, String>> dataRegister;
  final Function(Map<String, String>) onRowTap;

  const BioimpedanciaTableWidget({
    super.key,
    required this.dataRegister,
    required this.onRowTap,
  });

  @override
  _BioimpedanciaTableWidgetState createState() =>
      _BioimpedanciaTableWidgetState();
}

class _BioimpedanciaTableWidgetState extends State<BioimpedanciaTableWidget> {
  Map<String, String>? selectedRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.dataRegister.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      date: row['date'] ?? '',
                      hour: row['hour'] ?? '',
                      onTap: () {
                        setState(() {
                          selectedRow = row;
                        });
                        widget.onRowTap(row);
                      },
                    ),
                    const SizedBox(height: 20),
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
  final VoidCallback onTap;

  const DataRowWidget({
    super.key,
    required this.date,
    required this.hour,
    required this.onTap,
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
            buildCell(widget.date),
            buildCell(widget.hour),
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
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
