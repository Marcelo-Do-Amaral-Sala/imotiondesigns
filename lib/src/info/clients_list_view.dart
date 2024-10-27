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
    {'id': '1', 'name': 'Cliente A', 'phone': '123456789', 'status': 'Activo'},
    {'id': '2', 'name': 'Cliente B', 'phone': '987654321', 'status': 'Inactivo'},
    {'id': '3', 'name': 'Cliente C', 'phone': '555555555', 'status': 'Activo'},
    {'id': '4', 'name': 'Cliente D', 'phone': '654321789', 'status': 'Activo'},
    {'id': '5', 'name': 'Cliente E', 'phone': '321456987', 'status': 'Inactivo'},
    {'id': '6', 'name': 'Cliente F', 'phone': '987123654', 'status': 'Activo'},
    {'id': '7', 'name': 'Cliente G', 'phone': '147258369', 'status': 'Inactivo'},
  ];

  // Lista que se muestra filtrada
  List<Map<String, String>> filteredClients = [];

  @override
  void initState() {
    super.initState();
    filteredClients = allClients; // Inicialmente muestra todos los clientes

    // Agrega listener para el campo de nombre
    _clientNameController.addListener(_filterClients);
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();

      // Filtra solo si hay texto en el campo de nombre o una opción seleccionada en el dropdown
      if (searchText.isNotEmpty || selectedOption != null) {
        filteredClients = allClients.where((client) {
          final matchesName = client['name']!.toLowerCase().contains(searchText);
          final matchesStatus = selectedOption == null || client['status'] == selectedOption;
          return matchesName && matchesStatus;
        }).toList();
      } else {
        filteredClients = allClients; // Mostrar todos los clientes si no hay filtros
      }
    });
  }

  void _showPrint(Map<String, String> clientData) {
    _updateClientFields(clientData);
    widget.onClientTap(clientData);
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
                child: TextField(
                  controller: _clientIndexController,
                  enabled: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF313030),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: TextField(
                  controller: _clientNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'NOMBRE',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF313030),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.07),
              Container(
                alignment: Alignment.center,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Color(0xFF313030),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: DropdownButton<String>(
                  hint: const Text(
                    'Estado',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  value: selectedOption,
                  items: const [
                    DropdownMenuItem(
                      value: 'Activo',
                      child: Text(
                        'Activo',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Inactivo',
                      child: Text(
                        'Inactivo',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value;
                      _filterClients(); // Llamar al filtro al cambiar el dropdown
                    });
                  },
                  dropdownColor: const Color(0xFF313030),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF2be4f3),
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Container(
            height: screenHeight * 0.4,
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
