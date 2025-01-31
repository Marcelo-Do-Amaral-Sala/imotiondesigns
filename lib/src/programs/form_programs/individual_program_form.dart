import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class IndividualProgramForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final VoidCallback onClose;

  const IndividualProgramForm(
      {super.key, required this.onDataChanged, required this.onClose});

  @override
  IndividualProgramFormState createState() => IndividualProgramFormState();
}

class IndividualProgramFormState extends State<IndividualProgramForm>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _pulseController = TextEditingController();
  final _contractionController = TextEditingController();
  final _rampaController = TextEditingController();
  final _pauseController = TextEditingController();

  late TabController _tabController;

  String? selectedEquipOption;
  double scaleFactorTick = 1.0;

  Map<String, bool> selectedJacketGroups = {};
  Map<String, bool> selectedShapeGroups = {};

  Map<String, Color> hintJacketColors = {};
  Map<String, Color> hintShapeColors = {};

  Map<String, int> groupJacketIds = {};
  Map<String, int> groupShapeIds = {};

  Map<String, String> imageJacketPaths = {};
  Map<String, String> imageShapePaths = {};

  final DatabaseHelper dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> gruposBioJacket = [];
  List<Map<String, dynamic>> gruposBioShape = [];

  Map<String, TextEditingController> controllersJacket = {};
  Map<String, TextEditingController> controllersShape = {};
  bool programaGuardado = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchGruposMusculares();
    fetchCronaxias();
  }

  @override
  void dispose() {
    // Liberar los controladores dinámicos de BIO-JACKET
    controllersJacket.forEach((key, controller) {
      controller.dispose();
    });

    // Liberar los controladores dinámicos de BIO-SHAPE
    controllersShape.forEach((key, controller) {
      controller.dispose();
    });

    // Liberar el controlador de tabulación
    _tabController.dispose();

    // Llamar a super.dispose() para garantizar la limpieza general
    super.dispose();
  }

  Future<void> fetchCronaxias() async {
    try {
      Database db = await DatabaseHelper().database;

      // Obtener grupos musculares para BIO-JACKET
      var gruposJacket = await DatabaseHelper()
          .obtenerCronaxiaPorEquipamiento(db, 'BIO-JACKET');

      // Asignar datos para BIO-JACKET
      setState(() {
        gruposBioJacket = gruposJacket;
        // Inicializar controladores para cada grupo muscular de BIO-JACKET
        controllersJacket = {
          for (var row in gruposJacket) row['nombre']: TextEditingController(),
        };
      });

      // Obtener grupos musculares para BIO-SHAPE
      var gruposShape = await DatabaseHelper()
          .obtenerCronaxiaPorEquipamiento(db, 'BIO-SHAPE');

      // Asignar datos para BIO-SHAPE
      setState(() {
        gruposBioShape = gruposShape;
        controllersShape = {
          for (var row in gruposShape) row['nombre']: TextEditingController(),
        };
      });
    } catch (e) {
      print('Error al obtener los grupos musculares: $e');
    }
  }

  Future<void> fetchGruposMusculares() async {
    try {
      DatabaseHelper db = DatabaseHelper();

      // Obtener grupos musculares para BIO-JACKET
      var gruposJacket = await db.getGruposMuscularesEquipamiento('BIO-JACKET');

      // Asignar datos para BIO-JACKET
      setState(() {
        gruposBioJacket = gruposJacket;
        selectedJacketGroups = {
          for (var row in gruposJacket) row['nombre']: true // Cambiado a true
        };
        hintJacketColors = {
          for (var row in gruposJacket)
            row['nombre']: const Color(0xFF2be4f3) // Color de selección
        };
        groupJacketIds = {
          for (var row in gruposJacket) row['nombre']: row['id']
        };
        imageJacketPaths = {
          for (var row in gruposJacket) row['nombre']: row['imagen']
        };
      });

      // Obtener grupos musculares para BIO-SHAPE
      var gruposShape = await db.getGruposMuscularesEquipamiento('BIO-SHAPE');

      // Asignar datos para BIO-SHAPE
      setState(() {
        gruposBioShape = gruposShape;
        selectedShapeGroups = {
          for (var row in gruposShape) row['nombre']: true // Cambiado a true
        };
        hintShapeColors = {
          for (var row in gruposShape)
            row['nombre']: const Color(0xFF2be4f3) // Color de selección
        };
        groupShapeIds = {for (var row in gruposShape) row['nombre']: row['id']};
        imageShapePaths = {
          for (var row in gruposShape) row['nombre']: row['imagen']
        };
      });
    } catch (e) {
      print('Error al obtener los grupos musculares: $e');
    }
  }

  // Función para guardar el programa predeterminado desde el formulario
  Future<void> guardarProgramaPredeterminado() async {
    if (_nameController.text.isEmpty || selectedEquipOption == null) {
      // Verificación de '@' en el correo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Por favor, introduzca un nombre y el tipo de equipamiento al programa",
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Recoger los valores de los controladores de texto
    String nombrePrograma = _nameController.text;
    String equipamiento = selectedEquipOption ??
        ''; // Manejar el caso de que no se seleccione una opción
    double frecuencia = double.tryParse(_frequencyController.text) ?? 0.0;
    double pulso = double.tryParse(_pulseController.text) ?? 0.0;
    double contraccion = double.tryParse(_contractionController.text) ?? 0.0;
    double pausa = double.tryParse(_pauseController.text) ?? 0.0;
    int rampa = int.tryParse(_rampaController.text) ?? 0;

    // Crear el mapa con los datos del programa
    Map<String, dynamic> programa = {
      'nombre': nombrePrograma,
      'imagen': 'assets/images/programacreado.png',
      // Puedes agregar la ruta de la imagen aquí si es necesario
      'frecuencia': frecuencia,
      'pulso': pulso,
      'contraccion': contraccion,
      'rampa': rampa,
      'pausa': pausa,
      'tipo': 'Individual',
      // Puedes actualizar esto según el tipo de programa que quieras
      'tipo_equipamiento': equipamiento,
    };

    // Insertar el programa en la base de datos
    int programaId =
    await DatabaseHelper().insertarProgramaPredeterminado(programa);

    // Insertar las cronaxias y grupos musculares por defecto
    await DatabaseHelper()
        .insertarCronaxiasPorDefecto(programaId, equipamiento);
    await DatabaseHelper()
        .insertarGruposMuscularesPorDefecto(programaId, equipamiento);
    setState(() {
      programaGuardado = true; // 🔹 Ahora el usuario puede cambiar de pestañas
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, "Programa individual creado correctamente").toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  Future<void> actualizarCronaxias(
      int programaId, String tipoEquipamiento) async {
    // Iterar sobre los controladores según el tipo de equipamiento
    if (tipoEquipamiento == 'BIO-JACKET') {
      for (var grupo in gruposBioJacket) {
        String nombre = grupo['nombre'];
        var controller = controllersJacket[nombre];

        // Verificar si el controlador es válido antes de acceder a su texto
        if (controller == null) {
          print('Error: El controlador para "$nombre" es nulo.');
          continue; // Salir del ciclo actual si el controlador es nulo
        }

        // Depuración: verificar si el controlador tiene el valor correcto
        print('Valor para grupo "$nombre": ${controller.text}');

        // Verifica que el valor no sea nulo antes de actualizar
        double valor = controller.text.isNotEmpty
            ? double.tryParse(controller.text) ??
                0.0 // Usar valor por defecto si es nulo o vacío
            : 0.0;

        // Imprimir el valor antes de actualizarlo
        print('Actualizando cronaxia para grupo "$nombre" con valor: $valor');

        // Llamar a la función de actualización desde el DatabaseHelper
        await DatabaseHelper().updateCronaxia(programaId, grupo['id'], valor);

      }
    } else if (tipoEquipamiento == 'BIO-SHAPE') {
      for (var grupo in gruposBioShape) {
        String nombre = grupo['nombre'];
        var controller = controllersShape[nombre];

        // Verificar si el controlador es válido antes de acceder a su texto
        if (controller == null) {
          print('Error: El controlador para "$nombre" es nulo.');
          continue; // Salir del ciclo actual si el controlador es nulo
        }

        // Depuración: verificar si el controlador tiene el valor correcto
        print('Valor para grupo "$nombre": ${controller.text}');

        // Verificar si el valor es vacío, de ser así, usar 0.0
        double valor = controller.text.isNotEmpty
            ? double.tryParse(controller.text) ?? 0.0
            : 0.0;

        // Imprimir el valor antes de actualizarlo
        print('Actualizando cronaxia para grupo "$nombre" con valor: $valor');

        // Llamar a la función de actualización desde el DatabaseHelper
        await DatabaseHelper().updateCronaxia(programaId, grupo['id'], valor);
      }
    }

  }

  // Función para manejar la actualización de los grupos musculares
  Future<void> actualizarGruposEnPrograma() async {
    // Crear una instancia de DatabaseHelper
    DatabaseHelper dbHelper = DatabaseHelper();

    // Llamar al método de instancia para obtener el programa más reciente
    Map<String, dynamic>? programa = await dbHelper.getMostRecentPrograma();

    if (programa != null) {
      int programaId = programa['id_programa'];
      String tipoEquipamiento = programa['tipo_equipamiento'];

      print('El último id_programa es: $programaId');
      print('El tipo de equipamiento es: $tipoEquipamiento');

      // Filtrar los grupos musculares seleccionados según el tipo de grupo
      List<int> selectedGroupIds = [];

      // Usamos directamente los mapas de grupos seleccionados
      Map<String, bool> selectedGroups = tipoEquipamiento == 'BIO-JACKET'
          ? selectedJacketGroups
          : selectedShapeGroups;

      // Filtrar los grupos seleccionados
      selectedGroups.forEach((key, isSelected) {
        if (isSelected) {
          int? groupId = tipoEquipamiento == 'BIO-JACKET'
              ? groupJacketIds[key]
              : groupShapeIds[key];
          if (groupId != null) {
            selectedGroupIds.add(groupId);
          }
        }
      });

      // Mostrar los nuevos grupos musculares seleccionados
      print('Nuevos grupos musculares seleccionados: $selectedGroupIds');

      // Asegurarnos de que hay elementos en selectedGroupIds antes de actualizar
      if (selectedGroupIds.isNotEmpty) {
        // Llamamos a la función para actualizar los grupos musculares en la base de datos
        await dbHelper.actualizarGruposMusculares(programaId, selectedGroupIds);
      } else {
        print('No se seleccionaron grupos musculares.');
      }
    } else {
      print('No se encontraron programas en la base de datos');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, "Grupos añadidos correctamente").toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

// Función para crear el checkbox personalizado
  Widget customCheckbox(String option, String groupType) {
    // Según el tipo de grupo, actualizamos el mapa adecuado
    Map<String, bool> selectedGroups =
        groupType == 'BIO-JACKET' ? selectedJacketGroups : selectedShapeGroups;
    Map<String, Color> hintColors =
        groupType == 'BIO-JACKET' ? hintJacketColors : hintShapeColors;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Asegurarse de que selectedGroups[option] no sea null, lo inicializas como false si es nulo
          selectedGroups[option] =
              !(selectedGroups[option] ?? false); // Si es null, toma false
          hintColors[option] =
              selectedGroups[option]! ? const Color(0xFF2be4f3) : Colors.white;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectedGroups[option] == true
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: selectedGroups[option] == true
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: MediaQuery.of(context).size.width * 0.001,
          ),
        ),
      ),
    );
  }

// Función para manejar clic en el TextField
  void handleTextFieldTap(String option, String groupType) {
    // Según el tipo de grupo, actualizamos el mapa adecuado
    Map<String, bool> selectedGroups =
        groupType == 'BIO-JACKET' ? selectedJacketGroups : selectedShapeGroups;
    Map<String, Color> hintColors =
        groupType == 'BIO-JACKET' ? hintJacketColors : hintShapeColors;

    setState(() {
      // Cambiar el estado de selección
      selectedGroups[option] = !(selectedGroups[option] ?? false);

      // Cambiar color del hint según la selección
      hintColors[option] = selectedGroups[option]!
          ? const Color(0xFF2be4f3) // Color cuando está seleccionado
          : Colors.white; // Color cuando no está seleccionado
    });
  }

  Future<void> _showAlert(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Aquí defines el ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.01,
                vertical: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, '¡Alerta!').toUpperCase(),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  tr(context, 'Debes completar el formulario para continuar')
                      .toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.01,
                      vertical: MediaQuery.of(context).size.height * 0.01,
                    ),
                    side: BorderSide(
                      width: MediaQuery.of(context).size.width * 0.001,
                      color: const Color(0xFF2be4f3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, '¡Entendido!').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildConfigurationTab(screenWidth, screenHeight),
                  _buildCronaxiaTab(screenWidth, screenHeight),
                  _buildGroupsTab(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        physics: const NeverScrollableScrollPhysics(),
        onTap: (index) {
          if (index != 0 && !programaGuardado) {
            _showAlert(context); // Mostrar alerta
            _tabController.index = 0; // 🔹 FORZAR PERMANECER EN CONFIGURACIÓN
          } else {
            setState(() {
              _tabController.index = index;
            });
          }
        },
        tabs: [
          _buildTab(tr(context, 'Configuración').toUpperCase(), 0),
          _buildTab(tr(context, 'Cronaxia').toUpperCase(), 1),
          _buildTab(tr(context, 'Grupos activos').toUpperCase(), 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }



  Widget _buildTab(String text, int index) {
    bool isDisabled = !programaGuardado && index != 0; // Bloquear si no está guardado y no es Configuración

    return IgnorePointer(
      ignoring: isDisabled, // 🔹 Bloquea la interacción si el programa no está guardado
      child: Tab(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
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
      ),
    );
  }



  Widget _buildConfigurationTab(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Fila 1: Campos ID, Nombre, Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Nombre del programa').toUpperCase(),
                              style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: tr(
                                    context, 'Introducir nombre del programa'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Equipamiento').toUpperCase(),
                              style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: DropdownButton<String>(
                              hint: Text(tr(context, 'Seleccione'),
                                  style: _dropdownHintStyle),
                              value: selectedEquipOption,
                              items: [
                                DropdownMenuItem(
                                  value: 'BIO-JACKET',
                                  child: Text('BIO-JACKET',
                                      style: _dropdownItemStyle),
                                ),
                                DropdownMenuItem(
                                  value: 'BIO-SHAPE',
                                  child: Text('BIO-SHAPE',
                                      style: _dropdownItemStyle),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedEquipOption = value;
                                });
                              },
                              dropdownColor: const Color(0xFF313030),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF2be4f3),
                                  size: screenHeight * 0.05),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Fila 2: Campos de Frecuencia, Pulso, Rampa, Contracción y Pausa
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(tr(context, 'Frecuencia (Hz)').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _frequencyController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$')),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText:
                                      tr(context, 'Introducir frecuencia'),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(tr(context, 'Pulso (ms)').toUpperCase(),
                                style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _pulseController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d*$')),
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                  hintText: tr(context, 'Introducir pulso'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.05),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Campo de RAMPA con imagen a la izquierda
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/RAMPA.png',
                                  width: screenWidth * 0.05,
                                  height: screenHeight * 0.05,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${tr(context, 'Rampa').toUpperCase()} (sx10)",
                                        style: _labelStyle,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _rampaController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: tr(
                                                  context, 'Introducir rampa')),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Campo de CONTRACCIÓN con imagen a la izquierda
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/CONTRACCION.png',
                                  width: screenWidth * 0.05,
                                  height: screenHeight * 0.05,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${tr(context, 'Contracción').toUpperCase()} (s.)",
                                        style: _labelStyle,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _contractionController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                            hintText: tr(context,
                                                'Introducir contracción'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Campo de PAUSA con imagen a la izquierda
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/PAUSA.png',
                                  width: screenWidth * 0.05,
                                  height: screenHeight * 0.05,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${tr(context, 'Pausa').toUpperCase()} (s.)",
                                        style: _labelStyle,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _pauseController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                            hintText:
                                                tr(context, 'Introducir pausa'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.9),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {
                      await guardarProgramaPredeterminado();
                    },
                    child: AnimatedScale(
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCronaxiaTab(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Nombre del programa').toUpperCase(),
                              style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: tr(
                                    context, 'Introducir nombre del programa'),
                                enabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Equipamiento').toUpperCase(),
                              style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: AbsorbPointer(
                              // Deshabilita interacciones con el Dropdown
                              child: DropdownButton<String>(
                                hint: Text(tr(context, 'Seleccione'),
                                    style: _dropdownHintStyle),
                                value: selectedEquipOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BIO-JACKET',
                                    child: Text('BIO-JACKET',
                                        style: _dropdownItemStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'BIO-SHAPE',
                                    child: Text('BIO-SHAPE',
                                        style: _dropdownItemStyle),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedEquipOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF2be4f3),
                                  size: screenHeight * 0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.05),
                // Fila 2: Campos dinámicos dependiendo de la opción seleccionada
                if (selectedEquipOption == 'BIO-JACKET') ...[
                  // Campos específicos para BIO-JACKET
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Primera columna de TextFields
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los primeros grupos musculares
                              for (int i = 0; i < 3; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioJacket[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersJacket[
                                            gruposBioJacket[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los siguientes grupos musculares
                              for (int i = 3; i < 6; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioJacket[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersJacket[
                                            gruposBioJacket[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los últimos grupos musculares
                              for (int i = 6; i < 9; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioJacket[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersJacket[
                                            gruposBioJacket[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 9;
                                  i < 10;
                                  i++) // Aquí ajustamos el rango de grupos
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioJacket[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersJacket[
                                            gruposBioJacket[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ] else if (selectedEquipOption == 'BIO-SHAPE') ...[
                  // Campos específicos para BIO-SHAPE
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Primera columna de TextFields
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los primeros grupos musculares
                              for (int i = 0; i < 3; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioShape[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersShape[
                                            gruposBioShape[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los siguientes grupos musculares
                              for (int i = 3; i < 6; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioShape[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersShape[
                                            gruposBioShape[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Itera sobre los últimos grupos musculares
                              for (int i = 6; i < 7; i++)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${gruposBioShape[i]['nombre'].toUpperCase()} (ms)',
                                      style: _labelStyle,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: controllersShape[
                                            gruposBioShape[i]['nombre']],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*$')),
                                        ],
                                        style: _inputTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.9),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {
                      // Crear una instancia de DatabaseHelper
                      DatabaseHelper dbHelper = DatabaseHelper();

                      Map<String, dynamic>? programa =
                          await dbHelper.getMostRecentPrograma();

                      if (programa != null) {
                        int programaId = programa['id_programa'];
                        String tipoEquipamiento = programa['tipo_equipamiento'];

                        print('El último id_programa es: $programaId');
                        print('El tipo de equipamiento es: $tipoEquipamiento');

                        // Llamar a la función actualizarCronaxias pasando ambos valores
                        await actualizarCronaxias(programaId, tipoEquipamiento);
                        print('Cronaxias actualizadas al hacer tap.');
                      } else {
                        print(
                            'No se encontraron programas en la base de datos');
                      }
                    },
                    child: AnimatedScale(
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Nombre del programa').toUpperCase(),
                              style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: tr(
                                    context, 'Introducir nombre del programa'),
                                enabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(context, 'Equipamiento'), style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: AbsorbPointer(
                              // Deshabilita interacciones con el Dropdown
                              child: DropdownButton<String>(
                                hint: Text('Seleccione',
                                    style: _dropdownHintStyle),
                                value: selectedEquipOption,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BIO-JACKET',
                                    child: Text('BIO-JACKET',
                                        style: _dropdownItemStyle),
                                  ),
                                  DropdownMenuItem(
                                    value: 'BIO-SHAPE',
                                    child: Text('BIO-SHAPE',
                                        style: _dropdownItemStyle),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedEquipOption = value;
                                  });
                                },
                                dropdownColor: const Color(0xFF313030),
                                icon:  Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF2be4f3),
                                  size: screenHeight*0.05,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Fila 2: Campos dinámicos dependiendo de la opción seleccionada
                if (selectedEquipOption == 'BIO-JACKET') ...[
                  // Campos específicos para BIO-JACKET
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Primera lista de grupos: Trapecios, Dorsales, Lumbares, Glúteos, Isquios
                        Expanded(
                          child: ListView(
                            children: [
                              ...[
                                'Trapecios',
                                'Dorsales',
                                'Lumbares',
                                'Glúteos',
                                'Isquiotibiales'
                              ].map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(groupName, 'BIO-JACKET'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () => handleTextFieldTap(
                                              groupName, 'BIO-JACKET'),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF313030),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: TextField(
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.sp),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintJacketColors[
                                                          groupName],
                                                      fontSize: 15.sp,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        const Color(0xFF313030),
                                                    isDense: true,
                                                    enabled: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Imágenes para la parte superior del cuerpo (jacket)
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/avatar_back.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              ...selectedJacketGroups.entries
                                  .where((entry) =>
                                      [
                                        'Trapecios',
                                        'Dorsales',
                                        'Lumbares',
                                        'Glúteos',
                                        'Isquiotibiales',
                                        'Gemelos'
                                      ].contains(entry.key) &&
                                      entry.value)
                                  .map((entry) {
                                String groupName = entry.key;
                                String? imagePath = imageJacketPaths[groupName];
                                imagePath ??= 'assets/images/default_image.png';

                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Imágenes para la parte inferior del cuerpo (pantalón)
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/avatar_front.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              ...selectedJacketGroups.entries
                                  .where((entry) =>
                                      [
                                        'Pectorales',
                                        'Abdomen',
                                        'Cuádriceps',
                                        'Bíceps',
                                      ].contains(entry.key) &&
                                      entry.value)
                                  .map((entry) {
                                String groupName = entry.key;
                                String? imagePath = imageJacketPaths[groupName];
                                imagePath ??= 'assets/images/default_image.png';

                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Segunda lista de grupos: Pectorales, Abdominales, Cuádriceps, Bíceps, Gemelos
                        Expanded(
                          child: ListView(
                            children: [
                              ...[
                                'Pectorales',
                                'Abdomen',
                                'Cuádriceps',
                                'Bíceps',
                                'Gemelos'
                              ].map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(groupName, 'BIO-JACKET'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () => handleTextFieldTap(
                                              groupName, 'BIO-JACKET'),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF313030),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: TextField(
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.sp),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintJacketColors[
                                                          groupName],
                                                      fontSize: 15.sp,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        const Color(0xFF313030),
                                                    isDense: true,
                                                    enabled: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ] else if (selectedEquipOption == 'BIO-SHAPE') ...[
                  // Campos específicos para BIO-SHAPE
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sección vacía para la primera lista de músculos (parte superior)
                        Expanded(
                          child: ListView(
                            children: [
                              // Listar solo los grupos correspondientes a la primera lista de músculos
                              ...[
                                'Lumbares',
                                'Glúteos',
                                'Isquiotibiales',
                                'Gemelos',
                              ].map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(
                                          groupName, 'MUSCULOS PARTE SUPERIOR'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () => handleTextFieldTap(
                                              groupName,
                                              'MUSCULOS PARTE SUPERIOR'),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF313030),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: TextField(
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.sp),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintShapeColors[
                                                          groupName],
                                                      fontSize: 15.sp,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        const Color(0xFF313030),
                                                    isDense: true,
                                                    enabled: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Mostrar las imágenes para la parte superior del cuerpo
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/pantalon_post.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Mostrar imágenes para los grupos seleccionados
                              ...selectedShapeGroups.entries
                                  .where((entry) =>
                                      [
                                        'Lumbares',
                                        'Glúteos',
                                        'Isquiotibiales',
                                        'Gemelos',
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Solo mostrar los seleccionados
                                  .map((entry) {
                                String groupName = entry.key;
                                String? imagePath = imageShapePaths[groupName];
                                imagePath ??= 'assets/images/default_image.png';

                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/pantalon_front.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Mostrar imágenes para los grupos seleccionados
                              ...selectedShapeGroups.entries
                                  .where((entry) =>
                                      [
                                        'Abdomen',
                                        'Cuádriceps',
                                        'Bíceps',
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Solo mostrar los seleccionados
                                  .map((entry) {
                                String groupName = entry.key;
                                String? imagePath = imageShapePaths[groupName];
                                imagePath ??= 'assets/images/default_image.png';

                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // Sección vacía para la segunda lista de músculos (parte inferior)
                        Expanded(
                          child: ListView(
                            children: [
                              // Listar solo los grupos correspondientes a la segunda lista de músculos
                              ...[
                                'Abdomen',
                                'Cuádriceps',
                                'Bíceps',
                              ].map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(
                                          groupName, 'MUSCULOS PARTE INFERIOR'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () => handleTextFieldTap(
                                              groupName,
                                              'MUSCULOS PARTE INFERIOR'),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF313030),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: TextField(
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.sp),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintShapeColors[
                                                          groupName],
                                                      fontSize: 15.sp,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        const Color(0xFF313030),
                                                    isDense: true,
                                                    enabled: false,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SizedBox(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.9),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {
                      await actualizarGruposEnPrograma();
                      widget.onClose();
                    },
                    child: AnimatedScale(
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownHintStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownItemStyle =>
      TextStyle(color: Colors.white, fontSize: 15.sp);

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
