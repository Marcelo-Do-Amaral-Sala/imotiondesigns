import 'package:flutter/material.dart';
import '../db/db_helper_traducciones.dart';

class TranslationProvider extends ChangeNotifier {
  final DatabaseHelperTraducciones _dbHelper = DatabaseHelperTraducciones();
  String _currentLanguage = 'es';
  Map<String, String> _translations = {};

  String get currentLanguage => _currentLanguage;

  /// Obtiene traducciones actuales
  Map<String, String> get translations => _translations;

  /// Cambia el idioma y recarga las traducciones
  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;

    // Carga las traducciones desde SQLite
    _translations = await _dbHelper.getTranslationsByLanguage(languageCode);

    notifyListeners(); // Notifica a los widgets para que se actualicen
  }

  /// Traduce una clave
  String translate(String key) {
    return _translations[key] ?? key; // Retorna la clave si no hay traducción
  }
}
