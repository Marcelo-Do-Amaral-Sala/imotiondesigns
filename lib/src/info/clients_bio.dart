import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/bioimpedancia_table_custom.dart';

class ClientsBio extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic> clientDataBio;

  const ClientsBio({
    super.key,
    required this.onClientTap,
    required this.clientDataBio,
  });

  @override
  _ClientsBioState createState() => _ClientsBioState();
}

class _ClientsBioState extends State<ClientsBio> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;

  List<Map<String, String>> allBio = [
    {'date': '11/01/2024', 'hour': '10:20'},
    {'date': '15/02/2024', 'hour': '09:20'},
    {'date': '16/05/2024', 'hour': '12:20'},
    {'date': '19/05/2024', 'hour': '15:20'},
    {'date': '31/01/2024', 'hour': '11:20'},
  ];

  bool _showSubTab = false; // Controla si se muestra una subpestaña
  bool _showEvolutionTab =
      false; // Controla si se muestra la subpestaña de evolución
  Map<String, String>? _subTabData;

  @override
  void initState() {
    super.initState();
    _indexController.text = widget.clientDataBio['id'] ?? '';
    _nameController.text = widget.clientDataBio['name'] ?? '';
    selectedOption = widget.clientDataBio['status'];
  }

  void _showPrint(Map<String, String> clientData) {
    setState(() {
      _showSubTab = true; // Mostrar subpestaña por fila de datos
      _subTabData = clientData; // Asignar datos a mostrar
      _showEvolutionTab = false; // Asegurarse que no se muestre la evolución
    });
    widget
        .onClientTap(clientData); // Llama a la función para mostrar subpestaña
  }

  void _showEvolution() {
    setState(() {
      _showEvolutionTab = true; // Mostrar subpestaña de evolución
      _showSubTab = false; // Asegurarse que no se muestre la otra subpestaña
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF313030),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: TextField(
                                  controller: _indexController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NOMBRE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF313030),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: TextField(
                                  controller: _nameController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ESTADO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF313030),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: DropdownButton<String>(
                                  hint: const Text(
                                    'Seleccione',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: selectedOption,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Activo',
                                      child: Text(
                                        'Activo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Inactivo',
                                      child: Text(
                                        'Inactivo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedOption = value;
                                    });
                                  },
                                  dropdownColor: const Color(0xFF313030),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF2be4f3),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Color(0xFF2be4f3),
                            ),
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
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: screenHeight * 0.32,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 46, 46, 46),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: BioimpedanciaTableWidget(
                                dataRegister: allBio,
                                onRowTap: _showPrint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed:
                              _showEvolution, // Cambiar a la subpestaña de evolución
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side: const BorderSide(
                              width: 1.0,
                              color: Color(0xFF2be4f3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: const Text(
                            'EVOLUCIÓN',
                            style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_showSubTab)
              _buildSubTabView() // Mostrar subpestaña de datos
            else if (_showEvolutionTab)
              _buildEvolutionSubTab() // Mostrar subpestaña de evolución
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabView() {
    return Center(
      child: Text(
        'Subpestaña de Datos: ${_subTabData?['date'] ?? 'No disponible'}', // Ejemplo de datos
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildEvolutionSubTab() {
    return Center(
      child: const Text(
        'Subpestaña de Evolución', // Contenido de la subpestaña de evolución
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
