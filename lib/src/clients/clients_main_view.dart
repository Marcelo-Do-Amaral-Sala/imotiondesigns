import 'dart:io'; // Importante para detectar la plataforma (Android/iOS vs PC)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../utils/translation_utils.dart';
import '../db/db_helper.dart';
import '../db/db_helper_pc.dart';
import '../db/db_helper_web.dart';
import 'overlays/overlays_clients.dart';

class ClientsView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  final double screenWidth;
  final double screenHeight;
  const ClientsView({super.key, required this.onBack, required this.screenWidth, required this.screenHeight});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  double scaleFactorBack = 1.0;
  double scaleFactorListado = 1.0;
  double scaleFactorCrear = 1.0;

  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
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
                                              'assets/images/cliente.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Clientes')
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
                                tr(context, 'Listado de clientes')
                                    .toUpperCase(),
                                scaleFactorListado,
                                () {
                                  setState(() {
                                    scaleFactorListado = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                // Index 0 para OverlayInfo
                                () {
                                  setState(() => scaleFactorListado = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Crear clientes')
                                    .toUpperCase(),
                                scaleFactorCrear,
                                () {
                                  setState(() {
                                    scaleFactorCrear = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorCrear = 0.90);
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
          if (isOverlayVisible)
            Positioned.fill(
              child: overlayIndex == 0
                  ? OverlayInfo(
                      onClose: () => toggleOverlay(0),
                    )
                  : OverlayCrear(
                      onClose: () => toggleOverlay(1),
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
