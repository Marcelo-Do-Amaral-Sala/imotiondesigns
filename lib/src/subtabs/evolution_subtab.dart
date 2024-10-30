import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/activity_table_custom.dart';
import '../db/db_helper.dart';

class EvolutionSubTab extends StatefulWidget {
  const EvolutionSubTab({
    super.key,
  });

  @override
  _EvolutionSubTabState createState() => _EvolutionSubTabState();
}

class _EvolutionSubTabState extends State<EvolutionSubTab> {
  double scaleFactorBack = 1.0;
  List<Map<String, dynamic>> clients = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // Inicializar la base de datos y cargar datos
  }

  Future<void> _initializeDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.initializeDatabase(); // Inicializa la base de datos
    _fetchClients(); // Cargar los datos después de la inicialización
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        clients = clientData;
      });
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.02,
        ),
        child: Column(
          children: [
            // Contenedor para la imagen
            SizedBox(
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() => scaleFactorBack = 0.95),
                    onTapUp: (_) => setState(() => scaleFactorBack = 1.0),
                    onTap: () {
                      // Acción al hacer clic
                    },
                    child: AnimatedScale(
                      scale: scaleFactorBack,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                        width: screenWidth * 0.07,
                        height: screenHeight * 0.07,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/back.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Lista de clientes
            Expanded(
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      title: Text(client['name'] ?? 'Nombre no disponible'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estado: ${client['status'] ?? 'No disponible'}'),
                          Text('Género: ${client['gender'] ?? 'No disponible'}'),
                          Text('Altura: ${client['height'] ?? 'No disponible'} cm'),
                          Text('Peso: ${client['weight'] ?? 'No disponible'} kg'),
                          Text('Fecha de nacimiento: ${client['birthdate'] ?? 'No disponible'}'),
                          Text('Teléfono: ${client['phone'] ?? 'No disponible'}'),
                          Text('Email: ${client['email'] ?? 'No disponible'}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
