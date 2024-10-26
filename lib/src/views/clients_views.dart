import 'package:flutter/material.dart';

import '../customs/overlay_content.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  final List<String> clients = ["Cliente 1", "Cliente 2", "Cliente 3", "Cliente 4"];

  // Variables para controlar el efecto de escala en las imágenes
  double scaleFactorBack = 1.0;
  double scaleFactorListado = 1.0;
  double scaleFactorCrear = 1.0;

  // Variable para controlar la visibilidad del contenedor superpuesto
  bool isOverlayVisible = false;

  // Variable para determinar el tipo de contenido del overlay
  String overlayContentType = '';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            children: [
                              // Primer botón (sin animación)
                              SizedBox(
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
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
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
                              SizedBox(height: screenHeight * 0.05),
                              // Botón para listado de clientes
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTapDown: (_) => setState(() => scaleFactorListado = 0.95),
                                  onTapUp: (_) {
                                    setState(() {
                                      scaleFactorListado = 1.0;
                                      isOverlayVisible = true; // Muestra el contenedor superpuesto
                                      overlayContentType = 'listado'; // Establece el tipo de contenido
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: scaleFactorListado,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
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
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
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
                                ),
                              ),
                              const SizedBox(height: 25),
                              // Botón para crear clientes
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTapDown: (_) => setState(() => scaleFactorCrear = 0.95),
                                  onTapUp: (_) {
                                    setState(() {
                                      scaleFactorCrear = 1.0;
                                      isOverlayVisible = true; // Muestra el contenedor superpuesto
                                      overlayContentType = 'crear'; // Establece el tipo de contenido
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: scaleFactorCrear,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
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
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.5,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTapDown: (_) => setState(() => scaleFactorBack = 0.95),
                                onTapUp: (_) => setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  // NAVEGACION A PANTALLA ANTERIOR
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorBack,
                                  duration: const Duration(milliseconds: 100),
                                  child: SizedBox(
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/back.png',
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Contenedor superpuesto en el segundo Expanded
                            if (isOverlayVisible)
                              Positioned.fill(
                                top: screenHeight * 0.15,
                                child: OverlayContent(
                                  contentType: overlayContentType, // Pasamos el tipo de contenido
                                  onClose: () {
                                    setState(() {
                                      isOverlayVisible = false; // Oculta el contenedor superpuesto
                                    });
                                  },
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
          ),
        ],
      ),
    );
  }
}
