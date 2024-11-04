import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imotion_designs/src/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(App());
}
