import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelperWeb {
  static final DatabaseHelperWeb _instance = DatabaseHelperWeb._internal();
  static Database? _database;
  BuildContext? _context;

  List<String?> strings = List.filled(38, null, growable: true);
  factory DatabaseHelperWeb() {
    return _instance;
  }

  DatabaseHelperWeb._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    if (_context == null) {
      throw Exception(
          "⚠️ La base de datos debe inicializarse con contexto usando initializeDatabase(context).");
    }

    // Inicializa la base de datos automáticamente si no estaba lista
    await initializeDatabase(_context!);
    return _database!;
  }

  // Inicialización de la base de datos
  Future<Database> _initDatabase(BuildContext context) async {
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
          version: 1,
          onCreate: (db, version) async {
            print("✅ Base de datos creada. Ejecutando _onCreate...");
            await _onCreate(db, version, context);
          },
          onUpgrade: _onUpgrade,
        ));
  }
  Future<void> initializeDatabase(BuildContext context) async {
    if (_database != null) return; // Si ya está inicializada, no hacer nada
    _context = context;
    _database = await _initDatabase(context);
    print("📌 Estado actual de _database: $_database, _context: $_context");
  }

  void initializeTranslations(BuildContext context) {
    strings[0] = 'Calibración';
    strings[1] = 'Fuerza 1';
    strings[2] = 'Fuerza 2';
    strings[3] = 'Glúteos';
    strings[4] = 'Abdominal';
    strings[5] = 'Celulitis';
    strings[6] = 'Resistencia';
    strings[7] = 'Definición';
    strings[8] = 'Suelo pélvico';
    strings[9] = 'Tonificación';
    strings[10] = 'Fuerza';
    strings[11] = 'Hipertrofia';
    strings[12] = 'Resistencia 1';
    strings[13] = 'Resistencia 2';
    strings[14] = 'Dolor mecánico';
    strings[15] = 'Dolor neurálgico';
    strings[16] = 'Dolor químico';
    strings[17] = 'Contracturas';
    strings[18] = 'Drenaje';
    strings[19] = "Aumento de la resistencia y retraso de la fatiga";
    strings[20] = "Fortalece los músculos del suelo pélvico";
    strings[21] =
    "Aumento de la fuerza trabajando la potencia del músculo y quema de grasa";
    strings[22] =
    "Incremento del número de fibras musculares y el tamaño de las mismas. Aumenta la masa muscular y el metabolismo basal, mejora la postura corporal, etc.";
    strings[23] =
    "Aumento de la resistencia a la fatiga y recuperación entre entrenamientos";
    strings[24] =
    "Aumento de la resistencia a la fatiga y recuperación entre entrenamientos. Nivel avanzado";
    strings[25] =
    "Mejora del rendimiento cardiopulmonar y oxigenación del cuerpo";
    strings[26] =
    "Programa experto. Entrenamiento para la mejora de la condición física";
    strings[27] = "Quema de grasa y creación de nuevas células";
    strings[28] = "Pectorales";
    strings[29] = "Trapecios";
    strings[30] = "Dorsales";
    strings[31] = "Glúteos";
    strings[32] = "Isquiotibiales";
    strings[33] = "Lumbares";
    strings[34] = "Abdomen";
    strings[35] = "Cuádriceps";
    strings[36] = "Bíceps";
    strings[37] = "Gemelos";
  }

  Future<void> _onCreate(Database db, int version, BuildContext context) async {
    initializeTranslations(
        context); // Llamar a la función para traducir antes de insertar

    // Crear la tabla clientes
    await db.execute('''
  CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL, -- Relación con usuarios
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    gender TEXT NOT NULL,
    height INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    birthdate TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
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

    await db.execute('''
  CREATE TABLE IF NOT EXISTS sesiones_clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    fecha TEXT NOT NULL, 
    hora TEXT NOT NULL,
    bonos INTEGER NOT NULL,
    puntos INTEGER NOT NULL,
    eckal TEXT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE CASCADE
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
        {'nombre': strings[28], 'imagen': 'assets/images/Pectorales.png'});
    print('Inserted into grupos_musculares: Pectorales');

    await db.insert('grupos_musculares',
        {'nombre': strings[29], 'imagen': 'assets/images/Trapecios.png'});
    print('Inserted into grupos_musculares: Trapecios');

    await db.insert('grupos_musculares',
        {'nombre': strings[30], 'imagen': 'assets/images/Dorsales.png'});
    print('Inserted into grupos_musculares: Dorsales');

    await db.insert('grupos_musculares',
        {'nombre': strings[31], 'imagen': 'assets/images/Glúteos.png'});
    print('Inserted into grupos_musculares: Glúteos');

    await db.insert('grupos_musculares',
        {'nombre': strings[32], 'imagen': 'assets/images/Isquios.png'});
    print('Inserted into grupos_musculares: Isquiotibiales');

    await db.insert('grupos_musculares',
        {'nombre': strings[33], 'imagen': 'assets/images/Lumbares.png'});
    print('Inserted into grupos_musculares: Lumbares');

    await db.insert('grupos_musculares',
        {'nombre': strings[34], 'imagen': 'assets/images/Abdominales.png'});
    print('Inserted into grupos_musculares: Abdominales');

    await db.insert('grupos_musculares',
        {'nombre': strings[35], 'imagen': 'assets/images/Cuádriceps.png'});
    print('Inserted into grupos_musculares: Cuádriceps');

    await db.insert('grupos_musculares',
        {'nombre': strings[36], 'imagen': 'assets/images/Bíceps.png'});
    print('Inserted into grupos_musculares: Bíceps');

    await db.insert('grupos_musculares',
        {'nombre': strings[37], 'imagen': 'assets/images/Gemelos.png'});
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
      'nombre': strings[29],
      'imagen': 'assets/images/Trapecios.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Trapecios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[30],
      'imagen': 'assets/images/Dorsales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[33],
      'imagen': 'assets/images/Lumbares.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[31],
      'imagen': 'assets/images/Glúteos.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[32],
      'imagen': 'assets/images/Isquios.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Isquios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[28],
      'imagen': 'assets/images/Pectorales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Pectorales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[34],
      'imagen': 'assets/images/Abdominales.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[35],
      'imagen': 'assets/images/Cuádriceps.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[36],
      'imagen': 'assets/images/Bíceps.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[37],
      'imagen': 'assets/images/Gemelos.png',
      'tipo_equipamiento': 'BIO-JACKET'
    });
    print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

    // BIO-SHAPE
    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[33],
      'imagen': 'assets/images/lumbares_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[31],
      'imagen': 'assets/images/gluteo_shape.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Glúteo superior" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[32],
      'imagen': 'assets/images/isquios_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[34],
      'imagen': 'assets/images/abdomen_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Abdominales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[35],
      'imagen': 'assets/images/cuadriceps_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[36],
      'imagen': 'assets/images/biceps_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento', {
      'nombre': strings[37],
      'imagen': 'assets/images/gemelos_pantalon.png',
      'tipo_equipamiento': 'BIO-SHAPE'
    });
    print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS programas_predeterminados (
        id_programa INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        imagen TEXT,
        frecuencia REAL,
        pulso REAL,
        rampa REAL,
        contraccion REAL,
        pausa REAL,
        tipo TEXT,
        tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET', 'AMBOS'))
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
      await txn.insert('cronaxia', {
        'nombre': strings[29],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[33],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[30],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[31],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[32],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[28],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[34],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[35],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[36],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[37],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-JACKET'
      });

      // Inserciones para el tipo de equipamiento 'BIO-SHAPE'
      await txn.insert('cronaxia', {
        'nombre': strings[33],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[31],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[32],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[34],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[35],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[36],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });
      await txn.insert('cronaxia', {
        'nombre': strings[37],
        'valor': 0.0,
        'tipo_equipamiento': 'BIO-SHAPE'
      });

      // Imprimir mensaje para verificar inserciones
      print(
          'Inserciones completadas para los tipos de equipamiento BIO-JACKET y BIO-SHAPE');
    });

    await db.execute(''' -- Tabla intermedia programa_cronaxia
  CREATE TABLE IF NOT EXISTS programa_cronaxia (
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
        'nombre': strings[0],
        'imagen': 'assets/images/CALIBRACION.png',
        'frecuencia': 80,
        'rampa': 10,
        'pulso': 350,
        'contraccion': 4,
        'pausa': 1,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS' // Equipamiento seleccionado
      });

      print("Programa insertado con ID: $programaId1");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId1,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[1],
        'imagen': 'assets/images/STRENGTH1.png',
        'frecuencia': 85,
        'pulso': 350,
        'rampa': 8,
        'contraccion': 4,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
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
        'nombre': strings[2],
        'imagen': 'assets/images/STRENGTH2.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 400,
        'contraccion': 5,
        'pausa': 3,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
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
        'nombre': strings[3],
        'imagen': 'assets/images/GLUTEOS.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 0,
        'contraccion': 6,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Modificar valores específicos de cronaxias basándonos en su ID
        // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
        final nuevoValor = (cronaxiaId ==
            1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
            ? 200 // Nuevo valor para 'frecuencia'
            : (cronaxiaId ==
            2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
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
          'valor': nuevoValor,
          // Aquí almacenamos el valor modificado para este programa
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

        print(
            'ASOCIADO "${grupo['nombre']}" AL PROGRAMA ID $programaId4 CON ID GRUPO MUSCULAR ${grupo['id']}');
      }
    });
    await db.transaction((txn) async {
      // Paso 1: Insertar el programa en la tabla programas_predeterminados
      int programaId5 = await txn.insert('programas_predeterminados', {
        'nombre': strings[4],
        'imagen': 'assets/images/ABDOMINAL.png',
        'frecuencia': 43,
        'rampa': 8,
        'pulso': 450,
        'contraccion': 6,
        'pausa': 3,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId5");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId5,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId6");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId6,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId7");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId7,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });
      print("Programa insertado con ID: $programaId8");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId8,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId9");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId9,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId10");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId10,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId11");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId11,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[5],
        'imagen': 'assets/images/CELULITIS.png',
        'frecuencia': 10,
        'rampa': 5,
        'pulso': 450,
        'contraccion': 1,
        'pausa': 0,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId12");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId12,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[6],
        'imagen': 'assets/images/RESISTENCIA.png',
        'frecuencia': 43,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 10,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
      });
      print("Programa insertado con ID: $programaId13");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId13,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[7],
        'imagen': 'assets/images/DEFINICION.png',
        'frecuencia': 33,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 6,
        'pausa': 2,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId14");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId14,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });
      print("Programa insertado con ID: $programaId15");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId15,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[8],
        'imagen': 'assets/images/SUELOPELV.png',
        'frecuencia': 85,
        'rampa': 10,
        'pulso': 450,
        'contraccion': 4,
        'pausa': 4,
        'tipo': 'Individual',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId16");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId16,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[14],
        'imagen': 'assets/images/DOLORMECANICO.png',
        'frecuencia': 5,
        'rampa': 5,
        'pulso': 150,
        'contraccion': 6,
        'pausa': 3,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId17");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId17,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[16],
        'imagen': 'assets/images/DOLORQUIM.png',
        'frecuencia': 110,
        'rampa': 5,
        'pulso': 250,
        'contraccion': 5,
        'pausa': 1,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId18");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId18,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[15],
        'imagen': 'assets/images/DOLORNEU.png',
        'frecuencia': 150,
        'rampa': 5,
        'pulso': 100,
        'contraccion': 10,
        'pausa': 1,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId19");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId19,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId20");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId20,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'nombre': strings[17],
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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Modificar valores específicos de cronaxias basándonos en su ID
        // Aquí puedes definir los nuevos valores según el ID de cada cronaxia
        final nuevoValor = (cronaxiaId ==
            1) // Suponiendo que la cronaxia con ID = 1 es 'frecuencia'
            ? 375 // Nuevo valor para 'frecuencia'
            : (cronaxiaId ==
            2) // Suponiendo que la cronaxia con ID = 2 es 'rampa'
            ? 400 // Nuevo valor para 'rampa'
            : (cronaxiaId == 3) // ID = 3 'pulso'
            ? 400
            : valorCronaxia; // Para otras cronaxias, mantenemos el valor predeterminado

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId21,
          'cronaxia_id': cronaxiaId,
          'valor': nuevoValor,
          // Aquí almacenamos el valor modificado para este programa
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
        'nombre': strings[18],
        'imagen': 'assets/images/DRENAJE.png',
        'frecuencia': 21,
        'rampa': 5,
        'pulso': 350,
        'contraccion': 5,
        'pausa': 3,
        'tipo': 'Recovery',
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId22");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId22,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId23");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId23,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
        'tipo_equipamiento': 'AMBOS'
      });

      print("Programa insertado con ID: $programaId24");

      // Paso 2: Obtener las cronaxias para el tipo de equipamiento del programa
      final tipoEquipamiento =
          'BIO-JACKET'; // Tipo de equipamiento que estamos utilizando

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
        final valorCronaxia =
        cronaxia['valor']; // Usamos el valor predeterminado de la cronaxia

        // Relacionar la cronaxia con el programa en la tabla programa_cronaxia
        await txn.insert('programa_cronaxia', {
          'programa_id': programaId24,
          'cronaxia_id': cronaxiaId,
          'valor': valorCronaxia,
          // Mantener el valor predeterminado de la cronaxia
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
      CREATE TABLE IF NOT EXISTS Programas_Automaticos (
        id_programa_automatico INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT,
        descripcion TEXT,
        duracionTotal REAL,
         tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET', 'AMBOS'))
      );
    ''');

    // Crear la tabla Programas_Automaticos_Subprogramas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Programas_Automaticos_Subprogramas (
        id_programa_automatico INTEGER,
        id_programa_relacionado INTEGER,
        orden INTEGER,
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
          'nombre': strings[9],
          'imagen': 'assets/images/TONING.png',
          'descripcion':  strings[19],
          'duracionTotal': 25,
          'tipo_equipamiento': 'AMBOS',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

        // Insertamos los subprogramas
        for (var subprograma in subprogramas) {
          await txn.insert('Programas_Automaticos_Subprogramas', subprograma);
        }

        // Verificamos los subprogramas insertados
        print('Programa Automático: TONIFICACIÓN');
        print('ID: $idProgramaAutomatico');
        print('Descripción: Aumento de la resistencia y retraso de la fatiga.');
        print('Duración Total: 25.0');
        print('Tipo Equipamiento: BIO-JACKET');
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
          'nombre': strings[3],
          'imagen': 'assets/images/GLUTEOS.png',
          'descripcion':  strings[20],
          'duracionTotal': 25, // Duración total del programa en minutos
          'tipo_equipamiento': 'BIO-JACKET',
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
// Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }
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
          'nombre': strings[8],
          'imagen': 'assets/images/SUELOPELV.png',
          'descripcion':  strings[20],
          'duracionTotal': 25, // Duración total del programa en minutos
          'tipo_equipamiento': 'AMBOS',
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
// Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }
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
          'nombre': strings[10],
          'imagen': 'assets/images/STRENGTH.png',
          'descripcion':
          strings[21],
          'duracionTotal': 25, // Duración total del programa en minutos
          'tipo_equipamiento': 'AMBOS',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          'nombre': strings[11],
          'imagen': 'assets/images/HIPERTROFIA.png',
          'descripcion':
          strings[22],
          'duracionTotal': 25, // Duración total del programa en minutos
          'tipo_equipamiento': 'AMBOS',
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
        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          'nombre': strings[12],
          'imagen': 'assets/images/RESISTENCIA(ENDURANCE).png',
          'descripcion':
          strings[23],
          'duracionTotal': 25,
          'tipo_equipamiento': 'BIO-JACKET',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          'nombre': strings[13],
          'imagen': 'assets/images/RESISTENCIA2(ENDURANCE2).png',
          'descripcion':
          strings[24],
          'duracionTotal': 25,
          'tipo_equipamiento': 'AMBOS',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          strings[25],
          'duracionTotal': 25,
          'tipo_equipamiento': 'AMBOS',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          strings[26],
          'duracionTotal': 25,
          'tipo_equipamiento': 'AMBOS',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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
          'descripcion':  strings[27],
          'duracionTotal': 25,
          'tipo_equipamiento': 'BIO-JACKET',
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

        // Asignamos un orden a cada subprograma
        for (int i = 0; i < subprogramas.length; i++) {
          subprogramas[i]['orden'] =
              i + 1; // Asignamos un orden empezando por 1
        }

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

    await db.execute('''
  CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    gender TEXT NOT NULL,
    phone TEXT NOT NULL,
    pwd TEXT NOT NULL,
    user TEXT NOT NULL,
    status TEXT NOT NULL,
    birthdate TEXT NOT NULL,
    altadate TEXT NOT NULL,
    controlsesiones TEXT NOT NULL,
    controltiempo TEXT NOT NULL
  )
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS sesiones_usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    fecha TEXT NOT NULL, 
    bonos INTEGER NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE CASCADE
  )
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS tipos_perfil (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo TEXT NOT NULL UNIQUE
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS usuario_perfil (
  usuario_id INTEGER NOT NULL,
  perfil_id INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE,
  FOREIGN KEY (perfil_id) REFERENCES tipos_perfil (id) ON DELETE CASCADE,
  PRIMARY KEY (usuario_id, perfil_id)
)
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS bonos_usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuario_id INTEGER,
      cantidad INTEGER NOT NULL,
      fecha TEXT NOT NULL,
      estado TEXT NOT NULL,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
    )
  ''');

// Inserción en la tabla 'usuarios'
    int usuarioId = await db.insert('usuarios', {
      'name': 'Administrador',
      // Nombre del usuario
      'email': '',
      // Correo electrónico
      'gender': 'Hombre',
      // Género
      'phone': '',
      // Teléfono
      'pwd': 'admin',
      // Contraseña (en un caso real, no deberías guardarla como texto claro)
      'user': 'admin',
      // Nombre de usuario
      'status': 'Activo',
      // Estado
      'birthdate': '',
      // Fecha de nacimiento
      'altadate': DateFormat('dd/MM/yyyy').format(DateTime.now()),
      // Fecha de alta, usando la fecha actual
      'controlsesiones': 'No',
      // Control de sesiones
      'controltiempo': 'Sí',
      // Control de tiempo
    });

    print(
        'Usuario insertado con ID: $usuarioId'); // Mostrar el ID del usuario insertado

// Inserción en la tabla 'tipos_perfil' (insertamos el perfil "Ambos")
    int perfilId = await db.insert('tipos_perfil', {
      'tipo': 'Ambos', // Tipo de perfil
    });

    print(
        'Perfil "Ambos" insertado con ID: $perfilId'); // Mostrar el ID del perfil insertado

// Inserción en la tabla 'usuario_perfil' para asociar el usuario con el perfil
    await db.insert('usuario_perfil', {
      'usuario_id': usuarioId, // ID del usuario recién insertado
      'perfil_id': perfilId, // ID del perfil "Ambos"
    });

    print('Relación entre usuario y perfil insertada');

  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      print("ONPUGRADE EJECUTADIO");
    }
  }

  /*METODOS DE INSERCION BBDD*/

// Insertar un cliente y devolver el ID generado
  Future<int?> insertClient(Map<String, dynamic> client) async {
    final db = await database;
    try {
      int clienteId = await db.insert(
        'clientes',
        client,
        conflictAlgorithm: ConflictAlgorithm.replace, // Reemplazar en caso de conflicto
      );
      print('✔ Cliente insertado con ID: $clienteId');
      return clienteId; // Retornar el ID del cliente insertado
    } catch (e) {
      print('❌ Error al insertar el cliente: $e');
      return null; // Retornar null si hay error
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

  // Insertar relación entre un cliente y TODOS los grupos musculares
  Future<bool> insertClientAllGroups(int clienteId) async {
    final db = await database;
    try {
      // Obtener todos los IDs de los grupos musculares
      final List<Map<String, dynamic>> grupos = await db.query('grupos_musculares', columns: ['id']);

      if (grupos.isEmpty) {
        print('No hay grupos musculares en la base de datos.');
        return false;
      }

      // Iniciar una transacción para mejor rendimiento
      await db.transaction((txn) async {
        for (var grupo in grupos) {
          await txn.insert(
            'clientes_grupos_musculares',
            {
              'cliente_id': clienteId,
              'grupo_muscular_id': grupo['id'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      print('✔ Todos los grupos musculares fueron insertados para el cliente $clienteId');
      return true;

    } catch (e) {
      print('❌ Error al insertar todos los grupos musculares para el cliente: $e');
      return false;
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

  // Insertar un bono
  Future<void> insertBonoUsuario(Map<String, dynamic> bonoUser) async {
    final db = await database;
    try {
      await db.insert(
        'bonos_usuarios',
        bonoUser,
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

  // Función para insertar un programa predeterminado
  Future<int> insertarProgramaAutomatico(
      Map<String, dynamic> programaAuto) async {
    final db = await database;
    int idProgramaAuto = await db.insert('Programas_Automaticos', programaAuto);
    print('Programa insertado con ID: $idProgramaAuto');
    return idProgramaAuto;
  }

// Insertar relación entre un programa automático y subprogramas
  Future<bool> insertAutomaticProgram(
      int programaId, List<Map<String, dynamic>> subprogramas) async {
    final db = await database;
    try {
      // Ahora insertamos los subprogramas relacionados
      for (var subprograma in subprogramas) {
        await db.insert(
          'Programas_Automaticos_Subprogramas',
          {
            'id_programa_automatico': programaId,
            // Usamos el ID del programa automático insertado
            'id_programa_relacionado': subprograma['id_programa_relacionado'],
            'orden': subprograma['orden'],
            'ajuste': subprograma['ajuste'],
            'duracion': subprograma['duracion'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return true; // Si la inserción fue exitosa, retorna true
    } catch (e) {
      print('Error inserting automatic program subprograms: $e');
      return false; // Si ocurrió un error, retorna false
    }
  }

// Función para insertar las cronaxias por defecto
  Future<void> insertarCronaxiasPorDefecto(
      int programaId, String tipoEquipamiento) async {
    final db = await database;

    // Obtén las cronaxias asociadas al tipo de equipamiento para el programa recién creado
    List<Map<String, dynamic>> cronaxias = await db.query('cronaxia',
        where: 'tipo_equipamiento = ?', whereArgs: [tipoEquipamiento]);

    print(
        'Cronaxias encontradas para el tipo de equipamiento $tipoEquipamiento: ${cronaxias.length}');

    // Iterar sobre las cronaxias encontradas
    for (var cronaxia in cronaxias) {
      print('Cronaxia: ${cronaxia['nombre']} con valor: ${cronaxia['valor']}');

      // Verificar si la cronaxia ya está asociada con el programa en la tabla intermedia
      var existingCronaxia = await db.query('programa_cronaxia',
          where: 'programa_id = ? AND cronaxia_id = ?',
          whereArgs: [programaId, cronaxia['id']]);

      // Si no existe, insertamos la cronaxia en la tabla intermedia
      if (existingCronaxia.isEmpty) {
        await db.insert('programa_cronaxia', {
          'programa_id': programaId,
          'cronaxia_id': cronaxia['id'],
          'valor': 0.0,
        });
        print(
            'Cronaxia insertada: ${cronaxia['nombre']} para el programa $programaId');
      } else {
        print(
            'Cronaxia ya existe: ${cronaxia['nombre']} para el programa $programaId');
      }
    }
  }

  Future<void> insertarCronaxiasConPulso(int programaId, String tipoEquipamiento, double pulso) async {
    final db = await database;

    // Obtener todas las cronaxias del tipo de equipamiento
    List<Map<String, dynamic>> cronaxias = await db.query(
      'cronaxia',
      where: 'tipo_equipamiento = ?',
      whereArgs: [tipoEquipamiento],
    );

    print('📌 Insertando cronaxias con pulso $pulso para $tipoEquipamiento. Encontradas: ${cronaxias.length}');

    for (var cronaxia in cronaxias) {
      var existingCronaxia = await db.query(
        'programa_cronaxia',
        where: 'programa_id = ? AND cronaxia_id = ?',
        whereArgs: [programaId, cronaxia['id']],
      );

      if (existingCronaxia.isEmpty) {
        await db.insert('programa_cronaxia', {
          'programa_id': programaId,
          'cronaxia_id': cronaxia['id'],
          'valor': pulso, // 🔹 Se inserta el pulso en todas las cronaxias
        });
        print('✅ Cronaxia ${cronaxia['nombre']} insertada con pulso $pulso en el programa $programaId');
      } else {
        print('⚠️ Cronaxia ${cronaxia['nombre']} ya existe para el programa $programaId');
      }
    }
  }


// Función para insertar los grupos musculares por defecto
  Future<void> insertarGruposMuscularesPorDefecto(
      int programaId, String tipoEquipamiento) async {
    final db = await database;

    // Obtén los grupos musculares asociados al tipo de equipamiento para el programa recién creado
    List<Map<String, dynamic>> gruposMusculares = await db.query(
        'grupos_musculares_equipamiento',
        where: 'tipo_equipamiento = ?',
        whereArgs: [tipoEquipamiento]);

    print(
        'Grupos musculares encontrados para el tipo de equipamiento $tipoEquipamiento: ${gruposMusculares.length}');

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

  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await database;
    return await db.insert('usuarios', userData);
  }

  // Este método inserta un nuevo tipo de perfil en la tabla `tipos_perfil`.
  Future<int> insertTipoPerfil(String tipoPerfil) async {
    final db = await database;
    return await db.insert('tipos_perfil', {'tipo': tipoPerfil});
  }

  // Este método inserta la relación entre el usuario y el perfil en la tabla `usuario_perfil`.
  Future<void> insertUsuarioPerfil(int userId, int perfilId) async {
    final db = await database;
    await db.insert('usuario_perfil', {
      'usuario_id': userId,
      'perfil_id': perfilId,
    });
  }

  Future<void> updateUsuarioPerfil(int userId, int perfilId) async {
    final db = await database;

    // Actualizar la relación entre el usuario y el perfil
    await db.update(
      'usuario_perfil',
      {'perfil_id': perfilId},
      where: 'usuario_id = ?',
      whereArgs: [userId],
    );
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

  // Actualizar un cliente
  Future<void> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    // Verifica si el cliente existe
    final existingUser = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (existingUser.isNotEmpty) {
      try {
        await db.update(
          'usuarios',
          user,
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
  Future<void> updateCronaxia(
      int programaId, int cronaxiaId, double valor) async {
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
      print(
          'Cronaxia con programa_id $programaId y cronaxia_id $cronaxiaId no encontrada');
    }
  }

// Función para actualizar los grupos musculares asociados a un programa
  Future<void> actualizarGruposMusculares(
      int programaId, List<int> nuevosGruposMuscularesIds) async {
    final db = await database;

    // Empezamos una transacción para asegurar que todas las operaciones se ejecuten de manera atómica
    await db.transaction((txn) async {
      // Primero, eliminamos todos los grupos musculares existentes para el programa
      await txn.delete('ProgramaGrupoMuscular',
          where: 'programa_id = ?', whereArgs: [programaId]);
      print(
          'Grupos musculares existentes eliminados para el programa $programaId');

      // Ahora insertamos los nuevos grupos musculares seleccionados
      for (int grupoId in nuevosGruposMuscularesIds) {
        // Insertamos en la tabla ProgramaGrupoMuscular
        await txn.insert('ProgramaGrupoMuscular', {
          'programa_id': programaId,
          'grupo_muscular_id': grupoId,
        });
        print('Nuevo grupo muscular $grupoId asociado al programa $programaId');
      }
    });

    print('Grupos musculares actualizados para el programa $programaId');
  }

  Future<int> actualizarUsuario(int id, Map<String, dynamic> usuario) async {
    final db = await database;
    return await db
        .update('usuarios', usuario, where: 'id = ?', whereArgs: [id]);
  }

  /*METODOS GET DE LA BBDD*/

  // Obtener todos los clientes
  Future<List<Map<String, dynamic>>> getTutoriales() async {
    final db = await database;
    final List<Map<String, dynamic>> tuto = await db.query('videotutoriales');
    return tuto;
  }

  // Este método obtiene el `id` del tipo de perfil, dado su nombre.
  Future<int?> getTipoPerfilId(String tipoPerfil) async {
    final db = await database;
    var result = await db.query(
      'tipos_perfil',
      where: 'tipo = ?',
      whereArgs: [tipoPerfil],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    }
    return null;
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

  // Obtener un cliente por ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getClientsByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'clientes',
      where: 'usuario_id = ?',
      whereArgs: [userId],
    );
    return result;
  }


  Future<bool> checkUserCredentials(String username, String password) async {
    final db =
    await database; // Asegúrate de que la base de datos esté inicializada
    final List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      where: 'user = ? AND pwd = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
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

// Obtener los datos de la tabla grupos_musculares filtrados por tipo de equipamiento
  Future<List<Map<String, dynamic>>> getGruposMuscularesEquipamiento(
      String tipoEquipamiento) async {
    final db = await database;

    // Consulta con filtro por tipo de equipamiento
    final List<Map<String, dynamic>> result = await db.query(
      'grupos_musculares_equipamiento',
      where: 'tipo_equipamiento = ?', // Filtro por tipo
      whereArgs: [tipoEquipamiento], // Argumento para tipo de equipamiento
    );

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

  // Obtener todos los bonos
  Future<List<Map<String, dynamic>>> getAllPrograms() async {
    final db = await database;
    final result = await db.query('programas_predeterminados');
    return result;
  }

  Future<List<Map<String, dynamic>>>
  obtenerProgramasPredeterminadosPorTipoIndividual(Database db) async {
    // Consulta que une los datos de programas, cronaxias, y grupos musculares, filtrando solo los programas de tipo 'Individual'
    final List<Map<String, dynamic>> programasConDetalles =
    await db.rawQuery('''
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

  Future<List<Map<String, dynamic>>>
  obtenerProgramasPredeterminadosPorTipoRecovery(Database db) async {
    // Consulta que une los datos de programas, cronaxias, y grupos musculares, filtrando solo los programas de tipo 'Individual'
    final List<Map<String, dynamic>> programasConDetalles =
    await db.rawQuery('''
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

  Future<List<Map<String, dynamic>>> obtenerProgramasAutomaticosConSubprogramas(
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
        final List<Map<String, dynamic>> subprogramas = await db.rawQuery('''
        SELECT pa.id_programa_automatico, pa.id_programa_relacionado, pr.nombre, 
               pa.orden, pa.ajuste, pa.duracion, pr.imagen,
               pr.frecuencia, pr.pulso, pr.rampa, pr.contraccion, pr.pausa
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
            'tipo_equipamiento': programa['tipo_equipamiento'],
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
    if (tipoEquipamiento != 'BIO-SHAPE' && tipoEquipamiento != 'BIO-JACKET') {
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
    print('Grupos musculares obtenidos: ${gruposMusculares.length} elementos.');

    // Itera sobre los resultados e imprime cada grupo muscular y su tipo de equipamiento
    for (var grupo in gruposMusculares) {
      print(
          'INSERTADO "${grupo['nombre']}" TIPO "${grupo['tipo_equipamiento']}"');
    }

    return gruposMusculares;
  }

  Future<List<Map<String, dynamic>>> obtenerCronaxiaPorEquipamiento(
      Database db, String tipoEquipamiento) async {
    // Verifica que el tipo de equipamiento sea válido
    if (tipoEquipamiento != 'BIO-SHAPE' && tipoEquipamiento != 'BIO-JACKET') {
      throw ArgumentError(
          'Tipo de equipamiento inválido. Debe ser "BIO-SHAPE" o "BIO-JACKET".');
    }

    // Realiza la consulta en la base de datos
    List<Map<String, dynamic>> cronaxias = await db.query(
      'cronaxia', // Nombre de la tabla
      where: 'tipo_equipamiento = ?', // Filtro por tipo de equipamiento
      whereArgs: [tipoEquipamiento], // Argumento del filtro
    );

    // Itera sobre los resultados e imprime cada grupo muscular y su tipo de equipamiento
    for (var grupo in cronaxias) {}

    return cronaxias;
  }

  Future<List<Map<String, dynamic>>> obtenerGruposPorPrograma(
      Database db, int programaId) async {
    final List<Map<String, dynamic>> grupos = await db.rawQuery('''
      SELECT g.id, g.nombre, g.imagen, g.tipo_equipamiento
      FROM grupos_musculares_equipamiento g
      INNER JOIN ProgramaGrupoMuscular pg ON g.id = pg.grupo_muscular_id
      WHERE pg.programa_id = ?
    ''', [programaId]);

    return grupos;
  }

  Future<List<Map<String, dynamic>>> obtenerCronaxiasPorPrograma(
      Database db, int programaId) async {
    return await db.rawQuery('''
    SELECT c.id, c.nombre, pc.valor
    FROM programa_cronaxia AS pc
    INNER JOIN cronaxia AS c ON pc.cronaxia_id = c.id
    WHERE pc.programa_id = ?
  ''', [programaId]);
  }

// Obtener el programa más reciente (con el id más alto) y su tipo de equipamiento
  Future<Map<String, dynamic>?> getMostRecentPrograma() async {
    final db = await database;
    // Realizamos una consulta que ordene por id_programa de forma descendente (del más grande al más pequeño)
    final List<Map<String, dynamic>> result = await db.query(
      'programas_predeterminados', // Tabla 'programas'
      orderBy: 'id_programa DESC',
      // Ordenamos por id_programa de manera descendente
      limit: 1, // Solo nos interesa el primer resultado (el más reciente)
    );

    if (result.isNotEmpty) {
      return {
        'id_programa': result.first['id_programa'],
        'tipo_equipamiento': result.first['tipo_equipamiento'],
      }; // Retorna tanto el id_programa como el tipo_equipamiento
    }

    return null; // Si no se encontró ningún programa
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final db = await database;
    return await db.query('usuarios');
  }

  // Método para obtener los usuarios por tipo de perfil
  Future<List<Map<String, dynamic>>> getUsuariosPorTipoPerfil(
      String tipoPerfil) async {
    final db = await database;

    // Consulta para obtener los usuarios con un tipo de perfil específico
    final result = await db.rawQuery('''
      SELECT u.*
      FROM usuarios u
      JOIN usuario_perfil up ON u.id = up.usuario_id
      JOIN tipos_perfil tp ON up.perfil_id = tp.id
      WHERE tp.tipo = ?
    ''', [tipoPerfil]);

    return result;
  }

  Future<String?> getTipoPerfilByUserId(int userId) async {
    final db = await database;

    // Consulta para obtener el tipo de perfil del usuario a partir de la tabla `usuario_perfil`
    final result = await db.rawQuery('''
      SELECT tp.tipo
      FROM tipos_perfil tp
      JOIN usuario_perfil up ON tp.id = up.perfil_id
      WHERE up.usuario_id = ?
    ''', [userId]);

    if (result.isNotEmpty) {
      // Asegúrate de convertir a String, en caso de que el valor no sea null
      return result.first['tipo']
      as String?; // Convertimos explícitamente a String?
    }

    return null; // Si no se encuentra el tipo de perfil, devuelve null
  }

  Future<int> getUserIdByUsername(String username) async {
    final db = await database;

    // Consulta para obtener el ID del usuario a partir del nombre de usuario
    final result = await db.rawQuery('''
    SELECT id
    FROM usuarios
    WHERE user = ?
  ''', [username]);

    if (result.isNotEmpty) {
      return result.first['id'] as int; // Retorna el ID del usuario
    }

    throw Exception('Usuario no encontrado');
  }

  // Obtener el cliente más reciente (con el id más alto)
  Future<Map<String, dynamic>?> getMostRecentUser() async {
    final db = await database;
    // Realizamos una consulta que ordene por el id de forma descendente (del más grande al más pequeño)
    final List<Map<String, dynamic>> result = await db.query(
      'usuarios',
      orderBy: 'id DESC', // Ordenamos por id de manera descendente
      limit: 1, // Solo nos interesa el primer resultado (el más reciente)
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // Si no hay clientes en la base de datos
  }

  Future<List<Map<String, dynamic>>> getAvailableBonosByUserId(
      int userId) async {
    final db = await database;
    final result = await db.query(
      'bonos_usuarios', // Nombre de la tabla de bonos
      where: 'usuario_id = ? AND estado = ?',
      whereArgs: [
        userId,
        'Disponible'
      ], // Filtra por cliente y estado "Disponible"
    );
    return result;
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

  // Eliminar un cliente por ID
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'usuarios',
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

  static Future<File> backupDatabase() async {
    try {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'my_database.db');
      final file = File(path);
      if (await file.exists()) {
        return file;
      } else {
        throw Exception("La base de datos no existe en la ruta especificada.");
      }
    } catch (e) {
      throw Exception("Error al hacer la copia de seguridad: $e");
    }
  }

  // Método para obtener el SHA del archivo en GitHub
  static Future<String?> _getFileSha(
      String owner, String repo, String fileName, String token) async {
    String url = 'https://api.github.com/repos/$owner/$repo/contents/$fileName';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['sha']; // Devuelve el SHA si el archivo existe
    } else {
      return null; // Si no existe, el archivo será creado
    }
  }

// Método para subir o actualizar el archivo de la base de datos en GitHub
  static Future<void> uploadDatabaseToGitHub(String licenseNumber) async {
    try {
      // Cargar el token desde el archivo .env
      String? token =
      dotenv.env['GITHUB_TOKEN']; // Obtener el token desde el .env

      // Asegurarse de que el token esté presente
      if (token == null || token.isEmpty) {
        throw Exception(
            'El token de GitHub no está configurado correctamente en el archivo .env');
      }

      // Obtener la copia de seguridad de la base de datos
      File backupFile = await backupDatabase();

      // Incluir el número de licencia en el nombre del archivo
      String fileName =
          'database_v25_$licenseNumber.db'; // Nombre del archivo con el número de licencia
      String owner = 'Marcelo-Do-Amaral-Sala'; // Usuario de GitHub
      String repo = 'backups'; // Repositorio de GitHub

      // Leer el archivo y codificarlo en base64
      List<int> fileBytes = await backupFile.readAsBytes();
      String contentBase64 = base64Encode(fileBytes);

      // Print para ver el contenido antes de subirlo
      print(
          "Contenido a subir (base64, tamaño ${contentBase64.length} caracteres): $contentBase64");

      // Verificar si el archivo ya existe en el repositorio
      String? fileSha = await _getFileSha(owner, repo, fileName, token);

      // Construir la URL de la API de GitHub para subir el archivo
      String url =
          'https://api.github.com/repos/$owner/$repo/contents/$fileName';

      // Realizar la solicitud PUT para subir o actualizar el archivo
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'token $token',
          // Usar el token cargado desde el .env
          'Accept': 'application/vnd.github.v3+json',
        },
        body: jsonEncode({
          'message': 'Subida o actualización de copia de seguridad',
          'content': contentBase64,
          'sha': fileSha,
          // Si el archivo ya existe, pasamos el SHA para actualizarlo
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Copia de seguridad subida o actualizada exitosamente en GitHub');
      } else {
        throw Exception(
            'Error al subir o actualizar la copia de seguridad: ${response.body}');
      }
    } catch (e) {
      print('Error al subir o actualizar la copia de seguridad a GitHub: $e');
    }
  }

  static Future<void> downloadDatabaseFromGitHub(String licenseNumber) async {
    try {
      // Cargar el token desde el archivo .env
      String? token =
      dotenv.env['GITHUB_TOKEN']; // Obtener el token desde el .env

      // Asegurarse de que el token esté presente
      if (token == null || token.isEmpty) {
        throw Exception(
            'El token de GitHub no está configurado correctamente en el archivo .env');
      }

      String fileName =
          'database_v25_$licenseNumber.db'; // Nombre del archivo con el número de licencia
      String owner = 'Marcelo-Do-Amaral-Sala'; // Usuario de GitHub
      String repo = 'backups'; // Repositorio de GitHub

      // Construir la URL de la API de GitHub
      String url =
          'https://api.github.com/repos/$owner/$repo/contents/$fileName';

      // Realizar la solicitud GET para obtener el archivo
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        // Parsear el contenido de la respuesta
        final responseData = jsonDecode(response.body);

        // Verificar si 'content' está presente en la respuesta
        if (!responseData.containsKey('content')) {
          throw Exception(
              'El contenido base64 no está disponible en la respuesta.');
        }

        // Obtener el contenido codificado en base64
        String base64Content = responseData['content'];

        // Eliminar saltos de línea del contenido base64
        base64Content = base64Content.replaceAll('\n', '');

        // **Nuevo: Imprimir el contenido base64 descargado para depuración**
        print(
            "Contenido descargado (base64, tamaño ${base64Content.length} caracteres): $base64Content");

        // Verificar que el contenido base64 no esté vacío
        if (base64Content.isEmpty) {
          throw Exception('El contenido base64 descargado está vacío.');
        }

        // Decodificar el contenido de base64 a bytes
        List<int> fileBytes = base64Decode(base64Content);

        // Verificar que el tamaño del archivo descargado sea mayor que 0
        if (fileBytes.isEmpty) {
          throw Exception('El archivo descargado tiene un tamaño inválido.');
        }

        // **Nuevo: Verificar la estructura del archivo descargado**
        if (fileBytes.length < 1024) {
          // Verifica que el archivo sea lo suficientemente grande
          throw Exception(
              'El archivo descargado es muy pequeño, probablemente está corrupto.');
        }

        // Guardar los bytes en un archivo local
        final String path = join(await getDatabasesPath(), 'my_database.db');
        File localFile = File(path);

        // Asegúrate de que el archivo pueda escribirse
        await localFile.writeAsBytes(fileBytes);

        print(
            'Copia de seguridad descargada y guardada exitosamente en: $path');

        // Opción de probar que el archivo es válido (puedes añadir tu lógica aquí)
        // Puedes abrir el archivo para verificar que se puede usar
        // db = await openDatabase(path);
      } else {
        throw Exception(
            'Error al descargar la copia de seguridad: ${response.body}');
      }
    } catch (e) {
      print('Error al descargar la copia de seguridad desde GitHub: $e');
    }
  }
}
