import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../clients/custom_clients/bonos_table_custom.dart';
import '../../db/db_helper.dart';


class UsersFormBonos extends StatefulWidget {
  final Map<String, dynamic> userDataBonos;

  const UsersFormBonos({super.key, required this.userDataBonos});

  @override
  _UsersFormBonosState createState() => _UsersFormBonosState();
}

class _UsersFormBonosState extends State<UsersFormBonos> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  final _bonosController = TextEditingController();
  String? selectedOption;
  int? userId; // Variable para almacenar el ID del cliente
  int? lastUserId;
  List<Map<String, String>> availableBonos = []; // Cambiar el tipo aquí
  List<Map<String, String>> consumedBonos = [];
  int totalBonosAvailables = 0; // Total de bonos disponibles
  Map<String, dynamic>? selectedUser;


  @override
  void initState() {
    super.initState();
    _loadMostRecentUser();
    if (userId != null) {
      _loadAvailableBonos(userId!);
    }
  }

  Future<void> _loadMostRecentUser() async {
    final dbHelper = DatabaseHelper();
    final user = await dbHelper.getMostRecentUser();

    if (user != null) {
      setState(() {
        selectedUser = user;
        lastUserId = user['id'];
        _indexController.text = lastUserId.toString();
        _nameController.text = user['name'] ?? '';
        selectedOption = user['status'];
      });

      if (lastUserId != null) {
        _loadAvailableBonos(lastUserId!);
      }
    }
  }
  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBonos(int userId) async {
    final dbHelper = DatabaseHelper();
    final bonosUser = await dbHelper.getAvailableBonosByUserId(userId);

    if (bonosUser.isEmpty) {
      print('No se encontraron bonos disponibles para el cliente $userId');
    }

    setState(() {
      availableBonos = bonosUser.where((bonoUser) {
        return bonoUser['estado'] == 'Disponible';
      }).map((bonoUser) {
        return {
          'date': bonoUser['fecha']?.toString() ?? '',
          // Aseguramos que 'fecha' sea String
          'quantity': bonoUser['cantidad']?.toString() ?? '',
          // Aseguramos que 'cantidad' sea String
        };
      }).toList();
    });
    // Recalcular el total de bonos
    totalBonosAvailables = _calculateTotalBonos(availableBonos);
  }

  int _calculateTotalBonos(List<Map<String, dynamic>> bonos) {
    return bonos.fold(0, (sum, bono) {
      return sum +
          (int.tryParse(bono['quantity']) ??
              0); // Garantizar que la cantidad sea int
    });
  }

  Future<void> _saveBonosUser(int userId, int cantidadBonos) async {
    final dbHelper = DatabaseHelper();
    String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    await dbHelper.insertBonoUsuario({
      'usuario_id': userId,
      'cantidad': cantidadBonos,
      'estado': 'Disponible',
      'fecha': formattedDate,
    });

    _loadAvailableBonos(userId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Contenedor para el primer row de inputs y el botón
                  _buildInputRow(screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  // Fila con dos contenedores centrados
                  _buildHeaderRow(screenWidth),
                  _buildBonosContainers(screenHeight, screenWidth),
                  SizedBox(height: screenHeight * 0.01),
                  // Fila con dos contenedores centrados para totales
                  _buildTotalRow(screenHeight, screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(double screenWidth) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTextField('ID', _indexController, enabled: false), // Deshabilitar
          SizedBox(width: screenWidth * 0.02),
          _buildTextField('NOMBRE', _nameController, enabled: false),
          SizedBox(width: screenWidth * 0.02),
          _buildDropdownField('ESTADO', selectedOption, (value) {
            setState(() {
              selectedOption = value;
            });
          }, enabled: false), // Deshabilitar dropdown
          SizedBox(width: screenWidth * 0.02),
          OutlinedButton(
            onPressed: () {
              _addBonos(context);
            }, // Mantener vacío para que InkWell funcione
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(10.0),
              side: const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              backgroundColor: Colors.transparent,
            ),
            child: const Text(
              'AÑADIR BONOS',
              style: TextStyle(
                color: Color(0xFF2be4f3),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHeaderText("BONOS DISPONIBLES"),
        SizedBox(width: screenWidth * 0.02),
        _buildHeaderText("BONOS CONSUMIDOS"),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              color: Color(0xFF2be4f3),
              fontSize: 17,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBonosContainers(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBonosContainer(screenHeight, availableBonos, false),
        SizedBox(width: screenWidth * 0.02),
        _buildBonosContainer(screenHeight, consumedBonos, true),
      ],
    );
  }

  Widget _buildBonosContainer(
      double screenHeight, List<Map<String, String>> bonosData, bool showHour) {
    return Expanded(
      child: Container(
        height: screenHeight * 0.3,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BonosTableWidget(
            bonosData: bonosData,
            showHour: showHour,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTotalContainer(screenHeight, "TOTAL", totalBonosAvailables.toString(), Colors.green),
        SizedBox(width: screenWidth * 0.02),
        _buildTotalContainer(screenHeight, "TOTAL", "456", Colors.red),
      ],
    );
  }

  Widget _buildTotalContainer(
      double screenHeight, String label, String total, Color totalColor) {
    return Expanded(
      child: Container(
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  color: totalColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Reutilizando la creación de campos de texto
  Widget _buildTextField(
      String label, TextEditingController controller, {bool enabled = true}) {
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
            decoration: _inputDecoration(),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecorationStyle(enabled: enabled),
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }

// Reutilizando la creación de dropdown
  Widget _buildDropdownField(
      String label, String? value, Function(String?) onChanged, {bool enabled = true}) {
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
            decoration: _inputDecoration(),
            child: AbsorbPointer(
              absorbing: !enabled,
              child: DropdownButton<String>(
                hint: const Text('Seleccione',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                value: value,
                items: const [
                  DropdownMenuItem(
                      value: 'Activo',
                      child: Text('Activo',
                          style: TextStyle(color: Colors.white, fontSize: 14))),
                  DropdownMenuItem(
                      value: 'Inactivo',
                      child: Text('Inactivo',
                          style: TextStyle(color: Colors.white, fontSize: 14))),
                ],
                onChanged: enabled ? onChanged : null,
                dropdownColor: const Color(0xFF313030),
                icon: const Icon(Icons.arrow_drop_down,
                    color: Color(0xFF2be4f3), size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Métodos de estilo reutilizados
  BoxDecoration _inputDecoration() {
    return BoxDecoration(color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }

  InputDecoration _inputDecorationStyle({bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: enabled ? 'Introducir dato' : '',
      hintStyle: const TextStyle(color: Colors.grey),
      enabled: enabled,
    );
  }
  Future<void> _addBonos(BuildContext context) async {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF494949),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF2be4f3), width: 2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: SizedBox(
            height: screenHeight * 0.4,
            width: screenWidth * 0.4,
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF2be4f3)),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "COMPRAR BONOS",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2be4f3),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close_sharp,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF313030),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: TextField(
                            controller: _bonosController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Color(0xFF313030),
                              hintText: 'Introduzca los bonos',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final cantidadBonos = int.tryParse(_bonosController.text);
                            if (cantidadBonos == null || cantidadBonos <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Introduzca un valor válido",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            await _saveBonosUser(lastUserId!, cantidadBonos);
                            Navigator.of(context).pop();
                            _bonosController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Bonos añadidos correctamente",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green),
                            foregroundColor: MaterialStateProperty.all(Colors.white),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            ),
                          ),
                          child: const Text(
                            'AÑADIR',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
