import 'package:flutter/material.dart';

class PersonalDataForm extends StatefulWidget {
  final Function(String, String, String, String, int, int, DateTime)
      onDataChanged;

  PersonalDataForm({Key? key, required this.onDataChanged}) : super(key: key);

  @override
  _PersonalDataFormState createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? selectedOption;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      _genderController.text,
      int.parse(_heightController.text),
      int.parse(_weightController.text),
      DateTime.parse(_birthDateController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            // Primer contenedor para el primer row de inputs
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
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
                        Text(
                          'NOMBRE',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Color(0xFF313030),
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
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF313030),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: DropdownButton<String>(
                            hint: const Text(
                              'Seleccione',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            value: selectedOption,
                            items: const [
                              DropdownMenuItem(
                                value: 'Activo',
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Inactivo',
                                child: Text(
                                  'Inactivo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
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
                              size: 50,
                            ),
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
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ALTURA',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'PESO',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'FECHA DE NACIMIENTO',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _birthDateController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
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
                          const Text(
                            'GÉNERO',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _genderController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'EMAIL',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'TELÉFONO',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF313030),
                            ),
                          ),
                        ],
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
  }
}
