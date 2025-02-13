import 'package:flutter/material.dart';

import '../../db/db_helper.dart';
import '../customs_programs/individual_table_custom.dart';

class ProgramsIndividualesListView extends StatefulWidget {
  const ProgramsIndividualesListView({Key? key}) : super(key: key);

  @override
  _ProgramsIndividualesListViewState createState() => _ProgramsIndividualesListViewState();
}

class _ProgramsIndividualesListViewState extends State<ProgramsIndividualesListView> {
  late Future<List<Map<String, dynamic>>> _futurePrograms;

  @override
  void initState() {
    super.initState();
    _futurePrograms = _fetchIndividualPrograms(); // 🔹 Carga los programas una sola vez
  }

  Future<List<Map<String, dynamic>>> _fetchIndividualPrograms() async {
    final db = await DatabaseHelper().database;
    try {
      return await DatabaseHelper().obtenerProgramasPredeterminadosPorTipoIndividual(db);
    } catch (e) {
      print('❌ Error fetching programs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.03,
      ),
      child: Column(
        children: [
          _buildDataTable(screenHeight, screenWidth), // 🔹 Se renderiza de forma optimizada
        ],
      ),
    );
  }

  Widget _buildDataTable(double screenHeight, double screenWidth) {
    return Flexible(
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futurePrograms, // 🔹 Usamos FutureBuilder para manejar la carga de datos
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(); // 🔹 Muestra un loader mientras carga
              } else if (snapshot.hasError) {
                return Center(child: Text("❌ Error al cargar programas", style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("📭 No hay programas disponibles", style: TextStyle(color: Colors.white)));
              }

              return IndividualTableWidget(programData: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}
