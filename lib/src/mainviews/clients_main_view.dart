import 'package:flutter/material.dart';
import '../customs/overlay_custom.dart';

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  double scaleFactorBack = 1.0;
  double scaleFactorListado = 1.0;
  double scaleFactorCrear = 1.0;

  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData; // Define aquí tu variable clientData

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
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTapDown: (isOverlayVisible)
                                      ? null
                                      : (_) => setState(
                                          () => scaleFactorListado = 0.95),
                                  onTapUp: (isOverlayVisible)
                                      ? null
                                      : (_) {
                                          setState(() {
                                            scaleFactorListado = 1.0;
                                            isOverlayVisible = true;
                                            overlayContentType = 'listado';
                                          });
                                        },
                                  child: AnimatedScale(
                                    scale: scaleFactorListado,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
                                      width: screenWidth * 0.2,
                                      height: screenHeight * 0.1,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/recuadro.png',
                                            fit: BoxFit.fill,
                                            width: screenWidth * 0.2,
                                            height: screenHeight * 0.1,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Listado de clientes',
                                              style: TextStyle(
                                                color: Colors.lightBlueAccent,
                                                fontSize: 24,
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
                              SizedBox(height: screenHeight * 0.02),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTapDown: (isOverlayVisible)
                                      ? null
                                      : (_) => setState(
                                          () => scaleFactorCrear = 0.95),
                                  onTapUp: (isOverlayVisible)
                                      ? null
                                      : (_) {
                                          setState(() {
                                            scaleFactorCrear = 1.0;
                                            isOverlayVisible = true;
                                            overlayContentType = 'crear';
                                          });
                                        },
                                  child: AnimatedScale(
                                    scale: scaleFactorCrear,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
                                      width: screenWidth * 0.2,
                                      height: screenHeight * 0.1,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/recuadro.png',
                                            fit: BoxFit.fill,
                                            width: screenWidth * 0.2,
                                            height: screenHeight * 0.1,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Crear clientes',
                                              style: TextStyle(
                                                color: Colors.lightBlueAccent,
                                                fontSize: 24,
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
                      SizedBox(width: screenWidth * 0.01),
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
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.95),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
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
                            // Contenedor superpuesto
                            if (isOverlayVisible)
                              Positioned.fill(
                                top: screenHeight * 0.11,
                                right: 0,
                                left: 0,
                                child: OverlayContent(
                                  contentType: overlayContentType,
                                  onClose: () {
                                    setState(() {
                                      isOverlayVisible = false;
                                      clientData =
                                          null; // Reinicia si es necesario
                                    });
                                  },
                                  clientData:
                                      clientData, // Pasa los datos del cliente si es necesario
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