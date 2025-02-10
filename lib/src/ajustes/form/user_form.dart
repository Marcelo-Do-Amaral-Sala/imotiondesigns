import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class UserDataForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  const UserDataForm({super.key, required this.onDataChanged});

  @override
  UserDataFormState createState() => UserDataFormState();
}

class UserDataFormState extends State<UserDataForm> {
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? selectedOption='Activo';
  String? selectedGender;
  String? selectedTipoPerfil;
  String? selectedControlSesiones;
  String? selectedControlTiempo;
  String? _birthDate;
  String? _altaDate;
  double scaleFactorTick = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Mantén los controladores abiertos para preservar su estado
    _nameController.dispose();
     _emailController.dispose();
     _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime eighteenYearsAgo =
        DateTime(today.year - 18, today.month, today.day);

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

  Future<void> _selectAltaDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // Puedes poner cualquier fecha válida aquí, por ejemplo, hoy.
      firstDate: DateTime(1900),
      // Establecemos un límite inferior para la selección (por ejemplo, 1900).
      lastDate: DateTime(2050),
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
      // Aquí procesas la fecha seleccionada
      setState(() {
        // Formateamos la fecha seleccionada en el formato dd/MM/yyyy
        _altaDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _collectUserData() async {
    // Verificar que los campos no estén vacíos
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _userController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        selectedGender == null ||
        selectedOption == null ||
        selectedControlSesiones == null ||
        selectedControlTiempo == null ||
        _birthDate == null ||
        _altaDate == null ||
        !_emailController.text.contains('@')) {
      // Verificación de '@' en el correo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Por favor, complete todos los campos correctamente')
                .toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
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

    // Datos del usuario
    final clientData = {
      'name': name, // Nombre con la primera letra en mayúscula
      'email': _emailController.text,
      'phone': _phoneController.text,
      'pwd': '0000',
      'user': _userController.text,
      'gender': selectedGender,
      'altadate': _altaDate,
      'controlsesiones': selectedControlSesiones,
      'controltiempo': selectedControlTiempo,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    DatabaseHelper dbHelper = DatabaseHelper();

    // Insertar usuario en la tabla `usuarios`
    int userId = await dbHelper.insertUser(clientData);

    // Insertar tipo de perfil en la tabla `tipos_perfil` si aún no existe
    int? perfilId = await dbHelper.getTipoPerfilId(selectedTipoPerfil!);

    perfilId ??= await dbHelper.insertTipoPerfil(selectedTipoPerfil!);

    // Imprimir el tipo de perfil que se ha insertado
    print('Tipo de perfil insertado: $selectedTipoPerfil');

    // Insertar la relación en la tabla `usuario_perfil`
    await dbHelper.insertUsuarioPerfil(userId, perfilId);

    print('Datos del cliente insertados: $clientData');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'Usuario añadido correctamente').toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
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

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        child: SingleChildScrollView( // 🔹 Habilita el scroll en formularios largos
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  SizedBox(width: screenWidth * 0.02),
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
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(context, 'Usuario').toUpperCase(),
                            style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: TextField(
                            controller: _userController,
                            style: _inputTextStyle,
                            decoration: _inputDecorationStyle(
                              hintText: tr(context, 'Nombre de usuario'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
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
                        SizedBox(height: screenHeight * 0.02),
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
                        SizedBox(height: screenHeight * 0.02),
                        Text(tr(context, 'Teléfono').toUpperCase(),
                            style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: _inputTextStyle,
                            decoration: _inputDecorationStyle(
                              hintText: tr(context, 'Introducir teléfono'),
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
                        Text('E-MAIL', style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\s')),
                            ],
                            style: _inputTextStyle,
                            decoration: _inputDecorationStyle(
                              hintText: tr(context, 'Introducir e-mail'),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(tr(context, 'Fecha de alta').toUpperCase(),
                            style: _labelStyle),
                        GestureDetector(
                          onTap: () => _selectAltaDate(context),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            child: Text(_altaDate ?? 'DD/MM/YYYY',
                                style: _inputTextStyle),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(tr(context, 'Tipo de perfil').toUpperCase(),
                            style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: DropdownButton<String>(
                            hint: Text(tr(context, 'Seleccione'),
                                style: _dropdownHintStyle),
                            value: selectedTipoPerfil,
                            items: [
                              DropdownMenuItem(
                                  value: 'Administrador',
                                  child: Text(tr(context, 'Administrador'),
                                      style: _dropdownItemStyle)),
                              DropdownMenuItem(
                                  value: 'Entrenador',
                                  child: Text(tr(context, 'Entrenador'),
                                      style: _dropdownItemStyle)),
                              DropdownMenuItem(
                                  value: 'Ambos',
                                  child: Text(tr(context, 'Ambos'),
                                      style: _dropdownItemStyle)),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedTipoPerfil = value;
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
                  SizedBox(
                    width: screenWidth * 0.05,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            tr(context, 'Control de sesiones')
                                .toUpperCase(),
                            style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: DropdownButton<String>(
                            hint: Text(tr(context, 'Seleccione'),
                                style: _dropdownHintStyle),
                            value: selectedControlSesiones,
                            items: [
                              DropdownMenuItem(
                                  value: 'Sí',
                                  child: Text(tr(context, 'Sí'),
                                      style: _dropdownItemStyle)),
                              DropdownMenuItem(
                                  value: 'No',
                                  child: Text(tr(context, 'No'),
                                      style: _dropdownItemStyle)),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedControlSesiones = value;
                              });
                            },
                            dropdownColor: const Color(0xFF313030),
                            icon:  Icon(Icons.arrow_drop_down,
                                color: const Color(0xFF2be4f3), size: screenHeight*0.05),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(tr(context, 'Control de tiempo').toUpperCase(),
                            style: _labelStyle),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: DropdownButton<String>(
                            hint: Text(tr(context, 'Seleccione'),
                                style: _dropdownHintStyle),
                            value: selectedControlTiempo,
                            items: [
                              DropdownMenuItem(
                                  value: 'Sí',
                                  child: Text(tr(context, 'Sí'),
                                      style: _dropdownItemStyle)),
                              DropdownMenuItem(
                                  value: 'No',
                                  child: Text(tr(context, 'No'),
                                      style: _dropdownItemStyle)),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedControlTiempo = value;
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
              // 🔹 Botón de Confirmación (Tick)
              SizedBox(height: screenHeight * 0.05),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                  onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                  onTap: () {
                    _collectUserData();
                    print("TICK PULSADA");
                  },
                  child: AnimatedScale(
                    scale: scaleFactorTick,
                    duration: const Duration(milliseconds: 100),
                    child: SizedBox(
                      width: screenWidth * 0.1,
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
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
