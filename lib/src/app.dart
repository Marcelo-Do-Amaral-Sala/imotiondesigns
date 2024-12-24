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
  App({Key? key}) : super(key: key);

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

    switch (currentView) {
      case 'panel':
        viewToDisplay = PanelView(
          key: panelViewKey, // Usar la clave única para PanelView
          onBack: () => navigateTo('mainMenu'),
          onReset: () =>
              navigateTo('panel'), // Manejo de reinicio solo para Panel
        );
        break;
      case 'json':
        viewToDisplay = UploadJsonView();
        break;
      case 'clients':
        viewToDisplay = ClientsView(
          onBack: () => navigateTo('mainMenu'),
        );
        break;
      case 'programs':
        viewToDisplay = ProgramsMenuView(
          onBack: () => navigateTo('mainMenu'),
        );
        break;
      case 'tutoriales':
        viewToDisplay = TutorialesMenuView(
          onBack: () => navigateTo('mainMenu'),
        );
        break;
      case 'ajustes':
        viewToDisplay = AjustesMenuView(
          onBack: () => navigateTo('mainMenu'),
          onNavigatetoLicencia: () => navigateTo('licencia'),
          onNavigatetoGestion: () => navigateTo('gestion'),
        );
        break;
      case 'gestion':
        viewToDisplay = GestionMenuView(
          onBack: () => navigateTo('ajustes'),
        );
        break;
      case 'licencia':
        viewToDisplay = LicenciaFormView(
          onBack: () => navigateTo('ajustes'),
          onMciTap: (mciData) {
            selectMCI(mciData);
          },
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
  }
}
