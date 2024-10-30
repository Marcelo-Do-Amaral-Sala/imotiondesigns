import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  Future<void> initializeDatabase() async {
    await database; // Asegura que la base de datos esté inicializada
  }

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

  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;
    // Asegúrate de que el ID se maneje como int
    final List<Map<String, dynamic>> clients = await db.query('clientes');

    // Aquí podrías verificar que todos los campos se recuperen correctamente
    return clients.map((client) {
      return {
        'id': client['id'], // El ID debe ser un int
        'name': client['name'],
        'status': client['status'],
        'gender': client['gender'],
        'height': client['height'],
        'weight': client['weight'],
        'birthdate': client['birthdate'],
        'phone': client['phone'],
        'email': client['email'],
      };
    }).toList();
  }

  Future<void> updateClient(int id, Map<String, dynamic> client) async {
    final db = await database;
    await db.update(
      'clientes',
      client,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
