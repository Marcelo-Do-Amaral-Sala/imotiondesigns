import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/db_helper.dart';

class IndividualProgramForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  const IndividualProgramForm({super.key, required this.onDataChanged});

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
  final _trapController = TextEditingController();
  final _lumbController = TextEditingController();
  final _dorController = TextEditingController();
  final _glutController = TextEditingController();
  final _glutSupController = TextEditingController();
  final _glutInfController = TextEditingController();
  final _isquioController = TextEditingController();
  final _pectController = TextEditingController();
  final _abdoController = TextEditingController();
  final _abdoSupController = TextEditingController();
  final _abdoInfController = TextEditingController();
  final _cuadriController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _gemeloController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchGruposMusculares();
  }

  @override
  void dispose() {
    // Disposing de los controladores de texto
    _nameController.dispose();
    _frequencyController.dispose();
    _pulseController.dispose();
    _contractionController.dispose();
    _rampaController.dispose();
    _pauseController.dispose();

    // Disposing de los controladores relacionados con los grupos musculares
    _trapController.dispose();
    _lumbController.dispose();
    _dorController.dispose();
    _glutController.dispose();
    _glutSupController.dispose();
    _glutInfController.dispose();
    _isquioController.dispose();
    _pectController.dispose();
    _abdoController.dispose();
    _abdoSupController.dispose();
    _abdoInfController.dispose();
    _cuadriController.dispose();
    _bicepsController.dispose();
    _gemeloController.dispose();

    // Disposing del controlador de tabulación
    _tabController.dispose();

    // Llamada a super.dispose() para garantizar que se haga el proceso de limpieza general
    super.dispose();
  }

  Future<void> fetchGruposMusculares() async {
    try {
      Database db = await DatabaseHelper().database;

      // Obtener grupos musculares para BIO-JACKET
      var gruposJacket = await DatabaseHelper()
          .obtenerGruposMuscularesPorEquipamiento(db, 'BIO-JACKET');

      // Asignar datos para BIO-JACKET
      setState(() {
        gruposBioJacket = gruposJacket;
        selectedJacketGroups =
        {for (var row in gruposJacket) row['nombre']: false};
        hintJacketColors =
        {for (var row in gruposJacket) row['nombre']: Colors.white};
        groupJacketIds =
        {for (var row in gruposJacket) row['nombre']: row['id']};
        imageJacketPaths =
        {for (var row in gruposJacket) row['nombre']: row['imagen']};
      });

      // Obtener grupos musculares para BIO-SHAPE
      var gruposShape = await DatabaseHelper()
          .obtenerGruposMuscularesPorEquipamiento(db, 'BIO-SHAPE');

      // Asignar datos para BIO-SHAPE
      setState(() {
        gruposBioShape = gruposShape;
        selectedShapeGroups =
        {for (var row in gruposShape) row['nombre']: false};
        hintShapeColors =
        {for (var row in gruposShape) row['nombre']: Colors.white};
        groupShapeIds = {for (var row in gruposShape) row['nombre']: row['id']};
        imageShapePaths =
        {for (var row in gruposShape) row['nombre']: row['imagen']};
      });
    } catch (e) {
      print('Error al obtener los grupos musculares: $e');
    }
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
        width: 22.0,
        height: 22.0,
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
            width: 1.0,
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


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

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

  // Función modularizada para construir el TabBar
  Widget _buildTabBar() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * 0.5,
      height: MediaQuery
          .of(context)
          .size
          .height *
          0.05, // Ajusta la altura si es necesario
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        physics: const NeverScrollableScrollPhysics(),
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          _buildTab('CONFIGURACIÓN', 0),
          _buildTab('CRONAXIA', 1),
          _buildTab('GRUPOS ACTIVOS', 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  // Función modularizada para construir cada pestaña
  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: 150, // Ajusta el tamaño del ancho si lo necesitas
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
                          Text('ID', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Automático',
                                enabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NOMBRE DEL PROGRAMA', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Introducir nombre de programa',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EQUIPAMIENTO', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: DropdownButton<String>(
                              hint:
                              Text('Seleccione', style: _dropdownHintStyle),
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
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF2be4f3), size: 30),
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
                            Text('FRECUENCIA (Hz)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _frequencyController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                    hintText: 'Introducir frecuencia'),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text('PULSO (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _pulseController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                                decoration: _inputDecorationStyle(
                                    hintText: 'Introducir pulso'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
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
                                      Text('RAMPA (sx10)', style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _rampaController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: 'Introducir rampa'),
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
                                      Text('CONTRACCIÓN (s.)',
                                          style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _contractionController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText:
                                              'Introducir contracción'),
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
                                      Text('PAUSA (s.)', style: _labelStyle),
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: _inputDecoration(),
                                        child: TextField(
                                          controller: _pauseController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(3),
                                          ],
                                          style: _inputTextStyle,
                                          decoration: _inputDecorationStyle(
                                              hintText: 'Introducir pausa'),
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
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {},
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
                          Text('ID', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Automático',
                                enabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NOMBRE DEL PROGRAMA', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Introducir nombre de programa',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EQUIPAMIENTO', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: DropdownButton<String>(
                              hint:
                              Text('Seleccione', style: _dropdownHintStyle),
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
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF2be4f3),
                                size: 30,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TRAPECIO (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _trapController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text('LUMBARES (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _lumbController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            Text('DORSALES (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _dorController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GLÚTEOS (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _glutController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text('ISQUIOTIBIALES (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _isquioController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            Text('PECTORALES (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _pectController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ABDOMINALES (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _abdoController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text('CUÁDRICEPS (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _cuadriController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                            Text('BÍCEPS (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _bicepsController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.01),
                            Text('GEMELOS (ms)', style: _labelStyle),
                            Container(
                              alignment: Alignment.center,
                              decoration: _inputDecoration(),
                              child: TextField(
                                controller: _gemeloController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: _inputTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else
                  if (selectedEquipOption == 'BIO-SHAPE') ...[
                    // Campos específicos para BIO-SHAPE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LUMBARES (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _lumbController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text('GLÚTEO SUPERIOR (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _glutSupController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              Text('GLÚTEO INFERIOR (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _glutInfController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ISQUIOTIBIALES (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _isquioController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text('ABDOMEN SUPERIOR (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _abdoSupController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              Text('ABDOMEN INFERIOR (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _abdoInfController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CUÁDRICEPS (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _cuadriController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text('BÍCEPS (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _bicepsController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                              Text('GEMELOS (ms)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _gemeloController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: _inputTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
              ],
            ),
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {},
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
                          Text('ID', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Automático',
                                enabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NOMBRE DEL PROGRAMA', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: TextField(
                              controller: _nameController,
                              style: _inputTextStyle,
                              decoration: _inputDecorationStyle(
                                hintText: 'Introducir nombre de programa',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EQUIPAMIENTO', style: _labelStyle),
                          Container(
                            alignment: Alignment.center,
                            decoration: _inputDecoration(),
                            child: DropdownButton<String>(
                              hint:
                              Text('Seleccione', style: _dropdownHintStyle),
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
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF2be4f3), size: 30),
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
                                'Isquios'
                              ]
                                  .map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(groupName, 'BIO-JACKET'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () =>
                                              handleTextFieldTap(
                                                  groupName, 'BIO-JACKET'),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                      0xFF313030),
                                                  borderRadius: BorderRadius
                                                      .circular(7),
                                                ),
                                                child: TextField(
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintJacketColors[groupName],
                                                      fontSize: 14,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(7),
                                                    ),
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFF313030),
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
                                'Isquios',
                                'Gemelos'
                              ].contains(entry.key) && entry.value)
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
                                'Abdominales',
                                'Cuádriceps',
                                'Bíceps',
                              ].contains(entry.key) && entry.value)
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
                                'Abdominales',
                                'Cuádriceps',
                                'Bíceps',
                                'Gemelos'
                              ]
                                  .map((groupName) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: screenHeight * 0.01),
                                  child: Row(
                                    children: [
                                      customCheckbox(groupName, 'BIO-JACKET'),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () =>
                                              handleTextFieldTap(
                                                  groupName, 'BIO-JACKET'),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                      0xFF313030),
                                                  borderRadius: BorderRadius
                                                      .circular(7),
                                                ),
                                                child: TextField(
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    hintText: groupName,
                                                    hintStyle: TextStyle(
                                                      color: hintJacketColors[groupName],
                                                      fontSize: 14,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(7),
                                                    ),
                                                    filled: true,
                                                    fillColor: const Color(
                                                        0xFF313030),
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
                else
                  if (selectedEquipOption == 'BIO-SHAPE') ...[
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
                                  'Glúteo superior',
                                  'Glúteo inferior',
                                  'Isquiotibiales'
                                ]
                                    .map((groupName) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: screenHeight * 0.01),
                                    child: Row(
                                      children: [
                                        customCheckbox(groupName,
                                            'MUSCULOS PARTE SUPERIOR'),
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () =>
                                                handleTextFieldTap(groupName,
                                                    'MUSCULOS PARTE SUPERIOR'),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFF313030),
                                                    borderRadius: BorderRadius
                                                        .circular(7),
                                                  ),
                                                  child: TextField(
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      hintText: groupName,
                                                      hintStyle: TextStyle(
                                                        color: hintShapeColors[groupName],
                                                        fontSize: 14,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                      ),
                                                      filled: true,
                                                      fillColor: const Color(
                                                          0xFF313030),
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
                                  'Glúteo superior',
                                  'Glúteo inferior',
                                  'Isquiotibiales',
                                  'Gemelos',
                                ].contains(entry.key) && entry
                                    .value) // Solo mostrar los seleccionados
                                    .map((entry) {
                                  String groupName = entry.key;
                                  String? imagePath = imageShapePaths[groupName];
                                  imagePath ??=
                                  'assets/images/default_image.png';

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
                                  'Abdominales',
                                  'Cuádriceps',
                                  'Bíceps',

                                ].contains(entry.key) && entry
                                    .value) // Solo mostrar los seleccionados
                                    .map((entry) {
                                  String groupName = entry.key;
                                  String? imagePath = imageShapePaths[groupName];
                                  imagePath ??=
                                  'assets/images/default_image.png';

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
                                  'Abdominales',
                                  'Cuádriceps',
                                  'Bíceps',
                                  'Gemelos'
                                ]
                                    .map((groupName) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: screenHeight * 0.01),
                                    child: Row(
                                      children: [
                                        customCheckbox(groupName,
                                            'MUSCULOS PARTE INFERIOR'),
                                        Flexible(
                                          child: GestureDetector(
                                            onTap: () =>
                                                handleTextFieldTap(groupName,
                                                    'MUSCULOS PARTE INFERIOR'),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFF313030),
                                                    borderRadius: BorderRadius
                                                        .circular(7),
                                                  ),
                                                  child: TextField(
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      hintText: groupName,
                                                      hintStyle: TextStyle(
                                                        color: hintShapeColors[groupName],
                                                        fontSize: 14,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(7),
                                                      ),
                                                      filled: true,
                                                      fillColor: const Color(
                                                          0xFF313030),
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
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () async {},
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

  TextStyle get _labelStyle =>
      const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownHintStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownItemStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
