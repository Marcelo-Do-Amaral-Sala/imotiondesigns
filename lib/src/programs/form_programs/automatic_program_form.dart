import 'package:flutter/material.dart';

import '../../db/db_helper.dart';

class AutomaticProgramForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  const AutomaticProgramForm({super.key, required this.onDataChanged});

  @override
  AutomaticProgramFormState createState() => AutomaticProgramFormState();
}

class AutomaticProgramFormState extends State<AutomaticProgramForm> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _tiempoController = TextEditingController();
  final _ajusteController = TextEditingController();
  final _ordenController = TextEditingController();

  String? selectedEquipOption;
  String? selectedProgramOption;
  double scaleFactorTick = 1.0;

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _tiempoController.dispose();
    _ajusteController.dispose();
    _ordenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.05,
          horizontal: screenWidth * 0.05,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // Fila 1: Campos ID, Nombre, Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: 'Automático',
                                  enabled: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NOMBRE DEL PROGRAMA', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _nameController,
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: 'Introducir nombre de programa',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DURACIÓN', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _durationController,
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: 'Introducir duración de programa',
                                  enabled: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EQUIPAMIENTO', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione',
                                    style: _dropdownHintStyle),
                                value: selectedEquipOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BIO-JACKET',
                                    child: Text('BIO-JACKET',
                                        style: _dropdownItemStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'BIO-SHAPE',
                                    child: Text('BIO-SHAPE',
                                        style: _dropdownItemStyle),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedEquipOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF2be4f3), size: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // Fila 2: Campos de Frecuencia, Pulso, Rampa, Contracción y Pausa
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          // Flexible permite que el Container ocupe una fracción del espacio disponible
                          flex: 1,
                          // Este valor define cuánta parte del espacio disponible debe ocupar el widget
                          child: Container(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.5,
                            // Mantiene el ancho completo de la pantalla
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 46, 46, 46),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: const Padding(
                              padding: const EdgeInsets.all(10.0),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        OutlinedButton(
                          onPressed: () {
                            _addBonos(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side: const BorderSide(
                                width: 1.0, color: Color(0xFF2be4f3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: const Text(
                            'CREAR SECUENCIA',
                            style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                      onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                      onTap: () async {},
                      child: AnimatedScale(
                        scale: scaleFactorTick,
                        duration: const Duration(milliseconds: 100),
                        child: SizedBox(
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.1,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/tick.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBonos(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Limpia los controladores cuando el diálogo se cierra
        return Dialog(
          backgroundColor: const Color(0xFF494949),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF2be4f3), width: 2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.6,
              maxWidth: screenWidth * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF2be4f3)),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "CREAR SECUENCIA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2be4f3),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            // Limpia los controladores cuando se cierra el diálogo
                            _ordenController.clear();
                            _durationController.clear();
                            _ajusteController.clear();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close_sharp,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SELECCIÓN PROGRAMA', style: _labelStyle),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              width: screenWidth * 0.3,
                              alignment: Alignment.centerLeft,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedProgramOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BIO-JACKET',
                                    child: Text('BIO-JACKET', style: _dropdownItemStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'BIO-SHAPE',
                                    child: Text('BIO-SHAPE', style: _dropdownItemStyle),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedProgramOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ORDEN', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _ordenController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(hintText: ''),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DURACIÓN (s)', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _durationController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(hintText: '', enabled: true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AJUSTE', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _ajusteController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(hintText: '', enabled: true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                              onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                              onTap: () async {},
                              child: AnimatedScale(
                                scale: scaleFactorTick,
                                duration: const Duration(milliseconds: 100),
                                child: SizedBox(
                                  width: screenWidth * 0.1,
                                  height: screenHeight * 0.1,
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/tick.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }







  TextStyle get _labelStyle => const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownHintStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownItemStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
