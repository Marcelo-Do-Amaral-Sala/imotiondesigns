import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  // Atributos para guardar los valores
  String nLicencia = '';
  String nombre = '';
  String direccion = '';
  String ciudad = '';
  String provincia = '';
  String pais = '';
  String telefono = '';
  String email = '';
  bool isLicenciaValida = false;
  List<String> macList = [];
  List<String> macBleList = [];
  String bloqueada = '';
  Map<String, dynamic> licenciaData = {};
  List<Map<String, dynamic>> allLicencias = [];
  List<Map<String, dynamic>> mcis = []; // Lista de MCIs
  double tiempoSesion = 25;

  // Constructor privado para el patrón Singleton
  AppState._privateConstructor();

  // Instancia Singleton
  static final AppState _instance = AppState._privateConstructor();

  // Obtener la instancia de la clase
  static AppState get instance => _instance;

  // Función para cargar el estado desde SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar datos
    nLicencia = prefs.getString('nLicencia') ?? '';
    nombre = prefs.getString('name') ?? '';
    direccion = prefs.getString('adress') ?? '';
    ciudad = prefs.getString('city') ?? '';
    provincia = prefs.getString('provincia') ?? '';
    pais = prefs.getString('country') ?? '';
    telefono = prefs.getString('phone') ?? '';
    email = prefs.getString('email') ?? '';
    isLicenciaValida = prefs.getBool('isLicenciaValida') ?? false;
    macList = prefs.getStringList('macList') ?? [];
    macBleList = prefs.getStringList('macBleList') ?? [];
    bloqueada = prefs.getString('bloqueada') ?? '';

    // Cargar `tiempoSesion`, asegurando que tiene un valor válido
    tiempoSesion = prefs.getDouble('tiempoSesion') ?? 25;

    // Cargar JSON
    String? licenciaDataJson = prefs.getString('licenciaData');
    if (licenciaDataJson != null) {
      licenciaData = Map<String, dynamic>.from(jsonDecode(licenciaDataJson));
    }

    String? allLicenciasJson = prefs.getString('allLicencias');
    if (allLicenciasJson != null) {
      allLicencias = List<Map<String, dynamic>>.from(jsonDecode(allLicenciasJson));
    }

    // Cargar MCIs
    String? mcisJson = prefs.getString('mcis');
    if (mcisJson != null) {
      mcis = List<Map<String, dynamic>>.from(jsonDecode(mcisJson));
    }
  }


  // Función para guardar el estado en SharedPreferences
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar los valores
    await prefs.setString('nLicencia', nLicencia);
    await prefs.setString('name', nombre);
    await prefs.setString('country', pais);
    await prefs.setString('provincia', provincia);
    await prefs.setString('adress', direccion);
    await prefs.setString('city', ciudad);
    await prefs.setString('phone', telefono);
    await prefs.setString('email', email);
    await prefs.setBool('isLicenciaValida', isLicenciaValida);

    // Guardar listas
    await prefs.setStringList('macList', macList);
    await prefs.setStringList('macBleList', macBleList);
    await prefs.setString('bloqueada', bloqueada);

    // Guardar `tiempoSesion`
    await prefs.setDouble('tiempoSesion', tiempoSesion);

    // Guardar los mapas y listas como JSON
    await prefs.setString('licenciaData', jsonEncode(licenciaData));
    await prefs.setString('allLicencias', jsonEncode(allLicencias));
    await prefs.setString('mcis', jsonEncode(mcis));
  }

}


class AppStateIdioma {
  String currentLanguage = 'es'; // Idioma por defecto

  AppStateIdioma._privateConstructor();
  static final AppStateIdioma _instance = AppStateIdioma._privateConstructor();
  static AppStateIdioma get instance => _instance;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar el idioma seleccionado desde SharedPreferences
    currentLanguage = prefs.getString('currentLanguage') ?? 'es'; // Idioma por defecto: español

    // Verificar que el idioma cargado es correcto
    print('Idioma cargado desde SharedPreferences: $currentLanguage');
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentLanguage', language);

    // Verificar que el idioma se guardó correctamente
    String? savedLanguage = prefs.getString('currentLanguage');
    if (savedLanguage == language) {
      print('Idioma guardado correctamente: $language');
    } else {
      print('Error al guardar el idioma. Intentó guardar: $language, pero se guardó: $savedLanguage');
    }
  }
}



