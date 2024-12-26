import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imotion_designs/src/ajustes/form/licencia_form.dart';
import 'package:imotion_designs/src/mainviews/main_menu.dart';
import 'package:imotion_designs/src/panel/views/panel_view.dart';
import 'package:imotion_designs/src/programs/programs_menu.dart';
import 'package:imotion_designs/src/servicios/json.dart';
import 'package:imotion_designs/src/tutoriales/menus/menu_tutoriales.dart';
import 'ajustes/menus/ajustes_menu.dart';
import 'ajustes/menus/gestion_menu.dart';
import 'clients/clients_main_view.dart';

class App extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  App({Key? key, required this.screenWidth, required this.screenHeight}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  String currentView = 'mainMenu';
  Key? panelViewKey = UniqueKey(); // Clave única solo para PanelView
  Map<String, dynamic>? selectedMciData;

  void selectMCI(Map<String, dynamic> mciData) {
    setState(() {
      selectedMciData = mciData;
    });
  }

  void navigateTo(String view) {
    setState(() {
      currentView = view;
      if (view == 'panel') {
        panelViewKey = UniqueKey(); // Generar una nueva clave si es PanelView
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget viewToDisplay;

    // Usamos LayoutBuilder para obtener las restricciones de tamaño de la pantalla
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtiene el tamaño disponible de la pantalla
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        // Aquí ajustamos la vista según el tamaño disponible
        switch (currentView) {
          case 'panel':
            viewToDisplay = PanelView(
              key: panelViewKey, // Usar la clave única para PanelView
              onBack: () => navigateTo('mainMenu'),
              onReset: () => navigateTo('panel'), // Manejo de reinicio solo para Panel
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'json':
            viewToDisplay = UploadJsonView();
            break;
          case 'clients':
            viewToDisplay = ClientsView(
              onBack: () => navigateTo('mainMenu'),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
            break;
          case 'programs':
            viewToDisplay = ProgramsMenuView(
              onBack: () => navigateTo('mainMenu'),
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'tutoriales':
            viewToDisplay = TutorialesMenuView(
              onBack: () => navigateTo('mainMenu'),
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'ajustes':
            viewToDisplay = AjustesMenuView(
              onBack: () => navigateTo('mainMenu'),
              onNavigatetoLicencia: () => navigateTo('licencia'),
              onNavigatetoGestion: () => navigateTo('gestion'),
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'gestion':
            viewToDisplay = GestionMenuView(
              onBack: () => navigateTo('ajustes'),
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'licencia':
            viewToDisplay = LicenciaFormView(
              onBack: () => navigateTo('ajustes'),
              onMciTap: (mciData) {
                selectMCI(mciData);
              },
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
          case 'mainMenu':
          default:
            viewToDisplay = MainMenuView(
              onNavigateToPanel: () => navigateTo('panel'),
              onNavigateToClients: () => navigateTo('clients'),
              onNavigateToPrograms: () => navigateTo('programs'),
              onNavigateToAjustes: () => navigateTo('ajustes'),
              onNavigateToTutoriales: () => navigateTo('tutoriales'),
              screenWidth: screenWidth, // Pasa el tamaño disponible
              screenHeight: screenHeight,
            );
            break;
        }

        return MaterialApp(
          theme: ThemeData(
            textTheme: GoogleFonts.oswaldTextTheme(),
          ),
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            body: viewToDisplay,
          ),
        );
      },
    );
  }
}
