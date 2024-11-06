import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../db/db_helper.dart';

class PersonalDataForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  const PersonalDataForm({super.key, required this.onDataChanged});

  @override
  PersonalDataFormState createState() => PersonalDataFormState();
}

class PersonalDataFormState extends State<PersonalDataForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? selectedOption;
  String? selectedGender;
  String? _birthDate;
  double scaleFactorTick = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Mantén los controladores abiertos para preservar su estado
    _nameController.dispose();
    // _emailController.dispose();
    // _phoneController.dispose();
    // _heightController.dispose();
    // _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Obtener la fecha actual
    DateTime today = DateTime.now();

    // Restar 18 años a la fecha actual para obtener la fecha límite
    DateTime eighteenYearsAgo =
        DateTime(today.year - 18, today.month, today.day);

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: eighteenYearsAgo,
        // Puedes poner cualquier fecha válida aquí, por ejemplo, hoy.
        firstDate: DateTime(1900),
        // Establecemos un límite inferior para la selección (por ejemplo, 1900).
        lastDate:
            eighteenYearsAgo // La última fecha seleccionable debe ser hace 18 años.
        );

    if (picked != null) {
      // Aquí procesas la fecha seleccionada
      setState(() {
        // Formateamos la fecha seleccionada en el formato dd/MM/yyyy
        _birthDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _collectData() async {
    // Verificar que los campos no estén vacíos
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        selectedGender == null ||
        selectedOption == null ||
        _birthDate == null ||
        !_emailController.text.contains('@')) {
      // Verificación de '@' en el correo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, complete todos los campos correctamente.",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Convertir la primera letra del nombre a mayúscula
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1).toLowerCase();
    }

    final clientData = {
      'name': name, // Nombre con la primera letra en mayúscula
      'email': _emailController.text,
      'phone': _phoneController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'gender': selectedGender,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertClient(clientData);

    print('Datos del cliente insertados: $clientData');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Cliente añadido correctamente",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Llama a la función onDataChanged para informar de los datos
    widget.onDataChanged(
        clientData); // Aquí notificamos que los datos fueron guardados
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.03), // Ajustar el padding
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Primer contenedor para el primer row de inputs
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Campos de ID y NOMBRE
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ID',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                    filled: true,
                                    fillColor: const Color(0xFF313030),
                                    isDense: true,
                                    enabled: false,
                                    hintText: 'Automático',
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NOMBRE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                    filled: true,
                                    fillColor: const Color(0xFF313030),
                                    isDense: true,
                                    hintText: 'Introducir nombre',
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ESTADO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: DropdownButton<String>(
                                  hint: const Text('Seleccione',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  value: selectedOption,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Activo',
                                        child: Text('Activo',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                    DropdownMenuItem(
                                        value: 'Inactivo',
                                        child: Text('Inactivo',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value;
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
                  ),
                  const SizedBox(height: 2),
                  // Segundo contenedor para el segundo row de inputs
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('GÉNERO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: DropdownButton<String>(
                                    hint: const Text('Seleccione',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                    value: selectedGender,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'Hombre',
                                          child: Text('Hombre',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12))),
                                      DropdownMenuItem(
                                          value: 'Mujer',
                                          child: Text('Mujer',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12))),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedGender = value;
                                      });
                                    },
                                    dropdownColor: const Color(0xFF313030),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xFF2be4f3), size: 30),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('FECHA DE NACIMIENTO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF313030),
                                        borderRadius: BorderRadius.circular(7)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Text(_birthDate ?? 'DD/MM/YYYY',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('TELÉFONO',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      filled: true,
                                      fillColor: const Color(0xFF313030),
                                      isDense: true,
                                      hintText: 'Introducir teléfono',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.1),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ALTURA (cm)',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      filled: true,
                                      fillColor: const Color(0xFF313030),
                                      isDense: true,
                                      hintText: 'Introducir altura',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('PESO (kg)',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      filled: true,
                                      fillColor: const Color(0xFF313030),
                                      isDense: true,
                                      hintText: 'Introducir peso',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('E-MAIL',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'\s'))
                                    ],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      filled: true,
                                      fillColor: const Color(0xFF313030),
                                      isDense: true,
                                      hintText: 'Introducir e-mail',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () {
                      _collectData();
                      print("TICK PULSADA");
                    },
                    child: AnimatedScale(
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.08,
                        height: screenHeight * 0.08,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
