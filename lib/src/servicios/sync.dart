import 'package:imotion_designs/src/servicios/translation.dart';
import '../db/db_helper_traducciones.dart';


class SyncService {
  final TranslationService _translationService = TranslationService();
  final DatabaseHelperTraducciones _databaseHelperTraducciones = DatabaseHelperTraducciones();

  /// Sincroniza las traducciones de Firebase con SQLite.
  Future<void> syncFirebaseToSQLite() async {
    try {
      // Paso 1: Descargar traducciones desde Firebase
      final Map<String, dynamic> firebaseTranslations =
      await _translationService.fetchTranslations();

      // Paso 2: Guardar las traducciones en SQLite
      await _databaseHelperTraducciones.insertOrUpdateMultipleTranslations(firebaseTranslations);

      print("Sincronización completada: datos guardados localmente.");
    } catch (e) {
      print("Error durante la sincronización: $e");
    }
  }

}