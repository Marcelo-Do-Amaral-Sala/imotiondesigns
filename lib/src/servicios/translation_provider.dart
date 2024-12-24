import 'package:flutter/material.dart';
import '../db/db_helper_traducciones.dart';
import 'licencia_state.dart'; // Asegúrate de importar AppStateIdioma

class TranslationProvider with ChangeNotifier {
  Map<String, String> _translations = {};
  Map<String, Map<String, String>> _translationsCache =
      {}; // Caché de traducciones

  Map<String, String> get translations => _translations;

  Future<void> changeLanguage(String language) async {
    if (_translationsCache.containsKey(language)) {
      // Si las traducciones ya están en caché, las usamos directamente
      _translations = Map<String, String>.from(_translationsCache[language]!);
      notifyListeners();
    } else {
      // Si no están en caché, las cargamos desde la base de datos
      await _fetchTranslationsFromDatabase(language);
    }
  }

  // Cargar traducciones desde la base de datos
  Future<void> _fetchTranslationsFromDatabase(String language) async {
    final translations =
        await DatabaseHelperTraducciones().getTranslationsByLanguage(language);

    // Actualizamos el caché
    _translationsCache[language] = Map<String, String>.from(translations);

    // Actualizamos las traducciones y notificamos a los listeners
    _translations = Map<String, String>.from(translations);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[key] ??
        key; // Devuelve la clave si no encuentra la traducción
  }
}
