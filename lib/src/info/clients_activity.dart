import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/activity_table_custom.dart';

class ClientsActivity extends StatefulWidget {
  final Map<String, dynamic> clientDataActivity;

  const ClientsActivity({
    super.key,
    required this.clientDataActivity,
  });

  @override
  _ClientsActivityState createState() => _ClientsActivityState();
}

class _ClientsActivityState extends State<ClientsActivity> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;

  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

  List<Map<String, String>> allSesions = [
    {
      'date': '12/09/2024',
      'hour': '10:00',
      'bonos': '30',
      'points': '450',
      'ekal': '1230'
    },
    {
      'date': '12/02/2024',
      'hour': '11:00',
      'bonos': '40',
      'points': '460',
      'ekal': '1270'
    },
    {
      'date': '02/09/2023',
      'hour': '13:00',
      'bonos': '35',
      'points': '450',
      'ekal': '1200'
    },
    {
      'date': '01/09/2023',
      'hour': '08:00',
      'bonos': '40',
      'points': '550',
      'ekal': '1030'
    },
    {
      'date': '18/12/2023',
      'hour': '06:30',
      'bonos': '50',
      'points': '500',
      'ekal': '1250'
    },
  ];

  @override
  void initState() {
    super.initState();
    _indexController.text = widget.clientDataActivity['id'] ?? '';
    _nameController.text = widget.clientDataActivity['name'] ?? '';
    selectedOption = widget.clientDataActivity['status'];
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
            // Contenedor para los campos de entrada
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Campos de ID, NOMBRE y ESTADO
                  Flexible(
                    child: _buildTextField('ID', _indexController),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Flexible(
                    child: _buildTextField('NOMBRE', _nameController),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Flexible(
                    child:
                        _buildDropdownField('ESTADO', selectedOption, (value) {
                      setState(() {
                        selectedOption = value;
                      });
                    }),
                  ),
                ],
              ),
            ),
            // Contenedor para la tabla de actividades
            Container(
              height: screenHeight * 0.35,
              width: screenWidth,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 46, 46),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ActivityTableWidget(activityData: allSesions),
              ),
            ),
            const SizedBox(height: 5),
            // Aquí puedes reintroducir los botones de acción si lo necesitas
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
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
    );
  }

  Widget _buildDropdownField(
      String label, String? value, Function(String?) onChanged) {
    return Column(
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
    );
  }
}
