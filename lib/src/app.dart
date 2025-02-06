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
  int _changePwdUserId=0;
  int _selectedIndex = 0; // 🔹 Controla la vista activa
  Map<String, dynamic>? selectedMciData;
  final GlobalKey<LoginViewState> _loginKey = GlobalKey<LoginViewState>();
  final GlobalKey<MainMenuViewState> _menuKey = GlobalKey<MainMenuViewState>();
  final GlobalKey<OverlayChangePwdState> _changePwd = GlobalKey<OverlayChangePwdState>();

  @override
  void initState() {
    super.initState();
  }


  void selectMCI(Map<String, dynamic> mciData) {
    setState(() {
      selectedMciData = mciData;
    });
  }

  void changePage(int index, {int? userId}) {
    if (_selectedIndex == 9 && index != 9) {
      _loginKey.currentState?.clearFields();
    }
    if (_selectedIndex == 1 && index == 9) {
      _menuKey.currentState?.clearLoginData();
    }
    if (_selectedIndex == 8 && index == 8) {
      _changePwd.currentState?.clearFields();
    }

    // 🔹 Ocultar el teclado al cambiar de pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    setState(() {
      _selectedIndex = index;
    });

    if (index == 8 && userId != null) {
      _changePwdUserId = userId;
    }

    if (index == 1) {
      _menuKey.currentState?.checkUserProfile();
      _menuKey.currentState?.checkAppState();
    }
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
      home: GestureDetector(
        behavior: HitTestBehavior.opaque, // 🔹 Captura toques fuera de widgets interactivos
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus(); // 🔹 Cierra el teclado al tocar fuera
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              SplashView(
                onNavigateToMainMenu: () => changePage(1),
                onNavigateToLogin: () => changePage(9),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              MainMenuView(
                key: _menuKey,
                onNavigateToLogin: () => changePage(9),
                onNavigateToPanel: () => openPanelView(),
                onNavigateToClients: () => changePage(2),
                onNavigateToPrograms: () => changePage(3),
                onNavigateToAjustes: () => changePage(4),
                onNavigateToTutoriales: () => changePage(5),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              ClientsView(
                onBack: () => changePage(1),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              ProgramsMenuView(
                onBack: () => changePage(1),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              AjustesMenuView(
                onBack: () => changePage(1),
                onNavigatetoLicencia: () => changePage(6),
                onNavigatetoGestion: () => changePage(7),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              TutorialesMenuView(
                onBack: () => changePage(1),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              LicenciaFormView(
                onBack: () => changePage(4),
                onMciTap: (mciData) {
                  selectMCI(mciData);
                },
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              GestionMenuView(
                onBack: () => changePage(4),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              ChangePwdView(
                key: _changePwd,
                userId: _changePwdUserId,
                onNavigateToLogin: () => changePage(9),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              LoginView(
                key: _loginKey,
                onNavigateToMainMenu: () => changePage(1),
                onNavigateToChangePwd: (int userId) => changePage(8, userId: userId),
                screenWidth: widget.screenWidth,
                screenHeight: widget.screenHeight,
              ),
              UploadJsonView(),
            ],
          ),
        ),
      ),
    );
  }

}
