import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/translation_utils.dart';
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
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context)
          .unfocus(); // 🔹 Asegurar que no haya focus al abrir la vista
    });
  }

  @override
  void dispose() {
    _indexController.dispose();
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
        SnackBar(
          content: Text(
            tr(context, 'Por favor, complete todos los campos correctamente')
                .toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return; // Exit method if there are empty fields
    }

    // Obtener el userId desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Error: Usuario no autenticado').toUpperCase(),
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

    final clientData = {
      'usuario_id': userId, // Asociar el cliente con el usuario
      'name': name,
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


    // Refresh the text controllers with the updated data
    await _refreshControllers();

    // Show success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'Cliente actualizado correctamente').toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
          ),
        ),
        backgroundColor: const Color(0xFF2be4f3),
        duration: const Duration(seconds: 2),
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
        _phoneController.text = updatedClientData['phone'].toString();
        _heightController.text = updatedClientData['height']?.toString() ?? '';
        _weightController.text = updatedClientData['weight']?.toString() ?? '';
        selectedGender = updatedClientData['gender'];
        selectedOption = updatedClientData['status'];
        _birthDate = updatedClientData['birthdate'];
      });
    }
  }

  Future<void> _deleteClients(BuildContext context, int clientId) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF494949),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: BorderSide(
              color: const Color(0xFF28E2F5),
              width: screenWidth * 0.001,
            ),
          ),
          child: SizedBox(
            width: screenWidth * 0.4, // 🔹 Mantiene el tamaño original
            height: screenHeight * 0.35,
            child: Column(
              children: [
                // Contenido desplazable con SingleChildScrollView
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.02),
                      child: Column(
                        children: [
                          Text(
                            tr(context, 'Confirmar borrado').toUpperCase(),
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            tr(context,
                                '¿Estás seguro que quieres borrar este cliente?')
                                .toUpperCase(),
                            style:
                            TextStyle(color: Colors.white, fontSize: 25.sp),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botones de acción en la parte inferior
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cerrar el diálogo
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.01),
                          side: BorderSide(
                            width: screenWidth * 0.001,
                            color: const Color(0xFF2be4f3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          tr(context, 'Cancelar').toUpperCase(),
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
                            SnackBar(
                              content: Text(
                                tr(context, 'Cliente borrado correctamente')
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17.sp),
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          Navigator.of(context).pop(); // Cierra el diálogo
                          widget.onClose(); // Lógica post-cierre
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.01),
                          side: BorderSide(
                            width: screenWidth * 0.001,
                            color: Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          tr(context, '¡Sí, estoy seguro!').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
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
        child: SingleChildScrollView( // 🔹 Permite desplazamiento en pantallas pequeñas
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight*0.5, // 🔹 Evita que el contenido colapse
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primer contenedor de formulario, que ocupa el espacio disponible
                Column(
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
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: const Color(0xFF2be4f3),
                                      size: screenHeight * 0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    // Fila 2: Género, Fecha de Nacimiento, Teléfono
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
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: const Color(0xFF2be4f3),
                                      size: screenHeight * 0.05),
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
                                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                                      hintText: tr(context, 'Introducir teléfono')),
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(_heightFocus),
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
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(_weightFocus),
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
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: tr(context, 'Introducir peso'),
                                  ),
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).requestFocus(_emailFocus),
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
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: tr(context, 'Introducir e-mail'),
                                  ),
                                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.1,
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
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
      hintStyle: const TextStyle(color: Colors.grey),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
