import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imotion_designs/src/app.dart';
import 'package:imotion_designs/src/servicios/connectivity.dart';
import 'package:imotion_designs/src/servicios/sync.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await dotenv.load(fileName: ".env");
  WakelockPlus.enable();

  // Establece la orientación horizontal obligatoria
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final SyncService syncService = SyncService();

  // Sincronización inicial de Firebase a SQLite
  try {
    await syncService.syncFirebaseToSQLite();
  } catch (e) {
    print("Error durante la sincronización: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final connectivityService = ConnectivityService();
        connectivityService
            .startConnectivityCheck(); // Inicia la verificación de conectividad
        return connectivityService;
      },
      child: App(),
    ),
  );
}
