import 'package:flutter/material.dart';

import '../../clients/overlays/main_overlay.dart';
import '../../db/db_helper.dart';

String? globalSelectedProgram;

class OverlayTipoPrograma extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayTipoPrograma({super.key, required this.onClose});

  @override
  _OverlayTipoProgramaState createState() => _OverlayTipoProgramaState();
}

class _OverlayTipoProgramaState extends State<OverlayTipoPrograma>
    with SingleTickerProviderStateMixin {
  String? selectedProgram;

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "SELECCIONAR TIPO DE PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Columna para los ListTiles
            Expanded(
              flex: 2, // Le da más espacio a esta columna si se necesita
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildCustomCheckboxTile("INDIVIDUAL"),
                    buildCustomCheckboxTile("RECOVERY"),
                    buildCustomCheckboxTile("AUTOMÁTICOS"),
                  ],
                ),
              ),
            ),
            // Columna para el botón
            Expanded(
              flex: 1, // Menos espacio que la columna de ListTiles
              child: Align(
                alignment: Alignment.bottomCenter,
                child: OutlinedButton(
                  onPressed: () {
                    // Guarda el valor seleccionado en la variable global
                    globalSelectedProgram = selectedProgram;
                    widget.onClose(); // Llama al onClose para cerrar el overlay
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
                  child: const Text(
                    'SELECCIONAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
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
        width: 22.0,
        height: 22.0,
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

Map<String, dynamic>?
    selectedIndivProgram; // Variable global para el programa seleccionado

class OverlaySeleccionarProgramaIndividual extends StatefulWidget {
  final VoidCallback onClose;

  const OverlaySeleccionarProgramaIndividual(
      {super.key, required this.onClose});

  @override
  _OverlaySeleccionarProgramaIndividualState createState() =>
      _OverlaySeleccionarProgramaIndividualState();
}

class _OverlaySeleccionarProgramaIndividualState
    extends State<OverlaySeleccionarProgramaIndividual>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allIndividualPrograms = [];

  // Mapa para controlar el estado de 'long press' de cada programa
  Map<String, bool> longPressStates = {};

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
      title: const Text(
        "SELECCIONAR PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
                      // Guardar el programa seleccionado en la variable global
                      setState(() {
                        selectedIndivProgram = program;
                      });
                      print('Programa seleccionado: ${program['nombre']}');
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
                          style: const TextStyle(
                            color: Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
              maxHeight: screenHeight * 0.5, // Fijar altura máxima
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
                        const Text(
                          'DATOS',
                          style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF2be4f3)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildDetailRow('FRECUENCIA: ', frecuencia, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('RAMPA: ', rampa, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('PAUSA: ', pausa, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('CONTRACCIÓN: ', contraccion, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('PULSO: ', pulso, ' μs'),
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
                    child: const Text(
                      'CERRAR',
                      style: TextStyle(
                        color: Color(0xFF2be4f3),
                        fontSize: 15,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Text(
          suffix,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic>?
    selectedRecoProgram; // Variable global para el programa seleccionado

class OverlaySeleccionarProgramaRecovery extends StatefulWidget {
  final VoidCallback onClose;

  const OverlaySeleccionarProgramaRecovery({super.key, required this.onClose});

  @override
  _OverlaySeleccionarProgramaRecoveryState createState() =>
      _OverlaySeleccionarProgramaRecoveryState();
}

class _OverlaySeleccionarProgramaRecoveryState
    extends State<OverlaySeleccionarProgramaRecovery>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allRecoveryPrograms = [];

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
      title: const Text(
        "SELECCIONAR PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
                      // Guardar el programa seleccionado en la variable global
                      setState(() {
                        selectedRecoProgram = program;
                      });
                      print('Programa seleccionado: ${program['nombre']}');
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
                          style: const TextStyle(
                            color: Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
              maxHeight: screenHeight * 0.5, // Fijar altura máxima
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
                        const Text(
                          'DATOS',
                          style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF2be4f3)),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildDetailRow('FRECUENCIA: ', frecuencia, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('RAMPA: ', rampa, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('PAUSA: ', pausa, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('CONTRACCIÓN: ', contraccion, ' μs'),
                        SizedBox(height: screenHeight * 0.02),
                        _buildDetailRow('PULSO: ', pulso, ' μs'),
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
                    child: const Text(
                      'CERRAR',
                      style: TextStyle(
                        color: Color(0xFF2be4f3),
                        fontSize: 15,
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Text(
          suffix,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic>?
    selectedAutoProgram; // Variable global para el programa seleccionado

class OverlaySeleccionarProgramaAutomatic extends StatefulWidget {
  final VoidCallback onClose;

  const OverlaySeleccionarProgramaAutomatic({super.key, required this.onClose});

  @override
  _OverlaySeleccionarProgramaAutomaticState createState() =>
      _OverlaySeleccionarProgramaAutomaticState();
}

class _OverlaySeleccionarProgramaAutomaticState
    extends State<OverlaySeleccionarProgramaAutomatic>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allAutomaticPrograms = [];

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
      title: const Text(
        "SELECCIONAR PROGRAMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
                      // Guardar el programa seleccionado en la variable global
                      setState(() {
                        selectedAutoProgram = program;
                      });
                      print(
                          'Programa seleccionado: ${program['nombre_programa_automatico']}');
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
                          style: const TextStyle(
                            color: Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
            width: screenWidth * 0.7,  // Ajusta el tamaño del contenedor
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.7, // Fijar altura máxima
            ),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATOS',
                  style: TextStyle(
                    color: Color(0xFF2be4f3),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF2be4f3),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Sección de DESCRIPCIÓN
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESCRIPCIÓN:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Sección de EQUIPAMIENTO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EQUIPAMIENTO:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      tipoEquipamiento,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                const Text(
                  'SUBPROGRAMAS:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

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
                                _tableCell('Orden'),
                                _tableCell('Nombre'),
                                _tableCell('Duración'),
                                _tableCell('Ajuste'),
                              ],
                            ),
                            // Filas de los subprogramas
                            ...subprogramas.map((subprograma) {
                              String subnombre = subprograma['nombre'] ?? 'Sin nombre';
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

                // Botón de Cerrar
                Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      'CERRAR',
                      style: TextStyle(
                        color: Color(0xFF2be4f3),
                        fontSize: 15,
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

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}
