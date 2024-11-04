import 'package:flutter/material.dart';

import '../db/db_helper.dart';

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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? selectedOption;
  String? selectedGender;
  String? _birthDate;
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;
  int? clientId; // Declare a variable to store the client ID

  @override
  void initState() {
    super.initState();
    clientId = int.tryParse(widget.clientData['id'].toString());
    _indexController.text = clientId.toString(); // Set controller text
    _refreshControllers(); // Load initial data from the database
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateData() async {
    // Ensure all required fields are filled
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        selectedGender == null ||
        selectedOption == null ||
        _birthDate == null ||
        clientId == null) {
      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor, complete todos los campos.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return; // Exit method if there are empty fields
    }

    final clientData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': int.tryParse(_phoneController.text),
      'height': int.tryParse(_heightController.text), // Convert to int
      'weight': int.tryParse(_weightController.text), // Convert to int
      'gender': selectedGender,
      'status': selectedOption,
      'birthdate': _birthDate,
    };

    // Update in the database
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.updateClient(
        clientId!, clientData); // Pass the ID and client data

    // Print updated data
    print('Datos del cliente actualizados: $clientData');

    // Refresh the text controllers with the updated data
    await _refreshControllers();

    // Show success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Cliente actualizado correctamente",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF2be4f3),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _refreshControllers() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Fetch the updated client data from the database
    Map<String, dynamic>? updatedClientData = await dbHelper
        .getClientById(clientId!); // Create this method in your DatabaseHelper

    if (updatedClientData != null) {
      setState(() {
        _nameController.text = updatedClientData['name'] ?? '';
        _emailController.text = updatedClientData['email'] ?? '';
        _phoneController.text = updatedClientData['phone'].toString() ?? '';
        _heightController.text = updatedClientData['height']?.toString() ?? '';
        _weightController.text = updatedClientData['weight']?.toString() ?? '';
        selectedGender = updatedClientData['gender'];
        selectedOption = updatedClientData['status'];
        _birthDate = updatedClientData['birthdate'];
      });
    }
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
                              const Text('ESTADO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color(0xFF313030),
                                    borderRadius: BorderRadius.circular(7)),
                                child: DropdownButton<String>(
                                  hint: const Text('Seleccione',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  value: selectedOption,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Activo',
                                        child: Text('Activo',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                    DropdownMenuItem(
                                        value: 'Inactivo',
                                        child: Text('Inactivo',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value;
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
                  ),
                  const SizedBox(height: 10),
                  // Segundo contenedor para el segundo row de inputs
                  Container(
                    color: Colors.blue,
                    width: screenWidth,
                    height: screenHeight * 0.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sección vacía
                        Expanded(
                            child: Container(
                          color: Colors.yellow,
                          child: Column(
                            children: [
                              // Primer RadioButton con TextField
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'option1',
                                    groupValue: null,
                                    onChanged: (String? value) {
                                      // Manejar el cambio
                                    },
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              filled: true,
                                              fillColor:
                                                  const Color(0xFF313030),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              // Espacio entre los widgets
                              // Segundo RadioButton con TextField
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'option2',
                                    groupValue: null,
                                    onChanged: (String? value) {
                                      // Manejar el cambio
                                    },
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              filled: true,
                                              fillColor:
                                                  const Color(0xFF313030),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              // Espacio entre los widgets
                              // Tercer RadioButton con TextField
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'option3',
                                    groupValue: null,
                                    onChanged: (String? value) {
                                      // Manejar el cambio
                                    },
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              filled: true,
                                              fillColor:
                                                  const Color(0xFF313030),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              // Espacio entre los widgets
                              // Cuarto RadioButton con TextField
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'option4',
                                    groupValue: null,
                                    onChanged: (String? value) {
                                      // Manejar el cambio
                                    },
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0xFF313030),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextField(
                                            controller: _nameController,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              filled: true,
                                              fillColor:
                                                  const Color(0xFF313030),
                                              isDense: true,
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
                        )),

                        // Contenedor para la primera imagen (imagen de fondo)
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/avatar_back.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Contenedor para la segunda imagen (imagen frontal)
                        Expanded(
                          flex: 1,
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

                        // Sección vacía
                        Expanded(child: Container(color: Colors.green)),
                        // Segunda sección vacía
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
                    onTap: _updateData,
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
