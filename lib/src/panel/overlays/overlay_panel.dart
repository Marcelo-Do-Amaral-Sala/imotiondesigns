import 'package:flutter/material.dart';

import '../../clients/overlays/main_overlay.dart';

String? globalSelectedProgram;

class OverlayTipoPrograma extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayTipoPrograma({super.key, required this.onClose});

  @override
  _OverlayTipoProgramaState createState() => _OverlayTipoProgramaState();
}

class _OverlayTipoProgramaState extends State<OverlayTipoPrograma>
    with SingleTickerProviderStateMixin {
  String? selectedProgram;

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "SELECCIONAR TIPO DE PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Columna para los ListTiles
            Expanded(
              flex: 2, // Le da más espacio a esta columna si se necesita
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildCustomCheckboxTile("INDIVIDUAL"),
                    buildCustomCheckboxTile("RECOVERY"),
                    buildCustomCheckboxTile("AUTOMÁTICOS"),
                  ],
                ),
              ),
            ),
            // Columna para el botón
            Expanded(
              flex: 1, // Menos espacio que la columna de ListTiles
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () {
                    // Guarda el valor seleccionado en la variable global
                    globalSelectedProgram = selectedProgram;
                    widget.onClose(); // Llama al onClose para cerrar el overlay
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Color(0xFF2be4f3),
                  ),
                  child: const Text(
                    'SELECCIONAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget buildCustomCheckboxTile(String option) {
    return ListTile(
      leading: customCheckbox(option),
      title: Text(
        option,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          selectedProgram = option; // Actualiza la selección
        });
      },
    );
  }

  Widget customCheckbox(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProgram = option; // Actualiza la selección
        });
      },
      child: Container(
        width: 22.0,
        height: 22.0,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedProgram == option
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: selectedProgram == option
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
