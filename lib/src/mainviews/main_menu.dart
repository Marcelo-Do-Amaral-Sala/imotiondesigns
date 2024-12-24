import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/bio/overlay_bio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/db_helper.dart';
import '../db/db_helper_pc.dart';
import '../db/db_helper_traducciones.dart';
import '../db/db_helper_web.dart';
import '../servicios/licencia_state.dart';
import '../servicios/sync.dart';
import '../servicios/translation_provider.dart'; // Importa el TranslationProvider

class MainMenuView extends StatefulWidget {
  final Function() onNavigateToPanel;
  final Function() onNavigateToClients;
  final Function() onNavigateToPrograms;
  final Function() onNavigateToAjustes;
  final Function() onNavigateToTutoriales;

  const MainMenuView({
    Key? key,
    required this.onNavigateToPanel,
    required this.onNavigateToClients,
    required this.onNavigateToPrograms,
    required this.onNavigateToAjustes,
    required this.onNavigateToTutoriales,
  }) : super(key: key);

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

  Map<String, String> _translations = {};
  final SyncService _syncService = SyncService();
  final DatabaseHelperTraducciones _dbHelperTraducciones =
  DatabaseHelperTraducciones();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _requestLocationPermissions();
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
        debugPrint("Inicializando base de datos para Web...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperWeb().initializeDatabase();
      } else if (Platform.isAndroid || Platform.isIOS) {
        debugPrint("Inicializando base de datos para Móviles...");
        await DatabaseHelper().initializeDatabase();
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        debugPrint("Inicializando base de datos para Desktop...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperPC().initializeDatabase();
      } else {
        throw UnsupportedError(
            'Plataforma no soportada para la base de datos.');
      }
      debugPrint("Base de datos inicializada correctamente.");
    } catch (e) {
      debugPrint("Error al inicializar la base de datos: $e");
    }
  }


  Future<void> _requestLocationPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      PermissionStatus permission = PermissionStatus.denied;

      if (Platform.isAndroid) {
        permission = await Permission.locationWhenInUse.request();
        if (permission == PermissionStatus.granted) {
          permission = await Permission.locationAlways.request();
        }
      } else if (Platform.isIOS) {
        permission = await Permission.locationWhenInUse.request();
        if (permission == PermissionStatus.granted) {
          permission = await Permission.locationAlways.request();
        }
      }

      if (permission == PermissionStatus.denied ||
          permission == PermissionStatus.permanentlyDenied) {
        debugPrint("Permiso de ubicación denegado o denegado permanentemente.");
        openAppSettings();
      } else {
        debugPrint("Permisos de ubicación concedidos.");
      }
    }
  }

  // Función de traducción utilitaria
  String tr(BuildContext context, String key) {
    return Provider.of<TranslationProvider>(context, listen: false)
        .translate(key);
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
                                tr(context, 'Panel de control').toUpperCase(),
                                scaleFactorPanel,
                                () {
                                  scaleFactorPanel = 1;
                                  widget.onNavigateToPanel();
                                },
                                () => setState(() => scaleFactorPanel = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/cliente.png',
                                tr(context, 'Clientes').toUpperCase(),
                                scaleFactorClient,
                                () {
                                  scaleFactorClient = 1;
                                  widget.onNavigateToClients();
                                },
                                () => setState(() => scaleFactorClient = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/programas.png',
                                tr(context, 'Programas').toUpperCase(),
                                scaleFactorProgram,
                                () {
                                  setState(() {
                                    scaleFactorProgram = 1;
                                    widget.onNavigateToPrograms();
                                  });
                                },
                                () => setState(() => scaleFactorProgram = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/bio.png',
                                tr(context, 'Bioimpedancia').toUpperCase(),
                                scaleFactorBio,
                                () {
                                  setState(() {
                                    scaleFactorBio = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                () => setState(() => scaleFactorBio = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/tutoriales.png',
                                tr(context, 'Tutoriales').toUpperCase(),
                                scaleFactorTuto,
                                () {
                                  setState(() {
                                    scaleFactorTuto = 1;
                                    widget.onNavigateToTutoriales();
                                  });
                                },
                                () => setState(() => scaleFactorTuto = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/ajustes.png',
                                tr(context, 'Ajustes').toUpperCase(),
                                scaleFactorAjustes,
                                () {
                                  setState(() {
                                    scaleFactorAjustes = 1;
                                    widget.onNavigateToAjustes();
                                  });
                                },
                                () => setState(() => scaleFactorAjustes = 0.90),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
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
        return Container();
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
            width: screenWidth * 0.25,
            height: screenHeight * 0.12,
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
                      Container(
                        padding: const EdgeInsets.only(left: 20.0),
                        width: screenWidth * 0.05,
                        height: screenHeight * 0.1,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
