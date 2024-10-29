import 'package:flutter/material.dart';

import '../customs/bonos_table_custom.dart';

class ClientsBonos extends StatefulWidget {
  final Map<String, dynamic> clientDataBonos;

  const ClientsBonos({super.key, required this.clientDataBonos});

  @override
  // ignore: library_private_types_in_public_api
  _ClientsBonosState createState() => _ClientsBonosState();
}

class _ClientsBonosState extends State<ClientsBonos> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedOption;
// Lista completa de clientes
  // Lista de bonos disponibles (sin hora)
  List<Map<String, String>> availableBonos = [
    {'date': '12/12/2024', 'quantity': '5'},
    {'date': '12/02/2024', 'quantity': '15'},
  ];

// Lista de bonos consumidos (con hora)
  List<Map<String, String>> consumedBonos = [
    {'date': '10/12/2024', 'hour': '12:00', 'quantity': '50'},
    {'date': '10/10/2024', 'hour': '14:00', 'quantity': '500'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.clientDataBonos['name'] ?? '';
    selectedOption = widget.clientDataBonos['status'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
              // Campos de ID
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ID',
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
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF313030),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Campos de NOMBRE
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NOMBRE',
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
                      child: TextField(
                        controller: _nameController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF313030),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Campo de ESTADO
              Expanded(
                flex: 1,
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        value: selectedOption,
                        items: const [
                          DropdownMenuItem(
                              value: 'Activo',
                              child: Text('Activo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))),
                          DropdownMenuItem(
                              value: 'Inactivo',
                              child: Text('Inactivo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                          });
                        },
                        dropdownColor: const Color(0xFF313030),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF2be4f3), size: 30),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              // Botón AÑADIR BONOS
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    debugPrint("BONOS PULSADOS");
                  },
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text('AÑADIR BONOS',
                      style: TextStyle(
                        color: Color(0xFF2be4f3),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.03),
          // Fila con dos contenedores centrados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Expanded(
                child: Center(
                  // Centrar el texto
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
                  // Centrar el texto
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
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.2,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 46, 46, 46),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child: BonosTableWidget(
                        bonosData: availableBonos, // Lista de bonos disponibles
                        showHour: false, // Oculta la columna "HORA"
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: screenWidth * 0.02), // Espacio entre los contenedores
              Expanded(
                child: Container(
                  height: screenHeight * 0.2,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 46, 46, 46),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: BonosTableWidget(
                      bonosData: consumedBonos, // Lista de bonos disponibles
                      showHour: true, // Oculta la columna "HORA"
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          // Fila con dos contenedores centrados
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 46, 46, 46),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    // Puedes añadir contenido aquí
                  ),
                ),
              ),
              SizedBox(
                  width: screenWidth * 0.02), // Espacio entre los contenedores
              Expanded(
                child: Container(
                  height: screenHeight * 0.08,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 46, 46, 46),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
