import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/db_helper.dart';

class ClientsFormGroups extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> clientDataGroups;
  final VoidCallback onClose;

  const ClientsFormGroups({
    Key? key,
    required this.onDataChanged,
    required this.onClose,
    required this.clientDataGroups,
  }) : super(key: key);

  @override
  _ClientsFormGroupsState createState() => _ClientsFormGroupsState();
}

class _ClientsFormGroupsState extends State<ClientsFormGroups> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;
  Map<String, dynamic>? selectedClient;

  Map<String, bool> selectedGroups = {};
  Map<String, Color> hintColors = {};
  Map<String, int> groupIds = {};

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadMuscleGroups();
    _loadMostRecentClient(); // Llamar al método para cargar los grupos musculares
  }

  // Método para obtener los grupos musculares desde la base de datos
  Future<void> loadMuscleGroups() async {
    final db = await openDatabase(
        'my_database.db'); // Asegúrate de tener la ruta correcta de la base de datos
    final List<Map<String, dynamic>> result =
        await db.query('grupos_musculares');

    // Inicializar selectedGroups y hintColors con los grupos musculares obtenidos
    setState(() {
      selectedGroups = {for (var row in result) row['nombre']: false};
      hintColors = {for (var row in result) row['nombre']: Colors.white};
      groupIds = {for (var row in result) row['nombre']: row['id']};
    });
  }

  // Cargar el cliente más reciente desde la base de datos
  Future<void> _loadMostRecentClient() async {
    final dbHelper = DatabaseHelper();
    final client = await dbHelper.getMostRecentClient();

    if (client != null) {
      setState(() {
        selectedClient = client;
        _indexController.text = client['id'].toString();
        _nameController.text = client['name'] ?? '';
        selectedOption = client['status'];
      });
    }
  }

// Función para insertar la relación entre cliente y grupos musculares
  Future<void> insertClientGroups(
      int clienteId, List<int> grupoMuscularIds) async {
    // Variable para acumular el éxito de las inserciones
    bool allSuccess = true;

    // Imprimir los datos antes de intentar insertar las relaciones
    print(
        "Intentando insertar relaciones: Cliente ID: $clienteId, Grupos Musculares IDs: $grupoMuscularIds");

    // Recorrer la lista de grupos musculares e insertar cada uno
    for (int grupoMuscularId in grupoMuscularIds) {
      bool success =
          await dbHelper.insertClientGroup(clienteId, grupoMuscularId);

      if (!success) {
        allSuccess = false; // Si alguna inserción falla, cambiamos el estado
        break; // Salimos del bucle si alguna inserción falla
      }
    }

    // Mostrar el SnackBar solo una vez, dependiendo del resultado final
    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Grupos añadidos correctamente",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No se han podido añadir todos los grupos",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Crear el checkbox redondo personalizado
  Widget customCheckbox(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Asegurarte de que selectedGroups[option] no sea null, lo inicializas como false si es nulo
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

  // Función para manejar clic en TextField
  void handleTextFieldTap(String option) {
    setState(() {
      selectedGroups[option] = !selectedGroups[option]!;
      hintColors[option] =
          selectedGroups[option]! ? const Color(0xFF2be4f3) : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.03,
            horizontal: screenWidth * 0.03), // Ajustar el padding
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Primer contenedor para el primer row de inputs
                  Container(
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
                                      color: Colors.white, fontSize: 14),
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
                                      color: Colors.white, fontSize: 14),
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
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    value: selectedOption,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Activo',
                                        child: Text(
                                          'Activo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Inactivo',
                                        child: Text(
                                          'Inactivo',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
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
                  SizedBox(height: screenHeight * 0.05),
                  // Segundo contenedor para el segundo row de inputs
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sección vacía
                        Expanded(
                          child: ListView(
                            children: [
                              // Crear una lista con los grupos que quieres mostrar explícitamente
                              'Trapecios',
                              'Dorsales',
                              'Lumbares',
                              'Glúteos',
                              'Isquios',
                              // Añadir aquí solo los grupos que deseas mostrar
                            ].map((group) {
                              return Padding(
                                padding:  EdgeInsets.only(bottom: screenHeight*0.02),
                                child: Row(
                                  children: [
                                    customCheckbox(group),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => handleTextFieldTap(group),
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
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: group,
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
                                                    fontSize: 14,
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
                              // Iterar sobre los grupos seleccionados y mostrar las imágenes correspondientes
                              ...selectedGroups.entries
                                  .where((entry) =>
                                      [
                                        'Trapecios',
                                        'Dorsales',
                                        'Lumbares',
                                        'Glúteos',
                                        'Isquios',
                                        'Gemelos'
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Filtra solo los grupos seleccionados
                                  .map((entry) {
                                String groupName = entry.key;
                                String imagePath =
                                    'assets/images/$groupName.png'; // Ruta de la imagen correspondiente

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
                              }).toList(),
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
                                          'assets/images/avatar_front.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Iterar sobre los grupos seleccionados y mostrar las imágenes correspondientes
                              ...selectedGroups.entries
                                  .where((entry) =>
                                      [
                                        'Pectorales',
                                        'Abdominales',
                                        'Cuádriceps',
                                        'Bíceps'
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Filtra solo los grupos seleccionados
                                  .map((entry) {
                                String groupName = entry.key;
                                String imagePath =
                                    'assets/images/$groupName.png'; // Ruta de la imagen correspondiente

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
                              }).toList(),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView(
                            children: [
                              // Crear una lista con los grupos que quieres mostrar explícitamente
                              'Pectorales',
                              'Abdominales',
                              'Cuádriceps',
                              'Bíceps',
                              'Gemelos',
                              // Añadir aquí solo los grupos que deseas mostrar
                            ].map((group) {
                              return Padding(
                                padding:  EdgeInsets.only(bottom: screenHeight*0.02),
                                child: Row(
                                  children: [
                                    customCheckbox(group),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => handleTextFieldTap(group),
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
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: group,
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
                                                    fontSize: 14,
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
                          ),
                        ),
                      ],
                    ),
                  ),
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
                    onTap: () async {
                      // Crear una lista para los IDs de los grupos seleccionados
                      List<int> selectedGroupIds = [];

                      // Recoger los grupos seleccionados
                      for (var groupName in selectedGroups.keys) {
                        if (selectedGroups[groupName] == true) {
                          int grupoMuscularId = groupIds[groupName]!;
                          selectedGroupIds.add(grupoMuscularId);
                        }
                      }

                      // Verificar si hay grupos seleccionados antes de intentar la inserción
                      if (selectedGroupIds.isNotEmpty) {
                        int clienteId =
                            selectedClient!['id']; // Obtener el ID del cliente
                        await insertClientGroups(clienteId, selectedGroupIds);
                        widget.onClose();
                      } else {
                        // Si no hay grupos seleccionados, mostrar un mensaje informativo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No se han seleccionado grupos musculares",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
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