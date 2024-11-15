import 'dart:convert';

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
      version: 54,
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
        FOREIGN KEY (id_programa_relacionado) REFERENCES Programas(id_programa)
      );
    ''');

    /*  // Insertar programas de tipo Individual (hardcodeados)
    await db.insert('Programas', {
      'nombre': 'CALIBRACIÓN',
      'tipo': 'Individual',
      'imagen': 'assets/images/CALIBRACION.png',
      'frecuencia': 80,
      'rampa': 10,
      'pulso': 350,
      'contraccion': 4,
      'pausa': 1,
      'descripcion':
          'Primer programa para calibrar unos parámetros mínimos para iniciar la sesión.',
    });

    await db.insert('Programas', {
      'nombre': 'STRENGTH 1',
      'tipo': 'Individual',
      'imagen': 'assets/images/STRENGTH1.png',
      'frecuencia': 85,
      'rampa': 8,
      'pulso': 350,
      'contraccion': 4,
      'pausa': 2,
      'descripcion':
          'Estimulación de las fibras rápidas de tipo II y se consiguen grandes mejoras en fuerza y velocidad (fuerza explosiva).',
    });

    await db.insert('Programas', {
      'nombre': 'STRENGTH 2',
      'tipo': 'Individual',
      'imagen': 'assets/images/STRENGTH2.png',
      'frecuencia': 85,
      'rampa': 10,
      'pulso': 400,
      'contraccion': 5,
      'pausa': 3,
      'descripcion':
          'Se estimulan en gran medida las fibras rápidas tipo II y se consiguen grandes mejoras en fuerza y velocidad, “fuerza explosiva”. Más intenso que STRENGTH 1.',
    });

    await db.insert('Programas', {
      'nombre': 'GLÚTEOS',
      'tipo': 'Individual',
      'imagen': 'assets/images/GLUTEOS.png',
      'frecuencia': 85,
      'rampa': 10,
      'pulso': 0,
      'contraccion': 6,
      'pausa': 4,
      'descripcion':
          'Con una frecuencia de 85Hz y un ancho de pulso variado. Programa pensado para personas que deseen fortalecer los músculos especialmente los glúteos.',
    });

    await db.insert('Programas', {
      'nombre': 'ABDOMINAL',
      'tipo': 'Individual',
      'imagen': 'assets/images/ABDOMINAL.png',
      'frecuencia': 43,
      'rampa': 8,
      'pulso': 450,
      'contraccion': 6,
      'pausa': 3,
      'descripcion':
          'Usado para nuestros protocolos de entrenamiento del tórax, abdominales y obliquos.',
    });

    await db.insert('Programas', {
      'nombre': 'SLIM',
      'tipo': 'Individual',
      'imagen': 'assets/images/SLIM.png',
      'frecuencia': 66,
      'rampa': 5,
      'pulso': 350,
      'contraccion': 6,
      'pausa': 3,
      'descripcion': 'Programa pensado para personas que quieren perder peso.',
    });

    await db.insert('Programas', {
      'nombre': 'BODY BUILDING 1',
      'tipo': 'Individual',
      'imagen': 'assets/images/BODYBUILDING.png',
      'frecuencia': 75,
      'rampa': 5,
      'pulso': 300,
      'contraccion': 4,
      'pausa': 2,
      'descripcion':
          'El programa está indicado para personas que quieran lograr un aumento de su masa muscular.',
    });

    await db.insert('Programas', {
      'nombre': 'BODY BUILDING 2',
      'tipo': 'Individual',
      'imagen': 'assets/images/BODYBUILDING2.png',
      'frecuencia': 75,
      'rampa': 5,
      'pulso': 450,
      'contraccion': 4,
      'pausa': 2,
      'descripcion':
          'El programa está indicado para personas que quieran lograr un aumento de su masa muscular. Lo mismo que BODYBUILDING 1 pero más intenso, para personas con años de entrenamiento EMS.',
    });

    await db.insert('Programas', {
      'nombre': 'FITNESS',
      'tipo': 'Individual',
      'imagen': 'assets/images/FITNESS.png',
      'frecuencia': 90,
      'rampa': 5,
      'pulso': 350,
      'contraccion': 5,
      'pausa': 4,
      'descripcion':
          'Se estimulan en gran medida las fibras rápidas tipo II y se consiguen grandes mejoras en fuerza y velocidad. Se incrementa la capacidad de fuerza máxima instantánea durante el tiempo más corto posible.',
    });

    await db.insert('Programas', {
      'nombre': 'WARM UP',
      'tipo': 'Individual',
      'imagen': 'assets/images/WARMUP.png',
      'frecuencia': 7,
      'rampa': 2,
      'pulso': 250,
      'contraccion': 1,
      'pausa': 0,
      'descripcion':
          'Programa de calentamiento muscular para el entrenamiento.',
    });

    await db.insert('Programas', {
      'nombre': 'CARDIO',
      'tipo': 'Individual',
      'imagen': 'assets/images/CARDIO.png',
      'frecuencia': 10,
      'rampa': 2,
      'pulso': 350,
      'contraccion': 1,
      'pausa': 0,
      'descripcion':
          'Lograremos un gran aumento de la circulación local, con todo lo que ello supone elevación del trofismo, disminución de metabolitos, oxigenación de los tejidos y un cierto efecto de masaje ajustando los parámetros para que resulte agradable la sensación. ',
    });

    await db.insert('Programas', {
      'nombre': 'CELULITIS',
      'tipo': 'Individual',
      'imagen': 'assets/images/CELULITIS.png',
      'frecuencia': 10,
      'rampa': 5,
      'pulso': 450,
      'contraccion': 1,
      'pausa': 0,
      'descripcion':
          'Este programa es perfecto para tratar piel laxa, tejidos colgantes, acidez y piel de naranja.',
    });

    await db.insert('Programas', {
      'nombre': 'RESISTENCIA',
      'tipo': 'Individual',
      'imagen': 'assets/images/RESISTENCIA.png',
      'frecuencia': 43,
      'rampa': 5,
      'pulso': 350,
      'contraccion': 10,
      'pausa': 4,
      'descripcion':
          'Solicita fibras intermedias, concretamente las II a. Logra el mayor aumento de resistencia a la fatiga, es ideal para deportes de resistencia.',
    });

    await db.insert('Programas', {
      'nombre': 'DEFINICIÓN',
      'tipo': 'Individual',
      'imagen': 'assets/images/DEFINICION.png',
      'frecuencia': 33,
      'rampa': 5,
      'pulso': 350,
      'contraccion': 6,
      'pausa': 2,
      'descripcion':
          'Proporciona un mayor aumento del tono muscular sin desarrollar la musculatura. La sensación de potencia de contracción en grupos musculares es inalcanzable con ejercicios voluntarios. ',
    });

    await db.insert('Programas', {
      'nombre': 'BASIC',
      'tipo': 'Individual',
      'imagen': 'assets/images/BASIC.png',
      'frecuencia': 70,
      'rampa': 5,
      'pulso': 250,
      'contraccion': 4,
      'pausa': 4,
      'descripcion':
          'Se empiezan a estimular las FT (Fibras rápidas tipo II), consiguiendo un aumento de la fuerza de la masa muscular, pues estas fibras tienen un mayor tamaño que el tipo I. ',
    });

    await db.insert('Programas', {
      'nombre': 'SUELO PÉLVICO',
      'tipo': 'Individual',
      'imagen': 'assets/images/SUELOPELV.png',
      'frecuencia': 85,
      'rampa': 10,
      'pulso': 450,
      'contraccion': 4,
      'pausa': 4,
      'descripcion': 'Mejora la resistencia muscular y el suelo pélvico. ',
    });

    // Insertar programas de tipo Recovery
    await db.insert('Programas', {
      'nombre': 'DOLOR MECÁNICO',
      'tipo': 'Recovery',
      'imagen': 'assets/images/DOLORMECANICO.png',
      'frecuencia': 5,
      'rampa': 5,
      'pulso': 150,
      'contraccion': 6,
      'pausa': 3,
      'descripcion':
          'Tratamiento para el dolor de rodilla y el dolor lumbar.Tratamiento para cambios posturales y cargas anormales que causan estrés en algunas estructuras del organismo y dolor por sobrecarga. ',
    });

    await db.insert('Programas', {
      'nombre': 'DOLOR QUÍMICO',
      'tipo': 'Recovery',
      'imagen': 'assets/images/DOLORQUIM.png',
      'frecuencia': 110,
      'rampa': 5,
      'pulso': 250,
      'contraccion': 5,
      'pausa': 1,
      'descripcion':
          'Alivia el dolor muscular (lesiones, mala postura corporal, sobrecarga muscular, tensión o estrés).',
    });

    await db.insert('Programas', {
      'nombre': 'DOLOR NEURÁLGICO',
      'tipo': 'Recovery',
      'imagen': 'assets/images/DOLORNEU.png',
      'frecuencia': 150,
      'rampa': 5,
      'pulso': 100,
      'contraccion': 10,
      'pausa': 1,
      'descripcion': 'Alivia el malestar de tipo neurálgico.',
    });

    await db.insert('Programas', {
      'nombre': 'RELAX',
      'tipo': 'Recovery',
      'imagen': 'assets/images/RELAX.png',
      'frecuencia': 100,
      'rampa': 2,
      'pulso': 150,
      'contraccion': 3,
      'pausa': 2,
      'descripcion':
          'Efecto antialgico, para el dolor. Relax (vuelta la calma) programa pensado para luego de terminar el entrenamiento con baja cronaxia. ',
    });

    await db.insert('Programas', {
      'nombre': 'CONTRACTURAS',
      'tipo': 'Recovery',
      'imagen': 'assets/images/CONTRACTURAS.png',
      'frecuencia': 120,
      'rampa': 10,
      'pulso': 0,
      'contraccion': 4,
      'pausa': 3,
      'descripcion':
          'Ayuda a eliminar las contracturas musculares y a relajar la musculatura.',
    });

    await db.insert('Programas', {
      'nombre': 'DRENAJE',
      'tipo': 'Recovery',
      'imagen': 'assets/images/DRENAJE.png',
      'frecuencia': 21,
      'rampa': 5,
      'pulso': 350,
      'contraccion': 5,
      'pausa': 3,
      'descripcion':
          'Se consigue un aumento del flujo sanguíneo y una hiperoxigenación. Su aplicación es idónea para evitar calambres, reoxigenar tejidos, acelerar el retorno venoso, eliminar edemas y los metabolitos acumulados.  ',
    });

    await db.insert('Programas', {
      'nombre': 'CAPILLARY',
      'tipo': 'Recovery',
      'imagen': 'assets/images/CAPILLARY.png',
      'frecuencia': 9,
      'rampa': 2,
      'pulso': 150,
      'contraccion': 1,
      'pausa': 0,
      'descripcion':
          'Estimula crear nuevos capilares, permite una restauración de los tejidos y un verdadero drenaje venoso. Al aumentar los capilares evita tener contracturas musculares. Es particularmente eficaz para el cansancio localizado y en la disminución del lactato. Este aumento del riego sanguíneo facilita la restauración de tejidos y, bajo consejo médico o fisioterapéutico, es de gran ayuda en problemas articulares.  ',
    });

    await db.insert('Programas', {
      'nombre': 'METABOLIC',
      'tipo': 'Recovery',
      'imagen': 'assets/images/METABOLIC.png',
      'frecuencia': 7,
      'rampa': 2,
      'pulso': 350,
      'contraccion': 1,
      'pausa': 0,
      'descripcion':
          'Este programa tiene los mismos beneficios que el programa Celulítico.Sin embargo, al tener un ancho de pulso mayor está más enfocado a trabajar con hombres o mujeres que busquen realizar un trabajo más profundo y más intenso. ',
    });*/

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
          var result = await txn.query('Programas',
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
          var result = await txn.query('Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
            'Programas',
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
    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Trapecios',
          'imagen': 'assets/images/Trapecios.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Trapecios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Dorsales',
          'imagen': 'assets/images/Dorsales.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Lumbares',
          'imagen': 'assets/images/Lumbares.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Glúteos',
          'imagen': 'assets/images/Glúteos.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Isquiotibiales',
          'imagen': 'assets/images/Isquios.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Isquios" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Pectorales',
          'imagen': 'assets/images/Pectorales.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Pectorales" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Abdomen',
          'imagen': 'assets/images/Abdominales.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Cuádriceps',
          'imagen': 'assets/images/Cuádriceps.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Bíceps',
          'imagen': 'assets/images/Bíceps.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Gemelos',
          'imagen': 'assets/images/Gemelos.png',
          'tipo_equipamiento': 'BIO-JACKET'
        });
    print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

    // BIO-SHAPE
    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Lumbares',
          'imagen': 'assets/images/lumbares_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Glúteos',
          'imagen': 'assets/images/gluteo_shape.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Glúteo superior" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Isquiotibiales',
          'imagen': 'assets/images/isquios_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Abdomen',
          'imagen': 'assets/images/abdomen_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Abdominales" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Cuádriceps',
          'imagen': 'assets/images/cuadriceps_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Bíceps',
          'imagen': 'assets/images/biceps_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Gemelos',
          'imagen': 'assets/images/gemelos_pantalon.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
    print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS cronaxia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    valor REAL DEFAULT 0.0,  -- Cambiado a REAL con valor por defecto 0.0
    tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
  )
''');

// Inserciones con prints para ver si se han realizado correctamente
    await db.insert('cronaxia', {'nombre': 'Trapecio', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Trapecio" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Dorsales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Isquiotibiales" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

    await db.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
    print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

// Inserciones para BIO-SHAPE con prints
    await db.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Glúteos" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Abdomen" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

    await db.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
    print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');



/*
    await db.execute('''
      CREATE TABLE programas_predeterminados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        imagen TEXT,
        frecuencia REAL,
        pulso REAL,
        contraccion REAL,
        pausa REAL,
        tipo TEXT,
        equipamiento TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE programas_creados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        imagen TEXT,
        frecuencia REAL,
        pulso REAL,
        contraccion REAL,
        pausa REAL,
        tipo TEXT,
        equipamiento TEXT
      );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS programa_cronaxia (
    programa_id INTEGER,
    cronaxia_id INTEGER,
    FOREIGN KEY (programa_id) REFERENCES Programas(id),
    FOREIGN KEY (cronaxia_id) REFERENCES cronaxia(id)
 );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS ProgramaGrupoMuscular (
    programa_id INTEGER,
    grupo_muscular_id INTEGER,
    FOREIGN KEY (programa_id) REFERENCES Programas(id),
    FOREIGN KEY (grupo_muscular_id) REFERENCES grupos_musculares_equipamiento(id)
    );
    ''');
*/



  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 54) {
      await db.execute(''' 
      CREATE TABLE IF NOT EXISTS grupos_musculares_equipamiento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        imagen TEXT NOT NULL,
        tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
      )
    ''');

      // BIO-JACKET
      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Trapecios',
            'imagen': 'assets/images/Trapecios.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Trapecios" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Dorsales',
            'imagen': 'assets/images/Dorsales.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Lumbares',
            'imagen': 'assets/images/Lumbares.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Glúteos',
            'imagen': 'assets/images/Glúteos.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Isquiotibiales',
            'imagen': 'assets/images/Isquios.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Isquios" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Pectorales',
            'imagen': 'assets/images/Pectorales.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Pectorales" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Abdomen',
            'imagen': 'assets/images/Abdominales.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Cuádriceps',
            'imagen': 'assets/images/Cuádriceps.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Bíceps',
            'imagen': 'assets/images/Bíceps.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Gemelos',
            'imagen': 'assets/images/Gemelos.png',
            'tipo_equipamiento': 'BIO-JACKET'
          });
      print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

      // BIO-SHAPE
      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Lumbares',
            'imagen': 'assets/images/lumbares_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

    await db.insert('grupos_musculares_equipamiento',
        {
          'nombre': 'Glúteos',
          'imagen': 'assets/images/gluteo_shape.png',
          'tipo_equipamiento': 'BIO-SHAPE'
        });
      print('INSERTADO "Glúteo superior" TIPO "BIO-SHAPE"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Isquiotibiales',
            'imagen': 'assets/images/isquios_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Abdomen',
            'imagen': 'assets/images/abdomen_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Abdominales" TIPO "BIO-SHAPE"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Cuádriceps',
            'imagen': 'assets/images/cuadriceps_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Bíceps',
            'imagen': 'assets/images/biceps_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

      await db.insert('grupos_musculares_equipamiento',
          {
            'nombre': 'Gemelos',
            'imagen': 'assets/images/gemelos_pantalon.png',
            'tipo_equipamiento': 'BIO-SHAPE'
          });
      print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');

      await db.execute('''
  CREATE TABLE IF NOT EXISTS cronaxia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    valor REAL DEFAULT 0.0,  -- Cambiado a REAL con valor por defecto 0.0
    tipo_equipamiento TEXT CHECK(tipo_equipamiento IN ('BIO-SHAPE', 'BIO-JACKET'))
  )
''');

// Inserciones con prints para ver si se han realizado correctamente
      await db.insert('cronaxia', {'nombre': 'Trapecio', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Trapecio" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Lumbares" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Dorsales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Dorsales" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Glúteos" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Isquiotibiales" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Abdomen" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Cuádriceps" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Bíceps" TIPO "BIO-JACKET"');

      await db.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-JACKET'});
      print('INSERTADO "Gemelos" TIPO "BIO-JACKET"');

// Inserciones para BIO-SHAPE con prints
      await db.insert('cronaxia', {'nombre': 'Lumbares', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Lumbares" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Glúteos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Glúteos" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Isquiotibiales', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Isquiotibiales" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Abdomen', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Abdomen" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Cuádriceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Cuádriceps" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Bíceps', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Bíceps" TIPO "BIO-SHAPE"');

      await db.insert('cronaxia', {'nombre': 'Gemelos', 'valor': 0.0, 'tipo_equipamiento': 'BIO-SHAPE'});
      print('INSERTADO "Gemelos" TIPO "BIO-SHAPE"');



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

  Future<List<Map<String, dynamic>>> obtenerProgramasIndividual(
      Database db) async {
    String query =
    '''SELECT id_programa, nombre, tipo, imagen, frecuencia, rampa, pulso, contraccion, pausa, descripcion
                    FROM Programas
                    WHERE tipo = 'Individual';''';

    List<Map<String, dynamic>> result = await db.rawQuery(query);

    // Imprimir el id y nombre de los programas individuales
    for (var program in result) {
      print(
          'ID del programa: ${program['id_programa']}, Nombre del programa: ${program['nombre']}');
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> obtenerProgramasRecovery(
      Database db) async {
    String query =
    '''SELECT id_programa, nombre, tipo, imagen, frecuencia, rampa, pulso, contraccion, pausa, descripcion
                    FROM Programas
                    WHERE tipo = 'Recovery';''';

    List<Map<String, dynamic>> result = await db.rawQuery(query);

    // Imprimir el id y nombre de los programas de recuperación
    for (var program in result) {
      print(
          'ID del programa: ${program['id_programa']}, Nombre del programa: ${program['nombre']}');
    }

    return result;
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
        SELECT pa.id_programa_automatico, pa.id_programa_relacionado, pr.nombre, pa.ajuste, pa.duracion
        FROM Programas_Automaticos_Subprogramas pa
        JOIN Programas pr ON pr.id_programa = pa.id_programa_relacionado
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

    // Imprime el tipo de equipamiento
    print(
        'Cronaxia para el tipo de equipamiento: $tipoEquipamiento');

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
