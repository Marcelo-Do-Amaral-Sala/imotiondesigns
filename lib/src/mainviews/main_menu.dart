import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imotion_designs/src/bio/overlay_bio.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/db_helper.dart';
import '../db/db_helper_pc.dart';
import '../db/db_helper_web.dart';


class MainMenuView extends StatefulWidget {
  final Function() onNavigateToClients;
  final Function() onNavigateToPrograms;
  final Function() onNavigateToAjustes;

  const MainMenuView({Key? key, required this.onNavigateToClients, required this.onNavigateToPrograms, required this.onNavigateToAjustes})
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
  int overlayIndex = -1; // -1 indica que no hay overlay visible


  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  Future<void> _initializeDatabase() async {
    try {
      if (kIsWeb) {
        // Para la plataforma web, usamos sqflite_common_ffi_web
        debugPrint("Inicializando base de datos para Web...");
        databaseFactory = databaseFactoryFfi;
        // Aquí no es necesario asignar `databaseFactory` para la web ya que sqflite_common_ffi_web lo maneja automáticamente
        await DatabaseHelperWeb()
            .initializeDatabase(); // Inicializamos la base de datos con el helper de Web
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Para plataformas móviles (Android/iOS)
        debugPrint("Inicializando base de datos para Móviles...");

        // Usamos el factory de sqflite para dispositivos móviles
        await DatabaseHelper()
            .initializeDatabase(); // Inicializamos la base de datos con el helper de móviles
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Para plataformas de escritorio (Windows, macOS, Linux)
        debugPrint("Inicializando base de datos para Desktop...");

        // En plataformas de escritorio, se usa `databaseFactoryFfi`
        databaseFactory =
            databaseFactoryFfi; // Usamos el backend FFI para escritorio

        await DatabaseHelperPC()
            .initializeDatabase(); // Inicializamos la base de datos con el helper de PC
      } else {
        // Caso para plataformas no soportadas (como WebAssembly, otros casos)
        throw UnsupportedError(
            'Plataforma no soportada para la base de datos.');
      }

      debugPrint("Base de datos inicializada correctamente.");
    } catch (e) {
      debugPrint("Error al inicializar la base de datos: $e");
    }
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
                                    widget.onNavigateToPrograms();
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
                                    toggleOverlay(0);
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
                                    widget.onNavigateToAjustes();
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
        return OverlayBioimpedancia(
          onClose: () => toggleOverlay(0),
        );

      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
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
