import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/servicios/translation_provider.dart'; // Ajusta la ruta

/// Función global para traducir claves
String tr(BuildContext context, String key) {
  return Provider.of<TranslationProvider>(context, listen: false).translate(key);
}
