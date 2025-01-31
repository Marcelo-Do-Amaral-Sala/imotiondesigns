import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imotion_designs/src/panel/views/panel_view.dart';
import 'package:imotion_designs/src/programs/programs_menu.dart';
import 'package:imotion_designs/src/servicios/json.dart';
import 'package:imotion_designs/src/tutoriales/menus/menu_tutoriales.dart';
import 'ajustes/form/licencia_form.dart';
import 'ajustes/menus/ajustes_menu.dart';
import 'ajustes/menus/gestion_menu.dart';
import 'clients/clients_main_view.dart';
import 'mainviews/change_pwd.dart';
import 'mainviews/login.dart';
import 'mainviews/main_menu.dart';
import 'mainviews/splash_view.dart';

class App extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  App({Key? key, required this.screenWidth, required this.screenHeight}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0; // 🔹 Controla la vista activa
  Map<String, dynamic>? selectedMciData;

  @override
  void initState() {
    super.initState();
  }


  void selectMCI(Map<String, dynamic> mciData) {
    setState(() {
      selectedMciData = mciData;
    });
  }

  void changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 🔹 Función para abrir `PanelView` como pantalla independiente
  void openPanelView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PanelView(
          onBack: () => Navigator.pop(context), // 🔹 Vuelve al menú principal
          onReset: () => openPanelView(), // 🔹 Reinicia el panel desde cero
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.oswaldTextTheme(),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            // 🔹 0 - Splash Screen (se muestra primero)
            SplashView(
              onNavigateToMainMenu: () => changePage(1),
              onNavigateToLogin: () => changePage(9),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 1 - Menú Principal
            MainMenuView(
              onNavigateToLogin: () => changePage(9),
              onNavigateToPanel: openPanelView, // 🔹 Abre `PanelView` con `Navigator`
              onNavigateToClients: () => changePage(2),
              onNavigateToPrograms: () => changePage(3),
              onNavigateToAjustes: () => changePage(4),
              onNavigateToTutoriales: () => changePage(5),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 2 - Clientes
            ClientsView(
              onBack: () => changePage(1),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 3 - Programas
            ProgramsMenuView(
              onBack: () => changePage(1),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 4 - Ajustes
            AjustesMenuView(
              onBack: () => changePage(1),
              onNavigatetoLicencia: () => changePage(6),
              onNavigatetoGestion: () => changePage(7),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 5 - Tutoriales
            TutorialesMenuView(
              onBack: () => changePage(1),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 6 - Licencia
            LicenciaFormView(
              onBack: () => changePage(4),
              onMciTap: (mciData) {
                selectMCI(mciData);
              },
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 7 - Gestión
            GestionMenuView(
              onBack: () => changePage(4),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 8 - Cambio de Contraseña
            ChangePwdView(
              onNavigateToMainMenu: () => changePage(1),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
            // 🔹 9 - Login
            LoginView(
              onNavigateToMainMenu: () => changePage(1),
              onNavigateToChangePwd: () => changePage(8),
              screenWidth: widget.screenWidth,
              screenHeight: widget.screenHeight,
            ),
          ],
        ),
      ),
    );
  }
}
