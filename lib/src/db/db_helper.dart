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
      version: 93,
      // Incrementamos la versión a 3
      onCreate: _onCreate,
      // Método que se ejecuta solo al crear la base de datos
      onUpgrade:
      _onUpgrade, // Método que se ejecuta al actualizar la base de datos
    );
  }

  // Inicializar la base de datos al inicio de la app
  Future<void> initializeDatabase() async {
    await database; // Esto asegura que la base de datos esté inicializada
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

    // Crear la tabla grupos_musculares
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grupos_musculares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT NOT NULL
      )
    ''');

    // Insertar valores predeterminados en la tabla grupos_musculares
    await db.insert('grupos_musculares',
        {'nombre': 'Pectorales', 'imagen': 'assets/images/Pectorales.png'});
    print('Inserted into grupos_musculares: Pectorales');

    await db.insert('grupos_musculares',
        {'nombre': 'Trapecios', 'imagen': 'assets/images/Trapecios.png'});
    print('Inserted into grupos_musculares: Trapecios');

    await db.insert('grupos_musculares',
        {'nombre': 'Dorsales', 'imagen': 'assets/images/Dorsales.png'});
    print('Inserted into grupos_musculares: Dorsales');

    await db.insert('grupos_musculares',
        {'nombre': 'Glúteos', 'imagen': 'assets/images/Glúteos.png'});
    print('Inserted into grupos_musculares: Glúteos');

    await db.insert('grupos_musculares',
        {'nombre': 'Isquiotibiales', 'imagen': 'assets/images/Isquios.png'});
    print('Inserted into grupos_musculares: Isquiotibiales');

    await db.insert('grupos_musculares',
        {'nombre': 'Lumbares', 'imagen': 'assets/images/Lumbares.png'});
    print('Inserted into grupos_musculares: Lumbares');

    await db.insert('grupos_musculares',
        {'nombre': 'Abdomen', 'imagen': 'assets/images/Abdominales.png'});
    print('Inserted into grupos_musculares: Abdominales');

    await db.insert('grupos_musculares',
        {'nombre': 'Cuádriceps', 'imagen': 'assets/images/Cuádriceps.png'});
    print('Inserted into grupos_musculares: Cuádriceps');

    await db.insert('grupos_musculares',
        {'nombre': 'Bíceps', 'imagen': 'assets/images/Bíceps.png'});
    print('Inserted into grupos_musculares: Bíceps');

    await db.insert('grupos_musculares',
        {'nombre': 'Gemelos', 'imagen': 'assets/images/Gemelos.png'});
    print('Inserted into grupos_musculares: Gemelos');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS grupos_musculares_equipamiento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT NOT NULL,
        tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
      )
    ''');

    // BIO-JACKET
    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Trapecios',
      'imagen': 'assets/images/Trapecios.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Trapecios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Dorsales',
      'imagen': 'assets/images/Dorsales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Lumbares',
      'imagen': 'assets/images/Lumbares.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Glúteos',
      'imagen': 'assets/images/Glúteos.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Isquiotibiales',
      'imagen': 'assets/images/Isquios.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Isquios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Pectorales',
      'imagen': 'assets/images/Pectorales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Pectorales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Abdomen',
      'imagen': 'assets/images/Abdominales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Cuádriceps',
      'imagen': 'assets/images/Cuádriceps.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Bíceps',
      'imagen': 'assets/images/Bíceps.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Gemelos',
      'imagen': 'assets/images/Gemelos.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

    // BIO-SHAPE
    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Lumbares',
      'imagen': 'assets/images/lumbares_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Glúteos',
      'imagen': 'assets/images/gluteo_shape.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Glúteo superior" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Isquiotibiales',
      'imagen': 'assets/images/isquios_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Abdomen',
      'imagen': 'assets/images/abdomen_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Abdominales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Cuádriceps',
      'imagen': 'assets/images/cuadriceps_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Bíceps',
      'imagen': 'assets/images/biceps_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': 'Gemelos',
      'imagen': 'assets/images/gemelos_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');

    await db.execute('''
      CREATE TABLE programas_predeterminados (
        id_programa INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        imagen TEXT,
        frecuencia REAL,
        pulso REAL,
        rampa REAL,
        contraccion REAL,
        pausa REAL,
        tipo TEXT,
        tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
      );
    ''');
    print("Tabla 'programas_predeterminados' creada.");

    await db.execute('''
    CREATE TABLE IF NOT EXISTS cronaxia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    programa_id INTEGER, 
    nombre TEXT NOT NULL,
    valor REAL DEFAULT 0.0,  -- Cambiado a REAL con valor por defecto 0.0
    tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET')),
     FOREIGN KEY (programa_id) REFERENCES programas(id_programa)
  )
''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ProgramaGrupoMuscular (
        programa_id INTEGER,
        grupo_muscular_id INTEGER,
        FOREIGN KEY (programa_id) REFERENCES programas_predeterminados(id_programa),
        FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares_equipamiento(id)
      );
    ''');
    print("Tabla 'ProgramaGrupoMuscular' creada.");

// Iniciamos la transacción
    await db.transaction((txn) async {
      // Inserciones para el tipo de equipamiento 'BIO-JACKET'
      await txn.insert('cronaxia', {'nombre': 'Trapecio', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Dorsales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Pectorales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      await txn.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});

      // Inserciones para el tipo de equipamiento 'BIO-SHAPE'
      await txn.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      await txn.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});

      // Imprimir mensaje para verificar inserciones
      print('Inserciones completadas para los tipos de equipamiento BIO-JACKET y BIO-SHAPE');
    });

    await db.execute(''' -- Tabla intermedia programa_cronaxia
CREATE TABLE programa_cronaxia (
  programa_id INTEGER,
  cronaxia_id INTEGER,
  valor REAL,
  PRIMARY KEY (programa_id, cronaxia_id),
  FOREIGN KEY (programa_id) REFERENCES programas_predeterminados(id),
  FOREIGN KEY (cronaxia_id) REFERENCES cronaxia(id)
)''');

    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId1 = await txn.insert('programas_predeterminados', {
        'nombre': 'CALIBRACIÓN',
        'imagen': 'assets/images/CALIBRACION.png',
        'frecuencia': 80,
        'rampa': 10,
        'pulso': 350,
        'contraccion': 4,
        'pausa': 1,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'  // Equipamiento seleccionado
      });

      print("Programa insertado con ID: $programaId1");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId1,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId1 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares asociados al tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId1,
          'grupo_muscular_id': grupo['id'],
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId1 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId2 = await txn.insert('programas_predeterminados', {
        'nombre': 'STRENGTH 1',
        'imagen': 'assets/images/STRENGTH1.png',
        'frecuencia': 85,
        'pulso': 350,
        'rampa': 8,
        'contraccion': 4,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId2");

      final tipoEquipamiento = 'BIO-JACKET';

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, se actualiza su valor (si hay un nuevo valor, se usa, sino se usa el valor existente)
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor'];


        // Relacionar la cronaxia con el programa y almacenar el valor
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId2,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Aquí se almacena el valor de la cronaxia en la relación
        });
        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId2 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
  SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

      for (var grupo in gruposMusculares) {
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId2,
          'grupo_muscular_id': grupo['id'],
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId2 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      int programaId3 = await txn.insert('programas_predeterminados', {
        'nombre': 'STRENGTH 2',
        'imagen': 'assets/images/STRENGTH2.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 400,
        'contraccion': 5,
        'pausa': 3,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId3");

      final tipoEquipamiento = 'BIO-JACKET';

      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor'];

        // Relacionar la cronaxia con el programa y almacenar el valor
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId3,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Aquí se almacena el valor de la cronaxia en la relación
        });
        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId3 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
  SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

      for (var grupo in gruposMusculares) {
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId3,
          'grupo_muscular_id': grupo['id'],
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId3 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId4 = await txn.insert('programas_predeterminados', {
        'nombre': 'GLÚTEOS',
        'imagen': 'assets/images/GLUTEOS.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 0,
        'contraccion': 6,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId4");

      final tipoEquipamiento = 'BIO-JACKET';

      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa y sus valores modificados
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Modificar valores específicos de cronaxias basándonos en su ID
        // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
        final nuevoValor = (cronaxiaId == 1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
            ? 200 // Nuevo valor para 'frecuencia'
            : (cronaxiaId == 2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
            ? 250 // Nuevo valor para 'rampa'
            : (cronaxiaId == 3) // ID = 3 'pulso'
            ? 200
            : (cronaxiaId == 4) // ID = 4 'contracción'
            ? 400
            : (cronaxiaId == 5) // ID = 5 'pausa'
            ? 300
            : (cronaxiaId == 6) // ID = 6 'tipo'
            ? 150
            : (cronaxiaId == 7) // ID = 7 'equipamiento'
            ? 350
            : (cronaxiaId == 8) // ID = 8 'otro'
            ? 400
            : (cronaxiaId == 9)
            ? 150
            : (cronaxiaId == 10)
            ? 150
            : valorCronaxia; // Para otras cronaxias, mantenemos el valor predeterminado

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId4,
          'cronaxia_id': cronaxiaId,
          'valor': nuevoValor,  // Aquí almacenamos el valor modificado para este programa
        });

        print(
            'ASOCIADO cronaxia con ID $cronaxiaId al programa ID $programaId4 con valor $nuevoValor en la tabla programa_cronaxia');
      }

      // Paso 5: Asociar grupos musculares con el programa
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

      for (var grupo in gruposMusculares) {
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId4,
          'grupo_muscular_id': grupo['id'],
        });

        print('ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId4 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId5 = await txn.insert('programas_predeterminados', {
        'nombre': 'ABDOMINAL',
        'imagen': 'assets/images/ABDOMINAL.png',
        'frecuencia': 43,
        'rampa': 8,
        'pulso': 450,
        'contraccion': 6,
        'pausa': 3,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId5");


      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId5,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId5 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId5, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId5 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId6 = await txn.insert('programas_predeterminados', {
        'nombre': 'SLIM',
        'imagen': 'assets/images/SLIM.png',
        'frecuencia': 66,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 6,
        'pausa': 3,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId6");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId6,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId6 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId6, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId6 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId7 = await txn.insert('programas_predeterminados', {
        'nombre': 'BODY BUILDING 1',
        'imagen': 'assets/images/BODYBUILDING.png',
        'frecuencia': 75,
        'rampa': 5,
        'pulso': 300,
        'contraccion': 4,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId7");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId7,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId7 con valor $valorCronaxia en la tabla programa_cronaxia');
      }


      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId7, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId7 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId8 = await txn.insert('programas_predeterminados', {
        'nombre': 'BODY BUILDING 2',
        'imagen': 'assets/images/BODYBUILDING2.png',
        'frecuencia': 75,
        'rampa': 5,
        'pulso': 450,
        'contraccion': 4,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });
      print("Programa insertado con ID: $programaId8");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId8,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId8 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId8, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId8 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId9 = await txn.insert('programas_predeterminados', {
        'nombre': 'FITNESS',
        'imagen': 'assets/images/FITNESS.png',
        'frecuencia': 90,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 5,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId9");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId9,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId9 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId9, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId9 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId10 = await txn.insert('programas_predeterminados', {
        'nombre': 'WARM UP',
        'imagen': 'assets/images/WARMUP.png',
        'frecuencia': 7,
        'rampa': 2,
        'pulso': 250,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId10");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId10,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId10 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId10, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId10 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId11 = await txn.insert('programas_predeterminados', {
        'nombre': 'CARDIO',
        'imagen': 'assets/images/CARDIO.png',
        'frecuencia': 10,
        'rampa': 2,
        'pulso': 350,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId11");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId11,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId11 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId11, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId11 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId12 = await txn.insert('programas_predeterminados', {
        'nombre': 'CELULITIS',
        'imagen': 'assets/images/CELULITIS.png',
        'frecuencia': 10,
        'rampa': 5,
        'pulso': 450,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId12");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId12,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId12 con valor $valorCronaxia en la tabla programa_cronaxia');
      }


      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId12, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId12 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId13 = await txn.insert('programas_predeterminados', {
        'nombre': 'RESISTENCIA',
        'imagen': 'assets/images/RESISTENCIA.png',
        'frecuencia': 43,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 10,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });
      print("Programa insertado con ID: $programaId13");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId13,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId13 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId13, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId13 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId14 = await txn.insert('programas_predeterminados', {
        'nombre': 'DEFINICIÓN',
        'imagen': 'assets/images/DEFINICION.png',
        'frecuencia': 33,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 6,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId14");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId14,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId14 con valor $valorCronaxia en la tabla programa_cronaxia');
      }


      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId14, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId14 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId15 = await txn.insert('programas_predeterminados', {
        'nombre': 'BASIC',
        'imagen': 'assets/images/BASIC.png',
        'frecuencia': 70,
        'rampa': 5,
        'pulso': 250,
        'contraccion': 4,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });
      print("Programa insertado con ID: $programaId15");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId15,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId15 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId15, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId15 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId16 = await txn.insert('programas_predeterminados', {
        'nombre': 'SUELO PÉLVICO',
        'imagen': 'assets/images/SUELOPELV.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 450,
        'contraccion': 4,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId16");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId16,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId16 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId16, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId16 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId17 = await txn.insert('programas_predeterminados', {
        'nombre': 'DOLOR MECÁNICO',
        'imagen': 'assets/images/DOLORMECANICO.png',
        'frecuencia': 5,
        'rampa': 5,
        'pulso': 150,
        'contraccion': 6,
        'pausa': 3,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId17");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId17,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId17 con valor $valorCronaxia en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId17, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId17 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId18 = await txn.insert('programas_predeterminados', {
        'nombre': 'DOLOR QUÍMICO',
        'imagen': 'assets/images/DOLORQUIM.png',
        'frecuencia': 110,
        'rampa': 5,
        'pulso': 250,
        'contraccion': 5,
        'pausa': 1,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId18");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId18,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId18 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId18, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId18 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId19 = await txn.insert('programas_predeterminados', {
        'nombre': 'DOLOR NEURÁLGICO',
        'imagen': 'assets/images/DOLORNEU.png',
        'frecuencia': 150,
        'rampa': 5,
        'pulso': 100,
        'contraccion': 10,
        'pausa': 1,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId19");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId19,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId19 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId19, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId19 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId20 = await txn.insert('programas_predeterminados', {
        'nombre': 'RELAX',
        'imagen': 'assets/images/RELAX.png',
        'frecuencia': 100,
        'rampa': 2,
        'pulso': 150,
        'contraccion': 3,
        'pausa': 2,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId20");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId20,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId20 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId20, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId20 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId21 = await txn.insert('programas_predeterminados', {
        'nombre': 'CONTRACTURAS',
        'imagen': 'assets/images/CONTRACTURAS.png',
        'frecuencia': 120,
        'rampa': 10,
        'pulso': 0,
        'contraccion': 4,
        'pausa': 3,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId21");

      final tipoEquipamiento = 'BIO-JACKET';

      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa y sus valores modificados
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Modificar valores específicos de cronaxias basándonos en su ID
        // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
        final nuevoValor = (cronaxiaId == 1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
            ? 375 // Nuevo valor para 'frecuencia'
            : (cronaxiaId == 2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
            ? 400 // Nuevo valor para 'rampa'
            : (cronaxiaId == 3) // ID = 3 'pulso'
            ? 400
            : valorCronaxia; // Para otras cronaxias, mantenemos el valor predeterminado

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId21,
          'cronaxia_id': cronaxiaId,
          'valor': nuevoValor,  // Aquí almacenamos el valor modificado para este programa
        });

        print(
            'ASOCIADO cronaxia con ID $cronaxiaId al programa ID $programaId21 con valor $nuevoValor en la tabla programa_cronaxia');
      }

      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento 
    WHERE tipo_equipamiento = ? AND id IN (1, 2, 3)
  ''', [
        tipoEquipamiento
      ]); // Filtrar por tipo de equipamiento y los IDs específicos (1, 2, 3)

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId21,
          // Relación con el programa
          'grupo_muscular_id': grupo['id'],
          // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId21 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId22 = await txn.insert('programas_predeterminados', {
        'nombre': 'DRENAJE',
        'imagen': 'assets/images/DRENAJE.png',
        'frecuencia': 21,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 5,
        'pausa': 3,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId22");


      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId22,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId22 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId22, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId22 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId23 = await txn.insert('programas_predeterminados', {
        'nombre': 'CAPILLARY',
        'imagen': 'assets/images/CAPILLARY.png',
        'frecuencia': 9,
        'rampa': 2,
        'pulso': 150,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId23");


      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId23,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId23 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId23, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId23 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId24 = await txn.insert('programas_predeterminados', {
        'nombre': 'METABOLIC',
        'imagen': 'assets/images/METABOLIC.png',
        'frecuencia': 7,
        'rampa': 2,
        'pulso': 350,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'BIO-JACKET'
      });

      print("Programa insertado con ID: $programaId24");


      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

      // Seleccionar cronaxias del tipo de equipamiento
      final cronaxiasQuery = await txn.query(
        'cronaxia',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento],
      );

      // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
      for (var cronaxia in cronaxiasQuery) {
        final cronaxiaId = cronaxia['id'];
        final nombreCronaxia = cronaxia['nombre'];
        final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId24,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
        });

        print(
            'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId24 con valor $valorCronaxia en la tabla programa_cronaxia');
      }
      // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
      List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
        tipoEquipamiento
      ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

      // Para cada grupo muscular, insertamos la relación con el programa
      for (var grupo in gruposMusculares) {
        // Insertar la asociación de cada grupo muscular con el programa
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId24, // Relación con el programa
          'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
        });

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId24 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });

    // Crear la tabla Programas_Automaticos
    await db.execute('''
      CREATE TABLE Programas_Automaticos (
        id_programa_automatico INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT,
        descripcion TEXT,
        duracionTotal REAL
      );
    ''');

    // Crear la tabla Programas_Automaticos_Subprogramas
    await db.execute('''
      CREATE TABLE Programas_Automaticos_Subprogramas (
        id_programa_automatico INTEGER,
        id_programa_relacionado INTEGER,
        ajuste REAL,
        duracion REAL,
        FOREIGN KEY (id_programa_automatico) REFERENCES Programas_Automaticos(id_programa_automatico),
        FOREIGN KEY (id_programa_relacionado) REFERENCES programas_predeterminados(id_programa)
      );
    ''');

    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "TONIFICACIÓN"
        int idProgramaAutomatico = await txn.insert('Programas_Automaticos', {
          'nombre': 'TONIFICACIÓN',
          'imagen': 'assets/images/TONING.png',
          'descripcion': 'Aumento de la resistencia y retraso de la fatiga.',
          'duracionTotal': 25,
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 1,
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 10,
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 9,
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 9,
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 9,
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 9,
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 23,
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 5,
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 5,
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 5,
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 5,
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 5,
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 23,
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 2,
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 2,
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 2,
            'ajuste': 1,
            'duracion': 1.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico,
            'id_programa_relacionado': 20,
            'ajuste': -5,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: TONIFICACIÓN');
        print('ID: $idProgramaAutomatico');
        print('Descripción: Aumento de la resistencia y retraso de la fatiga.');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query('programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']]);

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "GLÚTEOS"
        int idProgramaAutomatico2 = await txn.insert('Programas_Automaticos', {
          'nombre': 'GLÚTEOS',
          'imagen': 'assets/images/GLUTEOS.png',
          'descripcion': 'Fortalece los músculos del suelo pélvico',
          'duracionTotal': 25, // Duración total del programa en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 2
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': -3,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 4, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico2,
            'id_programa_relacionado': 22, // ID del programa recovery 3
            'ajuste': -7,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: GLÚTEOS');
        print('ID: $idProgramaAutomatico2');
        print('Descripción: Fortalece los músculos del suelo pélvico');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query('programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']]);

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "SUELO PÉLVICO"
        int idProgramaAutomatico3 = await txn.insert('Programas_Automaticos', {
          'nombre': 'SUELO PÉLVICO',
          'imagen': 'assets/images/SUELOPELV.png',
          'descripcion': 'Fortalece los músculos del suelo pélvico',
          'duracionTotal': 25, // Duración total del programa en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa individual 14
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 2
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico3,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: SUELO PÉLVICO');
        print('ID: $idProgramaAutomatico3');
        print('Descripción: Fortalece los músculos del suelo pélvico');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "FUERZA"
        int idProgramaAutomatico4 = await txn.insert('Programas_Automaticos', {
          'nombre': 'FUERZA',
          'imagen': 'assets/images/STRENGTH.png',
          'descripcion':
          'Aumento de la fuerza trabajando la potencia del músculo y quema de grasa',
          'duracionTotal': 25, // Duración total del programa en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 2, // ID del programa individual 4
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 2, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 2, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 23, // ID del programa recovery 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 3
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico4,
            'id_programa_relacionado': 22, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: FUERZA');
        print('ID: $idProgramaAutomatico4');
        print(
            'Descripción: Aumento de la fuerza trabajando la potencia del músculo y quema de grasa');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "HIPERTROFIA"
        int idProgramaAutomatico5 = await txn.insert('Programas_Automaticos', {
          'nombre': 'HIPERTROFIA',
          'imagen': 'assets/images/HIPERTROFIA.png',
          'descripcion':
          'Incremento del número de fibras musculares y el tamaño de las mismas. Aumenta la masa muscular y el metabolismo basal. Activa la circulación sanguínea, tonificación general, mejora la postura corporal y aumenta la densidad ósea.',
          'duracionTotal': 25, // Duración total del programa en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 9, // ID del programa individual 4
            'ajuste': -3,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 9, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 9, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 23, // ID del programa recovery 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 8, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 3, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico5,
            'id_programa_relacionado': 22, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: HIPERTROFIA');
        print('ID: $idProgramaAutomatico5');
        print(
            'Descripción: Incremento del número de fibras musculares y el tamaño de las mismas...');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "RESISTENCIA 1"
        int idProgramaAutomatico6 = await txn.insert('Programas_Automaticos', {
          'nombre': 'RESISTENCIA 1',
          'imagen': 'assets/images/RESISTENCIA(ENDURANCE).png',
          'descripcion':
          'Aumento de resistencia a la fatiga y recuperación entre entrenamientos',
          'duracionTotal': 25,
          // Duración total del programa automático en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 14, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 14, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 14, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 23, // ID del programa recovery 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 2, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 2, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 2, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico6,
            'id_programa_relacionado': 21, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: RESISTENCIA 1');
        print('ID: $idProgramaAutomatico6');
        print(
            'Descripción: Aumento de resistencia a la fatiga y recuperación entre entrenamientos');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "RESISTENCIA 2"
        int idProgramaAutomatico7 = await txn.insert('Programas_Automaticos', {
          'nombre': 'RESISTENCIA 2',
          'imagen': 'assets/images/RESISTENCIA2(ENDURANCE2).png',
          'descripcion':
          'Aumento de resistencia a la fatiga y recuperación entre entrenamientos. Nivel avanzado',
          'duracionTotal': 25,
          // Duración total del programa automático en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 6, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 6, // ID del programa individual 14
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 6, // ID del programa recovery 1
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 13, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico7,
            'id_programa_relacionado': 20, // ID del programa recovery 3
            'ajuste': -5,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: RESISTENCIA 2');
        print('ID: $idProgramaAutomatico7');
        print(
            'Descripción: Aumento de resistencia a la fatiga y recuperación entre entrenamientos. Nivel avanzado');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "CARDIO"
        int idProgramaAutomatico8 = await txn.insert('Programas_Automaticos', {
          'nombre': 'CARDIO',
          'imagen': 'assets/images/CARDIO.png',
          'descripcion':
          'Mejora del rendimiento cardiopulmonar y oxigenación del cuerpo',
          'duracionTotal': 25,
          // Duración total del programa automático en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 11, // ID del programa individual 4
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 11, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 11, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 14, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 14, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 14, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 14, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 14, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 23, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico8,
            'id_programa_relacionado': 22, // ID del programa recovery 3
            'ajuste': -7,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: CARDIO');
        print('ID: $idProgramaAutomatico8');
        print(
            'Descripción: Mejora del rendimiento cardiopulmonar y oxigenación del cuerpo');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "CROSS MAX"
        int idProgramaAutomatico9 = await txn.insert('Programas_Automaticos', {
          'nombre': 'CROSS MAX',
          'imagen': 'assets/images/CROSSMAX.png',
          'descripcion':
          'Programa experto. Entrenamiento para la mejora de la condición física.',
          'duracionTotal': 25,
          // Duración total del programa automático en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 9, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 9, // ID del programa individual 14
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 9, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 12, // ID del programa individual 2
            'ajuste': 0,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 6, // ID del programa individual 2
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 6, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 6, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 0
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': -2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 5, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 12, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 1
          },
          {
            'id_programa_automatico': idProgramaAutomatico9,
            'id_programa_relacionado': 20, // ID del programa recovery 3
            'ajuste': -5,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: CROSS MAX');
        print('ID: $idProgramaAutomatico9');
        print(
            'Descripción: Programa experto. Entrenamiento para la mejora de la condición física.');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
    await db.transaction((txn) async {
      try {
        // Insertamos el programa automático "SLIM"
        int idProgramaAutomatico10 = await txn.insert('Programas_Automaticos', {
          'nombre': 'SLIM',
          'imagen': 'assets/images/SLIM.png',
          'descripcion': 'Quema de grasa y creación de nuevas células.',
          'duracionTotal': 25,
          // Duración total del programa automático en minutos
        });

        // Lista de subprogramas con sus detalles
        List<Map<String, dynamic>> subprogramas = [
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 1, // ID del programa individual 1
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 10, // ID del programa individual 2
            'ajuste': 7,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 23, // ID del programa individual 3
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 3, // ID del programa individual 4
            'ajuste': -4,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 3, // ID del programa individual 14
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 3, // ID del programa recovery 1
            'ajuste': 2,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 23, // ID del programa individual 2
            'ajuste': 0,
            'duracion': 0.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 6, // ID del programa individual 2
            'ajuste': 0,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 6, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 6, // ID del programa recovery 3
            'ajuste': 2,
            'duracion': 2.5
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': -4,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 16, // ID del programa recovery 3
            'ajuste': 1,
            'duracion': 2
          },
          {
            'id_programa_automatico': idProgramaAutomatico10,
            'id_programa_relacionado': 21, // ID del programa recovery 3
            'ajuste': 0,
            'duracion': 5
          },
        ];

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: SLIM');
        print('ID: $idProgramaAutomatico10');
        print('Descripción: Quema de grasa y creación de nuevas células.');
        print('Duración Total: 25.0');
        print('Subprogramas:');
        print('*****************************************************');

        // Consulta para obtener los subprogramas relacionados y sus nombres
        for (var subprograma in subprogramas) {
          // Realizamos la consulta para obtener el nombre del subprograma
          var result = await txn.query(
            'programas_predeterminados',
            columns: ['nombre'],
            where: 'id_programa = ?',
            whereArgs: [subprograma['id_programa_relacionado']],
          );

          // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
          String nombreSubprograma = result.isNotEmpty
              ? result.first['nombre']
          as String // Aquí hacemos el cast explícito a String
              : 'Desconocido';

          print('Subprograma: $nombreSubprograma');
          print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
          print('Ajuste: ${subprograma['ajuste']}');
          print('Duración: ${subprograma['duracion']}');
          print('*****************************************************');
        }

        // Si todo ha ido bien, imprimimos un mensaje de éxito
        print('Programa automático y subprogramas insertados correctamente.');
      } catch (e) {
        print('Error durante la transacción: $e');
      }
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 93) {
      await db.execute('''
      CREATE TABLE programas_predeterminados (
        id_programa INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        imagen TEXT,
        frecuencia REAL,
        pulso REAL,
        rampa REAL,
        contraccion REAL,
        pausa REAL,
        tipo TEXT,
        tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
      );
    ''');
      print("Tabla 'programas_predeterminados' creada.");

      await db.execute('''
    CREATE TABLE IF NOT EXISTS cronaxia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    programa_id INTEGER, 
    nombre TEXT NOT NULL,
    valor REAL DEFAULT 0.0,  -- Cambiado a REAL con valor por defecto 0.0
    tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET')),
     FOREIGN KEY (programa_id) REFERENCES programas(id_programa)
  )
''');

      await db.execute(''' -- Tabla intermedia programa_cronaxia
CREATE TABLE programa_cronaxia (
  programa_id INTEGER,
  cronaxia_id INTEGER,
  valor REAL,
  PRIMARY KEY (programa_id, cronaxia_id),
  FOREIGN KEY (programa_id) REFERENCES programas_predeterminados(id),
  FOREIGN KEY (cronaxia_id) REFERENCES cronaxia(id)
)''');

      await db.execute('''
      CREATE TABLE IF NOT EXISTS ProgramaGrupoMuscular (
        programa_id INTEGER,
        grupo_muscular_id INTEGER,
        FOREIGN KEY (programa_id) REFERENCES programas_predeterminados(id_programa),
        FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares_equipamiento(id)
      );
    ''');
      print("Tabla 'ProgramaGrupoMuscular' creada.");

// Iniciamos la transacción
      await db.transaction((txn) async {
        // Inserciones para el tipo de equipamiento 'BIO-JACKET'
        await txn.insert('cronaxia', {'nombre': 'Trapecio', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Dorsales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Pectorales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
        await txn.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});

        // Inserciones para el tipo de equipamiento 'BIO-SHAPE'
        await txn.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
        await txn.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});

        // Imprimir mensaje para verificar inserciones
        print('Inserciones completadas para los tipos de equipamiento BIO-JACKET y BIO-SHAPE');
      });


      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId1 = await txn.insert('programas_predeterminados', {
          'nombre': 'CALIBRACIÓN',
          'imagen': 'assets/images/CALIBRACION.png',
          'frecuencia': 80,
          'rampa': 10,
          'pulso': 350,
          'contraccion': 4,
          'pausa': 1,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'  // Equipamiento seleccionado
        });

        print("Programa insertado con ID: $programaId1");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId1,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId1 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares asociados al tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId1,
            'grupo_muscular_id': grupo['id'],
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId1 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId2 = await txn.insert('programas_predeterminados', {
          'nombre': 'STRENGTH 1',
          'imagen': 'assets/images/STRENGTH1.png',
          'frecuencia': 85,
          'pulso': 350,
          'rampa': 8,
          'contraccion': 4,
          'pausa': 2,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId2");

        final tipoEquipamiento = 'BIO-JACKET';

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, se actualiza su valor (si hay un nuevo valor, se usa, sino se usa el valor existente)
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor'];


          // Relacionar la cronaxia con el programa y almacenar el valor
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId2,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,
            // Aquí se almacena el valor de la cronaxia en la relación
          });
          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId2 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
  SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

        for (var grupo in gruposMusculares) {
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId2,
            'grupo_muscular_id': grupo['id'],
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId2 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        int programaId3 = await txn.insert('programas_predeterminados', {
          'nombre': 'STRENGTH 2',
          'imagen': 'assets/images/STRENGTH2.png',
          'frecuencia': 85,
          'rampa': 10,
          'pulso': 400,
          'contraccion': 5,
          'pausa': 3,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId3");

        final tipoEquipamiento = 'BIO-JACKET';

        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor'];

          // Relacionar la cronaxia con el programa y almacenar el valor
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId3,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,
            // Aquí se almacena el valor de la cronaxia en la relación
          });
          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId3 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
  SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

        for (var grupo in gruposMusculares) {
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId3,
            'grupo_muscular_id': grupo['id'],
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId3 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId4 = await txn.insert('programas_predeterminados', {
          'nombre': 'GLÚTEOS',
          'imagen': 'assets/images/GLUTEOS.png',
          'frecuencia': 85,
          'rampa': 10,
          'pulso': 0,
          'contraccion': 6,
          'pausa': 4,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId4");

        final tipoEquipamiento = 'BIO-JACKET';

        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa y sus valores modificados
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Modificar valores específicos de cronaxias basándonos en su ID
          // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
          final nuevoValor = (cronaxiaId == 1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
              ? 200 // Nuevo valor para 'frecuencia'
              : (cronaxiaId == 2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
              ? 250 // Nuevo valor para 'rampa'
              : (cronaxiaId == 3) // ID = 3 'pulso'
              ? 200
              : (cronaxiaId == 4) // ID = 4 'contracción'
              ? 400
              : (cronaxiaId == 5) // ID = 5 'pausa'
              ? 300
              : (cronaxiaId == 6) // ID = 6 'tipo'
              ? 150
              : (cronaxiaId == 7) // ID = 7 'equipamiento'
              ? 350
              : (cronaxiaId == 8) // ID = 8 'otro'
              ? 400
              : (cronaxiaId == 9)
              ? 150
              : (cronaxiaId == 10)
              ? 150
              : valorCronaxia; // Para otras cronaxias, mantenemos el valor predeterminado

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId4,
            'cronaxia_id': cronaxiaId,
            'valor': nuevoValor,  // Aquí almacenamos el valor modificado para este programa
          });

          print(
              'ASOCIADO cronaxia con ID $cronaxiaId al programa ID $programaId4 con valor $nuevoValor en la tabla programa_cronaxia');
        }

        // Paso 5: Asociar grupos musculares con el programa
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [tipoEquipamiento]);

        for (var grupo in gruposMusculares) {
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId4,
            'grupo_muscular_id': grupo['id'],
          });

          print('ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId4 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId5 = await txn.insert('programas_predeterminados', {
          'nombre': 'ABDOMINAL',
          'imagen': 'assets/images/ABDOMINAL.png',
          'frecuencia': 43,
          'rampa': 8,
          'pulso': 450,
          'contraccion': 6,
          'pausa': 3,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId5");


        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId5,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId5 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId5, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId5 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId6 = await txn.insert('programas_predeterminados', {
          'nombre': 'SLIM',
          'imagen': 'assets/images/SLIM.png',
          'frecuencia': 66,
          'rampa': 5,
          'pulso': 350,
          'contraccion': 6,
          'pausa': 3,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId6");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId6,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId6 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId6, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId6 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId7 = await txn.insert('programas_predeterminados', {
          'nombre': 'BODY BUILDING 1',
          'imagen': 'assets/images/BODYBUILDING.png',
          'frecuencia': 75,
          'rampa': 5,
          'pulso': 300,
          'contraccion': 4,
          'pausa': 2,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId7");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId7,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId7 con valor $valorCronaxia en la tabla programa_cronaxia');
        }


        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId7, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId7 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId8 = await txn.insert('programas_predeterminados', {
          'nombre': 'BODY BUILDING 2',
          'imagen': 'assets/images/BODYBUILDING2.png',
          'frecuencia': 75,
          'rampa': 5,
          'pulso': 450,
          'contraccion': 4,
          'pausa': 2,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });
        print("Programa insertado con ID: $programaId8");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId8,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId8 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId8, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId8 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId9 = await txn.insert('programas_predeterminados', {
          'nombre': 'FITNESS',
          'imagen': 'assets/images/FITNESS.png',
          'frecuencia': 90,
          'rampa': 5,
          'pulso': 350,
          'contraccion': 5,
          'pausa': 4,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId9");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId9,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId9 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId9, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId9 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId10 = await txn.insert('programas_predeterminados', {
          'nombre': 'WARM UP',
          'imagen': 'assets/images/WARMUP.png',
          'frecuencia': 7,
          'rampa': 2,
          'pulso': 250,
          'contraccion': 1,
          'pausa': 0,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId10");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId10,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId10 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId10, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId10 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId11 = await txn.insert('programas_predeterminados', {
          'nombre': 'CARDIO',
          'imagen': 'assets/images/CARDIO.png',
          'frecuencia': 10,
          'rampa': 2,
          'pulso': 350,
          'contraccion': 1,
          'pausa': 0,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId11");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId11,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId11 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId11, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId11 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId12 = await txn.insert('programas_predeterminados', {
          'nombre': 'CELULITIS',
          'imagen': 'assets/images/CELULITIS.png',
          'frecuencia': 10,
          'rampa': 5,
          'pulso': 450,
          'contraccion': 1,
          'pausa': 0,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId12");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId12,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId12 con valor $valorCronaxia en la tabla programa_cronaxia');
        }


        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId12, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId12 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId13 = await txn.insert('programas_predeterminados', {
          'nombre': 'RESISTENCIA',
          'imagen': 'assets/images/RESISTENCIA.png',
          'frecuencia': 43,
          'rampa': 5,
          'pulso': 350,
          'contraccion': 10,
          'pausa': 4,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });
        print("Programa insertado con ID: $programaId13");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId13,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId13 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId13, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId13 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId14 = await txn.insert('programas_predeterminados', {
          'nombre': 'DEFINICIÓN',
          'imagen': 'assets/images/DEFINICION.png',
          'frecuencia': 33,
          'rampa': 5,
          'pulso': 350,
          'contraccion': 6,
          'pausa': 2,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId14");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId14,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId14 con valor $valorCronaxia en la tabla programa_cronaxia');
        }


        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId14, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId14 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId15 = await txn.insert('programas_predeterminados', {
          'nombre': 'BASIC',
          'imagen': 'assets/images/BASIC.png',
          'frecuencia': 70,
          'rampa': 5,
          'pulso': 250,
          'contraccion': 4,
          'pausa': 4,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });
        print("Programa insertado con ID: $programaId15");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId15,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId15 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId15, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId15 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId16 = await txn.insert('programas_predeterminados', {
          'nombre': 'SUELO PÉLVICO',
          'imagen': 'assets/images/SUELOPELV.png',
          'frecuencia': 85,
          'rampa': 10,
          'pulso': 450,
          'contraccion': 4,
          'pausa': 4,
          'tipo': 'Individual',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId16");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId16,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId16 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId16, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId16 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId17 = await txn.insert('programas_predeterminados', {
          'nombre': 'DOLOR MECÁNICO',
          'imagen': 'assets/images/DOLORMECANICO.png',
          'frecuencia': 5,
          'rampa': 5,
          'pulso': 150,
          'contraccion': 6,
          'pausa': 3,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId17");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId17,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId17 con valor $valorCronaxia en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId17, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId17 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId18 = await txn.insert('programas_predeterminados', {
          'nombre': 'DOLOR QUÍMICO',
          'imagen': 'assets/images/DOLORQUIM.png',
          'frecuencia': 110,
          'rampa': 5,
          'pulso': 250,
          'contraccion': 5,
          'pausa': 1,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId18");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId18,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId18 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId18, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId18 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId19 = await txn.insert('programas_predeterminados', {
          'nombre': 'DOLOR NEURÁLGICO',
          'imagen': 'assets/images/DOLORNEU.png',
          'frecuencia': 150,
          'rampa': 5,
          'pulso': 100,
          'contraccion': 10,
          'pausa': 1,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId19");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId19,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId19 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId19, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId19 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId20 = await txn.insert('programas_predeterminados', {
          'nombre': 'RELAX',
          'imagen': 'assets/images/RELAX.png',
          'frecuencia': 100,
          'rampa': 2,
          'pulso': 150,
          'contraccion': 3,
          'pausa': 2,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId20");

        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId20,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId20 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId20, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId20 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId21 = await txn.insert('programas_predeterminados', {
          'nombre': 'CONTRACTURAS',
          'imagen': 'assets/images/CONTRACTURAS.png',
          'frecuencia': 120,
          'rampa': 10,
          'pulso': 0,
          'contraccion': 4,
          'pausa': 3,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId21");

        final tipoEquipamiento = 'BIO-JACKET';

        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa y sus valores modificados
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Modificar valores específicos de cronaxias basándonos en su ID
          // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
          final nuevoValor = (cronaxiaId == 1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
              ? 375 // Nuevo valor para 'frecuencia'
              : (cronaxiaId == 2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
              ? 400 // Nuevo valor para 'rampa'
              : (cronaxiaId == 3) // ID = 3 'pulso'
              ? 400
              : valorCronaxia; // Para otras cronaxias, mantenemos el valor predeterminado

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId21,
            'cronaxia_id': cronaxiaId,
            'valor': nuevoValor,  // Aquí almacenamos el valor modificado para este programa
          });

          print(
              'ASOCIADO cronaxia con ID $cronaxiaId al programa ID $programaId21 con valor $nuevoValor en la tabla programa_cronaxia');
        }

        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento 
    WHERE tipo_equipamiento = ? AND id IN (1, 2, 3)
  ''', [
          tipoEquipamiento
        ]); // Filtrar por tipo de equipamiento y los IDs específicos (1, 2, 3)

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId21,
            // Relación con el programa
            'grupo_muscular_id': grupo['id'],
            // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId21 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId22 = await txn.insert('programas_predeterminados', {
          'nombre': 'DRENAJE',
          'imagen': 'assets/images/DRENAJE.png',
          'frecuencia': 21,
          'rampa': 5,
          'pulso': 350,
          'contraccion': 5,
          'pausa': 3,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId22");


        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId22,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId22 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId22, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId22 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId23 = await txn.insert('programas_predeterminados', {
          'nombre': 'CAPILLARY',
          'imagen': 'assets/images/CAPILLARY.png',
          'frecuencia': 9,
          'rampa': 2,
          'pulso': 150,
          'contraccion': 1,
          'pausa': 0,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId23");


        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId23,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId23 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId23, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId23 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });
      await db.transaction((txn) async {
        // Paso 1: Insertar el programa en la tabla programas_predeterminados
        int programaId24 = await txn.insert('programas_predeterminados', {
          'nombre': 'METABOLIC',
          'imagen': 'assets/images/METABOLIC.png',
          'frecuencia': 7,
          'rampa': 2,
          'pulso': 350,
          'contraccion': 1,
          'pausa': 0,
          'tipo': 'Recovery',
          'tipo_equipamiento': 'BIO-JACKET'
        });

        print("Programa insertado con ID: $programaId24");


        // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
        final tipoEquipamiento = 'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

        // Seleccionar cronaxias del tipo de equipamiento
        final cronaxiasQuery = await txn.query(
          'cronaxia',
          where: 'tipo_equipamiento = ?',
          whereArgs: [tipoEquipamiento],
        );

        // Paso 3: Para cada cronaxia, insertamos la relación con el programa sin modificar los valores
        for (var cronaxia in cronaxiasQuery) {
          final cronaxiaId = cronaxia['id'];
          final nombreCronaxia = cronaxia['nombre'];
          final valorCronaxia = cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

          // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
          await txn.insert('programa_cronaxia', {
            'programa_id': programaId24,
            'cronaxia_id': cronaxiaId,
            'valor': valorCronaxia,  // Mantener el valor predeterminado de la cronaxia
          });

          print(
              'ASOCIADO cronaxia "$nombreCronaxia" al programa ID $programaId24 con valor $valorCronaxia en la tabla programa_cronaxia');
        }
        // Paso 4: Seleccionar los grupos musculares por tipo de equipamiento
        List<Map<String, dynamic>> gruposMusculares = await txn.rawQuery('''
    SELECT * FROM grupos_musculares_equipamiento WHERE tipo_equipamiento = ?
  ''', [
          tipoEquipamiento
        ]); // Aquí 'tipoEquipamiento' es el tipo de equipamiento (e.g., 'BIO-JACKET')

        // Para cada grupo muscular, insertamos la relación con el programa
        for (var grupo in gruposMusculares) {
          // Insertar la asociación de cada grupo muscular con el programa
          await txn.insert('ProgramaGrupoMuscular', {
            'programa_id': programaId24, // Relación con el programa
            'grupo_muscular_id': grupo['id'], // Relación con el grupo muscular
          });

          print(
              'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId24 CON ID GRUPO MUSCULAR ${grupo['id']}');
        }
      });

      await db.execute('''
      CREATE TABLE IF NOT EXISTS ProgramaGrupoMuscular (
        programa_id INTEGER,
        grupo_muscular_id INTEGER,
        FOREIGN KEY (programa_id) REFERENCES programas_predeterminados(id_programa),
        FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares_equipamiento(id)
      );
    ''');
      print("Tabla 'ProgramaGrupoMuscular' creada.");

      // Crear la tabla Programas_Automaticos
      await db.execute('''
      CREATE TABLE Programas_Automaticos (
        id_programa_automatico INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT,
        descripcion TEXT,
        duracionTotal REAL
      );
    ''');

      // Crear la tabla Programas_Automaticos_Subprogramas
      await db.execute('''
      CREATE TABLE Programas_Automaticos_Subprogramas (
        id_programa_automatico INTEGER,
        id_programa_relacionado INTEGER,
        ajuste REAL,
        duracion REAL,
        FOREIGN KEY (id_programa_automatico) REFERENCES Programas_Automaticos(id_programa_automatico),
        FOREIGN KEY (id_programa_relacionado) REFERENCES programas_predeterminados(id_programa)
      );
    ''');

      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "TONIFICACIÓN"
          int idProgramaAutomatico = await txn.insert('Programas_Automaticos', {
            'nombre': 'TONIFICACIÓN',
            'imagen': 'assets/images/TONING.png',
            'descripcion': 'Aumento de la resistencia y retraso de la fatiga.',
            'duracionTotal': 25,
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 1,
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 10,
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 9,
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 9,
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 9,
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 9,
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 23,
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 5,
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 5,
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 5,
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 5,
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 5,
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 23,
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 2,
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 2,
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 2,
              'ajuste': 1,
              'duracion': 1.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico,
              'id_programa_relacionado': 20,
              'ajuste': -5,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: TONIFICACIÓN');
          print('ID: $idProgramaAutomatico');
          print(
              'Descripción: Aumento de la resistencia y retraso de la fatiga.');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query('programas_predeterminados',
                columns: ['nombre'],
                where: 'id_programa = ?',
                whereArgs: [subprograma['id_programa_relacionado']]);

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "GLÚTEOS"
          int idProgramaAutomatico2 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'GLÚTEOS',
            'imagen': 'assets/images/GLUTEOS.png',
            'descripcion': 'Fortalece los músculos del suelo pélvico',
            'duracionTotal': 25, // Duración total del programa en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 2
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': -3,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 4, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico2,
              'id_programa_relacionado': 22, // ID del programa recovery 3
              'ajuste': -7,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: GLÚTEOS');
          print('ID: $idProgramaAutomatico2');
          print('Descripción: Fortalece los músculos del suelo pélvico');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query('programas_predeterminados',
                columns: ['nombre'],
                where: 'id_programa = ?',
                whereArgs: [subprograma['id_programa_relacionado']]);

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "SUELO PÉLVICO"
          int idProgramaAutomatico3 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'SUELO PÉLVICO',
            'imagen': 'assets/images/SUELOPELV.png',
            'descripcion': 'Fortalece los músculos del suelo pélvico',
            'duracionTotal': 25, // Duración total del programa en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa individual 14
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 2
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico3,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: SUELO PÉLVICO');
          print('ID: $idProgramaAutomatico3');
          print('Descripción: Fortalece los músculos del suelo pélvico');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "FUERZA"
          int idProgramaAutomatico4 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'FUERZA',
            'imagen': 'assets/images/STRENGTH.png',
            'descripcion':
            'Aumento de la fuerza trabajando la potencia del músculo y quema de grasa',
            'duracionTotal': 25, // Duración total del programa en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 2, // ID del programa individual 4
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 2, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 2, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 23, // ID del programa recovery 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 3
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico4,
              'id_programa_relacionado': 22, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: FUERZA');
          print('ID: $idProgramaAutomatico4');
          print(
              'Descripción: Aumento de la fuerza trabajando la potencia del músculo y quema de grasa');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "HIPERTROFIA"
          int idProgramaAutomatico5 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'HIPERTROFIA',
            'imagen': 'assets/images/HIPERTROFIA.png',
            'descripcion':
            'Incremento del número de fibras musculares y el tamaño de las mismas. Aumenta la masa muscular y el metabolismo basal. Activa la circulación sanguínea, tonificación general, mejora la postura corporal y aumenta la densidad ósea.',
            'duracionTotal': 25, // Duración total del programa en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 9, // ID del programa individual 4
              'ajuste': -3,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 9, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 9, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 23, // ID del programa recovery 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 8, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 3, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico5,
              'id_programa_relacionado': 22, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: HIPERTROFIA');
          print('ID: $idProgramaAutomatico5');
          print(
              'Descripción: Incremento del número de fibras musculares y el tamaño de las mismas...');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "RESISTENCIA 1"
          int idProgramaAutomatico6 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'RESISTENCIA 1',
            'imagen': 'assets/images/RESISTENCIA(ENDURANCE).png',
            'descripcion':
            'Aumento de resistencia a la fatiga y recuperación entre entrenamientos',
            'duracionTotal': 25,
            // Duración total del programa automático en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 14, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 14, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 14, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 23, // ID del programa recovery 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 2, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 2, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 2, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico6,
              'id_programa_relacionado': 21, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: RESISTENCIA 1');
          print('ID: $idProgramaAutomatico6');
          print(
              'Descripción: Aumento de resistencia a la fatiga y recuperación entre entrenamientos');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "RESISTENCIA 2"
          int idProgramaAutomatico7 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'RESISTENCIA 2',
            'imagen': 'assets/images/RESISTENCIA2(ENDURANCE2).png',
            'descripcion':
            'Aumento de resistencia a la fatiga y recuperación entre entrenamientos. Nivel avanzado',
            'duracionTotal': 25,
            // Duración total del programa automático en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 6, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 6, // ID del programa individual 14
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 6, // ID del programa recovery 1
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 13, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico7,
              'id_programa_relacionado': 20, // ID del programa recovery 3
              'ajuste': -5,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: RESISTENCIA 2');
          print('ID: $idProgramaAutomatico7');
          print(
              'Descripción: Aumento de resistencia a la fatiga y recuperación entre entrenamientos. Nivel avanzado');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "CARDIO"
          int idProgramaAutomatico8 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'CARDIO',
            'imagen': 'assets/images/CARDIO.png',
            'descripcion':
            'Mejora del rendimiento cardiopulmonar y oxigenación del cuerpo',
            'duracionTotal': 25,
            // Duración total del programa automático en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 11, // ID del programa individual 4
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 11, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 11, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 14, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 14, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 14, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 14, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 14, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 23, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico8,
              'id_programa_relacionado': 22, // ID del programa recovery 3
              'ajuste': -7,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: CARDIO');
          print('ID: $idProgramaAutomatico8');
          print(
              'Descripción: Mejora del rendimiento cardiopulmonar y oxigenación del cuerpo');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "CROSS MAX"
          int idProgramaAutomatico9 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'CROSS MAX',
            'imagen': 'assets/images/CROSSMAX.png',
            'descripcion':
            'Programa experto. Entrenamiento para la mejora de la condición física.',
            'duracionTotal': 25,
            // Duración total del programa automático en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 9, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 9, // ID del programa individual 14
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 9, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 12, // ID del programa individual 2
              'ajuste': 0,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 6, // ID del programa individual 2
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 6, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 6, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 0
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': -2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 5, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 12, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 1
            },
            {
              'id_programa_automatico': idProgramaAutomatico9,
              'id_programa_relacionado': 20, // ID del programa recovery 3
              'ajuste': -5,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: CROSS MAX');
          print('ID: $idProgramaAutomatico9');
          print(
              'Descripción: Programa experto. Entrenamiento para la mejora de la condición física.');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
      await db.transaction((txn) async {
        try {
          // Insertamos el programa automático "SLIM"
          int idProgramaAutomatico10 =
          await txn.insert('Programas_Automaticos', {
            'nombre': 'SLIM',
            'imagen': 'assets/images/SLIM.png',
            'descripcion': 'Quema de grasa y creación de nuevas células.',
            'duracionTotal': 25,
            // Duración total del programa automático en minutos
          });

          // Lista de subprogramas con sus detalles
          List<Map<String, dynamic>> subprogramas = [
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 1, // ID del programa individual 1
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 10, // ID del programa individual 2
              'ajuste': 7,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 23, // ID del programa individual 3
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 3, // ID del programa individual 4
              'ajuste': -4,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 3, // ID del programa individual 14
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 3, // ID del programa recovery 1
              'ajuste': 2,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 23, // ID del programa individual 2
              'ajuste': 0,
              'duracion': 0.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 6, // ID del programa individual 2
              'ajuste': 0,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 6, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 6, // ID del programa recovery 3
              'ajuste': 2,
              'duracion': 2.5
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': -4,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 16, // ID del programa recovery 3
              'ajuste': 1,
              'duracion': 2
            },
            {
              'id_programa_automatico': idProgramaAutomatico10,
              'id_programa_relacionado': 21, // ID del programa recovery 3
              'ajuste': 0,
              'duracion': 5
            },
          ];

          // Insertamos los subprogramas
          for (var subprograma in subprogramas) {
            await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
          }

          // Verificamos los subprogramas insertados
          print('Programa Automático: SLIM');
          print('ID: $idProgramaAutomatico10');
          print('Descripción: Quema de grasa y creación de nuevas células.');
          print('Duración Total: 25.0');
          print('Subprogramas:');
          print('*****************************************************');

          // Consulta para obtener los subprogramas relacionados y sus nombres
          for (var subprograma in subprogramas) {
            // Realizamos la consulta para obtener el nombre del subprograma
            var result = await txn.query(
              'programas_predeterminados',
              columns: ['nombre'],
              where: 'id_programa = ?',
              whereArgs: [subprograma['id_programa_relacionado']],
            );

            // Si el subprograma existe en la tabla de Programas, obtenemos su nombre
            String nombreSubprograma = result.isNotEmpty
                ? result.first['nombre']
            as String // Aquí hacemos el cast explícito a String
                : 'Desconocido';

            print('Subprograma: $nombreSubprograma');
            print('ID Subprograma: ${subprograma['id_programa_relacionado']}');
            print('Ajuste: ${subprograma['ajuste']}');
            print('Duración: ${subprograma['duracion']}');
            print('*****************************************************');
          }

          // Si todo ha ido bien, imprimimos un mensaje de éxito
          print('Programa automático y subprogramas insertados correctamente.');
        } catch (e) {
          print('Error durante la transacción: $e');
        }
      });
    }
  }

  /*METODOS DE INSERCION BBDD*/

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

// Función para insertar un programa predeterminado
  Future<int> insertarProgramaPredeterminado(
      Map<String, dynamic> programa) async {
    final db = await database;
    int idPrograma = await db.insert('programas_predeterminados', programa);
    print('Programa insertado con ID: $idPrograma');
    return idPrograma;
  }

// Función para insertar las cronaxias por defecto
  Future<void> insertarCronaxiasPorDefecto(int programaId,
      String tipoEquipamiento) async {
    final db = await database;

    // Obtén las cronaxias asociadas al tipo de equipamiento para el programa recién creado
    List<Map<String, dynamic>> cronaxias = await db.query('cronaxia',
        where: 'tipo_equipamiento = ?', whereArgs: [tipoEquipamiento]);

    print(
        'Cronaxias encontradas para el tipo de equipamiento $tipoEquipamiento: ${cronaxias
            .length}');

    // Iterar sobre las cronaxias encontradas
    for (var cronaxia in cronaxias) {
      print(
          'Cronaxia: ${cronaxia['nombre']} con valor: ${cronaxia['valor']}');

      // Verificar si la cronaxia ya está asociada con el programa en la tabla intermedia
      var existingCronaxia = await db.query('programa_cronaxia',
          where: 'programa_id = ? AND cronaxia_id = ?',
          whereArgs: [programaId, cronaxia['id']]);

      // Si no existe, insertamos la cronaxia en la tabla intermedia
      if (existingCronaxia.isEmpty) {
        await db.insert('programa_cronaxia', {
          'programa_id': programaId,
          'cronaxia_id': cronaxia['id'],
          'valor' : 0.0,
        });
        print(
            'Cronaxia insertada: ${cronaxia['nombre']} para el programa $programaId');
      } else {
        print(
            'Cronaxia ya existe: ${cronaxia['nombre']} para el programa $programaId');
      }
    }
  }

// Función para insertar los grupos musculares por defecto
  Future<void> insertarGruposMuscularesPorDefecto(int programaId,
      String tipoEquipamiento) async {
    final db = await database;

    // Obtén los grupos musculares asociados al tipo de equipamiento para el programa recién creado
    List<Map<String, dynamic>> gruposMusculares = await db.query(
        'grupos_musculares_equipamiento',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento]);

    print(
        'Grupos musculares encontrados para el tipo de equipamiento $tipoEquipamiento: ${gruposMusculares
            .length}');

    // Iterar sobre los grupos musculares encontrados
    for (var grupoMuscular in gruposMusculares) {
      print('Grupo muscular: ${grupoMuscular['nombre']}');

      // Verificar si el grupo muscular ya está asociado con el programa en la tabla intermedia
      var existingGrupoMuscular = await db.query('ProgramaGrupoMuscular',
          where: 'programa_id = ? AND grupo_muscular_id = ?',
          whereArgs: [programaId, grupoMuscular['id']]);

      // Si no existe, insertamos el grupo muscular en la tabla intermedia
      if (existingGrupoMuscular.isEmpty) {
        await db.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId,
          'grupo_muscular_id': grupoMuscular['id'],
        });
        print(
            'Grupo muscular insertado: ${grupoMuscular['nombre']} para el programa $programaId');
      } else {
        print(
            'Grupo muscular ya existe: ${grupoMuscular['nombre']} para el programa $programaId');
      }
    }
  }

/* METODOS ACTUALIZACION BBDD*/

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

  // Función para actualizar una cronaxia
  Future<void> updateCronaxia(int programaId, int cronaxiaId, double valor) async {
    final db = await database;

    // Verifica si la cronaxia existe en la tabla
    final existingCronaxia = await db.query(
      'programa_cronaxia',
      where: 'programa_id = ? AND cronaxia_id = ?',
      whereArgs: [programaId, cronaxiaId],
    );

    // Si la cronaxia existe, actualizamos el valor
    if (existingCronaxia.isNotEmpty) {
      try {
        await db.update(
          'programa_cronaxia',
          {'valor': valor},
          where: 'programa_id = ? AND cronaxia_id = ?',
          whereArgs: [programaId, cronaxiaId],
        );
        print('Cronaxia actualizada correctamente');
      } catch (e) {
        print('Error al actualizar la cronaxia: $e');
      }
    } else {
      print('Cronaxia con programa_id $programaId y cronaxia_id $cronaxiaId no encontrada');
    }
  }

  /*METODOS GET DE LA BBDD*/

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

  // Obtener los datos de la tabla grupos_musculares
  Future<List<Map<String, dynamic>>> getGruposMusculares() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
    await db.query('grupos_musculares');
    return result;
  }

  // Obtener los datos de la tabla grupos_musculares
  Future<List<Map<String, dynamic>>> getGruposMuscularesTraje() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
    await db.query('grupos_musculares_traje');
    return result;
  }

  // Obtener los datos de la tabla grupos_musculares
  Future<List<Map<String, dynamic>>> getGruposMuscularesPantalon() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
    await db.query('grupos_musculares_pantalon');
    return result;
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

  Future<List<Map<String, dynamic>>> obtenerProgramasPredeterminadosPorTipoIndividual(Database db) async {


    // Consulta que une los datos de programas, cronaxias, y grupos musculares, filtrando solo los programas de tipo 'Individual'
    final List<Map<String, dynamic>> programasConDetalles = await db.rawQuery('''
    SELECT 
      p.id_programa,
      p.nombre AS nombre,
      p.imagen,
      p.frecuencia,
      p.pulso,
      p.rampa,
      p.contraccion,
      p.pausa,
      p.tipo,
      p.tipo_equipamiento,
      c.id AS cronaxia_id,
      c.nombre AS nombre_cronaxia,
      pc.valor AS valor_cronaxia,
      gm.id AS grupo_muscular_id,
      gm.nombre AS nombre_grupo_muscular
    FROM 
      programas_predeterminados p
    LEFT JOIN 
      programa_cronaxia pc ON p.id_programa = pc.programa_id
    LEFT JOIN 
      cronaxia c ON pc.cronaxia_id = c.id
    LEFT JOIN 
      ProgramaGrupoMuscular pgm ON p.id_programa = pgm.programa_id
    LEFT JOIN 
      grupos_musculares_equipamiento gm ON pgm.grupo_muscular_id = gm.id
    WHERE 
      p.tipo = 'Individual'
    ORDER BY 
      p.id_programa, c.id, gm.id
  ''');

    // Procesar los resultados para estructurar la salida en una lista de programas
    List<Map<String, dynamic>> programas = [];
    Map<int, Map<String, dynamic>> programaMap = {};

    for (var row in programasConDetalles) {
      int programaId = row['id_programa'];

      // Verifica si ya tenemos el programa en el mapa
      if (!programaMap.containsKey(programaId)) {
        programaMap[programaId] = {
          'id_programa': row['id_programa'],
          'nombre': row['nombre'],
          'imagen': row['imagen'],
          'frecuencia': row['frecuencia'],
          'pulso': row['pulso'],
          'rampa': row['rampa'],
          'contraccion': row['contraccion'],
          'pausa': row['pausa'],
          'tipo': row['tipo'],
          'tipo_equipamiento': row['tipo_equipamiento'],
          'cronaxias': [],
          'grupos_musculares': [],
        };
      }

      // Agregar la cronaxia actual al programa si existe
      if (row['cronaxia_id'] != null) {
        programaMap[programaId]?['cronaxias'].add({
          'id': row['cronaxia_id'],
          'nombre': row['nombre_cronaxia'],
          'valor': row['valor_cronaxia'],
        });
      }

      // Agregar el grupo muscular actual al programa si existe
      if (row['grupo_muscular_id'] != null) {
        programaMap[programaId]?['grupos_musculares'].add({
          'id': row['grupo_muscular_id'],
          'nombre': row['nombre_grupo_muscular'],
        });
      }
    }
    // Convertir el mapa a lista
    programas = programaMap.values.toList();



    return programas;
  }



  Future<List<Map<String, dynamic>>> obtenerProgramasPredeterminadosPorTipoRecovery(Database db) async {


    // Consulta que une los datos de programas, cronaxias, y grupos musculares, filtrando solo los programas de tipo 'Individual'
    final List<Map<String, dynamic>> programasConDetalles = await db.rawQuery('''
    SELECT 
      p.id_programa,
      p.nombre AS nombre,
      p.imagen,
      p.frecuencia,
      p.pulso,
      p.rampa,
      p.contraccion,
      p.pausa,
      p.tipo,
      p.tipo_equipamiento,
      c.id AS cronaxia_id,
      c.nombre AS nombre_cronaxia,
      pc.valor AS valor_cronaxia,
      gm.id AS grupo_muscular_id,
      gm.nombre AS nombre_grupo_muscular
    FROM 
      programas_predeterminados p
    LEFT JOIN 
      programa_cronaxia pc ON p.id_programa = pc.programa_id
    LEFT JOIN 
      cronaxia c ON pc.cronaxia_id = c.id
    LEFT JOIN 
      ProgramaGrupoMuscular pgm ON p.id_programa = pgm.programa_id
    LEFT JOIN 
      grupos_musculares_equipamiento gm ON pgm.grupo_muscular_id = gm.id
    WHERE 
      p.tipo = 'Recovery'
    ORDER BY 
      p.id_programa, c.id, gm.id
  ''');

    // Procesar los resultados para estructurar la salida en una lista de programas
    List<Map<String, dynamic>> programas = [];
    Map<int, Map<String, dynamic>> programaMap = {};

    for (var row in programasConDetalles) {
      int programaId = row['id_programa'];

      // Verifica si ya tenemos el programa en el mapa
      if (!programaMap.containsKey(programaId)) {
        programaMap[programaId] = {
          'id_programa': row['id_programa'],
          'nombre': row['nombre'],
          'imagen': row['imagen'],
          'frecuencia': row['frecuencia'],
          'pulso': row['pulso'],
          'rampa': row['rampa'],
          'contraccion': row['contraccion'],
          'pausa': row['pausa'],
          'tipo': row['tipo'],
          'tipo_equipamiento': row['tipo_equipamiento'],
          'cronaxias': [],
          'grupos_musculares': [],
        };
      }

      // Agregar la cronaxia actual al programa si existe
      if (row['cronaxia_id'] != null) {
        programaMap[programaId]?['cronaxias'].add({
          'id': row['cronaxia_id'],
          'nombre': row['nombre_cronaxia'],
          'valor': row['valor_cronaxia'],
        });
      }

      // Agregar el grupo muscular actual al programa si existe
      if (row['grupo_muscular_id'] != null) {
        programaMap[programaId]?['grupos_musculares'].add({
          'id': row['grupo_muscular_id'],
          'nombre': row['nombre_grupo_muscular'],
        });
      }
    }
    // Convertir el mapa a lista
    programas = programaMap.values.toList();



    return programas;
  }

  Future<List<
      Map<String, dynamic>>> obtenerProgramasAutomaticosConSubprogramas(
      Database db) async {
    try {
      // Consulta los programas automáticos
      final List<Map<String, dynamic>> programas = await db.rawQuery('''
      SELECT * FROM Programas_Automaticos
    ''');

      // Lista para almacenar los programas junto con sus subprogramas
      List<Map<String, dynamic>> programasConSubprogramas = [];

      for (var programa in programas) {
        // Obtiene los subprogramas relacionados con el programa actual
        final List<Map<String, dynamic>> subprogramas = await db.rawQuery(
            '''
        SELECT pa.id_programa_automatico, pa.id_programa_relacionado, pr.nombre, pa.ajuste, pa.duracion
        FROM Programas_Automaticos_Subprogramas pa
        JOIN programas_predeterminados pr ON pr.id_programa = pa.id_programa_relacionado
        WHERE pa.id_programa_automatico = ?
      ''', [programa['id_programa_automatico']]);

        // Verificamos si el id de programa es válido (no nulo)
        if (programa['id_programa_automatico'] != null) {
          programasConSubprogramas.add({
            'id_programa_automatico': programa['id_programa_automatico'],
            'nombre': programa['nombre'],
            'imagen': programa['imagen'],
            'descripcion': programa['descripcion'],
            'duracionTotal': programa['duracionTotal'],
            'subprogramas': subprogramas,
          });
        }
      }

      return programasConSubprogramas;
    } catch (e) {
      print('Error al obtener programas automáticos: $e');
      return []; // Retorna una lista vacía si hay un error
    }
  }

  Future<List<Map<String, dynamic>>> obtenerGruposMuscularesPorEquipamiento(
      Database db, String tipoEquipamiento) async {
    // Verifica que el tipo de equipamiento sea válido
    if (tipoEquipamiento != 'BIO-SHAPE' &&
        tipoEquipamiento != 'BIO-JACKET') {
      throw ArgumentError(
          'Tipo de equipamiento inválido. Debe ser "BIO-SHAPE" o "BIO-JACKET".');
    }

    // Imprime el tipo de equipamiento
    print(
        'Obteniendo grupos musculares para el tipo de equipamiento: $tipoEquipamiento');

    // Realiza la consulta en la base de datos
    List<Map<String, dynamic>> gruposMusculares = await db.query(
      'grupos_musculares_equipamiento', // Nombre de la tabla
      where: 'tipo_equipamiento = ?', // Filtro por tipo de equipamiento
      whereArgs: [tipoEquipamiento], // Argumento del filtro
    );

    // Imprime el resultado de la consulta
    print('Grupos musculares obtenidos: ${gruposMusculares
        .length} elementos.');

    // Itera sobre los resultados e imprime cada grupo muscular y su tipo de equipamiento
    for (var grupo in gruposMusculares) {
      print(
          'INSERTADO "${grupo['nombre']}" TIPO "${grupo['tipo_equipamiento']}"');
    }

    return gruposMusculares;
  }

  Future<List<Map<String, dynamic>>> obtenerCronaxiaPorEquipamiento(Database db,
      String tipoEquipamiento) async {
    // Verifica que el tipo de equipamiento sea válido
    if (tipoEquipamiento != 'BIO-SHAPE' &&
        tipoEquipamiento != 'BIO-JACKET') {
      throw ArgumentError(
          'Tipo de equipamiento inválido. Debe ser "BIO-SHAPE" o "BIO-JACKET".');
    }

    // Imprime el tipo de equipamiento
    print('Cronaxia para el tipo de equipamiento: $tipoEquipamiento');

    // Realiza la consulta en la base de datos
    List<Map<String, dynamic>> cronaxias = await db.query(
      'cronaxia', // Nombre de la tabla
      where: 'tipo_equipamiento = ?', // Filtro por tipo de equipamiento
      whereArgs: [tipoEquipamiento], // Argumento del filtro
    );

    // Imprime el resultado de la consulta
    print('Grupos musculares obtenidos: ${cronaxias.length} elementos.');

    // Itera sobre los resultados e imprime cada grupo muscular y su tipo de equipamiento
    for (var grupo in cronaxias) {
      print(
          'INSERTADO "${grupo['nombre']}" TIPO "${grupo['tipo_equipamiento']}"');
    }

    return cronaxias;
  }

  Future<List<Map<String, dynamic>>> obtenerGruposPorPrograma(Database db,
      int programaId) async {
    final List<Map<String, dynamic>> grupos = await db.rawQuery('''
      SELECT g.id, g.nombre, g.imagen, g.tipo_equipamiento
      FROM grupos_musculares_equipamiento g
      INNER JOIN ProgramaGrupoMuscular pg ON g.id = pg.grupo_muscular_id
      WHERE pg.programa_id = ?
    ''', [programaId]);

    return grupos;
  }

  Future<List<Map<String, dynamic>>> obtenerCronaxiasPorPrograma(Database db, int programaId) async {
    return await db.rawQuery('''
    SELECT c.nombre, pc.valor
    FROM programa_cronaxia AS pc
    INNER JOIN cronaxia AS c ON pc.cronaxia_id = c.id
    WHERE pc.programa_id = ?
  ''', [programaId]);
  }


  // Obtener el programa más reciente (con el id más alto)
  Future<int?> getMostRecentProgramaId() async {
    final db = await database;
    // Realizamos una consulta que ordene por programa_id de forma descendente (del más grande al más pequeño)
    final List<Map<String, dynamic>> result = await db.query(
      'programas_predeterminados', // Asume que la tabla se llama 'programas'
      orderBy: 'id_programa DESC', // Ordenamos por programa_id de manera descendente
      limit: 1, // Solo nos interesa el primer resultado (el más reciente)
    );
    if (result.isNotEmpty) {
      return result.first['id_programa']; // Retorna el programa_id más reciente
    }
    return null; // Si no hay programas en la base de datos
  }


  /*METODOS DE BORRADO DE BBD*/

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

  // Eliminar un cliente por ID
  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
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

/* // Método para llamar al deleteDatabaseFile
  Future<void> _deleteDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteDatabaseFile();  // Elimina la base de datos
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Base de datos eliminada con éxito.'),
    ));
  }*/
}
