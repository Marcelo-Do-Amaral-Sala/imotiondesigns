import 'package:flutter/material.dart';

import '../../clients/overlays/main_overlay.dart';

class OverlayTipoPrograma extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayTipoPrograma({super.key, required this.onClose});

  @override
  _OverlayTipoProgramaState createState() => _OverlayTipoProgramaState();
}

class _OverlayTipoProgramaState extends State<OverlayTipoPrograma>
    with SingleTickerProviderStateMixin {
  String? selectedProgram = "INDIVIDUAL";

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "SELECCIONAR TIPO DE PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Reduce el tamaño de la columna
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            // Centra los hijos horizontalmente
            children: [
              buildRadioButton("INDIVIDUAL"),
              buildRadioButton("RECOVERY"),
              buildRadioButton("AUTOMATICOS"),
            ],
          ),
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget buildRadioButton(String value) {
    return Center(
      child: ListTile(
        leading: Radio<String>(
          value: value,
          groupValue: selectedProgram,
          activeColor: const Color(0xFF28E2F5),
          onChanged: (String? newValue) {
            setState(() {
              selectedProgram = newValue!;
            });
          },
        ),
        title: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
