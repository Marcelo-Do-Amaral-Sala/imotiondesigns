import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imotion_designs/src/app.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WakelockPlus.enable();

  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(App());
}
