import 'package:flutter/material.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  // Ejemplo de datos de clientes
  final List<String> clients = ["Cliente 1", "Cliente 2", "Cliente 3", "Cliente 4"];

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ancho y alto de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenido
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // Ajuste del 5% del ancho de la pantalla
              vertical: screenHeight * 0.1, // Ajuste del 2% de la altura de la pantalla
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // Columna estrecha
                      Expanded(
                        flex: 2, // Proporción para la columna estrecha
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05, // Ajuste del 5% del ancho de la pantalla
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            children: [
                              // Primera imagen
                              Container(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.15,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/recuadro.png',
                                      fit: BoxFit.fill,
                                      width: screenWidth * 0.25,
                                      height: screenHeight * 0.15,
                                    ),
                                    const Padding(
                                      padding: const EdgeInsets.all(8.0), // Padding dentro de la imagen
                                      child: const Text(
                                        '- CLIENTES',
                                        style: TextStyle(
                                          color: Colors.lightBlueAccent,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.05,
                              ),
                              // Segunda imagen (más pequeña y alineada a la derecha)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  height: screenHeight * 0.15,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/recuadro.png',
                                        fit: BoxFit.fill,
                                        width: screenWidth * 0.2,
                                        height: screenHeight * 0.15,
                                      ),
                                      const Padding(
                                        padding: const EdgeInsets.all(8.0), // Padding dentro de la imagen
                                        child: const Text(
                                          'Listado de clientes',
                                          style: TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Espacio entre la segunda y tercera imagen
                              const SizedBox(height: 25), // Ajusta este valor según sea necesario
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: screenWidth * 0.2,
                                  height: screenHeight * 0.15,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/recuadro.png',
                                        fit: BoxFit.fill,
                                        width: screenWidth * 0.2,
                                        height: screenHeight * 0.15,
                                      ),
                                      const Padding(
                                        padding: const EdgeInsets.all(8.0), // Padding dentro de la imagen
                                        child: const Text(
                                          'Crear clientes',
                                          style: TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10), // Espacio entre las columnas
                      // Columna más amplia
                      Expanded(
                        flex: 3, // Proporción para la columna amplia
                        child: Container(
                          child: Center(
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.5,
                                  height: screenHeight * 0.5,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
