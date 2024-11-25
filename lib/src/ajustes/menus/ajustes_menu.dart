import 'package:flutter/material.dart';
import 'package:imotion_designs/src/ajustes/overlays/overlays.dart';
import 'package:imotion_designs/src/programs/overlays/overlays_programs.dart';

class AjustesMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  final Function() onNavigatetoLicencia; // Callback para navegar de vuelta
  const AjustesMenuView({super.key, required this.onBack, required this.onNavigatetoLicencia});

  @override
  State<AjustesMenuView> createState() => _AjustesMenuViewState();
}

class _AjustesMenuViewState extends State<AjustesMenuView> {
  double scaleFactorBack = 1.0;
  double scaleFactorLicencia= 1.0;
  double scaleFactorCentros= 1.0;
  double scaleFactorBackup = 1.0;
  double scaleFactorIdioma = 1.0;
  double scaleFactorServicio = 1.0;

  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  @override
  void initState() {
    super.initState();
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido principal
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
                      // Contenedor de los botones
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            width: screenWidth * 0.05,
                                            height: screenHeight * 0.1,
                                            child: Image.asset(
                                              'assets/images/ajustes.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const Expanded(
                                            child: Text(
                                              "AJUSTES",
                                              style: TextStyle(
                                                color: Color(0xFF28E2F5),
                                                fontSize: 30,
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
                              SizedBox(height: screenHeight * 0.05),
                              buildButton(
                                context,
                                'Licencia',
                                scaleFactorLicencia,
                                    () {
                                  setState(() {
                                    scaleFactorLicencia = 1;
                                    widget.onNavigatetoLicencia();
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorLicencia = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Gestión de centros',
                                scaleFactorCentros,
                                    () {
                                  setState(() {
                                    scaleFactorCentros = 1;
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorCentros = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Copia de seguridad',
                                scaleFactorBackup,
                                    () {
                                  setState(() {
                                    scaleFactorBackup = 1;
                                    toggleOverlay(0);

                                  });
                                },
                                    () {
                                  setState(() => scaleFactorBackup = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Selección de idioma',
                                scaleFactorIdioma,
                                    () {
                                  setState(() {
                                    scaleFactorIdioma = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorIdioma = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Servicio técnico',
                                scaleFactorServicio,
                                    () {
                                  setState(() {
                                    scaleFactorServicio = 1;
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorServicio = 0.90);
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
                                aspectRatio: 1,
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
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  widget
                                      .onBack(); // Llama al callback para volver a la vista anterior
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlay: Esto se coloca fuera del contenido principal y en el centro de la pantalla
          if (isOverlayVisible)
            Positioned.fill(
              top:screenHeight*0.3,
              bottom: screenHeight*0.2,
              left: screenWidth*0.4,
              right: screenWidth*0.1,
              child: Align(
                alignment: Alignment.center,
                child: _getOverlayWidget(overlayIndex),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlayBackup(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlayIdioma(
          onClose: () => toggleOverlay(1),
        );
      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
  }

  Widget buildButton(BuildContext context, String text, double scale,
      VoidCallback onTapUp, VoidCallback onTapDown) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTapDown: isOverlayVisible ? null : (_) => onTapDown(),
        onTapUp: isOverlayVisible ? null : (_) => onTapUp(),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/recuadro.png',
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
        ),
      ),
    );
  }
}
