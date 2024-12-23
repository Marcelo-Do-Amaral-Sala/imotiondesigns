import 'package:flutter/material.dart';
import '../db/db_helper_traducciones.dart';
import 'licencia_state.dart';  // Asegúrate de importar AppStateIdioma

class TranslationProvider extends ChangeNotifier {
  final DatabaseHelperTraducciones _dbHelper = DatabaseHelperTraducciones();
  String _currentLanguage = 'es'; // Idioma predeterminado
  Map<String, String> _translations = {}; // Traducciones actuales

  String get currentLanguage => _currentLanguage;
  Map<String, String> get translations => _translations;

  // Cambia el idioma y recarga las traducciones
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    _translations = await _dbHelper.getTranslationsByLanguage(languageCode);
    notifyListeners(); // Notificar a los widgets para que se actualicen
  }

  // Traduce una clave
  String translate(String key) {
    return _translations[key] ?? key; // Retorna la clave si no hay traducción
  }
}

