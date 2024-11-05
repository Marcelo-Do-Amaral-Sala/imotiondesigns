import 'package:flutter/material.dart';

class ClientsGroups extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> clientData;
  final VoidCallback onClose;

  const ClientsGroups({
    Key? key,
    required this.onDataChanged,
    required this.clientData,
    required this.onClose,
  }) : super(key: key);

  @override
  _ClientsGroupsState createState() => _ClientsGroupsState();
}

class _ClientsGroupsState extends State<ClientsGroups> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;
  int? clientId; // Declare a variable to store the client ID

  Map<String, bool> selectedGroups = {
    'trapecios': false,
    'dorsales': false,
    'lumbares': false,
    'gluteos': false,
    'isquios': false,
    'pectorales': false,
    'abdomen': false,
    'cuadriceps': false,
    'biceps': false,
    'gemelos': false,
  };

  Map<String, Color> hintColors = {
    'trapecios': Colors.white,
    'dorsales': Colors.white,
    'lumbares': Colors.white,
    'gluteos': Colors.white,
    'isquios': Colors.white,
    'pectorales': Colors.white,
    'abdomen': Colors.white,
    'cuadriceps': Colors.white,
    'biceps': Colors.white,
    'gemelos': Colors.white,
  };



  // Crear el checkbox redondo personalizado
  Widget customCheckbox(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGroups[option] = !selectedGroups[option]!;
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
          color: selectedGroups[option]!
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: selectedGroups[option]!
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  // Función para manejar clic en TextField
  void handleTextFieldTap(String option) {
    setState(() {
      selectedGroups[option] = !selectedGroups[option]!;
      hintColors[option] =
          selectedGroups[option]! ? const Color(0xFF2be4f3) : Colors.white;
    });
  }

  @override
  void initState() {
    super.initState();
    clientId = int.tryParse(widget.clientData['id'].toString());
    _indexController.text = clientId.toString(); // Set controller text
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.03), // Ajustar el padding
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Primer contenedor para el primer row de inputs
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Campos de ID y NOMBRE
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ID',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextField(
                                  controller: _indexController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                    filled: true,
                                    fillColor: const Color(0xFF313030),
                                    isDense: true,
                                    enabled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NOMBRE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(7)),
                                    filled: true,
                                    fillColor: const Color(0xFF313030),
                                    isDense: true,
                                    enabled: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ESTADO',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: AbsorbPointer(
                                  absorbing: true,
                                  // Esto deshabilita la interacción con el DropdownButton
                                  child: DropdownButton<String>(
                                    hint: const Text(
                                      'Seleccione',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    value: selectedOption,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Activo',
                                        child: Text(
                                          'Activo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Inactivo',
                                        child: Text(
                                          'Inactivo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ],
                                    onChanged: null,
                                    // Asegura que no se pueda cambiar el valor
                                    dropdownColor: const Color(0xFF313030),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF2be4f3),
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // Segundo contenedor para el segundo row de inputs
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.33,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sección vacía
                        Expanded(
                          child: Column(
                            children: [
                              // Primer Checkbox con TextField
                              Row(
                                children: [
                                  customCheckbox('trapecios'),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('trapecios'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Trapecios',
                                                hintStyle: TextStyle(
                                                  color: hintColors['trapecios'],
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                              const SizedBox(height: 2.0),
                              // Segundo Checkbox con TextField
                              Row(
                                children: [
                                  customCheckbox('dorsales'),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('dorsales'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Dorsales',
                                                hintStyle: TextStyle(
                                                  color: hintColors['dorsales'],
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                              const SizedBox(height: 2.0),
                              // Tercer Checkbox con TextField
                              Row(
                                children: [
                                  customCheckbox('lumbares'),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('lumbares'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Lumbares',
                                                hintStyle: TextStyle(
                                                  color: hintColors['lumbares'],
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                              const SizedBox(height: 2.0),
                              // Cuarto Checkbox con TextField
                              Row(
                                children: [
                                  customCheckbox('gluteos'),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('gluteos'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Glúteos',
                                                hintStyle: TextStyle(
                                                  color: hintColors['gluteos'],
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                              const SizedBox(height: 2.0),
                              // Quinto Checkbox con TextField
                              Row(
                                children: [
                                  customCheckbox('isquios'),
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('isquios'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Isquios',
                                                hintStyle: TextStyle(
                                                  color: hintColors['isquios'],
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                            'assets/images/avatar_back.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['trapecios']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/trapecios.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['dorsales']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/dorsales.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['lumbares']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/lumbar.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['gluteos']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/gluteos.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['isquios']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/isquios.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedGroups['gemelos']!)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/gemelos.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          flex:1,
                          child: Stack(
                            children: [
                              // Imagen 2
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
                              if (selectedGroups['pectorales']!)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/pectorales.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              if (selectedGroups['abdomen']!)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/abdomen.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              if (selectedGroups['cuadriceps']!)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/cuadriceps.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              if (selectedGroups['biceps']!)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/biceps.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              // Primer Checkbox con TextField
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('pectorales'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Pectorales',
                                                hintStyle: TextStyle(
                                                  color: hintColors['pectorales'],
                                                  // Usar el color dinámico
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                  customCheckbox('pectorales'),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              // Segundo Checkbox con TextField
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('abdomen'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Abdominales',
                                                hintStyle: TextStyle(
                                                  color: hintColors['abdomen'],
                                                  // Usar el color dinámico
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                  customCheckbox('abdomen'),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              // Tercer Checkbox con TextField
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('cuadriceps'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Cuádriceps',
                                                hintStyle: TextStyle(
                                                  color: hintColors['cuadriceps'],
                                                  // Usar el color dinámico
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                  customCheckbox('cuadriceps'),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              // Cuarto Checkbox con TextField
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('biceps'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Bíceps',
                                                hintStyle: TextStyle(
                                                  color: hintColors['biceps'],
                                                  // Usar el color dinámico
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                  customCheckbox('biceps'),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              // Quinto Checkbox con TextField
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () =>
                                          handleTextFieldTap('gemelos'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: TextField(
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: 'Gemelos',
                                                hintStyle: TextStyle(
                                                  color: hintColors['gemelos'],
                                                  // Usar el color dinámico
                                                  fontSize: 13,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
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
                                  customCheckbox('gemelos'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Botón de acción
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    //onTap: _updateData,
                    child: AnimatedScale(
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.08,
                        height: screenHeight * 0.08,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
