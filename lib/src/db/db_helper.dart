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
    if (_database != null)
      return _database!; // Si la base de datos ya está abierta, devuélvela.
    _database = await _initDatabase(); // Si no, la inicializa.
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = join(
        await getDatabasesPath(), 'my_database.db'); // Ruta de la base de datos

    return await openDatabase(
      path,
      version: 12,
      // Incrementamos la versión a 3
      onCreate: _onCreate,
      // Método que se ejecuta solo al crear la base de datos
      onUpgrade:
      _onUpgrade, // Método que se ejecuta al actualizar la base de datos
    );
  }

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

// Crear la tabla bonos
    await db.execute('''
    CREATE TABLE IF NOT EXISTS bonos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cliente_id INTEGER,
      cantidad INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      estado TEXT NOT NULL,
      FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
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

    await db.execute('''
    CREATE TABLE IF NOT EXISTS programas_individuales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      image TEXT,           
      name TEXT NOT NULL,    
      frequency INTEGER,     
      pulse INTEGER,           
      rampa INTEGER,           
      contraction INTEGER,     
      pause INTEGER         
    )
  ''');
    await db.insert('programas_individuales', {
      'image': 'assets/images/CALIBRACION.png',
      'name': 'CALIBRACIÓN',
      'frequency': 80,
      'pulse': 350,
      'rampa': 10,
      'contraction': 4,
      'pause': 1,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/STRENGTH1.png',
      'name': 'STRENGTH 1',
      'frequency': 85,
      'pulse': 350,
      'rampa': 8,
      'contraction': 4,
      'pause': 2,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/STRENGTH2.png',
      'name': 'STRENGTH 2',
      'frequency': 85,
      'pulse': 400,
      'rampa': 10,
      'contraction': 5,
      'pause': 3,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/GLUTEOS.png',
      'name': 'GLÚTEOS',
      'frequency': 85,
      'pulse': 0,
      'rampa': 10,
      'contraction': 6,
      'pause': 4,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/ABDOMINAL.png',
      'name': 'ABDOMINAL',
      'frequency': 43,
      'pulse': 450,
      'rampa': 8,
      'contraction': 6,
      'pause': 3,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/SLIM.png',
      'name': 'SLIM',
      'frequency': 66,
      'pulse': 350,
      'rampa': 5,
      'contraction': 6,
      'pause': 3,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/BODYBUILDING.png',
      'name': 'BODY BUILDING 1',
      'frequency': 75,
      'pulse': 300,
      'rampa': 5,
      'contraction': 4,
      'pause': 2,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/BODYBUILDING2.png',
      'name': 'BODY BUILDING 2',
      'frequency': 75,
      'pulse': 450,
      'rampa': 5,
      'contraction': 4,
      'pause': 2,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/FITNESS.png',
      'name': 'FITNESS',
      'frequency': 90,
      'pulse': 350,
      'rampa': 5,
      'contraction': 5,
      'pause': 4,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/WARMUP.png',
      'name': 'WARM UP',
      'frequency': 7,
      'pulse': 250,
      'rampa': 2,
      'contraction': 1,
      'pause': 0,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/CARDIO.png',
      'name': 'CARDIO',
      'frequency': 10,
      'pulse': 350,
      'rampa': 2,
      'contraction': 1,
      'pause': 0,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/CELULITIS.png',
      'name': 'CELULITIS',
      'frequency': 10,
      'pulse': 450,
      'rampa': 5,
      'contraction': 1,
      'pause': 0,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/RESISTENCIA.png',
      'name': 'SLIM',
      'frequency': 43,
      'pulse': 350,
      'rampa': 5,
      'contraction': 10,
      'pause': 4,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/DEFINICION.png',
      'name': 'DEFINICIÓN',
      'frequency': 33,
      'pulse': 350,
      'rampa': 5,
      'contraction': 6,
      'pause': 2,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/BASIC.png',
      'name': 'BASIC',
      'frequency': 70,
      'pulse': 250,
      'rampa': 5,
      'contraction': 4,
      'pause': 4,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/METABOLIC.png',
      'name': 'METABOLIC',
      'frequency': 7,
      'pulse': 350,
      'rampa': 2,
      'contraction': 1,
      'pause': 0,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/SUELOPELV.png',
      'name': 'SUELO PÉLVICO',
      'frequency': 85,
      'pulse': 450,
      'rampa': 10,
      'contraction': 4,
      'pause': 4,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/CAPILLARY.png',
      'name': 'CAPILLARY',
      'frequency': 9,
      'pulse': 150,
      'rampa': 2,
      'contraction': 1,
      'pause': 0,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/DRENAJE.png',
      'name': 'DRENAJE',
      'frequency': 21,
      'pulse': 350,
      'rampa': 5,
      'contraction': 5,
      'pause': 3,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/CONTRACTURAS.png',
      'name': 'CONTRACTURAS',
      'frequency': 120,
      'pulse': 0,
      'rampa': 10,
      'contraction': 4,
      'pause': 3,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/RELAX.png',
      'name': 'RELAX',
      'frequency': 100,
      'pulse': 150,
      'rampa': 2,
      'contraction': 3,
      'pause': 2,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/DOLORNEU.png',
      'name': 'DOLOR NEURÁLGICO',
      'frequency': 150,
      'pulse': 100,
      'rampa': 5,
      'contraction': 10,
      'pause': 1,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/DOLORQUIM.png',
      'name': 'DOLOR QUÍMICO',
      'frequency': 110,
      'pulse': 250,
      'rampa': 5,
      'contraction': 5,
      'pause': 1,
    });
    await db.insert('programas_individuales', {
      'image': 'assets/images/DOLORMECANICO.png',
      'name': 'DOLOR MECÁNICO',
      'frequency': 5,
      'pulse': 150,
      'rampa': 5,
      'contraction': 6,
      'pause': 3,
    });
  }

  // Función para manejar la actualización de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 12) {
      // Inserción de un programa de ejemplo
      await db.insert('programas_individuales', {
        'image': 'assets/images/CALIBRACION.png',
        'name': 'CALIBRACIÓN',
        'frequency': 80,
        'pulse': 350,
        'rampa': 10,
        'contraction': 4,
        'pause': 1,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/STRENGTH1.png',
        'name': 'STRENGTH 1',
        'frequency': 85,
        'pulse': 350,
        'rampa': 8,
        'contraction': 4,
        'pause': 2,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/STRENGTH2.png',
        'name': 'STRENGTH 2',
        'frequency': 85,
        'pulse': 400,
        'rampa': 10,
        'contraction': 5,
        'pause': 3,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/GLUTEOS.png',
        'name': 'GLÚTEOS',
        'frequency': 85,
        'pulse': 0,
        'rampa': 10,
        'contraction': 6,
        'pause': 4,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/ABDOMINAL.png',
        'name': 'ABDOMINAL',
        'frequency': 43,
        'pulse': 450,
        'rampa': 8,
        'contraction': 6,
        'pause': 3,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/SLIM.png',
        'name': 'SLIM',
        'frequency': 66,
        'pulse': 350,
        'rampa': 5,
        'contraction': 6,
        'pause': 3,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/BODYBUILDING.png',
        'name': 'BODY BUILDING 1',
        'frequency': 75,
        'pulse': 300,
        'rampa': 5,
        'contraction': 4,
        'pause': 2,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/BODYBUILDING2.png',
        'name': 'BODY BUILDING 2',
        'frequency': 75,
        'pulse': 450,
        'rampa': 5,
        'contraction': 4,
        'pause': 2,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/FITNESS.png',
        'name': 'FITNESS',
        'frequency': 90,
        'pulse': 350,
        'rampa': 5,
        'contraction': 5,
        'pause': 4,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/WARMUP.png',
        'name': 'WARM UP',
        'frequency': 7,
        'pulse': 250,
        'rampa': 2,
        'contraction': 1,
        'pause': 0,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/CARDIO.png',
        'name': 'CARDIO',
        'frequency': 10,
        'pulse': 350,
        'rampa': 2,
        'contraction': 1,
        'pause': 0,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/CELULITIS.png',
        'name': 'CELULITIS',
        'frequency': 10,
        'pulse': 450,
        'rampa': 5,
        'contraction': 1,
        'pause': 0,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/RESISTENCIA.png',
        'name': 'SLIM',
        'frequency': 43,
        'pulse': 350,
        'rampa': 5,
        'contraction': 10,
        'pause': 4,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/DEFINICION.png',
        'name': 'DEFINICIÓN',
        'frequency': 33,
        'pulse': 350,
        'rampa': 5,
        'contraction': 6,
        'pause': 2,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/BASIC.png',
        'name': 'BASIC',
        'frequency': 70,
        'pulse': 250,
        'rampa': 5,
        'contraction': 4,
        'pause': 4,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/METABOLIC.png',
        'name': 'METABOLIC',
        'frequency': 7,
        'pulse': 350,
        'rampa': 2,
        'contraction': 1,
        'pause': 0,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/SUELOPELV.png',
        'name': 'SUELO PÉLVICO',
        'frequency': 85,
        'pulse': 450,
        'rampa': 10,
        'contraction': 4,
        'pause': 4,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/CAPILLARY.png',
        'name': 'CAPILLARY',
        'frequency': 9,
        'pulse': 150,
        'rampa': 2,
        'contraction': 1,
        'pause': 0,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/DRENAJE.png',
        'name': 'DRENAJE',
        'frequency': 21,
        'pulse': 350,
        'rampa': 5,
        'contraction': 5,
        'pause': 3,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/CONTRACTURAS.png',
        'name': 'CONTRACTURAS',
        'frequency': 120,
        'pulse': 0,
        'rampa': 10,
        'contraction': 4,
        'pause': 3,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/RELAX.png',
        'name': 'RELAX',
        'frequency': 100,
        'pulse': 150,
        'rampa': 2,
        'contraction': 3,
        'pause': 2,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/DOLORNEU.png',
        'name': 'DOLOR NEURÁLGICO',
        'frequency': 150,
        'pulse': 100,
        'rampa': 5,
        'contraction': 10,
        'pause': 1,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/DOLORQUIM.png',
        'name': 'DOLOR QUÍMICO',
        'frequency': 110,
        'pulse': 250,
        'rampa': 5,
        'contraction': 5,
        'pause': 1,
      });
      await db.insert('programas_individuales', {
        'image': 'assets/images/DOLORMECANICO.png',
        'name': 'DOLOR MECÁNICO',
        'frequency': 5,
        'pulse': 150,
        'rampa': 5,
        'contraction': 6,
        'pause': 3,
      });
      print("Programa insertado correctamente"); // Agregado para depuración
    }
  }

  // Método para verificar los datos en programas_individuales (para depuración)
  Future<void> checkProgramas() async {
    final db = await database;
    final result = await db.query('programas_individuales');
    print("Programas en la base de datos: $result");
  }

  // Método para obtener todos los programas individuales
  Future<List<Map<String, dynamic>>> getProgramasIndividuales() async {
    final db = await database;
    final result = await db.query('programas_individuales');
    print('Programas obtenidos: $result'); // Verifica los datos obtenidos
    return result;
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
        conflictAlgorithm:
        ConflictAlgorithm.replace, // Reemplazar en caso de conflicto
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

  // Obtener el cliente más reciente (con el id más alto)
  Future<Map<String, dynamic>?> getMostRecentClient() async {
    final db = await database;
    // Realizamos una consulta que ordene por el id de forma descendente (del más grande al más pequeño)
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      orderBy: 'id DESC', // Ordenamos por id de manera descendente
      limit: 1, // Solo nos interesa el primer resultado (el más reciente)
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // Si no hay clientes en la base de datos
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

  // Insertar un bono
  Future<void> insertBono(Map<String, dynamic> bono) async {
    final db = await database;

    try {
      await db.insert(
        'bonos',
        bono,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting bono: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableBonosByClientId(
      int clientId) async {
    final db = await database;
    final result = await db.query(
      'bonos', // Nombre de la tabla de bonos
      where: 'cliente_id = ? AND estado = ?',
      whereArgs: [
        clientId,
        'Disponible'
      ], // Filtra por cliente y estado "Disponible"
    );
    return result;
  }

  // Obtener todos los bonos
  Future<List<Map<String, dynamic>>> getAllBonos() async {
    final db = await database;

    final result = await db.query('bonos');
    return result;
  }

  // Eliminar un bono por ID
  Future<void> deleteBono(int id) async {
    final db = await database;

    await db.delete(
      'bonos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener los datos de la tabla grupos_musculares
  Future<List<Map<String, dynamic>>> getGruposMusculares() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
    await db.query('grupos_musculares');
    return result;
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
        conflictAlgorithm:
        ConflictAlgorithm.replace, // Reemplazar en caso de conflicto
      );
      return true; // Si la inserción fue exitosa, retorna true
    } catch (e) {
      print('Error inserting client-group relationship: $e');
      return false; // Si ocurrió un error, retorna false
    }
  }

  // Método para actualizar los grupos musculares asociados a un cliente
  Future<void> updateClientGroups(int clientId, List<int> groupIds) async {
    final db = await openDatabase(
        'my_database.db'); // Asegúrate de usar la ruta correcta

    // Primero, eliminamos todos los registros existentes de esta relación para este cliente
    await db.delete(
      'clientes_grupos_musculares',
      where: 'cliente_id = ?',
      whereArgs: [clientId],
    );

    // Luego, insertamos los nuevos registros de relación
    for (int groupId in groupIds) {
      await db.insert(
        'clientes_grupos_musculares',
        {
          'cliente_id': clientId,
          'grupo_muscular_id': groupId,
        },
        conflictAlgorithm: ConflictAlgorithm
            .replace, // Si existe un conflicto (mismo cliente y grupo), se reemplaza el registro
      );
    }
  }

  Future<List<Map<String, dynamic>>> getGruposDeCliente(int clienteId) async {
    try {
      final db = await database;

      // Realizar la consulta con un INNER JOIN
      final result = await db.rawQuery('''
      SELECT g.*
      FROM grupos_musculares g
      INNER JOIN clientes_grupos_musculares cg ON g.id = cg.grupo_muscular_id
      WHERE cg.cliente_id = ?
    ''', [clienteId]);

      // Si no hay resultados, retornar una lista vacía
      if (result.isEmpty) {
        return [];
      }

      return result;
    } catch (e) {
      // Manejo de errores: en caso de que ocurra algún problema con la base de datos
      print("Error al obtener grupos musculares: $e");
      return []; // Retorna una lista vacía en caso de error
    }
  }


  // Método para eliminar la base de datos
  Future<void> deleteDatabaseFile() async {
    try {
      String path = join(await getDatabasesPath(), 'my_database.db');
      await deleteDatabase(path); // Eliminar la base de datos físicamente
      print("Base de datos eliminada correctamente.");
    } catch (e) {
      print("Error al eliminar la base de datos: $e");
    }
  }
/* // Método para llamar al deleteDatabaseFile
  Future<void> _deleteDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteDatabaseFile();  // Elimina la base de datos
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Base de datos eliminada con éxito.'),
    ));
  }*/
}
