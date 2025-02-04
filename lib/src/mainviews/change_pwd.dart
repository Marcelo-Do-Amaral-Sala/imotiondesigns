
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/translation_utils.dart';
import '../clients/overlays/main_overlay.dart';
import '../db/db_helper.dart';

class ChangePwdView extends StatefulWidget {
  final Function() onNavigateToLogin;
  final int userId;
  final double screenWidth;
  final double screenHeight;

  const ChangePwdView({
    Key? key,
    required this.onNavigateToLogin,
    required this.screenWidth,
    required this.screenHeight, required this.userId,
  }) : super(key: key);

  @override
  State<ChangePwdView> createState() => _ChangePwdViewState();
}

class _ChangePwdViewState extends State<ChangePwdView> {
  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  final GlobalKey<OverlayChangePwdState> _overlayKey = GlobalKey<OverlayChangePwdState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      isOverlayVisible = true; // 🔹 Asegurar que el overlay esté visible al iniciar
      overlayIndex = 0;
    });
  }

  void clearOverlayFields() {
    _overlayKey.currentState?.clearFields(); // ✅ Limpiar los campos del overlay
  }
  void toggleOverlay(int index) {
    setState(() {
      if (!isOverlayVisible) {
        isOverlayVisible = true;  // 🔹 Asegurar que siempre se muestra si está oculto
      }
      overlayIndex = index;
    });
  }


  @override
  void dispose() {
    _overlayKey.currentState?.clearFields();
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
          key: _overlayKey,
          userId: widget.userId, // 🔹 Pasamos userId correctamente
          onClose: () => toggleOverlay(0),
          onNavigateToLogin: widget.onNavigateToLogin,
        );
      default:
        return Container();
    }
  }

}

class OverlayChangePwd extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onNavigateToLogin;
  final int userId;

  const OverlayChangePwd({
    Key? key,
    required this.onClose,
    required this.onNavigateToLogin, required this.userId,
  }) : super(key: key);

  @override
  OverlayChangePwdState createState() => OverlayChangePwdState();
}

class OverlayChangePwdState extends State<OverlayChangePwd> {
  final TextEditingController _pwd = TextEditingController();
  final TextEditingController _pwd2 = TextEditingController();
  int? userId;
  String? userTipoPerfil;
  bool _isPasswordHidden = true;
  bool _isPassword2Hidden = true;
  final FocusNode _pwdFocusNode = FocusNode();
  final FocusNode _pwd2FocusNode = FocusNode();
  @override
  void initState() {
    clearFields();
    super.initState();
  }
  void clearFields() {
    setState(() {
      _isPasswordHidden = true;
      _isPassword2Hidden = true;
      _pwd2.clear();
      _pwd.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    _pwdFocusNode.dispose(); // 🔹 Liberar recursos del FocusNode
    _pwd2FocusNode.dispose();
  }

  Future<void> _updatePassword() async {
    int userId = widget.userId; // 🔹 Tomamos el userId directamente

    if (_pwd.text != _pwd2.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    if (_pwd.text == '0000') {
      _showError('La contraseña no puede ser "0000"');
      return;
    }

    try {
      final clientData = {'pwd': _pwd.text};
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUser(userId, clientData);

      print('Contraseña actualizada correctamente para el usuario con ID $userId.');

      if (mounted) {
        _showSuccess('Contraseña actualizada con éxito');
        clearFields();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            widget.onNavigateToLogin(); // ✅ Solo navegar si sigue montado
          }
        });
      }
    } catch (e) {
      print('Error al actualizar la contraseña: $e');
      if (mounted) _showError('Error al resetear la contraseña');
    }

  }

  void _showError(String message) {
    if (!mounted) return; // ✅ Evita errores si el widget fue desmontado

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(context, message).toUpperCase()),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return; // ✅ Evita errores si el widget fue desmontado

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr(context, message).toUpperCase()),
        backgroundColor: Colors.green,
      ),
    );


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
                      focusNode: _pwdFocusNode,
                      // 🔹 Asigna FocusNode al campo de contraseña
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
                            padding: const EdgeInsets.only(right: 10.0),
                            width: screenWidth * 0.01,
                            height: screenHeight * 0.01,
                            child: Image.asset(
                              _isPasswordHidden
                                  ? 'assets/images/ojo1.png'
                                  : 'assets/images/ojo2.png',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      // 🔹 Muestra "Siguiente" en el teclado
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(
                            _pwd2FocusNode); // 🔹 Mueve el foco al campo de repetir contraseña
                      },
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
                      focusNode: _pwd2FocusNode,
                      // 🔹 Asigna FocusNode al campo de repetir contraseña
                      keyboardType: TextInputType.text,
                      obscureText: _isPassword2Hidden,
                      style: _inputTextStyle,
                      decoration: _inputDecorationStyle(
                        hintText: tr(context, ''),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPassword2Hidden = !_isPassword2Hidden;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 10.0),
                            width: screenWidth * 0.01,
                            height: screenHeight * 0.01,
                            child: Image.asset(
                              _isPassword2Hidden
                                  ? 'assets/images/ojo1.png'
                                  : 'assets/images/ojo2.png',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      // 🔹 Muestra "Hecho" en el teclado
                      onSubmitted: (_) {
                        FocusScope.of(context)
                            .unfocus(); // 🔹 Cierra el teclado al presionar "Hecho"
                      },
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
