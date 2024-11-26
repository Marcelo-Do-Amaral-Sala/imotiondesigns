import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../db/db_helper.dart';


class UserDataForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  const UserDataForm({super.key, required this.onDataChanged});

  @override
  UserDataFormState createState() => UserDataFormState();
}

class UserDataFormState extends State<UserDataForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? selectedOption;
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

 /* void _collectData() async {
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
  }*/

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
                            Text('NOMBRE', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _nameController,
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: 'Introducir nombre',
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
                            Text('ESTADO', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedOption,
                                items: [
                                  DropdownMenuItem(value: 'Activo', child: Text('Activo', style: _dropdownItemStyle)),
                                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo', style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
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
                            Text('GÉNERO', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedGender,
                                items: [
                                  DropdownMenuItem(value: 'Hombre', child: Text('Hombre', style: _dropdownItemStyle)),
                                  DropdownMenuItem(value: 'Mujer', child: Text('Mujer', style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text('FECHA DE NACIMIENTO', style: _labelStyle),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Text(_birthDate ?? 'DD/MM/YYYY', style: _inputTextStyle),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text('TELÉFONO', style: _labelStyle),
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
                                decoration: _inputDecorationStyle(hintText: 'Introducir teléfono'),
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
                                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(hintText: 'Introducir e-mail'),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text('FECHA DE ALTA', style: _labelStyle),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Text(_altaDate ?? 'DD/MM/YYYY', style: _inputTextStyle),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text('TIPO DE PERFIL', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedTipoPerfil,
                                items: [
                                  DropdownMenuItem(value: 'Administrador', child: Text('Administrador', style: _dropdownItemStyle)),
                                  DropdownMenuItem(value: 'Entrenador', child: Text('Entrenador', style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedTipoPerfil = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth*0.05,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CONTROL DE SESIONES', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedControlSesiones,
                                items: [
                                  DropdownMenuItem(value: 'Sí', child: Text('Sí', style: _dropdownItemStyle)),
                                  DropdownMenuItem(value: 'No', child: Text('No', style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedControlSesiones = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text('CONTROL DE TIEMPO', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione', style: _dropdownHintStyle),
                                value: selectedControlTiempo,
                                items: [
                                  DropdownMenuItem(value: 'Sí', child: Text('Sí', style: _dropdownItemStyle)),
                                  DropdownMenuItem(value: 'No', child: Text('No', style: _dropdownItemStyle)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedControlTiempo = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2be4f3), size: 30),
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
                 // _collectData();
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
  TextStyle get _labelStyle => const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);
  TextStyle get _inputTextStyle => const TextStyle(color: Colors.white, fontSize: 14);
  TextStyle get _dropdownHintStyle => const TextStyle(color: Colors.white, fontSize: 14);
  TextStyle get _dropdownItemStyle => const TextStyle(color: Colors.white, fontSize: 14);

  InputDecoration _inputDecorationStyle({String hintText = '', bool enabled = true}) {
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
    return BoxDecoration(color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }


}


