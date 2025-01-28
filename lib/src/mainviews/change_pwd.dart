import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/translation_utils.dart';
import '../clients/overlays/main_overlay.dart';
import '../db/db_helper.dart';

class ChangePwdView extends StatefulWidget {
  final Function() onNavigateToMainMenu;
  final double screenWidth;
  final double screenHeight;

  const ChangePwdView({
    Key? key,
    required this.onNavigateToMainMenu,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<ChangePwdView> createState() => _ChangePwdViewState();
}

class _ChangePwdViewState extends State<ChangePwdView> {
  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  @override
  void initState() {
    super.initState();
    toggleOverlay(0);
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
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
          if (isOverlayVisible)
            Positioned.fill(
              top: screenHeight * 0.25,
              bottom: screenHeight * 0.25,
              left: screenWidth * 0.3,
              right: screenWidth * 0.3,
              child: Align(
                alignment: Alignment.center,
                child: _getOverlayWidget(overlayIndex),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlayChangePwd(
          onClose: () => toggleOverlay(0),
          onNavigateToMainMenu: widget.onNavigateToMainMenu,
        );
      default:
        return Container();
    }
  }
}

class OverlayChangePwd extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onNavigateToMainMenu;

  const OverlayChangePwd({
    Key? key,
    required this.onClose,
    required this.onNavigateToMainMenu,
  }) : super(key: key);

  @override
  _OverlayChangePwdState createState() => _OverlayChangePwdState();
}

class _OverlayChangePwdState extends State<OverlayChangePwd> {
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _pwd2 = TextEditingController();
  int? userId;
  String? userTipoPerfil;
  bool _isPasswordHidden = true;
  bool _isPassword2Hidden = true;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
    _pwd.dispose();
    _pwd2.dispose();
  }


  Future<void> _checkUserProfile() async {
    // Obtener el userId desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId =
        prefs.getInt('user_id'); // Guardamos el userId en la variable de clase

    if (userId != null) {
      // Obtener el tipo de perfil del usuario usando el userId
      DatabaseHelper dbHelper = DatabaseHelper();
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId!);
      setState(() {
        userTipoPerfil = tipoPerfil; // Guardamos el tipo de perfil en el estado
      });
    } else {
      // Si no se encuentra el userId en SharedPreferences
      print('No se encontró el userId en SharedPreferences.');
    }
  }

  Future<void> _updatePassword() async {
    if (userId == null) {
      print('UserId no disponible.');
      return;
    }

    // Verificamos si las contraseñas coinciden
    if (_pwd.text != _pwd2.text) {
      // Mostrar un mensaje de error antes de desmontar el widget
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context, 'Las contraseñas no coinciden').toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Verificamos que la nueva contraseña no sea "0000"
    if (_pwd.text == '0000') {
      // Mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context, 'La contraseña no puede ser "0000"').toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('Intento de contraseña inválida: 0000');
      return;
    }

    try {
      // Crear el mapa con solo el campo pwd
      final clientData = {'pwd': _pwd.text};
      print('Datos a actualizar en la base de datos: $clientData');

      // Actualizar el usuario en la base de datos
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUser(userId!, clientData);
      print(
          'Contraseña actualizada correctamente para el usuario con ID $userId.');

      // Guardar el userId y tipo de perfil en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print('SharedPreferences obtenidas: ${prefs.getKeys()}');

      // Limpiar los valores anteriores antes de guardar nuevos datos
      await prefs.remove('user_id');
      await prefs.remove('user_tipo_perfil');
      print('Valores previos de user_id y user_tipo_perfil eliminados.');

      // Guardar el nuevo userId en SharedPreferences
      prefs.setInt('user_id', userId!); // Guardar el userId
      print('Nuevo user_id guardado: ${prefs.getInt('user_id')}');

      // Obtener el tipo de perfil actualizado para el usuario
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId!);
      if (tipoPerfil != null) {
        prefs.setString(
            'user_tipo_perfil', tipoPerfil); // Guardar el tipo de perfil
        print(
            'Nuevo user_tipo_perfil guardado: ${prefs.getString('user_tipo_perfil')}');
      }

      // Mostrar mensaje de éxito antes de desmontar el widget
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(context, 'Contraseña actualizada con éxito').toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navegar al menú principal
      widget.onNavigateToMainMenu();
    } catch (e) {
      print('Error al actualizar la contraseña: $e');
      // Mostrar un SnackBar de error antes de desmontar el widget
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Resetear contraseña').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(context, 'Nueva contraseña').toUpperCase(),
                      style: _labelStyle),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    alignment: Alignment.center,
                    decoration: _inputDecoration(),
                    child: TextField(
                      controller: _pwd,
                      keyboardType: TextInputType.text,
                      obscureText: _isPasswordHidden,
                      // Controlamos la visibilidad aquí
                      style: _inputTextStyle,
                      decoration: _inputDecorationStyle(
                        hintText: tr(context, ''),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordHidden =
                                !_isPasswordHidden; // Cambiar la visibilidad
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 10.0),
                              width: screenWidth * 0.01,
                              // Ajustar tamaño si es necesario
                              height: screenHeight * 0.01,
                              child: Image.asset(
                                _isPasswordHidden
                                    ? 'assets/images/ojo1.png' // Imagen para "ocultar"
                                    : 'assets/images/ojo2.png',
                                // Imagen para "mostrar"

                                fit: BoxFit.scaleDown,
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(context, 'Repetir contraseña').toUpperCase(),
                      style: _labelStyle),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    alignment: Alignment.center,
                    decoration: _inputDecoration(),
                    child: TextField(
                      controller: _pwd2,
                      keyboardType: TextInputType.text,
                      obscureText: _isPassword2Hidden,
                      // Controlamos la visibilidad aquí
                      style: _inputTextStyle,
                      decoration: _inputDecorationStyle(
                        hintText: tr(context, ''),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPassword2Hidden =
                                    !_isPassword2Hidden; // Cambiar la visibilidad
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 10.0),
                              width: screenWidth * 0.01,
                              // Ajustar tamaño si es necesario
                              height: screenHeight * 0.01,
                              child: Image.asset(
                                _isPassword2Hidden
                                    ? 'assets/images/ojo1.png' // Imagen para "ocultar"
                                    : 'assets/images/ojo2.png',
                                // Imagen para "mostrar"

                                fit: BoxFit.scaleDown,
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                // Cerrar el teclado
                FocusScope.of(context).unfocus();

                // Esperar un pequeño retraso para asegurar que el teclado se cierre
                await Future.delayed(const Duration(milliseconds: 300));

                // Actualizar la contraseña
                await _updatePassword();

                // Luego de ejecutar _updatePassword, cierra el overlay
                if (mounted) {
                  widget.onClose();
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(10.0),
                side: const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                tr(context, 'Entrar').toUpperCase(),
                style: TextStyle(
                  color: const Color(0xFF2be4f3),
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
      isChangePwdView: true,
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
      {String hintText = '', bool enabled = true, Widget? suffixIcon}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      enabled: enabled,
      suffixIcon: suffixIcon,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
