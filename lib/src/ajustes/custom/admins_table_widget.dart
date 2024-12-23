import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';

class AdminsTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data; // Mantener el tipo como dynamic
  final Function(Map<String, dynamic>)
      onRowTap; // Callback con el tipo correcto

  const AdminsTableWidget(
      {super.key, required this.data, required this.onRowTap});

  @override
  _AdminsTableWidgetState createState() => _AdminsTableWidgetState();
}

class _AdminsTableWidgetState extends State<AdminsTableWidget> {
  @override
  Widget build(BuildContext context) {
    // Ordenar la lista de datos por el id de menor a mayor
    List<Map<String, dynamic>> sortedData = List.from(widget.data);
    sortedData.sort((a, b) {
      int idA =
          a['id'] is int ? a['id'] : int.tryParse(a['id'].toString()) ?? 0;
      int idB =
          b['id'] is int ? b['id'] : int.tryParse(b['id'].toString()) ?? 0;
      return idA.compareTo(idB); // Ordenar de menor a mayor
    });
    return Column(
      children: [
        buildHeaderRow(), // Encabezado fijo
        SizedBox(
            height: MediaQuery.of(context).size.height *
                0.01), // Espaciado entre encabezado y filas
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: widget.data.map((row) {
                return Column(
                  children: [
                    DataRowWidget(
                      id: (row['id'] is int)
                          ? row['id']
                          : int.tryParse(row['id'].toString()) ?? 0,
                      name: row['name'] ?? '',
                      phone: (row['phone'] is int)
                          ? row['phone']
                          : int.tryParse(row['phone'].toString()) ?? 0,
                      status: row['status'] ?? '',
                      onTap: () {
                        widget.onRowTap(row); // Pasar el mapa completo
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
        buildCell(
          tr(context, 'Nombre').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Teléfono').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Estado').toUpperCase(),
        ),
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
  final int? id; // Cambiar a int
  final String name;
  final int phone; // Cambiar a int
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
            buildCell(
                widget.id.toString()), // Convertir a String solo para mostrar
            buildCell(widget.name),
            buildCell(
                widget.phone.toString()), // Convertir a String para mostrar
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
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ),
    );
  }
}
