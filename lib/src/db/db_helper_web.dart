import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/setup.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Usar sqflite_common_ffi_web para Web

class DatabaseHelperWeb {
  static final DatabaseHelperWeb _instance = DatabaseHelperWeb._internal();
  static Database? _database;

  factory DatabaseHelperWeb() {
    return _instance;
  }

  DatabaseHelperWeb._internal();

  // Asegúrate de que la base de datos esté inicializada
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Si la base de datos ya está abierta, devuélvela.
    }
    _database = await _initDatabase(); // Si no, la inicializa.
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDatabase() async {
    // Inicializar sqflite para plataformas no móviles
    sqfliteFfiInit();

    // Inicializar el motor FFI para usar la base de datos correctamente
    databaseFactory =
        databaseFactoryFfi; // Establece el backend FFI para SQLite

    // Obtener el directorio donde se almacenará la base de datos
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'my_database.db');

    return await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ));
  }

  // Crear las tablas
  Future<void> _onCreate(Database db, int version) async {
    // Crear la tabla clientes
    await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      status TEXT NOT NULL,
      gender TEXT NOT NULL,
      height INTEGER NOT NULL,
      weight INTEGER NOT NULL,
      birthdate TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT NOT NULL
    )
    ''');

    // Crear la tabla grupos_musculares
    await db.execute('''
    CREATE TABLE IF NOT EXISTS grupos_musculares (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre TEXT NOT NULL
    )
    ''');

    // Crear la tabla de relación N:M entre clientes y grupos musculares
    await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes_grupos_musculares (
      cliente_id INTEGER,
      grupo_muscular_id INTEGER,
      PRIMARY KEY (cliente_id, grupo_muscular_id),
      FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
      FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares(id) ON DELETE CASCADE
    )
    ''');

    // Insertar valores predeterminados en la tabla grupos_musculares
    await db.insert('grupos_musculares', {'nombre': 'Pectorales'});
    await db.insert('grupos_musculares', {'nombre': 'Trapecios'});
    await db.insert('grupos_musculares', {'nombre': 'Dorsales'});
    await db.insert('grupos_musculares', {'nombre': 'Glúteos'});
    await db.insert('grupos_musculares', {'nombre': 'Isquios'});
    await db.insert('grupos_musculares', {'nombre': 'Lumbares'});
    await db.insert('grupos_musculares', {'nombre': 'Abdominales'});
    await db.insert('grupos_musculares', {'nombre': 'Cuádriceps'});
    await db.insert('grupos_musculares', {'nombre': 'Bíceps'});
    await db.insert('grupos_musculares', {'nombre': 'Gemelos'});
  }

  // Actualizar la base de datos si es necesario
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Este bloque se ejecuta solo si la base de datos está en una versión anterior
      await db.execute('''
      CREATE TABLE IF NOT EXISTS clientes_grupos_musculares (
        cliente_id INTEGER,
        grupo_muscular_id INTEGER,
        PRIMARY KEY (cliente_id, grupo_muscular_id),
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
        FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares(id) ON DELETE CASCADE
      )
      ''');
    }
  }

  // Inicializar la base de datos al inicio de la app
  Future<void> initializeDatabase() async {
    await database; // Esto asegura que la base de datos esté inicializada
  }

  // Método para insertar un cliente
  Future<void> insertClient(Map<String, dynamic> client) async {
    final db = await database;
    try {
      await db.insert(
        'clientes',
        client,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting client: $e');
    }
  }

  // Obtener todos los clientes
  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;
    final List<Map<String, dynamic>> clients = await db.query('clientes');
    return clients;
  }

  // Obtener un cliente por ID
  Future<Map<String, dynamic>?> getClientById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Insertar relación entre un cliente y un grupo muscular
  Future<bool> insertClientGroup(int clienteId, int grupoMuscularId) async {
    final db = await database;
    try {
      await db.insert(
        'clientes_grupos_musculares',
        {
          'cliente_id': clienteId,
          'grupo_muscular_id': grupoMuscularId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error inserting client-group relationship: $e');
      return false;
    }
  }

  // Obtener los grupos musculares de un cliente
  Future<List<Map<String, dynamic>>> getGruposDeCliente(int clienteId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT g.*
      FROM grupos_musculares g
      INNER JOIN clientes_grupos_musculares cg ON g.id = cg.grupo_muscular_id
      WHERE cg.cliente_id = ?
    ''', [clienteId]);

    return result;
  }

  // Método para eliminar la base de datos (en Web no se puede eliminar de la misma forma)
  Future<void> deleteDatabaseFile() async {
    try {
      // No puedes eliminar la base de datos en Web de la misma forma
      // Una opción sería usar el almacenamiento local o eliminar los registros manualmente
      final db = await database;
      await db.execute('DELETE FROM clientes');
      await db.execute('DELETE FROM grupos_musculares');
      await db.execute('DELETE FROM clientes_grupos_musculares');
      print("Base de datos reiniciada correctamente.");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }
}
