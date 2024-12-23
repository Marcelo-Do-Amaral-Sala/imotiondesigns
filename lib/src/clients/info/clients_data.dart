import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../db/db_helper.dart';

class ClientsData extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> clientData;
  final VoidCallback onClose;

  const ClientsData({
    Key? key,
    required this.onDataChanged,
    required this.clientData,
    required this.onClose,
  }) : super(key: key);

  @override
  _ClientsDataState createState() => _ClientsDataState();
}

class _ClientsDataState extends State<ClientsData> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? selectedOption;
  String? selectedGender;
  String? _birthDate;
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;
  int? clientId; // Declare a variable to store the client ID

  @override
  void initState() {
    super.initState();
    clientId = int.tryParse(widget.clientData['id'].toString());
    _indexController.text = clientId.toString(); // Set controller text
    _refreshControllers(); // Load initial data from the database
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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

  void _updateData() async {
    // Ensure all required fields are filled
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        selectedGender == null ||
        selectedOption == null ||
        _birthDate == null ||
        clientId == null ||
        !_emailController.text.contains('@')) {
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, complete todos los campos.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return; // Exit method if there are empty fields
    }
    // Convertir la primera letra del nombre a mayúscula
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1).toLowerCase();
    }

    final clientData = {
      'name': name, // Nombre con la primera letra en mayúscula
      'email': _emailController.text,
      'phone': int.tryParse(_phoneController.text),
      'height': int.tryParse(_heightController.text), // Convert to int
      'weight': int.tryParse(_weightController.text), // Convert to int
      'gender': selectedGender,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    // Update in the database
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.updateClient(
        clientId!, clientData); // Pass the ID and client data

    // Print updated data
    print('Datos del cliente actualizados: $clientData');

    // Refresh the text controllers with the updated data
    await _refreshControllers();

    // Show success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Cliente actualizado correctamente",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        backgroundColor: Color(0xFF2be4f3),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshControllers() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Fetch the updated client data from the database
    Map<String, dynamic>? updatedClientData = await dbHelper
        .getClientById(clientId!); // Create this method in your DatabaseHelper

    if (updatedClientData != null) {
      setState(() {
        _nameController.text = updatedClientData['name'] ?? '';
        _emailController.text = updatedClientData['email'] ?? '';
        _phoneController.text = updatedClientData['phone'].toString() ?? '';
        _heightController.text = updatedClientData['height']?.toString() ?? '';
        _weightController.text = updatedClientData['weight']?.toString() ?? '';
        selectedGender = updatedClientData['gender'];
        selectedOption = updatedClientData['status'];
        _birthDate = updatedClientData['birthdate'];
      });
    }
  }

  Future<void> _deleteClients(BuildContext context, int clientId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF494949),
          // Color de fondo del diálogo
          title: Text(
            'Confirmar Borrado',
            style: TextStyle(
                color: Color(0xFF2be4f3),
                fontSize: 30.sp,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Color del texto
          ),
          content: Text(
            '¿Estás seguro que quieres borrar este cliente?',
            style: TextStyle(color: Colors.white, fontSize: 25.sp),
            textAlign: TextAlign.center, // Color del texto
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side: const BorderSide(
                      width: 1.0,
                      color: Color(0xFF2be4f3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    'CANCELAR',
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    DatabaseHelper dbHelper = DatabaseHelper();
                    await dbHelper.deleteClient(clientId); // Borrar cliente

                    // Mostrar Snackbar de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Cliente borrado correctamente",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Cierra el diálogo después de confirmar el borrado
                    Navigator.of(context).pop();
                    widget.onClose();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side: const BorderSide(
                      width: 1.0,
                      color: Colors.red,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    '¡SÍ, ESTOY SEGURO!',
                    style: TextStyle(
                      color:  Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ESTADO', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: DropdownButton<String>(
                                hint: Text('Seleccione',
                                    style: _dropdownHintStyle),
                                value: selectedOption,
                                items: [
                                  DropdownMenuItem(
                                      value: 'Activo',
                                      child: Text('Activo',
                                          style: _dropdownItemStyle)),
                                  DropdownMenuItem(
                                      value: 'Inactivo',
                                      child: Text('Inactivo',
                                          style: _dropdownItemStyle)),
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
                                hint: Text('Seleccione',
                                    style: _dropdownHintStyle),
                                value: selectedGender,
                                items: [
                                  DropdownMenuItem(
                                      value: 'Hombre',
                                      child: Text('Hombre',
                                          style: _dropdownItemStyle)),
                                  DropdownMenuItem(
                                      value: 'Mujer',
                                      child: Text('Mujer',
                                          style: _dropdownItemStyle)),
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
                            SizedBox(height: screenHeight * 0.03),
                            Text('FECHA DE NACIMIENTO', style: _labelStyle),
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
                                decoration: _inputDecorationStyle(
                                    hintText: 'Introducir teléfono'),
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
                            Text('ALTURA (cm)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                    hintText: 'Introducir altura'),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            Text('PESO (kg)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                    hintText: 'Introducir peso'),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
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
                                    hintText: 'Introducir e-mail'),
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
            SizedBox(height: screenHeight * 0.01),
            // Fila para el ícono de "tick" alineado a la parte inferior
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTapDown: (_) => setState(() => scaleFactorRemove = 0.95),
                onTapUp: (_) => setState(() => scaleFactorRemove = 1.0),
                onTap: () {
                  _deleteClients(context, clientId!);
                },
                child: AnimatedScale(
                  scale: scaleFactorRemove,
                  duration: const Duration(milliseconds: 100),
                  child: SizedBox(
                    width: screenWidth * 0.08,
                    height: screenHeight * 0.08,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/papelera.png',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                onTap: () {
                  _updateData(); // Llama a la función pasando el ID
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
            ]),
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
