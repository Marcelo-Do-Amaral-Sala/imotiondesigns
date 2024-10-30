import 'package:flutter/material.dart';
import 'package:imotion_designs/src/mainviews/main_menu.dart';
import 'mainviews/clients_main_view.dart';

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
      case 'clients':
        viewToDisplay = ClientsView(
          onBack: () =>
              navigateTo('mainMenu'), // Callback para volver a MainMenuView
        );
        break;
      case 'mainMenu':
      default:
        viewToDisplay = MainMenuView(
          onNavigateToClients: () => navigateTo('clients'),
        );
        break;
    }

    return MaterialApp(
      home: Scaffold(
        body: viewToDisplay,
      ),
    );
  }
}
