import 'dart:io'; // Importante para detectar la plataforma (Android/iOS vs PC)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/db_helper.dart';
import '../db/db_helper_pc.dart';
import '../db/db_helper_web.dart';
import '../overlayviews/overlays.dart';

class ProgramsMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  const ProgramsMenuView({super.key, required this.onBack});

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
                                          const Expanded(
                                            child: Text(
                                              "PROGRAMAS",
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
                                'Individuales',
                                scaleFactorIndiv,
                                    () {
                                  setState(() {
                                    scaleFactorIndiv = 1;
                                    //toggleOverlay(0);
                                  });
                                },
                                // Index 0 para OverlayInfo
                                    () {
                                  setState(() => scaleFactorIndiv = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Automáticos',
                                scaleFactorAuto,
                                    () {
                                  setState(() {
                                    scaleFactorAuto = 1;
                                    //toggleOverlay(1);
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorAuto = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Recovery',
                                scaleFactorRecovery,
                                    () {
                                  setState(() {
                                    scaleFactorRecovery = 1;
                                    //toggleOverlay(2);
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorRecovery = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Crear programa',
                                scaleFactorCrearP,
                                    () {
                                  setState(() {
                                    scaleFactorCrearP = 1;
                                    //toggleOverlay(3);
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
                           /* if (isOverlayVisible)
                              Positioned.fill(
                                top: screenHeight * 0.12,
                                child: overlayIndex == 0
                                    ? OverlayInfo(
                                  onClose: () => toggleOverlay(0),
                                )
                                    : OverlayCrear(
                                  onClose: () => toggleOverlay(1),
                                ),
                              ),*/
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
