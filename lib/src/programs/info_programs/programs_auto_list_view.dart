import 'package:flutter/material.dart';

import '../../db/db_helper.dart';

class ProgramsAutoListView extends StatefulWidget {
  const ProgramsAutoListView({Key? key}) : super(key: key);

  @override
  _ProgramsAutoListViewState createState() => _ProgramsAutoListViewState();
}

class _ProgramsAutoListViewState extends State<ProgramsAutoListView> {
  List<Map<String, dynamic>> allPrograms = []; // Lista de programas

  @override
  void initState() {
    super.initState();
    _fetchPrograms(); // Cargar los programas al iniciar el estado
  }

  // Método actualizado para obtener los programas automáticos
  Future<void> _fetchPrograms() async {
    final dbHelper = DatabaseHelper();
    try {
      // Aquí obtenemos la instancia de la base de datos
      final db = await dbHelper
          .database; // Asegúrate de que esta propiedad sea correcta en tu helper

      // Llamamos a la función que obtiene los programas de la base de datos
      final programData = await dbHelper.obtenerProgramasAutomaticos(db);

      // Verifica el contenido de los datos obtenidos
      print('Programas obtenidos: $programData');

      setState(() {
        allPrograms = programData; // Asigna los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(children: [
        // Cambiamos la tabla por un GridView
        _buildGridView(screenHeight, screenWidth),
      ]),
    );
  }

  Widget _buildGridView(double screenHeight, double screenWidth) {
    return Expanded(
      // Usamos Expanded para que el GridView ocupe el espacio disponible
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Número de columnas en el Grid
          crossAxisSpacing: 10, // Espaciado horizontal entre las celdas
          mainAxisSpacing: 10, // Espaciado vertical entre las celdas
          childAspectRatio:
              1, // Relación de aspecto de las celdas (1 significa cuadradas)
        ),
        itemCount: allPrograms.length, // Número de elementos en el Grid
        itemBuilder: (context, index) {
          var program =
              allPrograms[index]['programa']; // Acceder al programa individual
          var subprogramas = allPrograms[index]
              ['subprogramas']; // Obtener los subprogramas de cada programa

          return GestureDetector(
            onTap: () {
              // Puedes agregar alguna lógica al hacer clic en un programa (por ejemplo, navegar a una pantalla de detalles)
              print('Programa seleccionado: ${program['name']}');
            },
            child: Card(
              color: const Color.fromARGB(255, 46, 46, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SingleChildScrollView(
                // Hacemos que el contenido dentro del Card sea desplazable
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        program['image'],
                        // Usamos la ruta de la imagen del programa
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      Text(
                        program['name'], // Nombre del programa
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Mostrar los subprogramas
                      if (subprogramas != null && subprogramas.isNotEmpty)
                        ...subprogramas.map<Widget>((subprograma) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Aquí mostramos los nombres en lugar de los IDs
                                Text(
                                  'Programa Individual: ${subprograma['nombre_individual']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Programa Recovery: ${subprograma['nombre_recovery']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Ajuste: ${subprograma['ajuste']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Duración: ${subprograma['duracion_individual']} mins',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
