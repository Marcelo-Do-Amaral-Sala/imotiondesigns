import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../utils/translation_utils.dart';
import '../../clients/custom_clients/bonos_table_custom.dart';
import '../../db/db_helper.dart';

class AdminsBonos extends StatefulWidget {
  final Map<String, dynamic> userDataBonos;

  const AdminsBonos({super.key, required this.userDataBonos});

  @override
  _AdminsBonosState createState() => _AdminsBonosState();
}

class _AdminsBonosState extends State<AdminsBonos> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  final _bonosController = TextEditingController();
  String? selectedOption;
  int? userId; // Variable para almacenar el ID del cliente

  List<Map<String, String>> availableBonos = []; // Cambiar el tipo aquí
  List<Map<String, String>> consumedBonos = [];
  int totalBonosAvailables = 0; // Total de bonos disponibles

  @override
  void initState() {
    super.initState();
    userId = int.tryParse(widget.userDataBonos['id'].toString());
    _nameController.text = widget.userDataBonos['name'] ?? '';
    selectedOption = widget.userDataBonos['status'];
    if (userId != null) {
      _loadAvailableBonos(userId!);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTextField(tr(context, 'Nombre').toUpperCase(), _nameController,
            enabled: false),
        SizedBox(width: screenWidth * 0.02),
        _buildDropdownField(
            tr(context, 'Estado').toUpperCase(), selectedOption, (value) {
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
            padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.01,
                vertical: screenHeight * 0.01),
            side:  BorderSide(width: screenWidth*0.001, color: const Color(0xFF2be4f3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            backgroundColor: Colors.transparent,
          ),
          child: Text(
            tr(context, 'Añadir bonos').toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF2be4f3),
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHeaderText(
          tr(context, 'Bonos disponibles').toUpperCase(),
        ),
        SizedBox(width: screenWidth * 0.02),
        _buildHeaderText(
          tr(context, 'Bonos consumidos').toUpperCase(),
        ),
      ],
    );
  }

  Widget _buildHeaderText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              color: const Color(0xFF2be4f3),
              fontSize: 17.sp,
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        height: screenHeight * 0.3,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.015,
              vertical: screenHeight * 0.015),
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
        _buildTotalContainer(screenHeight, tr(context, 'Total').toUpperCase(),
            totalBonosAvailables.toString(), Colors.green),
        SizedBox(width: screenWidth * 0.02),
        _buildTotalContainer(screenHeight, tr(context, 'Total').toUpperCase(),
            "456", Colors.red),
      ],
    );
  }

  Widget _buildTotalContainer(
      double screenHeight, String label, String total, Color totalColor) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        height: screenHeight * 0.1,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.015,
              vertical: screenHeight * 0.015),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  color: totalColor,
                  fontSize: 17.sp,
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
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
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
            decoration: _inputDecoration(),
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
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
      String label, String? value, Function(String?) onChanged,
      {bool enabled = true}) {
    double screenHeight = MediaQuery.of(context).size.height;
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
            decoration: _inputDecoration(),
            child: AbsorbPointer(
              absorbing: !enabled,
              child: DropdownButton<String>(
                hint: Text(tr(context, 'Seleccione'),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                value: value,
                items: [
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
                onChanged: enabled ? onChanged : null,
                dropdownColor: const Color(0xFF313030),
                icon:  Icon(Icons.arrow_drop_down,
                    color: const Color(0xFF2be4f3), size: screenHeight*0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Métodos de estilo reutilizados
  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }

  InputDecoration _inputDecorationStyle({bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: enabled ? 'Introducir dato' : '',
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
            side:  BorderSide(color: const Color(0xFF2be4f3), width: screenWidth*0.001),
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
                      Center(
                        child: Text(
                          tr(context, 'Comprar bonos').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2be4f3),
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
                          icon:  Icon(
                            Icons.close_sharp,
                            color: Colors.white,
                            size: screenHeight*0.07,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.002,
                        vertical: screenHeight * 0.002),
                    child: Column(
                      children: [
                        Container(
                          padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.02),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF313030),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: _bonosController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style:
                            TextStyle(color: Colors.white, fontSize: 17.sp),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: const Color(0xFF313030),
                              hintText: tr(context, 'Introduzca los bonos'),
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 17.sp),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        OutlinedButton(
                          onPressed: () async {
                            final cantidadBonos =
                                int.tryParse(_bonosController.text);
                            if (cantidadBonos == null || cantidadBonos <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    tr(context, 'Introduzca un valor válido')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            await _saveBonosUser(userId!, cantidadBonos);
                            Navigator.of(context).pop();
                            _bonosController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tr(context, 'Bonos añadidos correctamente')
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side:  BorderSide(
                              width:screenWidth*0.001,
                              color: const Color(0xFF2be4f3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            tr(context, 'Añadir').toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
