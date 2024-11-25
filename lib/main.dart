import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imotion_designs/src/app.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  WakelockPlus.enable();


  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(App());
}
