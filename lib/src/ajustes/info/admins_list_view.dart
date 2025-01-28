import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/custom/admins_table_widget.dart';
import '../../../utils/translation_utils.dart';
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
  String selectedTipo = 'Todos'; // Valor predeterminado

  List<Map<String, dynamic>> allAdmins = []; // Lista original de clientes
  List<Map<String, dynamic>> filteredAdmins = []; // Lista filtrada

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
    _adminNameController.addListener(_filterAdmins);
  }

  @override
  void dispose() {
    _adminNameController.removeListener(_filterAdmins);
    super.dispose();
  }


  Future<void> _fetchAdmins() async {
    final dbHelper = DatabaseHelper();
    try {
      // Obtener los usuarios cuyo perfil es "Administrador" o "Ambos"
      final adminData =
          await dbHelper.getUsuariosPorTipoPerfil('Administrador');
      final adminDataEntrenador =
          await dbHelper.getUsuariosPorTipoPerfil('Entrenador');
      // También podemos obtener usuarios con el tipo de perfil 'Ambos' si es necesario
      final adminDataAmbos = await dbHelper.getUsuariosPorTipoPerfil('Ambos');

      // Combina ambas listas
      final allAdminData = [
        ...adminData,
        ...adminDataAmbos,
        ...adminDataEntrenador
      ];

      setState(() {
        allAdmins = allAdminData; // Asigna los usuarios filtrados
        filteredAdmins = allAdmins; // Inicializa la lista filtrada
      });

      _filterAdmins(); // Llama al filtro si es necesario
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  Future<void> _filterAdmins() async {
    String searchText = _adminNameController.text.toLowerCase();
    final dbHelper = DatabaseHelper();
    try {
      // Lista base para los filtros
      List<Map<String, dynamic>> admins;

      // Si el filtro de tipo no es 'Ambos', consulta la base de datos
      if (selectedTipo != 'Todos') {
        admins = await dbHelper.getUsuariosPorTipoPerfil(selectedTipo);
      } else {
        // Usa todos los administradores si no se filtra por tipo
        admins = List<Map<String, dynamic>>.from(allAdmins);
      }

      // Filtra por nombre
      admins = admins.where((admin) {
        final matchesName = admin['name']!.toLowerCase().contains(searchText);
        final matchesStatus = selectedAdminOption == 'Todos' ||
            admin['status'] == selectedAdminOption;
        return matchesName && matchesStatus;
      }).toList();

      // Actualiza el estado con la lista filtrada
      setState(() {
        filteredAdmins = admins;
      });
    } catch (e) {
      print("Error al filtrar administradores: $e");
    }
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
      selectedTipo = adminData['tipo'] ?? 'Todos';
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
              _buildTextField(tr(context, 'Nombre').toUpperCase(),
                  _adminNameController, tr(context, 'Introducir nombre')),
              SizedBox(width: screenWidth * 0.02),
              _buildDropdown1(),
              SizedBox(width: screenWidth * 0.02),
              _buildDropdown2(),
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
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown1() {
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
              value: selectedAdminOption,
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
                  selectedAdminOption = value!;
                  _filterAdmins(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon: Icon(Icons.arrow_drop_down,
                  color: const Color(0xFF2be4f3), size: screenHeight * 0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown2() {
    double screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(context, 'Tipo').toUpperCase(),
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
              value: selectedTipo,
              items: [
                DropdownMenuItem(
                    value: 'Todos',
                    child: Text(tr(context, 'Todos'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Ambos',
                    child: Text(tr(context, 'Ambos'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Administrador',
                    child: Text(tr(context, 'Administrador'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Entrenador',
                    child: Text(tr(context, 'Entrenador'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTipo = value!;
                  _filterAdmins(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon: Icon(Icons.arrow_drop_down,
                  color: const Color(0xFF2be4f3), size: screenHeight * 0.05),
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
