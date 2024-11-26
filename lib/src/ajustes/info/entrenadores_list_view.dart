import 'package:flutter/material.dart';
import 'package:imotion_designs/src/ajustes/custom/admins_table_widget.dart';
import 'package:imotion_designs/src/ajustes/custom/entrenadores_table_widget.dart';
import 'package:imotion_designs/src/clients/custom_clients/clients_table_custom.dart';

import '../../db/db_helper.dart';

class EntrenadoresListView extends StatefulWidget {
  final Function(Map<String, dynamic>)
  onTrainerTap; // Cambia el tipo a dynamic para incluir int

  const EntrenadoresListView({Key? key, required this.onTrainerTap}) : super(key: key);

  @override
  _EntrenadoresListViewState createState() => _EntrenadoresListViewState();
}

class _EntrenadoresListViewState extends State<EntrenadoresListView> {
  final TextEditingController _trainerNameController = TextEditingController();
  String selectedOption = 'Todos'; // Valor predeterminado

  List<Map<String, dynamic>> allTrainers = []; // Lista original de clientes
  List<Map<String, dynamic>> filteredTrainers = []; // Lista filtrada

  @override
  void initState() {
    super.initState();
    //_fetchAdmins();
    //_adminNameController.addListener(_filterAdmins);
  }

/*  Future<void> _fetchAdmins() async {
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
  }*/

  /* void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();
      String indexText = _clientIndexController.text;

      filteredClients = allClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        final matchesIndex =
            indexText.isEmpty || client['id'].toString() == indexText;

        // Filtra por estado basado en la selección del dropdown
        final matchesStatus =
            selectedOption == 'Todos' || client['status'] == selectedOption;

        return matchesName && matchesIndex && matchesStatus;
      }).toList();
    });
  }
*/
  void _showPrint(Map<String, dynamic> trainerData) {
    _updateTrainerFields(trainerData);
    // Asegúrate de que los datos se pasen correctamente como Map<String, String>
    widget.onTrainerTap(
        trainerData.map((key, value) => MapEntry(key, value.toString())));
    debugPrint(
        'Client Data: ${trainerData.toString()}'); // Imprime todos los datos del cliente
  }

  void _updateTrainerFields(Map<String, dynamic> trainerData) {
    setState(() {
      _trainerNameController.text = trainerData['name'] ?? '';
      selectedOption =
          trainerData['status'] ?? 'Todos'; // Cambiar a 'Todos' si es nulo
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
              _buildTextField(
                  'NOMBRE', _trainerNameController, 'Ingrese nombre'),
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

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
                  fontSize: 14,
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
                        style: TextStyle(color: Colors.white, fontSize: 14))),
                DropdownMenuItem(
                    value: 'Activo',
                    child: Text('Activo',
                        style: TextStyle(color: Colors.white, fontSize: 14))),
                DropdownMenuItem(
                    value: 'Inactivo',
                    child: Text('Inactivo',
                        style: TextStyle(color: Colors.white, fontSize: 14))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  //_filterClients(); // Filtrar después de seleccionar
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
    return Flexible(
      // Flexible permite que el Container ocupe una fracción del espacio disponible
      flex: 1,
      // Este valor define cuánta parte del espacio disponible debe ocupar el widget
      child: Container(
        width: screenWidth, // Mantiene el ancho completo de la pantalla
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: EntrenadoresTableWidget(
            data: filteredTrainers,
            onRowTap: (trainerData) {
              _showPrint(
                  trainerData); // Asegúrate de que se pase el cliente correcto
            },
          ),
        ),
      ),
    );
  }
}
