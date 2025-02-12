import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class ProgramsAutoListView extends StatefulWidget {
  final Function(Map<String, dynamic>) onProgramTap;

  const ProgramsAutoListView({Key? key, required this.onProgramTap}) : super(key: key);

  @override
  _ProgramsAutoListViewState createState() => _ProgramsAutoListViewState();
}

class _ProgramsAutoListViewState extends State<ProgramsAutoListView> {
  late Future<List<Map<String, dynamic>>> _futurePrograms;

  @override
  void initState() {
    super.initState();
    _futurePrograms = _fetchPrograms(); // 🔹 Carga los programas solo una vez
  }

  Future<List<Map<String, dynamic>>> _fetchPrograms() async {
    final db = await DatabaseHelper().database;
    try {
      final programData = await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);
      return _groupProgramsWithSubprograms(programData);
    } catch (e) {
      print('❌ Error fetching programs: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _groupProgramsWithSubprograms(List<Map<String, dynamic>> programData) {
    return programData.map((program) {
      return {
        'id_programa_automatico': program['id_programa_automatico'],
        'nombre_programa_automatico': program['nombre'],
        'imagen': program['imagen'],
        'descripcion_programa_automatico': program['descripcion'],
        'duracionTotal': program['duracionTotal'],
        'tipo_equipamiento': program['tipo_equipamiento'],
        'subprogramas': program['subprogramas'] ?? [],
      };
    }).toList();
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
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futurePrograms,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(); // 🔹 Loader mientras carga
            } else if (snapshot.hasError) {
              return Center(child: Text("❌ Error al cargar programas", style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("📭 No hay programas disponibles", style: TextStyle(color: Colors.white)));
            }

            return _buildRowView(snapshot.data!, screenHeight, screenWidth);
          },
        ),
      ),
    );
  }

  Widget _buildRowView(List<Map<String, dynamic>> allPrograms, double screenHeight, double screenWidth) {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allPrograms.length; i += 4) {
      rows.add(allPrograms.sublist(i, i + 4 > allPrograms.length ? allPrograms.length : i + 4));
    }

    return ListView.builder(
      shrinkWrap: true, // 🔹 Evita errores de overflow en Column()
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        List<Map<String, dynamic>> row = rows[rowIndex];

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((program) {
              return _buildProgramCard(program, screenWidth, screenHeight);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: GestureDetector(
        onTap: () {
          widget.onProgramTap(program); // 🔹 Llama al callback
        },
        child: Column(
          children: [
            Text(
              tr(context,program['nombre_programa_automatico']).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF2be4f3),
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            Image.asset(
              program['imagen'] ?? 'assets/default_image.png',
              width: screenWidth * 0.15,
              height: screenHeight * 0.15,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
