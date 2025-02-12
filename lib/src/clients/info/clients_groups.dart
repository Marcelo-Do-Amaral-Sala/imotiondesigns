import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

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
  Map<String, dynamic>? selectedClient;

  Map<String, bool> selectedGroups = {};
  Map<String, Color> hintColors = {};
  Map<String, int> groupIds = {};
  Map<String, String> imagePaths = {};

  int? clientId; // Declare a variable to store the client ID

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    clientId = int.tryParse(widget.clientData['id'].toString());
    _indexController.text = clientId.toString(); // Set controller text
    loadMuscleGroups();
    _loadClientById(); // Llamar al método para cargar los grupos musculares
  }

  @override
  void dispose() {
    // Liberar los controladores de texto
    _indexController.dispose();
    _nameController.dispose();

    // Limpiar mapas, si contienen datos pesados o referencias que podrían mantenerse
    selectedGroups.clear();
    hintColors.clear();
    groupIds.clear();
    imagePaths.clear();

    // Llamar al método base para liberar otros recursos
    super.dispose();
  }


// Obtener los IDs de los grupos seleccionados
  List<int> getSelectedGroupIds() {
    List<int> selectedGroupIds = [];
    selectedGroups.forEach((groupName, isSelected) {
      if (isSelected) {
        selectedGroupIds.add(groupIds[
            groupName]!); // Añadir el ID del grupo si está seleccionado
      }
    });
    return selectedGroupIds;
  }

  // Función para actualizar los grupos musculares del cliente
  Future<void> updateClientGroups() async {
    List<int> selectedGroupIds =
        getSelectedGroupIds(); // Obtener los IDs de los grupos seleccionados

    // Llamar al método en DatabaseHelper para actualizar la relación en la tabla
    await dbHelper.updateClientGroups(clientId!, selectedGroupIds);

    // Imprimir los grupos actualizados
    print("Grupos musculares actualizados para el cliente $clientId:");
    selectedGroupIds.forEach((groupId) {
      final groupName =
          groupIds.keys.firstWhere((key) => groupIds[key] == groupId);
      print("- $groupName (ID: $groupId)");
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'Grupos actualizados correctamente').toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
          ),
        ),
        backgroundColor: const Color(0xFF2be4f3),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> loadMuscleGroups() async {
    final db = await openDatabase('my_database.db');

    // 1. Obtener todos los grupos musculares disponibles
    final List<Map<String, dynamic>> result =
        await db.query('grupos_musculares');

    // 2. Obtener los grupos musculares asociados a este cliente
    final List<Map<String, dynamic>> clientGroupsResult = await db.rawQuery('''
    SELECT g.id, g.nombre
    FROM grupos_musculares g
    INNER JOIN clientes_grupos_musculares cg ON g.id = cg.grupo_muscular_id
    WHERE cg.cliente_id = ?
  ''', [clientId]);

    // Actualizar el estado de los grupos y sus colores
    setState(() {
      selectedGroups = {for (var row in result) row['nombre']: false};
      hintColors = {for (var row in result) row['nombre']: Colors.white};
      groupIds = {for (var row in result) row['nombre']: row['id']};
      imagePaths = {for (var row in result) row['nombre']: row['imagen']};

      // Marcar los grupos asociados al cliente como seleccionados
      for (var group in clientGroupsResult) {
        final groupName = group['nombre'];
        if (groupName != null) {
          selectedGroups[groupName] = true;
          hintColors[groupName] =
              const Color(0xFF2be4f3); // Color para los grupos seleccionados
        }
      }
    });

    // Imprimir los grupos asociados al cliente (clientGroupsResult)
    print("Grupos musculares asociados al cliente $clientId:");
    clientGroupsResult.forEach((group) {
      print("- ${group['nombre']} (ID: ${group['id']})");
    });
  }

// Método para cargar un cliente por ID desde la base de datos
  Future<void> _loadClientById() async {
    // Primero, obtenemos el clientId desde el _indexController
    final clientIdText = _indexController.text;

    if (clientIdText.isEmpty) {
      // Si el campo está vacío, mostramos un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor ingresa un ID de cliente'),
      ));
      return;
    }

    // Convertir el texto del TextEditingController en un entero (clientId)
    final int? clientId = int.tryParse(clientIdText);

    if (clientId == null) {
      // Si el clientId no es un número válido, mostramos un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ID de cliente no válido'),
      ));
      return;
    }

    // Buscar el cliente con el clientId
    final client = await dbHelper.getClientById(clientId);

    if (client != null) {
      setState(() {
        selectedClient = client;
        _indexController.text = client['id'].toString();
        _nameController.text = client['name'] ?? '';
        selectedOption = client['status'];
      });
    } else {
      // Si no se encuentra el cliente en la base de datos, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cliente no encontrado'),
      ));
    }
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
        width: MediaQuery.of(context).size.width * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.004,
          horizontal: MediaQuery.of(context).size.width * 0.004,
        ),
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
                                style:  TextStyle(
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
                                                style:  TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: tr(context, group),
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
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
                                if (imagePath == null) {
                                  imagePath = 'assets/images/default_image.png';
                                }

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
                                if (imagePath == null) {
                                  imagePath = 'assets/images/default_image.png';
                                }

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
                                                style:  TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
                                                ),
                                                textAlign: TextAlign.center,
                                                decoration: InputDecoration(
                                                  hintText: tr(context, group),
                                                  hintStyle: TextStyle(
                                                    color: hintColors[group],
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
                      await updateClientGroups();
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
