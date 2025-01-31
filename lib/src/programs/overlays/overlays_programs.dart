import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/programs/customs_programs/automatic_table_widget.dart';
import 'package:imotion_designs/src/programs/form_programs/individual_program_form.dart';
import 'package:imotion_designs/src/programs/form_programs/recovery_program_form.dart';
import 'package:imotion_designs/src/programs/info_programs/programs_indiv_list_view.dart';
import 'package:imotion_designs/src/programs/info_programs/programs_reco_list_view.dart';

import '../../../utils/translation_utils.dart';
import '../../clients/overlays/main_overlay.dart';
import '../form_programs/automatic_program_form.dart';
import '../info_programs/programs_auto_list_view.dart';

class OverlayIndividuales extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayIndividuales({super.key, required this.onClose});

  @override
  _OverlayIndividualesState createState() => _OverlayIndividualesState();
}

class _OverlayIndividualesState extends State<OverlayIndividuales>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedProgram;
  bool isInfoVisible = false;

  void selectProgram(Map<String, dynamic> programData) {
    setState(() {
      selectedProgram = programData;
      isInfoVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, 'Individuales').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? const Column()
          : const ProgramsIndividualesListView(),
      onClose: widget.onClose,
    );
  }
}

class OverlayAuto extends StatefulWidget {
  final VoidCallback onClose; // Callback para cerrar el overlay

  const OverlayAuto({super.key, required this.onClose});

  @override
  _OverlayAutoState createState() => _OverlayAutoState();
}

class _OverlayAutoState extends State<OverlayAuto> {
  Map<String, dynamic>?
      selectedProgram; // Para almacenar el programa seleccionado
  bool isInfoVisible =
      false; // Para controlar si se muestra la vista de detalles

  // Esta función se pasa al ProgramsAutoListView para manejar la selección de un programa
  void selectProgram(Map<String, dynamic> programData) {
    setState(() {
      selectedProgram = programData;
      isInfoVisible = true; // Muestra la vista detallada del programa
    });
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, 'Automáticos').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? _buildProgramInfoView() // Muestra la vista con los detalles del programa
          : ProgramsAutoListView(onProgramTap: selectProgram),
      // Pasamos la función selectProgram
      onClose: widget.onClose, // Callback para cerrar el overlay
    );
  }

  Widget _buildProgramInfoView() {
    var program =
        selectedProgram!; // Obtenemos los datos del programa seleccionado

    // Debug print para verificar la estructura de los datos
    debugPrint('Selected Program: ${program.toString()}');

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Row para los elementos de la izquierda (imagen y texto)
                Row(
                  children: [
                    // Contenedor para la imagen
                    Image.asset(
                      program['imagen'], // Imagen del programa seleccionado
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.2,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                    // Contenedor para el texto
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          // La columna se ajustará al tamaño mínimo necesario
                          children: [
                            // Texto con el nombre del programa y duración
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        'Nº${program['id_programa_automatico']}  ${program['nombre_programa_automatico']} - ',
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(
                                          0xFF2be4f3), // Color del nombre del programa
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${(program['duracionTotal'] as double).toInt()} min', // Convertir a entero
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Duración en blanco
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.01),

                            // Texto adicional para la descripción del programa
                            Text(
                              '${program['descripcion_programa_automatico'] ?? 'No disponible'}',
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.white, // Color del nuevo texto
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Contenedor para el GestureDetector con la imagen de "back" anclada a la derecha
                Positioned(
                  top: 0, // Alineado a la parte superior del contenedor
                  right: 0, // Alineado a la derecha del contenedor
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isInfoVisible = false;
                      });
                    },
                    child: Image.asset(
                      scale: 0.5,
                      'assets/images/back.png',
                      height: MediaQuery.of(context).size.height * 0.1,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Flexible(
            // Flexible permite que el Container ocupe una fracción del espacio disponible
            flex: 1,
            // Este valor define cuánta parte del espacio disponible debe ocupar el widget
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 46, 46),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: SubprogramTableWidget(
                  subprogramData: program['subprogramas'] ??
                      [], // Aquí se pasa la lista de subprogramas
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayRecovery extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayRecovery({super.key, required this.onClose});

  @override
  _OverlayRecoveryState createState() => _OverlayRecoveryState();
}

class _OverlayRecoveryState extends State<OverlayRecovery>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedProgram;
  bool isInfoVisible = false;

  void selectProgram(Map<String, dynamic> programData) {
    setState(() {
      selectedProgram = programData;
      isInfoVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, 'Recovery').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? const Column()
          : const ProgramsRecoveryListView(),
      onClose: widget.onClose,
    );
  }
}

class OverlayCrearPrograma extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayCrearPrograma({super.key, required this.onClose});

  @override
  _OverlayCrearProgramaState createState() => _OverlayCrearProgramaState();
}

class _OverlayCrearProgramaState extends State<OverlayCrearPrograma>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>?
      selectedClientData; // Nullable Map, no late initialization required

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Crear programa').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          _buildTab(tr(context, 'Individuales').toUpperCase(), 0),
          _buildTab(tr(context, 'Automáticos').toUpperCase(), 1),
          _buildTab(tr(context, 'Recovery').toUpperCase(), 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.black,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: MediaQuery.of(context).size.height * 0.2,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            decoration: _tabController.index == index
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        IndividualProgramForm(
          onDataChanged: (data) {
            debugPrint(
                data as String?); // Verify that the data is arriving correctly
            setState(() {});
          },
          onClose: widget.onClose,
        ),
        AutomaticProgramForm(
          onDataChanged: (data) {
            debugPrint(data as String?);
            setState(() {});
          },
          onClose: widget.onClose,
        ),
        RecoveryProgramForm(
          onDataChanged: (data) {
            debugPrint(data as String?);
            setState(() {});
          },
          onClose: widget.onClose,
        ),
      ],
    );
  }
}
