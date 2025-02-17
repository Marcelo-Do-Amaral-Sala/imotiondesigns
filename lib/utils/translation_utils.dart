import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/traductions/translation_provider.dart'; // Ajusta la ruta

/// Función global para traducir claves
String tr(BuildContext context, String key, {Map<String, String>? namedArgs}) {
  String translatedText = Provider.of<TranslationProvider>(context, listen: false).translate(key);

  // Si hay argumentos dinámicos, reemplaza los placeholders
  if (namedArgs != null) {
    namedArgs.forEach((placeholder, value) {
      translatedText = translatedText.replaceAll('{$placeholder}', value);
    });
  }

  return translatedText;
}
