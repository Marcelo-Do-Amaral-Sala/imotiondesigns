import 'package:flutter/material.dart';
import 'package:imotion_designs/src/programs/customs_programs/recovery_table_widget.dart';
import '../../db/db_helper.dart';
class ProgramsRecoveryListView extends StatefulWidget {
  const ProgramsRecoveryListView({Key? key})
      : super(key: key);

  @override
  _ProgramsRecoveryListViewState createState() => _ProgramsRecoveryListViewState();
}

class _ProgramsRecoveryListViewState extends State<ProgramsRecoveryListView> {
  List<Map<String, dynamic>> allPrograms = []; // Lista de programas

  @override
  void initState() {
    super.initState();
    _fetchRecoveryPrograms(); // Cargar los programas al iniciar el estado
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchRecoveryPrograms() async {
    var db = await DatabaseHelper().database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final programData = await DatabaseHelper().obtenerProgramasPredeterminadosPorTipoRecovery(db);

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
      child: Column(children: [
        _buildDataTable(screenHeight, screenWidth),
      ]),
    );
  }

  Widget _buildDataTable(double screenHeight, double screenWidth) {
    return Flexible( // Flexible permite que el Container ocupe una fracción del espacio disponible
      flex: 1, // Este valor define cuánta parte del espacio disponible debe ocupar el widget
      child: Container(
        width: screenWidth, // Mantiene el ancho completo de la pantalla
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: RecoveryTableWidget(
            programData: allPrograms,
          ),
        ),
      ),
    );
  }

}
