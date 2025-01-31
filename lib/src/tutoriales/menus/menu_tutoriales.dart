import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/translation_utils.dart';
import '../overlays/overlays_tuto.dart';

class TutorialesMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  final double screenWidth;
  final double screenHeight;

  const TutorialesMenuView(
      {super.key,
      required this.onBack,
      required this.screenWidth,
      required this.screenHeight});

  @override
  State<TutorialesMenuView> createState() => _TutorialesMenuViewState();
}

class _TutorialesMenuViewState extends State<TutorialesMenuView> {
  double scaleFactorBack = 1.0;
  double scaleFactorPP = 1.0;
  double scaleFactorSoft = 1.0;
  double scaleFactorIncid = 1.0;
  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.01,
                                        vertical: screenHeight * 0.01,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.001,
                                              vertical: screenHeight * 0.001,
                                            ),
                                            width: screenWidth * 0.05,
                                            height: screenHeight * 0.1,
                                            child: Image.asset(
                                              'assets/images/tutoriales.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Tutoriales')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: const Color(0xFF28E2F5),
                                                fontSize: 34.sp,
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
                                tr(context, 'Primeros pasos').toUpperCase(),
                                scaleFactorPP,
                                () {
                                  setState(() {
                                    scaleFactorPP = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorPP = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Software').toUpperCase(),
                                scaleFactorSoft,
                                () {
                                  setState(() {
                                    scaleFactorSoft = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorSoft = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Incidencias comunes')
                                    .toUpperCase(),
                                scaleFactorIncid,
                                () {
                                  setState(() {
                                    scaleFactorIncid = 1;
                                    toggleOverlay(2);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorIncid = 0.90);
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
        return OverlayPP(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlaySw(
          onClose: () => toggleOverlay(1),
        );
      case 2:
        return OverlayIncidencias(
          onClose: () => toggleOverlay(2),
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
                    style: TextStyle(
                      color: const Color(0xFF28E2F5),
                      fontSize: 22.sp,
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
