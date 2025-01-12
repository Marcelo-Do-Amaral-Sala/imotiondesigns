import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/translation_utils.dart';
import '../../clients/overlays/main_overlay.dart';
import '../../db/db_helper.dart';

class OverlayTipoPrograma extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String)
      onProgramSelected; // Función para pasar el programa seleccionado

  const OverlayTipoPrograma({
    super.key,
    required this.onClose,
    required this.onProgramSelected, // Recibe la función para seleccionar el programa
  });

  @override
  _OverlayTipoProgramaState createState() => _OverlayTipoProgramaState();
}

class _OverlayTipoProgramaState extends State<OverlayTipoPrograma> {
  String? selectedProgram;

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, "Seleccionar tipo de programa").toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildCustomCheckboxTile(
                      tr(context, "Individual").toUpperCase(),
                    ),
                    buildCustomCheckboxTile(
                      tr(context, "Recovery").toUpperCase(),
                    ),
                    buildCustomCheckboxTile(
                      tr(context, "Automáticos").toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () {
                    if (selectedProgram != null) {
                      widget.onProgramSelected(
                          selectedProgram!); // Llama a la función para pasar el programa seleccionado
                    }
                    widget.onClose(); // Cierra el overlay
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Color(0xFF2be4f3),
                  ),
                  child: Text(
                    tr(context, "Seleccionar").toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget buildCustomCheckboxTile(String option) {
    return ListTile(
      leading: customCheckbox(option),
      title: Text(
        option,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          selectedProgram = option; // Actualiza la selección
        });
      },
    );
  }

  Widget customCheckbox(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProgram = option; // Actualiza la selección
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedProgram == option
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: selectedProgram == option
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}

class OverlaySeleccionarProgramaIndividual extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>?) onIndivProgramSelected;

  const OverlaySeleccionarProgramaIndividual(
      {super.key, required this.onClose, required this.onIndivProgramSelected});

  @override
  _OverlaySeleccionarProgramaIndividualState createState() =>
      _OverlaySeleccionarProgramaIndividualState();
}

class _OverlaySeleccionarProgramaIndividualState
    extends State<OverlaySeleccionarProgramaIndividual>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allIndividualPrograms = [];
  String? individualSelectedProgram;

  @override
  void initState() {
    super.initState();
    _fetchIndividualPrograms();
  }

  Future<void> _fetchIndividualPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final individualProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoIndividual(db);

      setState(() {
        allIndividualPrograms =
            individualProgramData; // Asignamos los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  // Función de estilo global para los textos
  TextStyle getGlobalTextStyle({
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, "Seleccionar programa").toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
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
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildRowView(double screenHeight, double screenWidth) {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allIndividualPrograms.length; i += 4) {
      rows.add(allIndividualPrograms.sublist(
          i,
          i + 4 > allIndividualPrograms.length
              ? allIndividualPrograms.length
              : i + 4));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, rowIndex) {
          List<Map<String, dynamic>> row = rows[rowIndex];

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // Cambiado a start para ajustar desde la izquierda
              children: row.map((program) {
                String imagen = program['imagen'] ?? 'assets/default_image.png';
                String nombre = program['nombre'] ?? 'Sin nombre';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  // Espacio entre los elementos
                  child: GestureDetector(
                    onTap: () {
                      // Aquí solo seleccionamos el programa si no está seleccionado aún
                      setState(() {
                        individualSelectedProgram = program['nombre'];
                      });

                      widget.onIndivProgramSelected(
                          program); // Llama a la función para pasar el programa seleccionado
                      widget.onClose(); // Cerrar el overlay
                    },
                    onLongPress: () {
                      // Mostrar el Dialog con más detalles
                      _showProgramDetailsDialog(
                          context, program, screenHeight, screenWidth);
                    },
                    child: Column(
                      children: [
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Image.asset(
                          imagen,
                          width: screenWidth * 0.15,
                          height: screenHeight * 0.15,
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

  void _showProgramDetailsDialog(BuildContext context,
      Map<String, dynamic> program, double screenHeight, double screenWidth) {
    // Asegúrate de que los valores sean correctos y estén bien asignados
    var frecuencia = program['frecuencia'] ?? 'Sin descripción';
    var rampa = program['rampa'] ?? 'Sin descripción';
    var pausa = program['pausa'] ?? 'Sin información de equipamiento';
    var contraccion =
        program['contraccion'] ?? 'Sin información de equipamiento';
    var pulso = program['pulso'] ?? 'Sin información de equipamiento';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xFF2be4f3),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          backgroundColor: const Color(0xFF2E2E2E),
          child: Container(
            width: screenWidth * 0.3,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.55, // Fijar altura máxima
            ),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              // Centra todo en el eje vertical
              children: [
                SingleChildScrollView(
                  child: Center(
                    // Usa el widget Center para centrar el contenido
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          tr(context, "Datos").toUpperCase(),
                          style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF2be4f3)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildDetailRow(
                            '${tr(context, "Frecuencia (Hz)").toUpperCase()}: ',
                            frecuencia,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Rampa").toUpperCase()}: ',
                            rampa,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Pausa").toUpperCase()}: ',
                            pausa,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Contracción").toUpperCase()}: ',
                            contraccion,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Pulso (ms)").toUpperCase()}: ',
                            pulso,
                            ' μs'),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(
                          width: 1.0, color: Color(0xFF2be4f3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, 'Cerrar').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Función para construir las filas con los detalles
  Widget _buildDetailRow(String label, dynamic value, String suffix) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        Text(
          suffix,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class OverlaySeleccionarProgramaRecovery extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>?) onRecoProgramSelected;

  const OverlaySeleccionarProgramaRecovery(
      {super.key, required this.onClose, required this.onRecoProgramSelected});

  @override
  _OverlaySeleccionarProgramaRecoveryState createState() =>
      _OverlaySeleccionarProgramaRecoveryState();
}

class _OverlaySeleccionarProgramaRecoveryState
    extends State<OverlaySeleccionarProgramaRecovery>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allRecoveryPrograms = [];
  String? recoverySelectedProgram;

  @override
  void initState() {
    super.initState();
    _fetchRecoveryPrograms();
  }

  Future<void> _fetchRecoveryPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final recoveryProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoRecovery(db);

      // Iteramos sobre los programas y obtenemos las cronaxias y los grupos de las tablas intermedias
      for (var recoveryProgram in recoveryProgramData) {
        // Obtener cronaxias
        var cronaxias = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, recoveryProgram['id_programa']);
        var grupos = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, recoveryProgram['id_programa']);

        print('Cronaxias asociadas:');
        for (var cronaxia in cronaxias) {
          print(' - ${cronaxia['nombre']} (Valor: ${cronaxia['valor']})');
        }

        print('Grupos musculares asociados:');
        for (var grupo in grupos) {
          print(' - ${grupo['nombre']}');
        }

        print('---'); // Separador para cada programa
      }

      // Actualizamos el estado con los programas obtenidos
      setState(() {
        allRecoveryPrograms =
            recoveryProgramData; // Asignamos los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  // Función de estilo global para los textos
  TextStyle getGlobalTextStyle({
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, "Seleccionar programa").toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
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
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildRowView(double screenHeight, double screenWidth) {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allRecoveryPrograms.length; i += 4) {
      rows.add(allRecoveryPrograms.sublist(
          i,
          i + 4 > allRecoveryPrograms.length
              ? allRecoveryPrograms.length
              : i + 4));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, rowIndex) {
          List<Map<String, dynamic>> row = rows[rowIndex];

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // Cambiado a start para ajustar desde la izquierda
              children: row.map((program) {
                String imagen = program['imagen'] ?? 'assets/default_image.png';
                String nombre = program['nombre'] ?? 'Sin nombre';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  // Espacio entre los elementos
                  child: GestureDetector(
                    onTap: () {
                      // Aquí solo seleccionamos el programa si no está seleccionado aún
                      setState(() {
                        recoverySelectedProgram = program['nombre'];
                      });

                      widget.onRecoProgramSelected(
                          program); // Llama a la función para pasar el programa seleccionado
                      widget.onClose(); // Cerrar el overlay
                    },
                    onLongPress: () {
                      // Mostrar el Dialog con más detalles
                      _showProgramDetailsDialog(
                          context, program, screenHeight, screenWidth);
                    },
                    child: Column(
                      children: [
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Image.asset(
                          imagen,
                          width: screenWidth * 0.15,
                          height: screenHeight * 0.15,
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

  void _showProgramDetailsDialog(BuildContext context,
      Map<String, dynamic> program, double screenHeight, double screenWidth) {
    // Asegúrate de que los valores sean correctos y estén bien asignados
    var frecuencia = program['frecuencia'] ?? 'Sin descripción';
    var rampa = program['rampa'] ?? 'Sin descripción';
    var pausa = program['pausa'] ?? 'Sin información de equipamiento';
    var contraccion =
        program['contraccion'] ?? 'Sin información de equipamiento';
    var pulso = program['pulso'] ?? 'Sin información de equipamiento';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xFF2be4f3),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          backgroundColor: const Color(0xFF2E2E2E),
          child: Container(
            width: screenWidth * 0.3,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.55, // Fijar altura máxima
            ),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              // Centra todo en el eje vertical
              children: [
                SingleChildScrollView(
                  child: Center(
                    // Usa el widget Center para centrar el contenido
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          tr(context, "Datos").toUpperCase(),
                          style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFF2be4f3)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildDetailRow(
                            '${tr(context, "Frecuencia (Hz)").toUpperCase()}: ',
                            frecuencia,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Rampa").toUpperCase()}: ',
                            rampa,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Pausa").toUpperCase()}: ',
                            pausa,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Contracción").toUpperCase()}: ',
                            contraccion,
                            ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow(
                            '${tr(context, "Pulso (ms)").toUpperCase()}: ',
                            pulso,
                            ' μs'),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(
                          width: 1.0, color: Color(0xFF2be4f3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, 'Cerrar').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Función para construir las filas con los detalles
  Widget _buildDetailRow(String label, dynamic value, String suffix) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        Text(
          suffix,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class OverlaySeleccionarProgramaAutomatic extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>?) onAutoProgramSelected;

  const OverlaySeleccionarProgramaAutomatic(
      {super.key, required this.onClose, required this.onAutoProgramSelected});

  @override
  _OverlaySeleccionarProgramaAutomaticState createState() =>
      _OverlaySeleccionarProgramaAutomaticState();
}

class _OverlaySeleccionarProgramaAutomaticState
    extends State<OverlaySeleccionarProgramaAutomatic>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allAutomaticPrograms = [];
  String? automaticSelectedProgram;

  @override
  void initState() {
    super.initState();
    _fetchAutoPrograms();
  }

  Future<void> _fetchAutoPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas automáticos y sus subprogramas
      final autoProgramData =
          await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);

      // Agrupamos los subprogramas por programa automático
      List<Map<String, dynamic>> groupedPrograms =
          _groupProgramsWithSubprograms(autoProgramData);

      setState(() {
        allAutomaticPrograms =
            groupedPrograms; // Asigna los programas obtenidos a la lista
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  List<Map<String, dynamic>> _groupProgramsWithSubprograms(
      List<Map<String, dynamic>> autoProgramData) {
    List<Map<String, dynamic>> groupedPrograms = [];

    for (var autoProgram in autoProgramData) {
      List<Map<String, dynamic>> subprogramas =
          autoProgram['subprogramas'] ?? [];

      Map<String, dynamic> groupedProgram = {
        'id_programa_automatico': autoProgram['id_programa_automatico'],
        'nombre_programa_automatico': autoProgram['nombre'],
        'imagen': autoProgram['imagen'],
        'descripcion_programa_automatico': autoProgram['descripcion'],
        'duracionTotal': autoProgram['duracionTotal'],
        'tipo_equipamiento': autoProgram['tipo_equipamiento'],
        'subprogramas': subprogramas,
      };

      groupedPrograms.add(groupedProgram);
    }

    return groupedPrograms;
  }

  // Función de estilo global para los textos
  TextStyle getGlobalTextStyle({
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = Colors.white,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, "Seleccionar programa").toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
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
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildRowView(double screenHeight, double screenWidth) {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allAutomaticPrograms.length; i += 4) {
      rows.add(allAutomaticPrograms.sublist(
          i,
          i + 4 > allAutomaticPrograms.length
              ? allAutomaticPrograms.length
              : i + 4));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, rowIndex) {
          List<Map<String, dynamic>> row = rows[rowIndex];

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((program) {
                String imagen = program['imagen'] ?? 'assets/default_image.png';
                String nombre =
                    program['nombre_programa_automatico'] ?? 'Sin nombre';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      // Aquí solo seleccionamos el programa si no está seleccionado aún
                      setState(() {
                        automaticSelectedProgram = program['nombre'];
                      });

                      widget.onAutoProgramSelected(
                          program); // Llama a la función para pasar el programa seleccionado
                      widget.onClose(); // Cerrar el overlay
                    },
                    onLongPress: () {
                      // Mostrar el Dialog con más detalles
                      _showProgramDetailsDialog(
                          context, program, screenHeight, screenWidth);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // Ajusta el tamaño de la columna al contenido
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Centra la columna verticalmente
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Centra horizontalmente
                      children: [
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Image.asset(
                          imagen,
                          width: screenWidth * 0.15,
                          height: screenHeight * 0.15,
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

  void _showProgramDetailsDialog(BuildContext context,
      Map<String, dynamic> program, double screenHeight, double screenWidth) {
    var duracion = program['duracionTotal'] ?? 'Sin descripción';
    String descripcion =
        program['descripcion_programa_automatico'] ?? 'Sin descripción';
    String tipoEquipamiento =
        program['tipo_equipamiento'] ?? 'Sin información de equipamiento';
    List<Map<String, dynamic>> subprogramas = program['subprogramas'] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xFF2be4f3),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          backgroundColor: const Color(0xFF2E2E2E),
          child: Container(
            width: screenWidth * 0.7, // Ajusta el tamaño del contenedor
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8, // Fijar altura máxima
            ),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, 'Datos').toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF2be4f3),
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF2be4f3),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Sección de DESCRIPCIÓN
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'Duración').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${formatNumber(duracion)} min',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'Descripción').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      descripcion,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                // Sección de EQUIPAMIENTO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'Equipamiento').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      tipoEquipamiento,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                Text(
                  tr(context, 'Subprogramas').toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                if (subprogramas.isNotEmpty)
                  // ScrollView para la tabla
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          children: [
                            // Encabezado de la tabla
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFF2be4f3),
                              ),
                              children: [
                                _tableCell(tr(context, 'Orden').toUpperCase()),
                                _tableCell(tr(context, 'Nombre').toUpperCase()),
                                _tableCell(
                                    tr(context, 'Duración').toUpperCase()),
                                _tableCell(tr(context, 'Ajuste').toUpperCase()),
                              ],
                            ),
                            // Filas de los subprogramas
                            ...subprogramas.map((subprograma) {
                              String subnombre =
                                  subprograma['nombre'] ?? 'Sin nombre';
                              double subduracion = subprograma['duracion'] ?? 0;
                              double subajuste = subprograma['ajuste'] ?? 0;
                              int suborden = subprograma['orden'] ?? 0;

                              return TableRow(
                                children: [
                                  _tableCell('$suborden'),
                                  _tableCell(subnombre),
                                  _tableCell('$subduracion'),
                                  _tableCell('$subajuste'),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: screenHeight * 0.01),
                // Botón de Cerrar
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(
                          width: 1.0, color: Color(0xFF2be4f3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, 'Cerrar').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class OverlaySeleccionarCliente extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Map<String, dynamic>?) onClientSelected;

  const OverlaySeleccionarCliente(
      {super.key, required this.onClose, required this.onClientSelected});

  @override
  _OverlaySeleccionarClienteState createState() =>
      _OverlaySeleccionarClienteState();
}

class _OverlaySeleccionarClienteState extends State<OverlaySeleccionarCliente>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allClients = [];
  List<Map<String, dynamic>> filteredClients = []; // Lista filtrada
  final TextEditingController _clientNameController = TextEditingController();
  String selectedOption = 'Todos';
  List<Map<String, dynamic>> selectedClients =
      []; // Lista de clientes seleccionados
  String? selectedClient;

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _clientNameController.addListener(_filterClients);
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        allClients = clientData; // Asigna a la lista original
        filteredClients = allClients; // Inicializa la lista filtrada
      });
      _filterClients(); // Filtra para mostrar todos los clientes
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();

      filteredClients = allClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        // Filtra por estado basado en la selección del dropdown
        final matchesStatus =
            selectedOption == 'Todos' || client['status'] == selectedOption;

        return matchesName && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Seleccionar cliente').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextField(tr(context, 'Nombre').toUpperCase(),
                    _clientNameController, tr(context, 'Introducir nombre')),
                SizedBox(width: screenWidth * 0.05),
                _buildDropdown(),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildDataTable(screenHeight, screenWidth),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(context, 'Estado').toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              value: selectedOption,
              items: [
                DropdownMenuItem(
                    value: 'Todos',
                    child: Text(tr(context, 'Todos'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Activo',
                    child: Text(tr(context, 'Activo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Inactivo',
                    child: Text(tr(context, 'Inactivo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  _filterClients(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF2be4f3), size: 30),
            ),
          ),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Encabezado fijo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderCell('ID'),
                  _buildHeaderCell(tr(context, 'Nombre').toUpperCase()),
                  _buildHeaderCell(tr(context, 'Teléfono').toUpperCase()),
                  _buildHeaderCell(tr(context, 'Estado').toUpperCase()),
                ],
              ),
              const SizedBox(height: 10), // Espaciado entre encabezado y filas
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: filteredClients.map((client) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Provider.of<ClientsProvider>(context, listen: false).addClient(client);

                              // Llama a la función para pasar el cliente seleccionado
                              widget.onClientSelected(client);
                              widget.onClose(); // Cerrar el overlay
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: const Color(0xFF2be4f3),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDataCell(
                                      client['id']?.toString() ?? ''),
                                  _buildDataCell(client['name'] ?? ''),
                                  _buildDataCell(
                                      client['phone']?.toString() ?? ''),
                                  _buildDataCell(client['status'] ?? ''),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // Espaciado entre filas
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ),
    );
  }
}

class ClientsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _selectedClients = [];
  List<Map<String, dynamic>> get selectedClients => _selectedClients;
  void addClient(Map<String, dynamic> client) {
    if (!_selectedClients.any((c) => c['id'] == client['id'])) {
      _selectedClients.add(client);
      notifyListeners(); // Notifica a los widgets que están escuchando
    }
  }
  void removeClient(Map<String, dynamic> client) {
    _selectedClients.removeWhere((c) => c['id'] == client['id']);
    notifyListeners(); // Notifica después de eliminar
  }
  void clearSelectedClientsSilently() {
    selectedClients.clear(); // Limpia los datos sin notificar
  }
}


