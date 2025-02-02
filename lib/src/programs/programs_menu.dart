import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/programs/overlays/overlays_programs.dart';

import '../../utils/translation_utils.dart';

class ProgramsMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  final double screenWidth;
  final double screenHeight;
  const ProgramsMenuView({super.key, required this.onBack, required this.screenWidth, required this.screenHeight});

  @override
  State<ProgramsMenuView> createState() => _ProgramsMenuViewState();
}

class _ProgramsMenuViewState extends State<ProgramsMenuView> {
  double scaleFactorBack = 1.0;
  double scaleFactorIndiv = 1.0;
  double scaleFactorAuto = 1.0;
  double scaleFactorRecovery = 1.0;
  double scaleFactorCrearP = 1.0;

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
      resizeToAvoidBottomInset: false,
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
                                              'assets/images/programas.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Programas')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: const Color(0xFF28E2F5),
                                                fontSize: 33.sp,
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
                                tr(context, 'Individuales').toUpperCase(),
                                scaleFactorIndiv,
                                () {
                                  setState(() {
                                    scaleFactorIndiv = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorIndiv = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Automáticos').toUpperCase(),
                                scaleFactorAuto,
                                () {
                                  setState(() {
                                    scaleFactorAuto = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorAuto = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Recovery').toUpperCase(),
                                scaleFactorRecovery,
                                () {
                                  setState(() {
                                    scaleFactorRecovery = 1;
                                    toggleOverlay(2);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorRecovery = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Crear programa').toUpperCase(),
                                scaleFactorCrearP,
                                () {
                                  setState(() {
                                    scaleFactorCrearP = 1;
                                    toggleOverlay(3);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorCrearP = 0.90);
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
        return OverlayIndividuales(
          onClose: () => toggleOverlay(0),
        );

      case 1:
        return OverlayAuto(
          onClose: () => toggleOverlay(1),
        );
      case 2:
        return OverlayRecovery(
          onClose: () => toggleOverlay(2),
        );
      case 3:
        return OverlayCrearPrograma(
          onClose: () => toggleOverlay(3),
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
