import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelperPC {
  static final DatabaseHelperPC _instance = DatabaseHelperPC._internal();
  static Database? _database;

  factory DatabaseHelperPC() {
    return _instance;
  }

  DatabaseHelperPC._internal();

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
    databaseFactory = databaseFactoryFfi;  // Establece el backend FFI para SQLite

    // Obtener el directorio donde se almacenará la base de datos
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'my_database.db');

    return await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions(
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    ));
  }

  // Crear tablas en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla clientes
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

    // Crear tabla grupos musculares
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

    // Insertar valores predeterminados en la tabla grupos musculares
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

  // Actualización de la base de datos en caso de nuevas versiones
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear relaciones N:M entre clientes y grupos musculares si la base de datos se encuentra en una versión anterior
      await db.execute(''' 
      CREATE TABLE IF NOT EXISTS clientes_grupos_musculares (
        cliente_id INTEGER,
        grupo_muscular_id INTEGER,
        PRIMARY KEY (cliente_id, grupo_muscular_id),
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
        FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares(id) ON DELETE CASCADE
      )
      ''');

      // Insertar relaciones predeterminadas si es necesario, etc.
    }
  }

  // Inicializar la base de datos al inicio de la app
  Future<void> initializeDatabase() async {
    await database; // Esto asegura que la base de datos esté inicializada
  }

  // Insertar un cliente
  Future<void> insertClient(Map<String, dynamic> client) async {
    final db = await database;
    try {
      await db.insert(
        'clientes',
        client,
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar en caso de conflicto
      );
    } catch (e) {
      print('Error inserting client: $e');
    }
  }

  // Actualizar un cliente
  Future<void> updateClient(int id, Map<String, dynamic> client) async {
    final db = await database;
    final existingClient = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existingClient.isNotEmpty) {
      try {
        await db.update(
          'clientes',
          client,
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (e) {
        print('Error updating client: $e');
      }
    } else {
      print('Client with id $id not found');
    }
  }

  // Obtener todos los clientes
  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;
    return await db.query('clientes');
  }

  // Obtener un cliente por ID
  Future<Map<String, dynamic>?> getClientById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Obtener el cliente más reciente
  Future<Map<String, dynamic>?> getMostRecentClient() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Eliminar un cliente por ID
  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener los datos de la tabla grupos musculares
  Future<List<Map<String, dynamic>>> getGruposMusculares() async {
    final db = await database;
    return await db.query('grupos_musculares');
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
    return await db.rawQuery(''' 
      SELECT g.* FROM grupos_musculares g
      INNER JOIN clientes_grupos_musculares cg ON g.id = cg.grupo_muscular_id
      WHERE cg.cliente_id = ? 
    ''', [clienteId]);
  }

  // Método para eliminar la base de datos
  Future<void> deleteDatabaseFile() async {
    final dbPath = join(await getDatabasesPath(), 'my_database.db');
    try {
      await deleteDatabase(dbPath);
      print("Base de datos eliminada correctamente.");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }
}
