import 'dart:convert'; // Para manejar JSON
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelperTraduccionesPc {
  static final DatabaseHelperTraduccionesPc _instance =
      DatabaseHelperTraduccionesPc._internal();
  static Database? _database;

  DatabaseHelperTraduccionesPc._internal();

  factory DatabaseHelperTraduccionesPc() => _instance;

  // Inicialización del DB para plataformas no móviles (PC, Web)
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase(); // Si no está inicializada, la inicializa
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDatabase() async {
    // Inicializar sqflite para plataformas no móviles
    sqfliteFfiInit(); // Inicializa el motor de base de datos SQLite en plataformas no móviles

    // Inicializar el motor FFI para usar la base de datos correctamente
    databaseFactory =
        databaseFactoryFfi; // Establece el backend FFI para SQLite

    // Obtener el directorio donde se almacenará la base de datos
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'tarducciones.db');

    return await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ));
  }

  // Inicializar la base de datos al inicio de la app
  Future<void> initializeDatabase() async {
    await database; // Esto asegura que la base de datos esté inicializada
  }

  /// Crea la tabla `TRADUCCIONES`
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE TRADUCCIONES (
        idioma TEXT PRIMARY KEY, -- El UID del idioma ('es', 'en', etc.)
        traducciones TEXT NOT NULL -- Un string JSON con las claves y valores
      )
    ''');
  }

  /// Inserta o actualiza las traducciones para un idioma
  Future<void> insertOrUpdateTranslations(
      String idioma, Map<String, dynamic> traducciones) async {
    final db = await database;
    await db.insert(
      'TRADUCCIONES',
      {
        'idioma': idioma,
        'traducciones': jsonEncode(traducciones), // Convierte el mapa a JSON
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
    );
  }

  /// Inserta o actualiza traducciones para varios idiomas
  Future<void> insertOrUpdateMultipleTranslations(
      Map<String, dynamic> allTranslations) async {
    final db = await database;

    Batch batch = db.batch();
    allTranslations.forEach((idioma, traducciones) {
      batch.insert(
        'TRADUCCIONES',
        {
          'idioma': idioma,
          'traducciones': jsonEncode(traducciones), // Convierte el mapa a JSON
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });

    await batch.commit(noResult: true);
  }

  Future<void> updateSQLiteDatabase(
      List<Map<String, dynamic>> firebaseData) async {
    final db = await database;

    // Inicia una transacción para actualizar la base de datos de forma eficiente
    Batch batch = db.batch();

    for (var data in firebaseData) {
      batch.insert(
        'TRADUCCIONES',
        {
          'idioma': data['idioma'],
          'traducciones': jsonEncode(data['traducciones']),
          // Convierte las traducciones a JSON
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si ya existe
      );
    }

    // Ejecuta las operaciones de la transacción
    await batch.commit(noResult: true);
  }

  Stream<List<Map<String, dynamic>>> getTranslationsStream() async* {
    final db = await database;
    // Esto emite los cambios en las traducciones
    while (true) {
      final translations = await db.query('TRADUCCIONES');
      yield translations;
      await Future.delayed(Duration(
          seconds: 1)); // Espera un segundo antes de volver a obtener datos
    }
  }

  Future<Map<String, String>> getTranslationsByLanguage(String idioma) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> result = await db.query(
        'TRADUCCIONES',
        where: 'idioma = ?',
        whereArgs: [idioma],
      );

      if (result.isNotEmpty) {
        final String jsonString = result.first['traducciones'];
        final Map<String, dynamic> decoded = jsonDecode(jsonString);

        // Retorna el mapa de claves y valores como Map<String, String>.
        return Map<String, String>.from(decoded);
      } else {
        throw Exception(
            'No se encontraron traducciones para el idioma: $idioma');
      }
    } catch (e) {
      // Aquí puedes loguear el error o manejarlo como prefieras.
      throw Exception('Error al obtener las traducciones: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllTranslations() async {
    final db = await database;

    if (db.isOpen) {
      return await db.query('TRADUCCIONES');
    } else {
      throw Exception('La base de datos está cerrada');
    }
  }

  /// Obtiene todos los idiomas almacenados
  Future<List<String>> getAllLanguages() async {
    final db = await database;

    final List<Map<String, dynamic>> result =
        await db.query('TRADUCCIONES', columns: ['idioma']);

    return result.map((row) => row['idioma'] as String).toList();
  }
}
