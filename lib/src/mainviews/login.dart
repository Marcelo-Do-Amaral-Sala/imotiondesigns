import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/translation_utils.dart';

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
                                        obscureText: true, // Esto oculta siempre el texto
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(
                                          hintText: tr(context, ''),
                                          suffixIcon: Icon(Icons.visibility_off),
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
                                onPressed: () {
                                  _validateLogin();
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

  // Función para validar la contraseña y el usuario
  void _validateLogin() {
    setState(() {
      if (_pwd.text != "admin") {
        _errorMessage = "Contraseña incorrecta"; // Establecer mensaje de error
      } else {
        _errorMessage = ''; // Limpiar el mensaje de error
        widget.onNavigateToMainMenu(); // Navegar al menú principal
      }
    });
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
