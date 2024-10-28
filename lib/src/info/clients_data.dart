import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ClientsData extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic> clientData; // Agregar clientData

  const ClientsData({
    Key? key,
    required this.onDataChanged,
    required this.clientData, // Recibir clientData
  }) : super(key: key);

  @override
  _ClientsDataState createState() => _ClientsDataState();
}

class _ClientsDataState extends State<ClientsData> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? selectedOption;
  String? selectedGender;
  String? _birthDate;
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

  @override
  void initState() {
    super.initState();
    // Establecer valores predeterminados desde clientData
    _nameController.text = widget.clientData['name'] ?? '';
    _emailController.text = widget.clientData['email'] ?? '';
    _phoneController.text = widget.clientData['phone'] ?? '';
    _heightController.text = widget.clientData['height']?.toString() ?? '';
    _weightController.text = widget.clientData['weight']?.toString() ?? '';
    selectedOption = widget.clientData['status'];
    selectedGender = widget.clientData['gender'];
    _birthDate = widget.clientData['birthDate'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _collectData() {
    final clientData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'gender': selectedGender,
      'status': selectedOption,
      'birthDate': _birthDate,
    };

    widget.onDataChanged(clientData);
    // Crear un string con todos los datos
    String dataString = 'Nombre: ${clientData['name']}\n'
        'Email: ${clientData['email']}\n'
        'Teléfono: ${clientData['phone']}\n'
        'Altura: ${clientData['height']} cm\n'
        'Peso: ${clientData['weight']} kg\n'
        'Género: ${clientData['gender']}\n'
        'Fecha de Nacimiento: ${clientData['birthDate']}\n'
        'Estado: ${clientData['status']}';

    // Mostrar Snackbar con todos los datos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(dataString),
        duration: const Duration(seconds: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Primer contenedor para el primer row de inputs
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Campos de ID y NOMBRE
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
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
                        const Text('NOMBRE',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
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
                        const Text('ESTADO',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF313030),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButton<String>(
                            hint: const Text('Seleccione',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
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
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Segundo contenedor para el segundo row de inputs
            SizedBox(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Campos de GÉNERO, FECHA DE NACIMIENTO y TELÉFONO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GÉNERO',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF313030),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButton<String>(
                            hint: const Text('Seleccione',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            value: selectedGender,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Hombre',
                                  child: Text('Hombre',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))),
                              DropdownMenuItem(
                                  value: 'Mujer',
                                  child: Text('Mujer',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            dropdownColor: const Color(0xFF313030),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF2be4f3), size: 30),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('FECHA DE NACIMIENTO',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF313030),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              _birthDate ?? 'DD/MM/YYYY',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('TELÉFONO',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ALTURA (cm)',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('PESO (kg)',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('E-MAIL',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(2.0),
              height: screenHeight * 0.09,
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorRemove = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorRemove = 1.0),
                    onTap: () {
                      print("PAPELARA PULSADA");
                    },
                    child: AnimatedScale(
                      scale: scaleFactorRemove,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/papelera.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
                    onTap: () {
                      print("TICK PUuuuLSADA");
                    },
                    child: AnimatedScale(        
                      scale: scaleFactorTick,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.1,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/tick.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
