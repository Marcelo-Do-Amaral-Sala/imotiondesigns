import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class AdminsData extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> adminData;
  final VoidCallback onClose;

  const AdminsData({
    super.key,
    required this.onDataChanged,
    required this.onClose,
    required this.adminData,
  });

  @override
  AdminsDataState createState() => AdminsDataState();
}

class AdminsDataState extends State<AdminsData> {
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
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
  double scaleFactorRemove = 1.0;
  int? userId;

  @override
  void initState() {
    super.initState();
    userId = int.tryParse(widget.adminData['id'].toString());
    _refreshControllers(); // Load initial data from the database
  }

  @override
  void dispose() {
    // Mantén los controladores abiertos para preservar su estado
    _nameController.dispose();
    _userController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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

  Future<void> _selectAltaDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // Puedes poner cualquier fecha válida aquí, por ejemplo, hoy.
      firstDate: DateTime(1900),
      // Establecemos un límite inferior para la selección (por ejemplo, 1900).
      lastDate: DateTime(
          2050), // La última fecha seleccionable debe ser hace 18 años.
    );

    if (picked != null) {
      // Aquí procesas la fecha seleccionada
      setState(() {
        // Formateamos la fecha seleccionada en el formato dd/MM/yyyy
        _altaDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _refreshControllers() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Obtener los datos del usuario desde la base de datos
    Map<String, dynamic>? updatedAdminData =
        await dbHelper.getUserById(userId!);

    if (updatedAdminData != null) {
      // Obtener el tipo de perfil asociado al usuario desde la base de datos
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId!);

      setState(() {
        // Actualizar los campos del formulario con los datos del usuario
        _nameController.text = updatedAdminData['name'] ?? '';
        _userController.text = updatedAdminData['user'] ?? '';
        _emailController.text = updatedAdminData['email'] ?? '';
        _phoneController.text = updatedAdminData['phone'].toString();
        selectedGender = updatedAdminData['gender'];
        selectedTipoPerfil =
            tipoPerfil ?? ''; // Actualiza con el tipo de perfil obtenido
        selectedControlTiempo = updatedAdminData['controltiempo'];
        selectedControlSesiones = updatedAdminData['controlsesiones'];
        selectedOption = updatedAdminData['status'];
        _birthDate = updatedAdminData['birthdate'];
        _altaDate = updatedAdminData['altadate'];
      });
    }
  }

  void _updateUserData() async {
    // Asegurarse de que todos los campos requeridos estén completos
    if (_nameController.text.isEmpty ||
        _userController.text.isEmpty ||
        _emailController.text.isEmpty ||
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

    // Datos del usuario
    final clientData = {
      'name': name, // Nombre con la primera letra en mayúscula
      'email': _emailController.text,
      'user': _userController.text,
      'phone': _phoneController.text,
      'gender': selectedGender,
      'altadate': _altaDate,
      'controlsesiones': selectedControlSesiones,
      'controltiempo': selectedControlTiempo,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    // Update in the database
    DatabaseHelper dbHelper = DatabaseHelper();

    // Actualizar el usuario en la base de datos
    await dbHelper.updateUser(userId!, clientData);

    // Imprimir los datos actualizados del cliente
    print('Datos del cliente actualizados: $clientData');

    // Obtener el perfilId correspondiente al tipo de perfil seleccionado
    int? perfilId = await dbHelper.getTipoPerfilId(selectedTipoPerfil!);

    // Si el perfilId no se encuentra, se crea uno nuevo
    perfilId ??= await dbHelper.insertTipoPerfil(selectedTipoPerfil!);

    // Actualizar la relación entre el usuario y el tipo de perfil en la tabla usuario_perfil
    await dbHelper.updateUsuarioPerfil(userId!, perfilId);

    // Refrescar los controladores con los datos actualizados
    await _refreshControllers();

    // Mostrar un SnackBar de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'Usuario actualizado correctamente').toUpperCase(),
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

  Future<void> _updatePassword() async {
    try {
      // Crear el mapa con solo el campo pwd
      final clientData = {'pwd': '0000'};

      // Actualizar el usuario en la base de datos
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUser(userId!, clientData);
    } catch (e) {
      print('Error al actualizar la contraseña: $e');
      // Mostrar un SnackBar de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(context, 'Error al resetear la contraseña').toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteUsers(BuildContext context, int userId) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.3,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: screenWidth * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, 'Confirmar borrado').toUpperCase(),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  tr(context, '¿Estás seguro que quieres borrar este cliente?')
                      .toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
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
                        await dbHelper.deleteUser(userId); // Borrar cliente

                        // Mostrar Snackbar de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(context, 'Usuario borrado correctamente')
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetPwd(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.3,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01, horizontal: screenWidth * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: screenWidth * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, 'Resetear contraseña').toUpperCase(),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  tr(context, '¿Reestablecer contraseña a 0000?').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
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
                        _updatePassword(); // Lógica para resetear contraseña
                        Navigator.of(context).pop(); // Cierra el diálogo
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
                                icon: Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3),
                                    size: screenHeight * 0.05),
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
                      OutlinedButton(
                        onPressed: () {
                          _resetPwd(context);
                        }, // Mantener vacío para que InkWell funcione
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.01),
                          side: BorderSide(
                              width: screenWidth * 0.001,
                              color: const Color(0xFF2be4f3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          tr(context, 'Reset password').toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
                                icon: Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3),
                                    size: screenHeight * 0.05),
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
                                icon: Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3),
                                    size: screenHeight * 0.05),
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
                                icon: Icon(Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3),
                                    size: screenHeight * 0.05),
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
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapDown: (_) => setState(() => scaleFactorRemove = 0.95),
                  onTapUp: (_) => setState(() => scaleFactorRemove = 1.0),
                  onTap: () {
                    _deleteUsers(context, userId!);
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
                    _updateUserData(); // Llama a la función pasando el ID
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
      TextStyle(color: Colors.white, fontSize: 14.sp);

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
