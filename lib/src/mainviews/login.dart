import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../utils/translation_utils.dart';
import '../db/db_helper.dart';
import '../db/db_helper_pc.dart';
import '../db/db_helper_traducciones.dart';
import '../db/db_helper_traducciones_pc.dart';
import '../db/db_helper_traducciones_web.dart';
import '../db/db_helper_web.dart';
import '../servicios/sync.dart';
import '../servicios/translation_provider.dart'; // Asegúrate de tener esta importación para manejar la base de datos.

class LoginView extends StatefulWidget {
  final Function() onNavigateToMainMenu;
  final double screenWidth;
  final double screenHeight;

  const LoginView({
    Key? key,
    required this.onNavigateToMainMenu,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  String _errorMessage = ''; // Para almacenar el mensaje de error
  Map<String, String> _translations = {};
  final SyncService _syncService = SyncService();
  final DatabaseHelperTraducciones _dbHelperTraducciones =
  DatabaseHelperTraducciones();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeDatabase();
    _initializeDatabaseTraducciones();
    _requestLocationPermissions();
  }

  Future<void> _initializeDatabase() async {
    try {
      if (kIsWeb) {
        debugPrint("Inicializando base de datos para Web...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperWeb().initializeDatabase();
      } else if (Platform.isAndroid || Platform.isIOS) {
        debugPrint("Inicializando base de datos para Móviles...");
        await DatabaseHelper().initializeDatabase();
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        debugPrint("Inicializando base de datos para Desktop...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperPC().initializeDatabase();
      } else {
        throw UnsupportedError(
            'Plataforma no soportada para la base de datos.');
      }
      debugPrint("Base de datos inicializada correctamente.");
    } catch (e) {
      debugPrint("Error al inicializar la base de datos: $e");
    }
  }

  Future<void> _initializeDatabaseTraducciones() async {
    try {
      if (kIsWeb) {
        debugPrint("Inicializando base de datos para Web...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperTraduccionesWeb().initializeDatabase();
      } else if (Platform.isAndroid || Platform.isIOS) {
        debugPrint("Inicializando base de datos para Móviles...");
        await DatabaseHelperTraducciones().initializeDatabase();
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        debugPrint("Inicializando base de datos para Desktop...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperTraduccionesPc().initializeDatabase();
      } else {
        throw UnsupportedError(
            'Plataforma no soportada para la base de datos.');
      }
      debugPrint("Base de datos inicializada correctamente.");
    } catch (e) {
      debugPrint("Error al inicializar la base de datos: $e");
    }
  }

  Future<void> _requestLocationPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      PermissionStatus permission = PermissionStatus.denied;

      if (Platform.isAndroid) {
        permission = await Permission.locationWhenInUse.request();
        if (permission == PermissionStatus.granted) {
          permission = await Permission.locationAlways.request();
        }
      } else if (Platform.isIOS) {
        permission = await Permission.locationWhenInUse.request();
        if (permission == PermissionStatus.granted) {
          permission = await Permission.locationAlways.request();
        }
      }

      if (permission == PermissionStatus.denied ||
          permission == PermissionStatus.permanentlyDenied) {
        debugPrint("Permiso de ubicación denegado o denegado permanentemente.");
        openAppSettings();
      } else {
        debugPrint("Permisos de ubicación concedidos.");
      }
    }
  }

  // Función de traducción utilitaria
  String tr(BuildContext context, String key) {
    return Provider.of<TranslationProvider>(context, listen: false)
        .translate(key);
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: Column(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.15,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/recuadro.png',
                                      fit: BoxFit.fill,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Iniciar sesión')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: const Color(0xFF28E2F5),
                                                fontSize: 30.sp,
                                                fontWeight: FontWeight.w600,
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
                              // Campo para el nombre de usuario
                              SizedBox(height: screenHeight * 0.1),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        tr(context, 'Nombre de usuario')
                                            .toUpperCase(),
                                        style: _labelStyle),
                                    SizedBox(height: screenHeight * 0.01),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _user,
                                        keyboardType: TextInputType.text,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(
                                          hintText: tr(context, ''),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Campo para la contraseña con asteriscos visibles
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        tr(context, 'Contraseña').toUpperCase(),
                                        style: _labelStyle),
                                    SizedBox(height: screenHeight * 0.01),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _pwd,
                                        keyboardType: TextInputType.text,
                                        obscureText: true,
                                        // Esto oculta siempre el texto
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(
                                          hintText: tr(context, ''),
                                          suffixIcon:
                                              Icon(Icons.visibility_off),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Mensaje de error
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              // Botón de inicio de sesión
                              OutlinedButton(
                                onPressed: () async {
                                  // Cerrar el teclado
                                  FocusScope.of(context).unfocus();

                                  // Esperar un pequeño retraso para asegurar que el teclado se cierre
                                  await Future.delayed(const Duration(milliseconds: 300));

                                  // Llamar a la función de validación
                                  await _validateLogin();
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
        ],
      ),
    );
  }

  Future<void> _validateLogin() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    String username = _user.text.trim();
    String password = _pwd.text.trim();

    // Verificar en la base de datos si las credenciales del usuario son correctas
    bool userExists = await dbHelper.checkUserCredentials(username, password);

    if (userExists) {
      // Si las credenciales son correctas, limpiar el mensaje de error
      setState(() {
        _errorMessage = ''; // Limpiar error
      });

      // Obtener el userId después de la autenticación
      int userId = await dbHelper.getUserIdByUsername(username); // Asegúrate de tener esta función

      // Obtener el tipo de perfil del usuario
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId);

      // Imprimir el userId y el tipo de perfil en consola
      print('User ID: $userId');
      print('Tipo de Perfil: $tipoPerfil');

      // Guardar el userId y tipo de perfil en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', userId); // Guardar el userId
      if (tipoPerfil != null) {
        prefs.setString('user_tipo_perfil', tipoPerfil); // Guardar el tipo de perfil
      }

      // Retraso antes de navegar
      await Future.delayed(const Duration(seconds: 1)); // Retraso de 1 segundo

      // Navegar al menú principal
      widget.onNavigateToMainMenu();
    } else {
      // Si las credenciales son incorrectas, mostrar el mensaje de error
      setState(() {
        _errorMessage = "Usuario o contraseña incorrectos"; // Mostrar error
      });
    }
  }


}

// Ajustes de estilos para simplificar
TextStyle get _labelStyle => TextStyle(
    color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold);

TextStyle get _inputTextStyle =>
    TextStyle(color: Colors.white, fontSize: 17.sp);

InputDecoration _inputDecorationStyle(
    {String hintText = '', bool enabled = true, Widget? suffixIcon}) {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(0.2))),
    fillColor: Colors.transparent,
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
    enabled: enabled,
    suffixIcon: suffixIcon,
  );
}

BoxDecoration _inputDecoration() {
  return BoxDecoration(
      color: Colors.black12.withOpacity(0.2),
      borderRadius: BorderRadius.circular(7));
}
