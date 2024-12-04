import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imotion_designs/src/ajustes/form/licencia_form.dart';
import 'package:imotion_designs/src/mainviews/main_menu.dart';
import 'package:imotion_designs/src/panel/views/panel_view.dart';
import 'package:imotion_designs/src/programs/programs_menu.dart';
import 'package:imotion_designs/src/servicios/simulacion_ia.dart';
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

  void navigateTo(String view) {
    setState(() {
      currentView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget viewToDisplay;

    switch (currentView) {
      case 'panel':
        viewToDisplay = PanelView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
        );
        break;
      case 'clients':
        viewToDisplay = ClientsView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
        );
        break;

      case 'programs':
        viewToDisplay = ProgramsMenuView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
        );
        break;
      case 'tutoriales':
        viewToDisplay = TutorialesMenuView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
        );
        break;
      case 'ajustes':
        viewToDisplay = AjustesMenuView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
          onNavigatetoLicencia: () => navigateTo('licencia'),
          onNavigatetoGestion: () => navigateTo('gestion'),
        );
        break;

      case 'gestion':
        viewToDisplay = GestionMenuView(
          onBack: () =>
              navigateTo('ajustes'), // Callback para volver a MainMenuView
        );
        break;

      case 'licencia':
        viewToDisplay = LicenciaFormView(
          onBack: () =>
              navigateTo('ajustes'), // Callback para volver a MainMenuView
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
      /* case 'json':
      default:
        viewToDisplay=UploadJsonView();
        break;*/
    }

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.oswaldTextTheme(),
      ),
      home: Scaffold(
        body: viewToDisplay,
      ),
    );
  }
}
