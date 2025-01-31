import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/app.dart';
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

  // 🔹 Sincronización inicial de Firebase a SQLite antes de iniciar la app
  try {
    await syncService.syncFirebaseToSQLite();
  } catch (e) {
    print("Error durante la sincronización: $e");
  }

  // 🔹 Cargar el idioma guardado ANTES de ejecutar la app
  await AppStateIdioma.instance.loadLanguage();
  final String savedLanguage = AppStateIdioma.instance.currentLanguage;

  // 🔹 Esperamos a que TranslationProvider cargue el idioma antes de `runApp`
  final TranslationProvider translationProvider = TranslationProvider();
  await translationProvider.changeLanguage(savedLanguage);

  print('Idioma cargado en main.dart: $savedLanguage');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => translationProvider, // 🔹 Ya tiene el idioma cargado
        ),
        ChangeNotifierProvider(
          create: (_) => ClientsProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1200, 1920),
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

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

