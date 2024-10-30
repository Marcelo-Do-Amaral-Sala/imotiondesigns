import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/bioimpedancia_table_custom.dart';

class ClientsBio extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Function(Map<String, String>) onButtonTap; // Nueva función
  final Map<String, dynamic> clientDataBio;

  const ClientsBio({
    super.key,
    required this.onClientTap,
    required this.onButtonTap, // Asegúrate de pasar esta función
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

  bool _showSessionSubTab = false;
  bool _showEvolutionSubTab = false; // Para la subpestaña de evolución
  Map<String, String>? _subTabData;

  @override
  void initState() {
    super.initState();
    _indexController.text = widget.clientDataBio['id'] ?? '';
    _nameController.text = widget.clientDataBio['name'] ?? '';
    selectedOption = widget.clientDataBio['status'];
  }

  void _showSession(Map<String, String> clientData) {
    setState(() {
      _showSessionSubTab = true;
      _subTabData = clientData;
    });
    widget.onClientTap(clientData);
  }

  void _onButtonTap(Map<String, String> clientData) {
    setState(() {
      _showEvolutionSubTab = true; // Mostrar la subpestaña de evolución
      _subTabData = clientData; // Asignar datos a mostrar
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 10, horizontal: screenWidth * 0.05), // Padding dinámico
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInputRow(screenWidth),
                  SizedBox(height: screenHeight * 0.03),
                  _buildBioRow(screenHeight, screenWidth),
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
          _buildTextField('ID', _indexController),
          SizedBox(width: screenWidth * 0.02),
          _buildTextField('NOMBRE', _nameController),
          SizedBox(width: screenWidth * 0.02),
          _buildDropdownField('ESTADO', selectedOption, (value) {
            setState(() {
              selectedOption = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildBioRow(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBioContainer(screenHeight),
        SizedBox(width: screenWidth * 0.02),
        _buildEvolutionButton(),
      ],
    );
  }

  Widget _buildBioContainer(double screenHeight) {
    return Expanded(
      flex: 2,
      child: Container(
        height: screenHeight * 0.32,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BioimpedanciaTableWidget(
            dataRegister: allBio,
            onRowTap: _showSession,
          ),
        ),
      ),
    );
  }

  Widget _buildEvolutionButton() {
    return Expanded(
      flex: 1,
      child: _buildOutlinedButton('EVOLUCIÓN', () {
        _showSession;
      }),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(10.0),
        side: const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2be4f3),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      String label, String? value, Function(String?) onChanged) {
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
              onChanged: onChanged,
              dropdownColor: const Color(0xFF313030),
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF2be4f3), size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
