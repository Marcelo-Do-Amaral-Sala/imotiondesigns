import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/clients/custom_clients/clients_table_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';

class ClientListView extends StatefulWidget {
  final Function(Map<String, dynamic>)
      onClientTap; // Cambia el tipo a dynamic para incluir int

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

  @override
  void dispose() {
    // Removemos los listeners de los controladores
    _clientNameController.removeListener(_filterClients);
    _clientIndexController.removeListener(_filterClients);

    // Liberamos los controladores de texto
    _clientIndexController.dispose();
    _clientNameController.dispose();

    // Llamamos al método de la superclase para limpiar recursos adicionales
    super.dispose();
  }


  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();

    try {
      // Obtener el userId desde SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        // Manejar el caso de usuario no autenticado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: Usuario no autenticado',
              style: TextStyle(color: Colors.white, fontSize: 17.sp),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Obtener clientes: si userId es 1, mostrar todos; si no, filtrar por userId
      List<Map<String, dynamic>> clientData;
      if (userId == 1) {
        // Obtener todos los clientes sin filtrar
        clientData = await dbHelper.getClients();
      } else {
        // Obtener clientes asociados al usuario
        clientData = await dbHelper.getClientsByUserId(userId);
      }

      setState(() {
        allClients = clientData; // Asigna a la lista original
        filteredClients = allClients; // Inicializa la lista filtrada
      });

      _filterClients(); // Aplica cualquier filtrado adicional
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
        final matchesIndex =
            indexText.isEmpty || client['id'].toString() == indexText;

        // Filtra por estado basado en la selección del dropdown
        final matchesStatus =
            selectedOption == 'Todos' || client['status'] == selectedOption;

        return matchesName && matchesIndex && matchesStatus;
      }).toList();
    });
  }

  void _showPrint(Map<String, dynamic> clientData) {
    _updateClientFields(clientData);
    // Asegúrate de que los datos se pasen correctamente como Map<String, String>
    widget.onClientTap(
        clientData.map((key, value) => MapEntry(key, value.toString())));
    debugPrint(
        'Client Data: ${clientData.toString()}'); // Imprime todos los datos del cliente
  }

  void _updateClientFields(Map<String, dynamic> clientData) {
    setState(() {
      _clientIndexController.text = clientData['id'].toString();
      _clientNameController.text = clientData['name'] ?? '';
      selectedOption =
          clientData['status'] ?? 'Todos'; // Cambiar a 'Todos' si es nulo
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTextField(
                tr(context, 'Nombre').toUpperCase(),
                _clientNameController,
                tr(context, 'Introducir nombre'),
              ),
              SizedBox(width: screenWidth * 0.05),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextField(
              controller: controller,
              style:  TextStyle(color: Colors.white, fontSize: 12.sp),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
                hintText: hint,
                hintStyle:  TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(context, 'Estado').toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              value: selectedOption,
              items: [
                DropdownMenuItem(
                    value: 'Todos',
                    child: Text(tr(context, 'Todos'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Activo',
                    child: Text(tr(context, 'Activo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Inactivo',
                    child: Text(tr(context, 'Inactivo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  _filterClients(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon:  Icon(Icons.arrow_drop_down,
                  color: const Color(0xFF2be4f3), size: screenHeight*0.05),
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
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
          child: DataTableWidget(
            data: filteredClients,
            onRowTap: (clientData) {
              _showPrint(
                  clientData); // Asegúrate de que se pase el cliente correcto
            },
          ),
        ),
      ),
    );
  }
}
