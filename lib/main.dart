import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔹 Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // 🔹 Mantener pantalla encendida
  WakelockPlus.enable();

  // 🔹 Configurar SQLite para escritorio
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 🔹 Bloquear orientación en horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  // 🔹 Instancias de servicios
  final SyncService syncService = SyncService();
  final TranslationProvider translationProvider = TranslationProvider();

  // 🔹 Ejecutar sincronización y carga de idioma en paralelo
  await Future.wait([
    syncService.syncFirebaseToSQLite(),
    AppStateIdioma.instance.loadLanguage(),
  ]);

  // 🔹 Cargar idioma guardado
  final String savedLanguage = AppStateIdioma.instance.currentLanguage;
  await translationProvider.changeLanguage(savedLanguage);

  print('✅ Idioma cargado en main.dart: $savedLanguage');
  await ScreenUtil.ensureScreenSize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => translationProvider,
          lazy: false, // 🔹 Se inicializa inmediatamente
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
              return SafeArea( // 🔹 Se agregó SafeArea para evitar notch o barras del sistema
                child: App(
                  screenWidth: constraints.maxWidth,
                  screenHeight: constraints.maxHeight,
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
