import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

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
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  String? selectedOption = 'Activo';
  String? selectedGender;
  String? _birthDate;
  double scaleFactorTick = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context)
          .unfocus(); // 🔹 Asegurar que no haya focus al abrir la vista
    });
  }

  @override
  void dispose() {
    // Mantén los controladores abiertos para preservar su estado
    _nameController.dispose();
     _emailController.dispose();
     _phoneController.dispose();
     _heightController.dispose();
     _weightController.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime eighteenYearsAgo = DateTime(today.year - 18, today.month, today.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF2be4f3), // 🔥 Color de selección
              onPrimary: Colors.white, // 🔥 Color del texto en la selección
              surface: const Color(0xFF494949), // 🔥 Color de fondo
              onSurface: Colors.white, // 🔥 Color de los días normales
            ),
            dialogBackgroundColor: Colors.white, // 🔥 Fondo del diálogo
          ),
          child: Transform.scale(
            scale: 1.1, // 🔥 Aumenta o reduce el tamaño del contenido interno
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
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
        !_emailController.text.contains('@')) { // Verificación básica de correo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Por favor, complete todos los campos correctamente').toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Obtener el userId desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Error: Usuario no autenticado').toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
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
      'usuario_id': userId, // Asociar el cliente con el usuario
      'name': name,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'height': int.parse(_heightController.text),
      'weight': int.parse(_weightController.text),
      'gender': selectedGender,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    DatabaseHelper dbHelper = DatabaseHelper();

    // 🔹 Insertar cliente y obtener el ID creado
    int? clienteId = await dbHelper.insertClient(clientData);

    if (clienteId != null) {
      print('✔ Cliente insertado con ID: $clienteId');

      // 🔹 Asignar todos los grupos musculares al cliente recién creado
      bool gruposInsertados = await dbHelper.insertClientAllGroups(clienteId);

      if (gruposInsertados) {
        print('✔ Todos los grupos musculares asignados correctamente al cliente.');
      } else {
        print('❌ Error al asignar grupos musculares al cliente.');
      }
    } else {
      print('❌ Error al insertar el cliente en la base de datos.');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'Cliente añadido correctamente').toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Llama a la función onDataChanged para informar de los datos
    widget.onDataChanged(clientData);
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        child: Column(
          children: [
            // Primer contenedor de formulario, que ocupa el espacio disponible
            Expanded(
              flex: 2, // Ocupa más espacio en la pantalla
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: Campos ID, Nombre, Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Nombre').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _nameController,
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context, 'Introducir nombre'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Estado').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text(tr(context, 'Seleccione'),
                                    style: _dropdownHintStyle),
                                value: selectedOption,
                                items: [
                                  DropdownMenuItem(
                                      value: 'Activo',
                                      child: Text(tr(context, 'Activo'),
                                          style: _dropdownItemStyle)),
                                  DropdownMenuItem(
                                      value: 'Inactivo',
                                      child: Text(tr(context, 'Inactivo'),
                                          style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon:  Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3), size: screenHeight*0.05),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // Fila 2: Campos de Género, Fecha de Nacimiento, Teléfono
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Género').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text(tr(context, 'Seleccione'),
                                    style: _dropdownHintStyle),
                                value: selectedGender,
                                items: [
                                  DropdownMenuItem(
                                      value: 'Hombre',
                                      child: Text(tr(context, 'Hombre'),
                                          style: _dropdownItemStyle)),
                                  DropdownMenuItem(
                                      value: 'Mujer',
                                      child: Text(tr(context, 'Mujer'),
                                          style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon:  Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3), size: screenHeight*0.05),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text(
                                tr(context, 'Fecha de nacimiento')
                                    .toUpperCase(),
                                style: _labelStyle),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Text(_birthDate ?? 'DD/MM/YYYY',
                                    style: _inputTextStyle),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text(tr(context, 'Teléfono').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                    hintText:
                                        tr(context, 'Introducir teléfono')),
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_heightFocus),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.1),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Altura (cm)').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _heightController,
                                focusNode: _heightFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context, 'Introducir altura'),
                                ),
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_weightFocus),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text(tr(context, 'Peso (kg)').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _weightController,
                                focusNode: _weightFocus,
                                textInputAction: TextInputAction.next,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$')),
                                  // Permite números enteros y decimales
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context, 'Introducir peso'),
                                ),
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_emailFocus),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text('E-MAIL', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context, 'Introducir e-mail'),
                                ),
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fila para el ícono de "tick" alineado a la parte inferior
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
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
                    width: screenWidth * 0.1, // Ajusta el tamaño de la imagen
                    height: screenHeight * 0.1,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/tick.png',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Ajustes de estilos para simplificar
  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownHintStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownItemStyle =>
      TextStyle(color: Colors.white, fontSize: 15.sp);

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
