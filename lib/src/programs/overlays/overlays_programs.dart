import 'package:flutter/material.dart';
import 'package:imotion_designs/src/programs/customs_programs/automatic_table_widget.dart';
import 'package:imotion_designs/src/programs/info_programs/programs_indiv_list_view.dart';
import 'package:imotion_designs/src/programs/info_programs/programs_reco_list_view.dart';

import '../../clients/overlays/main_overlay.dart';
import '../info_programs/programs_auto_list_view.dart';

class OverlayIndividuales extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayIndividuales({Key? key, required this.onClose})
      : super(key: key);

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
      title: const Text(
        "INDIVIDUALES",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? Column()
          : ProgramsIndividualesListView(),
      onClose: widget.onClose,
    );
  }
}

class OverlayAuto extends StatefulWidget {
  final VoidCallback onClose; // Callback para cerrar el overlay

  const OverlayAuto({Key? key, required this.onClose}) : super(key: key);

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
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "AUTOMÁTICOS",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
      padding: const EdgeInsets.all(20.0), // Añadir padding general
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.25,
            color: Colors.red,
            child: Stack(
              children: [
                // Imagen a la izquierda y texto principal
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      program['imagen'], // Imagen del programa seleccionado
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Nº${program['id_programa_automatico']}  ${program['nombre_programa_automatico']} - ',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                      0xFF2be4f3), // Color del nombre del programa
                                ),
                              ),
                              TextSpan(
                                text: '${program['duracionTotal']} min',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Duración en blanco
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        // Espacio entre el texto principal y el nuevo texto
                        Expanded(
                          child: Text(
                            '${program['descripcion_programa_automatico'] ?? 'No disponible'}',
                            // Este es el nuevo texto
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.white, // Color del nuevo texto
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isInfoVisible = false;
                        });
                      },
                      child:
                          // Imagen de "back" a la derecha
                          Positioned(
                        right: 0, // Alineado a la derecha
                        top:
                            0, // Alineado desde la parte superior del contenedor
                        child: Image.asset(
                          'assets/images/back.png',
                          // Imagen del botón de "back"
                          height: MediaQuery.of(context).size.height * 0.1,
                          // Ajusta el tamaño según sea necesario
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
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
                padding: const EdgeInsets.all(20.0),
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

  const OverlayRecovery({Key? key, required this.onClose}) : super(key: key);

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
      title: const Text(
        "RECOVERY",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? Column()
          : ProgramsRecoveryListView(),
      onClose: widget.onClose,
    );
  }
}
/*
class OverlayCrear extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayCrear({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayCrearState createState() => _OverlayCrearState();
}

class _OverlayCrearState extends State<OverlayCrear>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isClientSaved = false; // Variable to check if the client has been saved
  Map<String, dynamic>?
      selectedClientData; // Nullable Map, no late initialization required

  final GlobalKey<PersonalDataFormState> _personalDataFormKey =
      GlobalKey<PersonalDataFormState>();

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
      title: const Text(
        "CREAR CLIENTE",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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

  Future<void> _showAlert(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF494949),
          title: const Text(
            '¡ALERTA!',
            style: TextStyle(
                color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Debes completar el formulario para continuar',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2be4f3)),
                  ),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(color: Color(0xFF2be4f3)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          if (!isClientSaved) {
            _showAlert(context);
          }
        },
        child: AbsorbPointer(
          absorbing: !isClientSaved,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index != 0 && !isClientSaved) {
                return; // Don't switch tabs if not saved
              } else {
                setState(() {
                  _tabController.index = index;
                });
              }
            },
            tabs: [
              _buildTab('DATOS PERSONALES', 0),
              _buildTab('BONOS', 1),
              _buildTab('GRUPOS ACTIVOS', 2),
            ],
            indicator: const BoxDecoration(
              color: Color(0xFF494949),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
            ),
            labelColor: const Color(0xFF2be4f3),
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: 200,
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
        PersonalDataForm(
          key: _personalDataFormKey,
          onDataChanged: (data) {
            print(data); // Verify that the data is arriving correctly
            setState(() {
              isClientSaved = true; // Client has been saved
              selectedClientData = data; // Save the client data
            });
          },
        ),
        // Check if selectedClientData is not null before passing it to ClientsFormBonos
        selectedClientData != null
            ? ClientsFormBonos(clientDataBonos: selectedClientData!)
            : Center(child: Text("No client data available.")),
        selectedClientData != null
            ? ClientsFormGroups(
                onDataChanged: (data) {
                  print(data); // Handle changed data
                },
                onClose: widget.onClose,
                clientDataGroups: selectedClientData!,
              )
            : Center(child: Text("No client data available.")),
      ],
    );
  }
}*/
