import 'package:flutter/material.dart';
import 'package:imotion_designs/src/customs/activity_table_custom.dart';

class EvolutionSubTab extends StatefulWidget {
  const EvolutionSubTab({
    super.key,
  });

  @override
  _EvolutionSubTabState createState() => _EvolutionSubTabState();
}

class _EvolutionSubTabState extends State<EvolutionSubTab> {
  double scaleFactorBack = 1.0;

  List<Map<String, String>> allBioEvo = [
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
  }

  @override
  void dispose() {
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
          horizontal: screenWidth * 0.02, // Ajustar el padding
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
            // Espacio entre los contenedores
            // Row con dos contenedores del mismo tamaño
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: screenHeight * 0.4, // Altura del contenedor
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'FECHA: ',
                          style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'HORA: ',
                          style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                // Espacio entre los contenedores
                Expanded(
                  child: Container(
                    height: screenHeight * 0.4, // Altura del contenedor
                    decoration: BoxDecoration(
                      color: Colors.green, // Color del segundo contenedor
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Contenedor 2',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            // Espacio entre los contenedores
            // Aquí puedes añadir el contenedor para la tabla de actividades
          ],
        ),
      ),
    );
  }
}
