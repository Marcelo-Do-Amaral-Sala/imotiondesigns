import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';

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
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
        buildCell(
          tr(context, 'Hora').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Bonos').toUpperCase(),
        ),
        buildCell(
          tr(context, 'Puntos').toUpperCase(),
        ),
        buildCell('E-KAL'),
      ],
    );
  }

  Widget buildCell(String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
        child: Text(
          text,
          textAlign: TextAlign.center, // Alineación centrada
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
