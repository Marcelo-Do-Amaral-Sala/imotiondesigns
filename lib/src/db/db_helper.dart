import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        phone INTEGER NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertClient(Map<String, dynamic> client) async {
    final db = await database;

    // Asegúrate de que la tabla existe
    await db.execute('''
    CREATE TABLE IF NOT EXISTS clientes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      status TEXT NOT NULL,
      gender TEXT NOT NULL,
      height INTEGER NOT NULL,
      weight INTEGER NOT NULL,
      birthdate TEXT NOT NULL,
      phone INTEGER NOT NULL,
      email TEXT NOT NULL
    )
  ''');

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


// READ
  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;
    return await db.query('clientes');
  }

// UPDATE
  Future<void> updateClient(int id, Map<String, dynamic> client) async {
    final db = await database;
    await db.update(
      'clientes',
      client,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// DELETE
  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
