import 'package:flutter/material.dart';

class MainMenuView extends StatefulWidget {
  final Function() onNavigateToClients;

  const MainMenuView({Key? key, required this.onNavigateToClients})
      : super(key: key);

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView> {
  double scaleFactorPanel = 1.0;
  double scaleFactorClient = 1.0;
  double scaleFactorProgram = 1.0;
  double scaleFactorBio = 1.0;
  double scaleFactorTuto = 1.0;
  double scaleFactorAjustes = 1.0;

  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;

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
                              SizedBox(height: screenHeight * 0.05),
                              buildButton(
                                context,
                                'assets/images/panel.png',
                                'PANEL DE CONTROL',
                                scaleFactorPanel,
                                () {
                                  setState(() {
                                    scaleFactorPanel = 1;
                                  });
                                },
                                () {
                                  setState(() => scaleFactorPanel = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'assets/images/cliente.png',
                                'CLIENTES',
                                scaleFactorClient,
                                () {
                                  scaleFactorClient = 1;
                                  widget.onNavigateToClients();
                                },
                                () {
                                  setState(() => scaleFactorClient = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'assets/images/programas.png',
                                'PROGRAMAS',
                                scaleFactorProgram,
                                () {
                                  setState(() {
                                    scaleFactorProgram = 1;
                                  });
                                },
                                () {
                                  setState(() => scaleFactorProgram = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'assets/images/bio.png',
                                'BIOIMPEDANCIA',
                                scaleFactorBio,
                                () {
                                  setState(() {
                                    scaleFactorBio = 1;
                                  });
                                },
                                () {
                                  setState(() => scaleFactorBio = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'assets/images/tutoriales.png',
                                'TUTORIALES',
                                scaleFactorTuto,
                                () {
                                  setState(() {
                                    scaleFactorTuto = 1;
                                  });
                                },
                                () {
                                  setState(() => scaleFactorTuto = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'assets/images/ajustes.png',
                                'AJUSTES',
                                scaleFactorAjustes,
                                () {
                                  setState(() {
                                    scaleFactorAjustes = 1;
                                  });
                                },
                                () {
                                  setState(() => scaleFactorAjustes = 0.90);
                                },
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
                              child: AspectRatio(
                                aspectRatio: 1, // Mantiene la proporción
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
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
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String imagePath, String text,
      double scale, VoidCallback onTapUp, VoidCallback onTapDown) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTapDown: isOverlayVisible ? null : (_) => onTapDown(),
        onTapUp: isOverlayVisible ? null : (_) => onTapUp(),
        child: AnimatedScale(
          scale: scale,
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Contenedor para el ícono
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        width: screenWidth *
                            0.05, // Ajusta el tamaño del ícono aquí
                        height: screenHeight *
                            0.1, // Ajusta la altura del ícono aquí
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit
                              .contain, // Ajuste para llenar el contenedor
                        ),
                      ),

                      // Contenedor para el texto
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Color(0xFF28E2F5),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
