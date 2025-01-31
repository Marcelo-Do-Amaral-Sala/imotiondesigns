import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  final Function() onNavigateToMainMenu;
  final Function() onNavigateToLogin;
  final double screenWidth;
  final double screenHeight;

  const SplashView({
    Key? key,
    required this.onNavigateToMainMenu,
    required this.screenWidth,
    required this.screenHeight,
    required this.onNavigateToLogin,
  }) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _canNavigate = false; // 🔹 Evita la navegación automática

  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(seconds: 2)); // 🔹 Esperamos 2 segundos
    setState(() {
      _canNavigate = true; // 🔹 Permitimos la navegación solo cuando el usuario toque la pantalla
    });
  }

  Future<void> _navigateIfAllowed() async {
    if (!_canNavigate) return; // 🔹 No navegar si el tiempo no ha pasado

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      widget.onNavigateToMainMenu();
    } else {
      widget.onNavigateToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateIfAllowed, // 🔹 Solo navega cuando el usuario toca la pantalla
      child: Scaffold(
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
                horizontal: widget.screenWidth * 0.02,
                vertical: widget.screenHeight * 0.07,
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
                              horizontal: widget.screenWidth * 0.05,
                              vertical: widget.screenHeight * 0.02,
                            ),
                          ),
                        ),
                        SizedBox(width: widget.screenWidth * 0.01),
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
      ),
    );
  }
}
