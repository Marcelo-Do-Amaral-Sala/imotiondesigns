import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Asegúrate de que la base de datos esté inicializada
  Future<Database> get database async {
    if (_database != null) return _database!; // Si la base de datos ya está abierta, devuélvela.
    _database = await _initDatabase(); // Si no, la inicializa.
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db'); // Ruta de la base de datos

    return await openDatabase(
      path,
      version: 2, // Incrementamos la versión para permitir la creación de nuevas tablas.
      onCreate: _onCreate, // Método que se ejecuta al crear la base de datos
      onUpgrade: _onUpgrade, // Para manejar la actualización de la base de datos si es necesario
    );
  }

  // Crear las tablas cuando la base de datos se inicializa
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

  // Método para manejar actualizaciones de la base de datos (si cambian las tablas)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Aquí puedes agregar lógica de actualización si fuera necesario en el futuro
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

    // Verifica si el cliente existe
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

  // Eliminar un cliente por ID
  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener los datos de la tabla grupos_musculares
  Future<List<Map<String, dynamic>>> getGruposMusculares() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('grupos_musculares');
    return result;
  }
}
