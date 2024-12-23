import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/app.dart';
import 'package:imotion_designs/src/servicios/licencia_state.dart';
import 'package:imotion_designs/src/servicios/sync.dart';
import 'package:imotion_designs/src/servicios/translation_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await dotenv.load(fileName: ".env");
  WakelockPlus.enable();

  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  final SyncService syncService = SyncService();

  // Sincronización inicial de Firebase a SQLite
  try {
    await syncService.syncFirebaseToSQLite();
  } catch (e) {
    print("Error durante la sincronización: $e");
  }

  // Cargar el idioma guardado al inicio
  await AppStateIdioma.instance.loadLanguage();

  // Verificación: imprimir el idioma cargado
  print('Idioma cargado en main.dart: ${AppStateIdioma.instance.currentLanguage}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TranslationProvider()..changeLanguage(AppStateIdioma.instance.currentLanguage), // Cargar el idioma guardado
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1200, 1920),  // Tamaño base de la tablet Galaxy A8
        builder: (context, child) {
          return App(); // Aquí colocamos el widget raíz como child de MultiProvider
        },
      ),
    ),
  );
}



