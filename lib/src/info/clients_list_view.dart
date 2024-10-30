import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/clients_table_custom.dart';
import '../db/db_helper.dart'; // Asegúrate de importar tu DatabaseHelper

class ClientListView extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;

  const ClientListView({Key? key, required this.onClientTap}) : super(key: key);

  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final TextEditingController _clientIndexController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  String? selectedOption;

  // Lista que se muestra filtrada
  List<Map<String, dynamic>> filteredClients = [];

  @override
  void initState() {
    super.initState();
    _fetchClients(); // Cargar los clientes al iniciar
    // Agrega listener para los campos de nombre e índice
    _clientNameController.addListener(_filterClients);
    _clientIndexController.addListener(_filterClients);
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        filteredClients = clientData; // Asignar a la lista filtrada
      });
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();
      String indexText = _clientIndexController.text;

      filteredClients = filteredClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        final matchesIndex = indexText.isEmpty || client['id'].toString() == indexText;
        final matchesStatus = selectedOption == null || client['status'] == selectedOption;
        return matchesName && matchesIndex && matchesStatus;
      }).toList();
    });
  }

  void _showPrint(Map<String, dynamic> clientData) {
    _updateClientFields(clientData);
    widget.onClientTap(clientData.map((key, value) => MapEntry(key, value.toString()))); // Asegura que todos los valores sean cadenas
    debugPrint('Client Data: $clientData');
  }

  void _updateClientFields(Map<String, dynamic> clientData) {
    setState(() {
      _clientIndexController.text = clientData['id'].toString();
      _clientNameController.text = clientData['name'] ?? '';
      selectedOption = clientData['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextField('ID', _clientIndexController, 'Ingrese ID'),
              SizedBox(width: screenWidth * 0.02),
              _buildTextField('NOMBRE', _clientNameController, 'Ingrese nombre'),
              SizedBox(width: screenWidth * 0.02),
              _buildDropdown(),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          _buildDataTable(screenHeight, screenWidth),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Expanded(
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
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              hint: const Text('Seleccione',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              value: selectedOption,
              items: const [
                DropdownMenuItem(
                    value: 'Activo',
                    child: Text('Activo',
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                DropdownMenuItem(
                    value: 'Inactivo',
                    child: Text('Inactivo',
                        style: TextStyle(color: Colors.white, fontSize: 12))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value;
                  _filterClients(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF2be4f3), size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.45,
      width: screenWidth,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 46, 46, 46),
        borderRadius: BorderRadius.circular(7.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DataTableWidget(
          data: filteredClients,
          onRowTap: _showPrint,
        ),
      ),
    );
  }
}
