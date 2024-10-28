import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PersonalDataForm extends StatefulWidget {
  final Function(String, String, String, String, int, int, String)
      onDataChanged;

  // ignore: use_super_parameters
  const PersonalDataForm({Key? key, required this.onDataChanged})
      : super(key: key);

  @override
  _PersonalDataFormState createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? selectedOption;
  String? selectedGender;
  String? _birthDate; // Variable para almacenar la fecha

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    widget.onDataChanged(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      selectedGender ?? '',
      int.parse(_heightController.text),
      int.parse(_weightController.text),
      _birthDate ?? '', // Se pasa la fecha seleccionada
    );
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
        _birthDate =
            DateFormat('dd/MM/yyyy').format(picked); // Formatear la fecha
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
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
                        const Text(
                          'NOMBRE',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
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
                        const Text(
                          'ESTADO',
                          style: TextStyle(color: Colors.white, fontSize: 12),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            value: selectedOption,
                            items: const [
                              DropdownMenuItem(
                                value: 'Activo',
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Inactivo',
                                child: Text(
                                  'Inactivo',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
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
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Segundo contenedor para el segundo row de inputs
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
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
                            'GÉNERO',
                            style: TextStyle(color: Colors.white, fontSize: 12),
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
                                    color: Colors.white, fontSize: 12),
                              ),
                              value: selectedGender,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Hombre',
                                  child: Text(
                                    'Hombre',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Mujer',
                                  child: Text(
                                    'Mujer',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value;
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
                          const SizedBox(height: 5),
                          const Text(
                            'FECHA DE NACIMIENTO',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
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
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'TELÉFONO',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number, // Solo números
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly, // Restringe a solo dígitos
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
                          const Text(
                            'ALTURA (cm)',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number, // Solo números
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly, // Restringe a solo dígitos
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
                          const Text(
                            'PESO (kg)',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number, // Solo números
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly, // Restringe a solo dígitos
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
                          const Text(
                            'E-MAIL',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType
                                .emailAddress, // Teclado específico para correos
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\s')) // Evitar espacios en blanco
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
            ),
          ],
        ),
      ),
    );
  }
}
