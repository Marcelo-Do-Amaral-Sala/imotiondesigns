import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ClientsActivity extends StatefulWidget {
  final Map<String, dynamic> clientDataActivity; // Agregar clientData

  const ClientsActivity({
    Key? key,
    required this.clientDataActivity, // Recibir clientData
  }) : super(key: key);

  @override
  _ClientsActivityState createState() => _ClientsActivityState();
}

class _ClientsActivityState extends State<ClientsActivity> {
  final _nameController = TextEditingController();
  String? selectedOption;

  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

  @override
  void initState() {
    super.initState();
    // Establecer valores predeterminados desde clientData
    _nameController.text = widget.clientDataActivity['name'] ?? '';

    selectedOption = widget.clientDataActivity['status'];
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
            Container(
              height: screenHeight * 0.27,
              width: screenWidth,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 46, 46),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(),
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
