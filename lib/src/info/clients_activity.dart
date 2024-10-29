import 'package:flutter/material.dart';


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
// Lista completa de clientes
  List<Map<String, String>> allSesions = [
    {
      'date': '12/09/2024',
      'hour': '10:00',
      'bonos': '30',
      'points': '450',
      'ekal': '1230',
    },
    {
      'date': '12/02/2024',
      'hour': '11:00',
      'bonos': '40',
      'points': '460',
      'ekal': '1270',
    },
    {
      'date': '02/09/2023',
      'hour': '13:00',
      'bonos': '35',
      'points': '450',
      'ekal': '1200',
    },
    {
      'date': '01/09/2023',
      'hour': '08:00',
      'bonos': '40',
      'points': '550',
      'ekal': '1030',
    },
    {
      'date': '18/12/2023',
      'hour': '06:30',
      'bonos': '50',
      'points': '500',
      'ekal': '1250',
    },
  ];
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
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            // Primer contenedor para el primer row de inputs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Campos de ID y NOMBRE
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
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
         
            const SizedBox(height: 8),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(5.0),
                height: screenHeight * 0.09,
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTapDown: (_) =>
                          setState(() => scaleFactorRemove = 0.95),
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
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTableWidget {
}
