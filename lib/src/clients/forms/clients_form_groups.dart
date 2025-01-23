import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/translation_utils.dart';
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
  Map<String, String> imagePaths = {};

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
      selectedGroups = {for (var row in result) row['nombre']: true};
      hintColors = {
        for (var row in result) row['nombre']: const Color(0xFF2be4f3)
      };
      groupIds = {for (var row in result) row['nombre']: row['id']};
      imagePaths = {for (var row in result) row['nombre']: row['imagen']};
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
        SnackBar(
          content: Text(
            tr(context, 'Grupos añadidos correctamente').toUpperCase(),
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
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
        width: MediaQuery.of(context).size.width * 0.03,
        height: MediaQuery.of(context).size.height * 0.03,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr(context, 'Nombre').toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold)),
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF313030),
                                  borderRadius: BorderRadius.circular(7)),
                              child: TextField(
                                controller: _nameController,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp),
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
                      SizedBox(width: screenWidth * 0.05),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr(context, 'Estado').toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
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
                                  hint: Text(
                                    tr(context, 'Seleccione'),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.sp),
                                  ),
                                  value: selectedOption,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'Activo',
                                      child: Text(
                                        tr(context, 'Activo'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Inactivo',
                                      child: Text(
                                        tr(context, 'Inactivo'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                  onChanged: null,
                                  // Asegura que no se pueda cambiar el valor
                                  dropdownColor: const Color(0xFF313030),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF2be4f3),
                                    size: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                              'Isquiotibiales',
                            ].map((group) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.01),
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
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: group,
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
                                                    fontSize: 14.sp,
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
                                        'Isquiotibiales',
                                        'Gemelos'
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Filtra solo los grupos seleccionados
                                  .map((entry) {
                                String groupName = entry.key;

                                // Obtener la ruta de la imagen desde imagePaths (con la extensión)
                                String? imagePath = imagePaths[groupName];

                                // Si la ruta no está definida, asignamos una imagen predeterminada
                                imagePath ??= 'assets/images/default_image.png';

                                // Cargar la imagen con la ruta completa, incluyendo la extensión
                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        // Usar la ruta completa con extensión
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
                                        'Abdomen',
                                        'Cuádriceps',
                                        'Bíceps'
                                      ].contains(entry.key) &&
                                      entry
                                          .value) // Filtra solo los grupos seleccionados
                                  .map((entry) {
                                String groupName = entry.key;

                                // Obtener la ruta de la imagen desde imagePaths (con la extensión)
                                String? imagePath = imagePaths[groupName];

                                // Si la ruta no está definida, asignamos una imagen predeterminada
                                imagePath ??= 'assets/images/default_image.png';

                                // Cargar la imagen con la ruta completa, incluyendo la extensión
                                return Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(imagePath),
                                        // Usar la ruta completa con extensión
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
                              'Abdomen',
                              'Cuádriceps',
                              'Bíceps',
                              'Gemelos',
                            ].map((group) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: screenHeight * 0.01),
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
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: group,
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
                                                    fontSize: 14.sp,
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
            SizedBox(height: screenHeight * 0.01),
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
