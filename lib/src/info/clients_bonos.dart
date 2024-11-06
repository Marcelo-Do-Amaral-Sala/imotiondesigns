import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../customs/bonos_table_custom.dart';

class ClientsBonos extends StatefulWidget {
  final Map<String, dynamic> clientDataBonos;

  const ClientsBonos({super.key, required this.clientDataBonos});

  @override
  _ClientsBonosState createState() => _ClientsBonosState();
}

class _ClientsBonosState extends State<ClientsBonos> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  final _bonosController = TextEditingController();
  String? selectedOption;
  int? clientId; // Declare a variable to store the client ID

  List<Map<String, String>> availableBonos = [
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
  ];

  List<Map<String, String>> consumedBonos = [
    {'date': '10/12/2024', 'hour': '12:00', 'quantity': '50'},
    {'date': '10/10/2024', 'hour': '14:00', 'quantity': '500'},
    {'date': '10/12/2024', 'hour': '12:00', 'quantity': '50'},
    {'date': '10/10/2024', 'hour': '14:00', 'quantity': '500'},
    {'date': '10/12/2024', 'hour': '12:00', 'quantity': '50'},
    {'date': '10/10/2024', 'hour': '14:00', 'quantity': '500'},
    {'date': '10/12/2024', 'hour': '12:00', 'quantity': '50'},
    {'date': '10/10/2024', 'hour': '14:00', 'quantity': '500'},
  ];

  @override
  void initState() {
    super.initState();
    clientId = int.tryParse(widget.clientDataBonos['id'].toString());
    _indexController.text = widget.clientDataBonos['id'] ?? '';
    _nameController.text = widget.clientDataBonos['name'] ?? '';
    selectedOption = widget.clientDataBonos['status'];
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.03), // Ajustar el padding
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Contenedor para el primer row de inputs y el botón
                  _buildInputRow(screenWidth),
                  const SizedBox(height: 2),
                  // Fila con dos contenedores centrados
                  _buildHeaderRow(screenWidth),
                  _buildBonosContainers(screenHeight, screenWidth),
                  const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTextField('ID', _indexController, false), // Deshabilitar
          SizedBox(width: screenWidth * 0.02),
          _buildTextField('NOMBRE', _nameController, false), // Deshabilitar
          SizedBox(width: screenWidth * 0.02),
          _buildDropdownField('ESTADO', selectedOption, (value) {
            setState(() {
              selectedOption = value;
            });
          }, false), // Deshabilitar dropdown
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
                fontSize: 14,
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
        const Expanded(
          child: Center(
            child: Text(
              "BONOS DISPONIBLES",
              style: TextStyle(
                  color: Color(0xFF2be4f3),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        const Expanded(
          child: Center(
            child: Text(
              "BONOS CONSUMIDOS",
              style: TextStyle(
                  color: Color(0xFF2be4f3),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
        height: screenHeight * 0.25,
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
        _buildTotalContainer(screenHeight, "TOTAL", "123", Colors.green),
        SizedBox(width: screenWidth * 0.02),
        _buildTotalContainer(screenHeight, "TOTAL", "456", Colors.red),
      ],
    );
  }

  Widget _buildTotalContainer(
      double screenHeight, String label, String total, Color totalColor) {
    return Expanded(
      child: Container(
        height: screenHeight * 0.08,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  color: totalColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool enabled) {
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
                borderRadius: BorderRadius.circular(7)),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
              ),
              enabled: enabled, // Controlar si está habilitado
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      String label, String? value, Function(String?) onChanged, bool enabled) {
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
                borderRadius: BorderRadius.circular(7)),
            child: AbsorbPointer(
              absorbing: !enabled, // Si es 'false' no se puede interactuar
              child: DropdownButton<String>(
                hint: const Text('Seleccione',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                value: value,
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
                onChanged: enabled ? onChanged : null,
                // Si no está habilitado, no permite cambiar
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

  Future<void> _addBonos(BuildContext context) async {
    // Obtener el tamaño de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF494949), // Fondo del Dialog
          shape: RoundedRectangleBorder(
            side: BorderSide(color: const Color(0xFF2be4f3), width: 2),
            borderRadius: BorderRadius.circular(7), // Bordes redondeados
          ),
          child: SizedBox(
            height: screenHeight * 0.4,
            // Ajusta el alto del dialog a un tercio de la pantalla
            width: screenWidth * 0.4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border:
                        Border(bottom: BorderSide(color: Color(0xFF2be4f3))),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF313030),
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: Colors.white,
                                  width: 1), // Borde blanco
                            ),
                            child: TextField(
                              controller: _bonosController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: const Color(0xFF313030),
                                hintText: 'Introduzca los bonos',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                              // Fondo verde
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              // Texto blanco
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 20), // Ajusta el tamaño aquí
                              ),
                            ),
                            child: const Text(
                              'AÑADIR',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20), // Color del texto (blanco)
                            ),
                          ),
                        ],
                      )),
                )

                // El TextField para ingresar los bonos
                // Botón de acción
              ],
            ),
          ),
        );
      },
    );
  }
}
