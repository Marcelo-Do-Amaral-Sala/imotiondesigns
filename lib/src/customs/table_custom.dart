import 'package:flutter/material.dart';

import '../info/detail_clients.dart';

class DataTableWidget extends StatefulWidget {
  final List<Map<String, String>> data;
  final Function(Map<String, String>) onRowTap; // Cambiado a aceptar un Map

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
        buildHeaderRow(),
        const SizedBox(height: 20),
        ...widget.data.map((row) {
          return Column(
            children: [
              DataRowWidget(
                id: row['id'] ?? '',
                name: row['name'] ?? '',
                phone: row['phone'] ?? '',
                status: row['status'] ?? '',
                onTap: () {
                  setState(() {
                    selectedRow = row; // Guarda la fila seleccionada.
                  });
                  widget.onRowTap(row); // Llama a onRowTap con la fila seleccionada.
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        }),
        if (selectedRow != null)
          DetailsView(data: selectedRow!), // Muestra la vista de detalles
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          isPressed = true;
        });

        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            isPressed = false;
          });
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
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}