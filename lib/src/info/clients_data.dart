import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../db/db_helper.dart';

class ClientsData extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> clientData;

  const ClientsData({
    Key? key,
    required this.onDataChanged,
    required this.clientData,
  }) : super(key: key);

  @override
  _ClientsDataState createState() => _ClientsDataState();
}

class _ClientsDataState extends State<ClientsData> {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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

  Future<void> _deleteClients(BuildContext context, int clientId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF494949),
          // Color de fondo del diálogo
          title: const Text(
            'Confirmar Borrado',
            style: TextStyle(
                color: Color(0xFF2be4f3),
                fontSize: 28,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Color del texto
          ),
          content: const Text(
            '¿Estás seguro de que quieres borrar este cliente?',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center, // Color del texto
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Cierra el diálogo sin hacer nada
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0xFF2be4f3)), // Color del borde
                  ),
                  child: const Text(
                    'CANCELAR',
                    style:
                        TextStyle(color: Color(0xFF2be4f3)), // Color del texto
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    DatabaseHelper dbHelper = DatabaseHelper();
                    await dbHelper.deleteClient(clientId); // Borrar cliente

                    // Mostrar Snackbar de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Cliente borrado correctamente",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 4),
                      ),
                    );

                    // Cierra el diálogo después de confirmar el borrado
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Colors.red), // Color del borde
                  ),
                  child: const Text(
                    '¡SÍ, ESTOY SEGURO!',
                    style: TextStyle(color: Colors.red), // Color del texto
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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
                  const SizedBox(height: 2),
                  // Segundo contenedor para el segundo row de inputs
                  SizedBox(
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('GÉNERO',
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
                                  value: selectedGender,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Hombre',
                                        child: Text('Hombre',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                    DropdownMenuItem(
                                        value: 'Mujer',
                                        child: Text('Mujer',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  dropdownColor: const Color(0xFF313030),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF2be4f3), size: 30),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text('FECHA DE NACIMIENTO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF313030),
                                      borderRadius: BorderRadius.circular(7)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Text(_birthDate ?? 'DD/MM/YYYY',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text('TELÉFONO',
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
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                        SizedBox(width: screenWidth * 0.1),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ALTURA (cm)',
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
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                              const SizedBox(height: 5),
                              const Text('PESO (kg)',
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
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                              const SizedBox(height: 5),
                              const Text('E-MAIL',
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
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s'))
                                  ],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorRemove = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorRemove = 1.0),
                    onTap: () {
                      _deleteClients(context, clientId!);
                    },
                    child: AnimatedScale(
                      scale: scaleFactorRemove,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.08,
                        height: screenHeight * 0.08,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/papelera.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () {
                      _updateData(); // Llama a la función pasando el ID
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
