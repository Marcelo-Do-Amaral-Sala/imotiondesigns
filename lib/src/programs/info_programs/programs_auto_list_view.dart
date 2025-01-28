import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../db/db_helper.dart';

class ProgramsAutoListView extends StatefulWidget {
  final Function(Map<String, dynamic>) onProgramTap; // Callback para manejar el tap

  const ProgramsAutoListView({Key? key, required this.onProgramTap}) : super(key: key);

  @override
  _ProgramsAutoListViewState createState() => _ProgramsAutoListViewState();
}

class _ProgramsAutoListViewState extends State<ProgramsAutoListView> {
  List<Map<String, dynamic>> allPrograms = []; // Lista de programas automáticos con subprogramas

  @override
  void initState() {
    super.initState();
    _fetchPrograms(); // Cargar los programas automáticos al iniciar el estado
  }
  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _fetchPrograms() async {
    var db = await DatabaseHelper().database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas automáticos y sus subprogramas
      final programData = await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);

      // Verifica si se obtuvieron datos correctamente
      if (programData.isEmpty) {
        print('No se encontraron programas automáticos.');
      } else {
        print('Programas obtenidos:');
        print(programData); // Mostrar la estructura completa de los programas y subprogramas
      }

      // Agrupamos los subprogramas por programa automático
      List<Map<String, dynamic>> groupedPrograms = _groupProgramsWithSubprograms(programData);

      setState(() {
        allPrograms = groupedPrograms; // Asigna los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  List<Map<String, dynamic>> _groupProgramsWithSubprograms(List<Map<String, dynamic>> programData) {
    List<Map<String, dynamic>> groupedPrograms = [];

    for (var program in programData) {
      List<Map<String, dynamic>> subprogramas = program['subprogramas'] ?? [];

      Map<String, dynamic> groupedProgram = {
        'id_programa_automatico': program['id_programa_automatico'],
        'nombre_programa_automatico': program['nombre'],
        'imagen': program['imagen'],
        'descripcion_programa_automatico': program['descripcion'],
        'duracionTotal': program['duracionTotal'],
        'tipo_equipamiento' : program['tipo_equipamiento'],
        'subprogramas': subprogramas,
      };

      groupedPrograms.add(groupedProgram);
    }

    return groupedPrograms;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Column(
          children: [
            _buildRowView(screenHeight, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildRowView(double screenHeight, double screenWidth) {
    // Dividir la lista en chunks de 4 elementos por fila
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allPrograms.length; i += 4) {
      rows.add(allPrograms.sublist(i, i + 4 > allPrograms.length ? allPrograms.length : i + 4));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, rowIndex) {
          List<Map<String, dynamic>> row = rows[rowIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Cambiado a start para ajustar desde la izquierda
              children: row.map((program) {
                String imagen = program['imagen'] ?? 'assets/default_image.png';
                String nombre = program['nombre_programa_automatico'] ?? 'Sin nombre';
                String descripcion = program['descripcion_programa_automatico'] ?? 'Sin descripción';
                List<Map<String, dynamic>> subprogramas = program['subprogramas'] ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0), // Espacio entre los elementos
                  child: GestureDetector(
                    onTap: () {
                      // Llamamos a la función onProgramTap pasando los datos del programa
                      widget.onProgramTap(program); // Ejecuatemos el callback
                    },
                    child: Column(
                      children: [
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Image.asset(
                          imagen,
                          width: screenWidth * 0.15, // Ajuste dinámico para el tamaño de la imagen
                          height: screenHeight * 0.15, // Ajuste dinámico para el tamaño de la imagen
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
