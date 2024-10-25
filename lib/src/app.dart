import 'package:flutter/material.dart';
import 'package:imotion_designs/src/views/clients_views.dart';


class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      initialRoute: '/ClientsMenu',
      routes: {
        '/ClientsMenu': (context) => const ClientsView(),

      },
    );
  }
}
