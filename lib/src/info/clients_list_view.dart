import 'package:flutter/material.dart';

import '../customs/table_custom.dart';

class ClientListView extends StatefulWidget {
  final Function(Map<String, String>) onClientTap; // Agregar callback

  const ClientListView({super.key, required this.onClientTap});

  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final TextEditingController _clientIndexController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  String? selectedOption;

  void _showPrint(Map<String, String> clientData) {
    _updateClientFields(clientData);
    widget.onClientTap(clientData); // Invocar el callback
  }

  void _updateClientFields(Map<String, String> clientData) {
    setState(() {
      _clientIndexController.text = clientData['id'] ?? '';
      _clientNameController.text = clientData['name'] ?? '';
      selectedOption = clientData['status']; // Actualiza el estado seleccionado
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
                  style: const TextStyle(color: Colors.white), // Color del texto
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF313030), // Color de fondo
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02), // Espaciado
              Expanded(
                child: TextField(
                  controller: _clientNameController,
                  enabled: false,
                  style: const TextStyle(color: Colors.white), // Color del texto
                  decoration: const InputDecoration(
                    labelText: 'NOMBRE',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFF313030), // Color de fondo
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.07), // Espaciado
              Container(
                alignment: Alignment.center,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  color: Color(0xFF313030), // Fondo negro
                  borderRadius: BorderRadius.circular(7), // Bordes redondeados
                ),
                child: DropdownButton<String>(
                  hint: const Text(
                    'Activo',
                    style: TextStyle(color: Colors.white, fontSize: 20), // Color y tamaño del hint
                  ),
                  value: selectedOption,
                  // Asigna el valor seleccionado
                  items: const [
                    DropdownMenuItem(
                      value: 'Activo',
                      child: Text(
                        'Activo',
                        style: TextStyle(color: Colors.white, fontSize: 20), // Color y tamaño del texto
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Inactivo',
                      child: Text(
                        'Inactivo',
                        style: TextStyle(color: Colors.white, fontSize: 20), // Color y tamaño del texto
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value; // Almacena el valor seleccionado
                    });
                  },
                  dropdownColor: const Color(0xFF313030),
                  // Color del menú desplegable
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF2be4f3),
                    size: 50,
                  ), // Ícono en blanco
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          Container(
            height: screenHeight * 0.4, // Aumentar la altura del contenedor
            width: screenWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                // Habilitar el desplazamiento
                child: DataTableWidget(
                  data: const [
                    {'id': '1', 'name': 'Cliente A', 'phone': '123456789', 'status': 'Activo'},
                    {'id': '2', 'name': 'Cliente B', 'phone': '987654321', 'status': 'Inactivo'},
                    {'id': '3', 'name': 'Cliente C', 'phone': '555555555', 'status': 'Activo'},
                    // Puedes agregar más datos aquí para probar el desplazamiento
                    {'id': '4', 'name': 'Cliente D', 'phone': '654321789', 'status': 'Activo'},
                    {'id': '5', 'name': 'Cliente E', 'phone': '321456987', 'status': 'Inactivo'},
                    {'id': '6', 'name': 'Cliente F', 'phone': '987123654', 'status': 'Activo'},
                    {'id': '7', 'name': 'Cliente G', 'phone': '147258369', 'status': 'Inactivo'},
                  ],
                  onRowTap: _showPrint, // Llama a la función al pulsar sobre la fila
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
