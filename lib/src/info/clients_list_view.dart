import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/clients_table_custom.dart';
import '../db/db_helper.dart';

class ClientListView extends StatefulWidget {
  final Function(Map<String, dynamic>) onClientTap; // Cambia el tipo a dynamic para incluir int

  const ClientListView({Key? key, required this.onClientTap}) : super(key: key);

  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final TextEditingController _clientIndexController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  String selectedOption = 'Todos'; // Valor predeterminado

  List<Map<String, dynamic>> allClients = []; // Lista original de clientes
  List<Map<String, dynamic>> filteredClients = []; // Lista filtrada

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _clientNameController.addListener(_filterClients);
    _clientIndexController.addListener(_filterClients);
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        allClients = clientData; // Asigna a la lista original
        filteredClients = allClients; // Inicializa la lista filtrada
      });
      _filterClients(); // Filtra para mostrar todos los clientes
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();
      String indexText = _clientIndexController.text;

      filteredClients = allClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        final matchesIndex = indexText.isEmpty || client['id'].toString() == indexText;

        // Filtra por estado basado en la selección del dropdown
        final matchesStatus = selectedOption == 'Todos' || client['status'] == selectedOption;

        return matchesName && matchesIndex && matchesStatus;
      }).toList();
    });
  }

  void _showPrint(Map<String, dynamic> clientData) {
    _updateClientFields(clientData);
    // Asegúrate de que los datos se pasen correctamente como Map<String, String>
    widget.onClientTap(clientData.map((key, value) => MapEntry(key, value.toString())));
    debugPrint('Client Data: ${clientData.toString()}'); // Imprime todos los datos del cliente
  }


  void _updateClientFields(Map<String, dynamic> clientData) {
    setState(() {
      _clientIndexController.text = clientData['id'].toString();
      _clientNameController.text = clientData['name'] ?? '';
      selectedOption = clientData['status'] ?? 'Todos'; // Cambiar a 'Todos' si es nulo
    });
  }
  // Método para llamar al deleteDatabaseFile
  Future<void> _deleteDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteDatabaseFile();  // Elimina la base de datos
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Base de datos eliminada con éxito.'),
    ));
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
              ElevatedButton(
                onPressed: _deleteDatabase,  // Llama al método que elimina la base de datos
                child: Text('Eliminar Base de Datos'),
              ),
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
              value: selectedOption,
              items: const [
                DropdownMenuItem(
                    value: 'Todos',
                    child: Text('Todos',
                        style: TextStyle(color: Colors.white, fontSize: 12))),
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
                  selectedOption = value!;
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
          onRowTap: (clientData) {
            _showPrint(clientData); // Asegúrate de que se pase el cliente correcto
          },
        ),
      ),
    );
  }
}
