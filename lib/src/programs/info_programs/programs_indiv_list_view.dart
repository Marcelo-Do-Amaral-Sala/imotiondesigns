import 'package:flutter/material.dart';
import '../../db/db_helper.dart';
import '../customs_programs/individual_table_custom.dart';

class ProgramsIndividualesListView extends StatefulWidget {


  const ProgramsIndividualesListView({Key? key})
      : super(key: key);

  @override
  _ProgramsIndividualesListViewState createState() => _ProgramsIndividualesListViewState();
}

class _ProgramsIndividualesListViewState extends State<ProgramsIndividualesListView> {
  List<Map<String, dynamic>> allPrograms = []; // Lista de programas

  @override
  void initState() {
    super.initState();
    _fetchPrograms(); // Cargar los programas al iniciar el estado
  }

  Future<void> _fetchPrograms() async {
    final dbHelper = DatabaseHelper();
    try {
      // Primero obtenemos el número total de programas individuales
      int numProgramas = await dbHelper.getNumeroDeProgramasIndividuales();

      // Imprime el número total de programas
      print('Número total de programas individuales: $numProgramas');

      // Llamamos a la función que obtiene los programas de la base de datos
      final programData = await dbHelper.getProgramasIndividuales();

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
          child: IndividualTableWidget(
            programData: allPrograms,
          ),
        ),
      ),
    );
  }

}
