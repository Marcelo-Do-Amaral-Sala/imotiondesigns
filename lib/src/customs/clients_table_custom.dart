import 'dart:async';
import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  final List<Map<String, String>> data;
  final Function(Map<String, String>) onRowTap;

  const DataTableWidget({super.key, required this.data, required this.onRowTap});

  @override
  _DataTableWidgetState createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  Map<String, String>? selectedRow;

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
                      id: row['id'] ?? '',
                      name: row['name'] ?? '',
                      phone: row['phone'] ?? '',
                      status: row['status'] ?? '',
                      onTap: () {
                        setState(() {
                          selectedRow = row;
                        });
                        widget.onRowTap(row);
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
        buildCell('ID'),
        buildCell('NOMBRE'),
        buildCell('TELÉFONO'),
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
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String id;
  final String name;
  final String phone;
  final String status;
  final VoidCallback onTap;

  const DataRowWidget({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
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
            buildCell(widget.id),
            buildCell(widget.name),
            buildCell(widget.phone),
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
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
