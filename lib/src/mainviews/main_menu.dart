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
import '../db/db_helper_traducciones_pc.dart';
import '../db/db_helper_traducciones_web.dart';
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
  final double screenWidth;
  final double screenHeight;

  const MainMenuView({
    Key? key,
    required this.onNavigateToPanel,
    required this.onNavigateToClients,
    required this.onNavigateToPrograms,
    required this.onNavigateToAjustes,
    required this.onNavigateToTutoriales,
    required this.screenWidth,
    required this.screenHeight,
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
  bool _isImagesLoaded = false;
  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  Map<String, String> _translations = {};
  final SyncService _syncService = SyncService();
  final DatabaseHelperTraducciones _dbHelperTraducciones =
      DatabaseHelperTraducciones();
  Map<int, String> imagePathsApp = {
    1: 'assets/images/fondo.jpg',
    2: 'assets/images/logo.png',
    3: 'assets/images/recuadro.png',
    4: 'assets/images/back.png',
    5: 'assets/images/tick.png',
    6: 'assets/images/papelera.png',
    7: 'assets/images/ajustes.png',
    8: 'assets/images/bio.png',
    9: 'assets/images/cliente.png',
    10: 'assets/images/panel.png',
    11: 'assets/images/programas.png',
    12: 'assets/images/tutoriales.png',
    13: 'assets/images/avatar_back.png',
    14: 'assets/images/avatar_front.png',
    15: 'assets/images/Abdominales.png',
    16: 'assets/images/Isquios.png',
    17: 'assets/images/Pectorales.png',
    18: 'assets/images/Cuádriceps.png',
    19: 'assets/images/Dorsales.png',
    20: 'assets/images/Gemelos.png',
    21: 'assets/images/Glúteos.png',
    22: 'assets/images/Lumbares.png',
    23: 'assets/images/Bíceps.png',
    24: 'assets/images/Trapecios.png',
    25: 'assets/images/ABDOMINAL.png',
    26: 'assets/images/BASIC.png',
    27: 'assets/images/BODYBUILDING.png',
    28: 'assets/images/BODYBUILDING2.png',
    29: 'assets/images/CALIBRACION.png',
    30: 'assets/images/CAPILLARY.png',
    31: 'assets/images/CARDIO.png',
    32: 'assets/images/CELULITIS.png',
    33: 'assets/images/CONTRACTURAS.png',
    34: 'assets/images/DEFINICION.png',
    35: 'assets/images/DOLORMECANICO.png',
    36: 'assets/images/DOLORNEU.png',
    37: 'assets/images/DOLORQUIM.png',
    38: 'assets/images/DRENAJE.png',
    39: 'assets/images/FITNESS.png',
    40: 'assets/images/GLUTEOS.png',
    41: 'assets/images/METABOLIC.png',
    42: 'assets/images/RELAX.png',
    43: 'assets/images/RESISTENCIA.png',
    44: 'assets/images/SLIM.png',
    45: 'assets/images/programacreado.png',
    46: 'assets/images/STRENGTH.png',
    47: 'assets/images/STRENGTH1.png',
    48: 'assets/images/STRENGTH2.png',
    49: 'assets/images/SUELOPELV.png',
    50: 'assets/images/WARMUP.png',
    51: 'assets/images/CROSSMAX.png',
    52: 'assets/images/HIPERTROFIA.png',
    53: 'assets/images/RESISTENCIA.png',
    54: 'assets/images/RESISTENCIA(ENDURANCE).png',
    55: 'assets/images/RESISTENCIA2(ENDURANCE2).png',
    56: 'assets/images/TONING.png',
    57: 'assets/images/PAUSA.png',
    58: 'assets/images/RAMPA.png',
    59: 'assets/images/CONTRACCION.png',
    60: 'assets/images/pantalon_front.png',
    61: 'assets/images/pantalon_post.png',
    62: 'assets/images/lumbar_pantalon.png',
    63: 'assets/images/biceps_azul_pantalon.png',
    64: 'assets/images/isquios_pantalon.png',
    65: 'assets/images/gluteos_shape.png',
    66: 'assets/images/gluteoinf_pantalon.png',
    67: 'assets/images/gemelos_pantalon.png',
    68: 'assets/images/cuadriceps_pantalon.png',
    69: 'assets/images/abdomen_pantalon.png',
    70: 'assets/images/biceps-pantalon.png',
    71: 'assets/images/ibodyPro.png',
    72: 'assets/images/obtenerBio.png',
    73: 'assets/images/leerbio.png',
    74: 'assets/images/espana.png',
    75: 'assets/images/francia.png',
    76: 'assets/images/italia.png',
    77: 'assets/images/portugal.png',
    78: 'assets/images/reino-unido.png',
    79: 'assets/images/mujer.png',
    80: 'assets/images/repeat.png',
    81: 'assets/images/flderecha.png',
    82: 'assets/images/flizquierda.png',
    83: 'assets/images/chalecoblanco.png',
    84: 'assets/images/pantalonblanco.png',
    85: 'assets/images/virtualtrainer.png',
    86: 'assets/images/rayoaz.png',
    87: 'assets/images/rayoverd.png',
    88: 'assets/images/absazul.png',
    89: 'assets/images/pecazul.png',
    90: 'assets/images/cuazul.png',
    91: 'assets/images/gemelosazul.png',
    92: 'assets/images/bicepsazul.png',
    93: 'assets/images/gluteoazul.png',
    94: 'assets/images/dorsalazul.png',
    95: 'assets/images/isquioazul.png',
    96: 'assets/images/lumbarazul.png',
    97: 'assets/images/trapazul.png',
    98: 'assets/images/trap_gris.png',
    99: 'assets/images/trap_blanco.png',
    100: 'assets/images/trap_naranja.png',
    101: 'assets/images/lumbar_gris.png',
    102: 'assets/images/lumbar_gris_pantalon.png',
    103: 'assets/images/lumbar_blanco.png',
    104: 'assets/images/lumbar_naranja.png',
    105: 'assets/images/lumbar_naranja_pantalon.png',
    106: 'assets/images/abs_gris.png',
    107: 'assets/images/abs_blanco.png',
    108: 'assets/images/abs_naranja.png',
    109: 'assets/images/pec_gris.png',
    110: 'assets/images/pec_blanco.png',
    111: 'assets/images/pec_naranja.png',
    112: 'assets/images/biceps_blanco.png',
    113: 'assets/images/biceps_gris.png',
    114: 'assets/images/biceps_naranja.png',
    115: 'assets/images/cua_gris.png',
    116: 'assets/images/cua_blanco.png',
    117: 'assets/images/cua_naranja.png',
    118: 'assets/images/gemelos_gris.png',
    119: 'assets/images/gemelos_blanco.png',
    120: 'assets/images/gemelos_naranja.png',
    121: 'assets/images/dorsal_gris.png',
    122: 'assets/images/dorsal_blanco.png',
    123: 'assets/images/dorsal_naranja.png',
    124: 'assets/images/gluteo_blanco.png',
    125: 'assets/images/gluteo_gris.png',
    126: 'assets/images/gluteo_naranja.png',
    127: 'assets/images/isquio_gris.png',
    128: 'assets/images/isquio_blanco.png',
    129: 'assets/images/isquio_naranja.png',
    130: 'assets/images/lumbar_pantalon_azul.png',
    131: 'assets/images/biceps_blanco_pantalon.png',
    132: 'assets/images/cua_blanco_pantalon.png',
    133: 'assets/images/gemelo_blanco_pantalon.png',
    134: 'assets/images/lumbar_blanco_pantalon.png',
    135: 'assets/images/isquio_blanco_pantalon.png',
    136: 'assets/images/avatar_frontal.png',
    137: 'assets/images/avatar_post.png',
    138: 'assets/images/pantalon_frontal.png',
    139: 'assets/images/pantalon_posterior.png',
    140: 'assets/images/RESET.png',
    141: 'assets/images/average.png',
    142: 'assets/images/mas.png',
    143: 'assets/images/menos.png',
    144: 'assets/images/play.png',
    145: 'assets/images/pause.png',
    146: 'assets/images/RELOJ.png',
    147: 'assets/images/flecha-arriba.png',
    148: 'assets/images/flecha-abajo.png',
    149: 'assets/images/capa_pecho_azul.png',
    150: 'assets/images/capa_abs_azul.png',
    151: 'assets/images/capa_trap_azul.png',
    152: 'assets/images/capa_gem_azul.png',
    153: 'assets/images/capa_biceps_azul.png',
    154: 'assets/images/capa_cua_azul.png',
    155: 'assets/images/capa_dorsal_azul.png',
    156: 'assets/images/capa_gluteo_azul.png',
    157: 'assets/images/capa_lumbar_azul.png',
    158: 'assets/images/capa_isquio_azul.png',
    159: 'assets/images/capa_isquio_azul_pantalon.png',
    160: 'assets/images/capa_lumbar_azul_pantalon.png',
    161: 'assets/images/capa_abs_inf_azul_pantalon.png',
    162: 'assets/images/capa_abs_sup_azul_pantalon.png',
    163: 'assets/images/capa_glut_sup_azul_pantalon.png',
    164: 'assets/images/capa_glut_inf_azul_pantalon.png',
    165: 'assets/images/capa_biceps_azul_pantalon.png',
    166: 'assets/images/capa_cua_azul_pantalon.png',
    167: 'assets/images/capa_gem_azul_pantalon.png',
    168: 'assets/images/capa_pec_blanco.png',
    169: 'assets/images/capa_biceps_blanco.png',
    170: 'assets/images/capa_abs_blanco.png',
    171: 'assets/images/capa_cua_blanco.png',
    172: 'assets/images/capa_gemelo_blanco.png',
    173: 'assets/images/capa_trap_blanco.png',
    174: 'assets/images/capa_dorsal_blanco.png',
    175: 'assets/images/capa_lumbar_blanco.png',
    176: 'assets/images/capa_gluteo_blanco.png',
    177: 'assets/images/capa_isquio_blanco.png',
    178: 'assets/images/capa_isquio_blanco_pantalon.png',
    179: 'assets/images/capa_biceps_blanco_pantalon.png',
    180: 'assets/images/capa_abs_inf_blanco.png',
    181: 'assets/images/capa_abs_sup_blanco.png',
    182: 'assets/images/capa_glut_sup_blanco.png',
    183: 'assets/images/capa_glut_inf_blanco.png',
    184: 'assets/images/capa_cua_blanco_pantalon.png',
    185: 'assets/images/capa_gem_blanco_pantalon.png',
    186: 'assets/images/capa_lumbar_blanco_pantalon.png',
    187: 'assets/images/capa_abs_naranja.png',
    188: 'assets/images/capa_pec_naranja.png',
    189: 'assets/images/capa_biceps_naranja.png',
    190: 'assets/images/capa_cua_naranja.png',
    191: 'assets/images/capa_gemelos_naranja.png',
    192: 'assets/images/capa_trap_naranja.png',
    193: 'assets/images/capa_dorsal_naranja.png',
    194: 'assets/images/capa_lumbar_naranja.png',
    195: 'assets/images/capa_gluteo_naranja.png',
    196: 'assets/images/capa_isquio_naranja.png',
    197: 'assets/images/capa_abs_gris.png',
    198: 'assets/images/capa_pec_gris.png',
    199: 'assets/images/capa_biceps_gris.png',
    200: 'assets/images/capa_cua_gris.png',
    201: 'assets/images/capa_gemelos_gris.png',
    202: 'assets/images/capa_trap_gris.png',
    203: 'assets/images/capa_dorsal_gris.png',
    204: 'assets/images/capa_lumbar_gris.png',
    205: 'assets/images/capa_gluteos_gris.png',
    206: 'assets/images/capa_isquio_gris.png',
    207: 'assets/images/capa_isquio_naranja_pantalon.png',
    208: 'assets/images/capa_biceps_naranja_pantalon.png',
    209: 'assets/images/capa_abs_inf_naranja_pantalon.png',
    210: 'assets/images/capa_abs_sup_naranja_pantalon.png',
    211: 'assets/images/capa_glut_inf_naranja_pantalon.png',
    212: 'assets/images/capa_glut_sup_naranja_pantalon.png',
    213: 'assets/images/capa_gemelos_naranja_pantalon.png',
    214: 'assets/images/capa_lumbar_naranja_pantalon.png',
    215: 'assets/images/capa_cua_naranja_pantalon.png',
    216: 'assets/images/capa_cua_gris_pantalon.png',
    217: 'assets/images/capa_abs_inf_gris_pantalon.png',
    218: 'assets/images/capa_abs_sup_gris_pantalon.png',
    219: 'assets/images/capa_biceps_gris_pantalon.png',
    220: 'assets/images/capa_isquio_gris_pantalon.png',
    221: 'assets/images/capa_lumbar_gris_pantalon.png',
    222: 'assets/images/capa_gemelos_gris_pantalon.png',
    223: 'assets/images/capa_glut_inf_gris_pantalon.png',
    224: 'assets/images/capa_glut_sup_gris_pantalon.png',
    225: 'assets/images/fullscreen.png',
    226: 'assets/images/31.png',
    227: 'assets/images/30.png',
    228: 'assets/images/29.png',
    229: 'assets/images/28.png',
    230: 'assets/images/27.png',
    231: 'assets/images/26.png',
    232: 'assets/images/25.png',
    233: 'assets/images/24.png',
    234: 'assets/images/23.png',
    235: 'assets/images/22.png',
    236: 'assets/images/21.png',
    237: 'assets/images/20.png',
    238: 'assets/images/19.png',
    239: 'assets/images/18.png',
    240: 'assets/images/17.png',
    241: 'assets/images/16.png',
    242: 'assets/images/15.png',
    243: 'assets/images/14.png',
    244: 'assets/images/13.png',
    245: 'assets/images/12.png',
    246: 'assets/images/11.png',
    247: 'assets/images/10.png',
    248: 'assets/images/9.png',
    249: 'assets/images/8.png',
    250: 'assets/images/7.png',
    251: 'assets/images/6.png',
    252: 'assets/images/5.png',
    253: 'assets/images/4.png',
    254: 'assets/images/3.png',
    255: 'assets/images/2.png',
    256: 'assets/images/1.png',
    257: 'assets/images/seleccion_cliente.png',
  };

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _initializeDatabaseTraducciones();
    _requestLocationPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  } // Verificar que BLE esté inicializado correctamente

  Future<void> _preloadImages() async {
    // Itera sobre las claves del mapa (1 a 31)
    for (int key in imagePathsApp.keys) {
      String path = imagePathsApp[key]!; // Obtiene la ruta de la imagen
      await precacheImage(AssetImage(path), context); // Pre-carga la imagen
    }

    if (mounted) {
      // Cambia el estado una vez que todas las imágenes estén precargadas
      setState(() {
        _isImagesLoaded = true;
      });
    }
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

  Future<void> _initializeDatabaseTraducciones() async {
    try {
      if (kIsWeb) {
        debugPrint("Inicializando base de datos para Web...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperTraduccionesWeb().initializeDatabase();
      } else if (Platform.isAndroid || Platform.isIOS) {
        debugPrint("Inicializando base de datos para Móviles...");
        await DatabaseHelperTraducciones().initializeDatabase();
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        debugPrint("Inicializando base de datos para Desktop...");
        databaseFactory = databaseFactoryFfi;
        await DatabaseHelperTraduccionesPc().initializeDatabase();
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
