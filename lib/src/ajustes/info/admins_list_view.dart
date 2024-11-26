import 'package:flutter/material.dart';
import 'package:imotion_designs/src/ajustes/custom/admins_table_widget.dart';
import 'package:imotion_designs/src/clients/custom_clients/clients_table_custom.dart';

import '../../db/db_helper.dart';

class AdminsListView extends StatefulWidget {
  final Function(Map<String, dynamic>)
  onAdminTap; // Cambia el tipo a dynamic para incluir int

  const AdminsListView({Key? key, required this.onAdminTap}) : super(key: key);

  @override
  _AdminsListViewState createState() => _AdminsListViewState();
}

class _AdminsListViewState extends State<AdminsListView> {
  final TextEditingController _adminNameController = TextEditingController();
  String selectedAdminOption = 'Todos'; // Valor predeterminado

  List<Map<String, dynamic>> allAdmins = []; // Lista original de clientes
  List<Map<String, dynamic>> filteredAdmins = []; // Lista filtrada

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
    _adminNameController.addListener(_filterAdmins);
  }

  Future<void> _fetchAdmins() async {
    final dbHelper = DatabaseHelper();
    try {
      // Obtener los usuarios cuyo perfil es "Administrador" o "Ambos"
      final adminData = await dbHelper.getUsuariosPorTipoPerfil('Administrador');

      // También podemos obtener usuarios con el tipo de perfil 'Ambos' si es necesario
      final adminDataAmbos = await dbHelper.getUsuariosPorTipoPerfil('Ambos');

      // Combina ambas listas
      final allAdminData = [...adminData, ...adminDataAmbos];

      setState(() {
        allAdmins = allAdminData; // Asigna los usuarios filtrados
        filteredAdmins = allAdmins; // Inicializa la lista filtrada
      });

      _filterAdmins(); // Llama al filtro si es necesario
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }


 void _filterAdmins() {
    setState(() {
      String searchText = _adminNameController.text.toLowerCase();

      filteredAdmins = allAdmins.where((admin) {
        final matchesName = admin['name']!.toLowerCase().contains(searchText);
        // Filtra por estado basado en la selección del dropdown
        final matchesStatus =
            selectedAdminOption == 'Todos' || admin['status'] == selectedAdminOption;

        return matchesName &&  matchesStatus;
      }).toList();
    });
  }

  void _showPrint(Map<String, dynamic> adminData) {
    _updateAdminFields(adminData);
    // Asegúrate de que los datos se pasen correctamente como Map<String, String>
    widget.onAdminTap(
        adminData.map((key, value) => MapEntry(key, value.toString())));
    debugPrint(
        'Client Data: ${adminData.toString()}'); // Imprime todos los datos del cliente
  }

  void _updateAdminFields(Map<String, dynamic> adminData) {
    setState(() {
      _adminNameController.text = adminData['name'] ?? '';
      selectedAdminOption =
          adminData['status'] ?? 'Todos'; // Cambiar a 'Todos' si es nulo
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
                  'NOMBRE', _adminNameController, 'Ingrese nombre'),
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
              value: selectedAdminOption,
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
                  selectedAdminOption = value!;
                  _filterAdmins(); // Filtrar después de seleccionar
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
          child: AdminsTableWidget(
            data: filteredAdmins,
            onRowTap: (adminData) {
              _showPrint(
                  adminData); // Asegúrate de que se pase el cliente correcto
            },
          ),
        ),
      ),
    );
  }
}
