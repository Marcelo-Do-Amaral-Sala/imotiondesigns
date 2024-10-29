// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../customs/table_custom.dart';

class ClientListView extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;

  const ClientListView({super.key, required this.onClientTap});

  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final TextEditingController _clientIndexController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  String? selectedOption;

  // Lista completa de clientes
  List<Map<String, String>> allClients = [
     {
      'id': '1',
      'name': 'Cliente A',
      'email': 'clientea@gmail.com',
      'gender': 'Mujer',
      'height': '167',
      'weight': '49',
      'birthDate': '12/02/1994',
      'phone': '987654556',
      'status': 'Inactivo'
    },
    {
      'id': '2',
      'name': 'Cliente B',
      'email': 'clienteb@gmail.com',
      'gender': 'Hombre',
      'height': '187',
      'weight': '89',
      'birthDate': '12/09/1990',
      'phone': '987654321',
      'status': 'Inactivo'
    },
    {
      'id': '3',
      'name': 'Cliente C',
      'email': 'clientec@gmail.com',
      'gender': 'Hombre',
      'height': '180',
      'weight': '79',
      'birthDate': '22/09/1980',
      'phone': '666654321',
      'status': 'Activo'
    },
    {
      'id': '4',
      'name': 'Cliente D',
      'email': 'cliented@gmail.com',
      'gender': 'Hombre',
      'height': '177',
      'weight': '71',
      'birthDate': '11/01/2000',
      'phone': '987652221',
      'status': 'Activo'
    },
    {
      'id': '5',
      'name': 'Cliente E',
      'email': 'clientee@gmail.com',
      'gender': 'Mujer',
      'height': '147',
      'weight': '49',
      'birthDate': '19/12/2004',
      'phone': '987612321',
      'status': 'Inactivo'
    },

  ];

  // Lista que se muestra filtrada
  List<Map<String, String>> filteredClients = [];

  @override
  void initState() {
    super.initState();
    filteredClients = allClients; // Inicialmente muestra todos los clientes

    // Agrega listener para los campos de nombre e índice
    _clientNameController.addListener(_filterClients);
    _clientIndexController.addListener(_filterClients); // Agrega este listener
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();
      String indexText = _clientIndexController.text;

      // Filtra solo si hay texto en el campo de nombre, índice o una opción seleccionada en el dropdown
      filteredClients = allClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        final matchesIndex = indexText.isEmpty ||
            client['id'] == indexText; // Cambia 'index' a 'id'
        final matchesStatus =
            selectedOption == null || client['status'] == selectedOption;
        return matchesName && matchesIndex && matchesStatus;
      }).toList();
    });
  }

  void _showPrint(Map<String, String> clientData) {
    _updateClientFields(clientData);
    widget.onClientTap(clientData);
    print('Client Data: $clientData');

  }

  void _updateClientFields(Map<String, String> clientData) {
    setState(() {
      _clientIndexController.text = clientData['id'] ?? '';
      _clientNameController.text = clientData['name'] ?? '';
      selectedOption = clientData['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ID',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _clientIndexController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF313030),
                        isDense: true, // Compactar el campo
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
                    const Text(
                      'NOMBRE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _clientNameController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF313030),
                        isDense: true, // Compactar el campo
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
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Seleccione',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        value: selectedOption,
                        items: const [
                          DropdownMenuItem(
                            value: 'Activo',
                            child: Text(
                              'Activo',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Inactivo',
                            child: Text(
                              'Inactivo',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                            _filterClients();
                          });
                        },
                        dropdownColor: const Color(0xFF313030),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF2be4f3),
                          size: 30, // Reducir tamaño del icono
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Container(
            height: screenHeight * 0.45,
            width: screenWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: DataTableWidget(
                  data: filteredClients,
                  onRowTap: _showPrint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
