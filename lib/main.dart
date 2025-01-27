import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/app.dart';
import 'package:imotion_designs/src/panel/overlays/overlay_panel.dart';
import 'package:imotion_designs/src/servicios/licencia_state.dart';
import 'package:imotion_designs/src/servicios/provider.dart';
import 'package:imotion_designs/src/servicios/sync.dart';
import 'package:imotion_designs/src/servicios/translation_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  WakelockPlus.enable();

  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

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
  print(
      'Idioma cargado en main.dart: ${AppStateIdioma.instance.currentLanguage}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TranslationProvider()
            ..changeLanguage(AppStateIdioma
                .instance.currentLanguage), // Cargar el idioma guardado
        ),
        ChangeNotifierProvider(
          create: (_) => ClientsProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1200, 1920),
        // Tamaño base de la tablet Galaxy A8
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Aquí obtienes las restricciones máximas de ancho y alto de la pantalla
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              // Ajusta el diseño de acuerdo al tamaño disponible
              return App(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              );
            },
          );
        },
      ),
    ),
  );
}
