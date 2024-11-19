import 'package:flutter/material.dart';
import '../../db/db_helper.dart'; // Asegúrate de que estás importando correctamente tu clase DatabaseHelper
import '../customs_programs/individual_table_custom.dart'; // Tu widget personalizado para mostrar los programas

class ProgramsIndividualesListView extends StatefulWidget {
  const ProgramsIndividualesListView({Key? key}) : super(key: key);

  @override
  _ProgramsIndividualesListViewState createState() =>
      _ProgramsIndividualesListViewState();
}

class _ProgramsIndividualesListViewState
    extends State<ProgramsIndividualesListView> {
  List<Map<String, dynamic>> allPrograms = []; // Lista para almacenar los programas

  @override
  void initState() {
    super.initState();
    _fetchIndividualPrograms(); // Llamamos a la función para obtener los programas al iniciar
  }

  Future<void> _fetchIndividualPrograms() async {
    var db = await DatabaseHelper().database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final programData = await DatabaseHelper().obtenerProgramasPredeterminadosPorTipoIndividual(db);

      // Verifica el contenido de los datos obtenidos
      print('Programas obtenidos: $programData');

      // Iteramos sobre los programas y obtenemos las cronaxias y los grupos de las tablas intermedias
      for (var program in programData) {
        // Obtener cronaxias
        var cronaxias = await DatabaseHelper().obtenerCronaxiasPorPrograma(db, program['id_programa']);
        var grupos = await DatabaseHelper().obtenerGruposPorPrograma(db, program['id_programa']);

        // Imprimir los valores de las cronaxias y los grupos
        print('Programa: ${program['nombre']}');

        print('Cronaxias asociadas:');
        for (var cronaxia in cronaxias) {
          print(' - ${cronaxia['nombre']} (Valor: ${cronaxia['valor']})');
        }

        print('Grupos musculares asociados:');
        for (var grupo in grupos) {
          print(' - ${grupo['nombre']}');
        }

        print('---');  // Separador para cada programa
      }

      // Actualizamos el estado con los programas obtenidos
      setState(() {
        allPrograms = programData; // Asignamos los programas obtenidos a la lista
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
      child: Column(
        children: [
          _buildDataTable(screenHeight, screenWidth), // Construimos la tabla
        ],
      ),
    );
  }

  Widget _buildDataTable(double screenHeight, double screenWidth) {
    return Flexible(
      flex: 1,
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IndividualTableWidget(
            programData: allPrograms, // Pasamos los programas a la tabla
          ),
        ),
      ),
    );
  }
}
