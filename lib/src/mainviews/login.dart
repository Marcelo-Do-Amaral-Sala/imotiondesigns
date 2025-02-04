import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/translation_utils.dart';
import '../db/db_helper.dart';

class LoginView extends StatefulWidget {
  final Function() onNavigateToMainMenu;
  final Function(int userId) onNavigateToChangePwd;
  final double screenWidth;
  final double screenHeight;

  const LoginView({
    Key? key,
    required this.onNavigateToMainMenu,
    required this.screenWidth,
    required this.screenHeight,
    required this.onNavigateToChangePwd,
  }) : super(key: key);

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  String _errorMessage = ''; // Para almacenar el mensaje de error


  final FocusNode _userFocusNode = FocusNode(); // 🔹 FocusNode para usuario
  final FocusNode _pwdFocusNode = FocusNode();
  List<Map<String, dynamic>> allAdmins = []; // Lista original de clientes
  List<Map<String, dynamic>> filteredAdmins = []; // Lista filtrada

  int? userId;
  String? userTipoPerfil;

  bool _isPasswordHidden = true;
  double scaleFactorBack = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationPermissions();
    _fetchAdmins();
    _checkUserProfile();
    clearFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _user.dispose();
    _pwd.dispose();
    _userFocusNode.dispose(); // 🔹 Liberar recursos
    _pwdFocusNode.dispose();
  }

  void clearFields() {
    if (!mounted) return; // 🔹 Evita errores si el widget se desmontó


    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        _isPasswordHidden = true;
        _user.clear();
        _pwd.clear();
        _errorMessage = '';
      });
    });
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

  Future<void> _fetchAdmins() async {
    final dbHelper = DatabaseHelper();
    try {
      // Obtener los usuarios cuyo perfil es "Administrador" o "Ambos"
      final adminData =
          await dbHelper.getUsuariosPorTipoPerfil('Administrador');
      final adminDataEntrenador =
          await dbHelper.getUsuariosPorTipoPerfil('Entrenador');
      // También podemos obtener usuarios con el tipo de perfil 'Ambos' si es necesario
      final adminDataAmbos = await dbHelper.getUsuariosPorTipoPerfil('Ambos');

      // Combina todas las listas
      final allAdminData = [
        ...adminData,
        ...adminDataAmbos,
        ...adminDataEntrenador
      ];

      // Imprime la información de todos los usuarios obtenidos
      print('Información de todos los usuarios:');
      for (var admin in allAdminData) {
        print(
            admin); // Asegúrate de que admin tenga un formato imprimible (e.g., Map<String, dynamic>)
      }

      setState(() {
        allAdmins = allAdminData; // Asigna los usuarios filtrados
        filteredAdmins = allAdmins; // Inicializa la lista filtrada
      });
    } catch (e) {
      print('Error fetching clients: $e');
    }
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

  Future<void> _closeApp(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.2,
            padding:  EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height *0.01, horizontal: MediaQuery.of(context).size.height *0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width:  MediaQuery.of(context).size.height *0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  ('¿${tr(context, 'Cerrar aplicación')}?').toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF2be4f3),
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Cierra el diálogo sin hacer nada
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2be4f3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        tr(context, 'Cancelar').toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFF2be4f3),
                          fontSize: 17.sp,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        // Cerrar la app completamente y detenerla
                        if (Platform.isAndroid || Platform.isIOS) {
                          exit(0); // Cerrar la app por completo
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        tr(context, 'Cerrar aplicación').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                        ),
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
                                      padding:  EdgeInsets.symmetric( horizontal: screenWidth * 0.005,
                                        vertical: screenHeight * 0.002,),
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
                                        focusNode: _userFocusNode, // 🔹 Asigna FocusNode al campo de usuario
                                        keyboardType: TextInputType.text,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(
                                          hintText: tr(context, ''),
                                        ),
                                        textInputAction: TextInputAction.next, // Muestra "Siguiente" en el teclado
                                        onSubmitted: (_) {
                                          FocusScope.of(context).requestFocus(_pwdFocusNode); // 🔹 Mueve el foco al campo de contraseña
                                        },
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
                                        focusNode: _pwdFocusNode, // 🔹 Asigna FocusNode al campo de contraseña
                                        keyboardType: TextInputType.text,
                                        obscureText: _isPasswordHidden,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(
                                          hintText: tr(context, ''),
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isPasswordHidden = !_isPasswordHidden;
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(right: screenWidth * 0.01),
                                              width: screenWidth * 0.01,
                                              height: screenHeight * 0.01,
                                              child: Image.asset(
                                                _isPasswordHidden ? 'assets/images/ojo1.png' : 'assets/images/ojo2.png',
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done, // Muestra "Hecho" en el teclado
                                        onSubmitted: (_) {
                                          FocusScope.of(context).unfocus(); // 🔹 Cierra el teclado al presionar "Hecho"
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Mensaje de error
                              if (_errorMessage.isNotEmpty)
                                  Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                              // Botón de inicio de sesión
                              OutlinedButton(
                                onPressed: () async {
                                  // Cerrar el teclado
                                  FocusScope.of(context).unfocus();

                                  // Esperar un pequeño retraso para asegurar que el teclado se cierre
                                  await Future.delayed(
                                      const Duration(milliseconds: 300));

                                  // Llamar a la función de validación
                                  await _validateLogin();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(10.0),
                                  side:  BorderSide(
                                      width: screenWidth*0.001, color: const Color(0xFF2be4f3)),
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
                        child: Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  _closeApp(context);
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorBack,
                                  duration: const Duration(milliseconds: 100),
                                  child: SizedBox(
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/apagar.png',
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

    bool userExists = await dbHelper.checkUserCredentials(username, password);

    if (userExists) {
      setState(() {
        _errorMessage = ''; // Limpiar error
      });

      int userId = await dbHelper.getUserIdByUsername(username);
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId);

      print('User ID: $userId');
      print('Tipo de Perfil: $tipoPerfil');

      if (password == "0000") {
        // 🔹 Pasar userId al navegar a ChangePwd
        widget.onNavigateToChangePwd(userId);
      } else {
        // 🔹 Guardar userId solo si va al MainMenu
        await _saveUserToPrefs(userId, tipoPerfil);

        await Future.delayed(const Duration(seconds: 1));
        widget.onNavigateToMainMenu();
      }
    } else {
      setState(() {
        _errorMessage = tr(context, 'Usuario o contraseña incorrectos');
      });
    }
  }


  /// 🔹 Función para guardar el userId en SharedPreferences
  Future<void> _saveUserToPrefs(int userId, String? tipoPerfil) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Limpiar datos previos antes de guardar
    await prefs.remove('user_id');
    await prefs.remove('user_tipo_perfil');

    // Guardar nuevos valores
    await prefs.setInt('user_id', userId);
    if (tipoPerfil != null) {
      await prefs.setString('user_tipo_perfil', tipoPerfil);
    }

    // Confirmar en consola
    print('✅ Usuario guardado: ID=$userId, TipoPerfil=${tipoPerfil ?? "N/A"}');
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
