import 'package:flutter/material.dart';
import 'package:imotion_designs/src/programs/customs_programs/recovery_table_widget.dart';
import '../../db/db_helper.dart';

class ProgramsRecoveryListView extends StatefulWidget {
  const ProgramsRecoveryListView({Key? key}) : super(key: key);

  @override
  _ProgramsRecoveryListViewState createState() => _ProgramsRecoveryListViewState();
}

class _ProgramsRecoveryListViewState extends State<ProgramsRecoveryListView> {
  late Future<List<Map<String, dynamic>>> _futurePrograms;

  @override
  void initState() {
    super.initState();
    _futurePrograms = _fetchRecoveryPrograms(); // 🔹 Carga los programas una sola vez
  }

  Future<List<Map<String, dynamic>>> _fetchRecoveryPrograms() async {
    final db = await DatabaseHelper().database;
    try {
      return await DatabaseHelper().obtenerProgramasPredeterminadosPorTipoRecovery(db);
    } catch (e) {
      print('❌ Error fetching recovery programs: $e');
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
          _buildDataTable(screenHeight, screenWidth), // 🔹 Renderizado eficiente
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
            future: _futurePrograms, // 🔹 Usamos FutureBuilder para la carga de datos
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(); // 🔹 Loader mientras carga
              } else if (snapshot.hasError) {
                return Center(child: Text("❌ Error al cargar programas", style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("📭 No hay programas disponibles", style: TextStyle(color: Colors.white)));
              }

              return RecoveryTableWidget(programData: snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}
