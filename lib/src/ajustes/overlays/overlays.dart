import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/form/user_form_bonos.dart';
import 'package:imotion_designs/src/ajustes/info/admins_activity.dart';
import 'package:imotion_designs/src/ajustes/info/admins_list_view.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/translation_utils.dart';
import '../../bio/overlay_bio.dart';
import '../../clients/overlays/main_overlay.dart';
import '../../db/db_helper.dart';
import '../../db/db_helper_traducciones.dart';
import '../../servicios/generate_pdf.dart';
import '../../servicios/licencia_state.dart';
import '../../servicios/recomendations.dart';
import '../../servicios/sync.dart';
import '../../servicios/translation_provider.dart';
import '../custom/imc_graph.dart';
import '../form/user_form.dart';
import '../info/admins_bonos.dart';
import '../info/admins_data.dart';

class OverlayBackup extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayBackup({super.key, required this.onClose});

  @override
  _OverlayBackupState createState() => _OverlayBackupState();
}

class _OverlayBackupState extends State<OverlayBackup>
    with SingleTickerProviderStateMixin {
  bool isBodyPro = true;
  String? selectedGender;
  bool showConfirmation = false;
  bool showConfirmationUpload = false;
  bool isLoading = false;
  double progress = 0.0; // Agregar variable de progreso
  String statusMessage = 'Listo para hacer la copia de seguridad';


  // Variable para definir la acción (subir o bajar)
  String actionMessage = '';
  String subActionMessage = '';
  String confirmationMessage = 'COPIA DE SEGURIDAD SUBIDA CON ÉXITO';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  // Función para subir la copia de seguridad
  Future<void> _uploadBackup() async {
    try {
      setState(() {
        isLoading = true;
        progress = 0.1; // Inicio del progreso
        statusMessage = 'Subiendo la copia de seguridad a GitHub...';
      });

      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.initializeDatabase(context);

      print('BASE DE DATOS INICIALIZADA');

      // Espera antes de subir el backup
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        progress = 0.3; // Progreso después de la espera
      });

      print('SUBIENDO BACKUP...');

      // Realiza la subida del backup a GitHub
      await DatabaseHelper.uploadDatabaseToGitHub('12345');

      setState(() {
        progress = 0.7; // Progreso después de subir el backup
      });

      // Reabrir la base de datos después de subir el backup
      await dbHelper.initializeDatabase(context);

      setState(() {
        progress = 1.0; // Progreso completo
        isLoading = false;
        statusMessage =
            'Copia de seguridad subida exitosamente a GitHub'; // Mensaje final
      });

      // Mostrar el mensaje de éxito durante 10 segundos
      setState(() {
        showConfirmationUpload = true;
      });

      // Esperar 10 segundos antes de ocultar el mensaje
      await Future.delayed(Duration(seconds: 5));

      // Después de 10 segundos, ocultar el mensaje de confirmación
      if (mounted) {
        setState(() {
          showConfirmationUpload = false;
          widget.onClose();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        progress = 0.0; // Resetear el progreso en caso de error
        statusMessage = 'Error al subir la copia de seguridad: $e';
      });
    }
  }

  // Función para descargar la copia de seguridad
  Future<void> _downloadBackup() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Imprimir el estado actual de la base de datos antes de hacer cualquier cosa
      debugPrint(
          "Estado de la base de datos antes de la inicialización: ${db.isOpen ? 'Abierta' : 'Cerrada'}");

      setState(() {
        isLoading = true;
        progress = 0.1; // Inicio del progreso
        statusMessage = 'Descargando la copia de seguridad desde GitHub...';
      });

      // Inicializar la base de datos (asegúrate de que esté abierta después de la eliminación)
      await dbHelper.initializeDatabase(context);
      setState(() {
        progress = 0.3; // Progreso después de la inicialización
      });

      // Verificar si la base de datos está abierta después de la inicialización
      if (!db.isOpen) {
        throw Exception(
            'La base de datos no se pudo abrir después de la inicialización');
      }

      debugPrint("Database open (after re-opening): ${db.isOpen}");

      // Descargar la copia de seguridad desde GitHub
      await DatabaseHelper.downloadDatabaseFromGitHub('12345');
      setState(() {
        progress = 0.7; // Progreso después de la descarga
      });

      // Verificar nuevamente si la base de datos sigue abierta después de la descarga
      final dbAfterDownload = await dbHelper.database;
      debugPrint(
          "Estado de la base de datos después de la descarga: ${dbAfterDownload.isOpen ? 'Abierta' : 'Cerrada'}");

      if (!dbAfterDownload.isOpen) {
        throw Exception('La base de datos está cerrada después de la descarga');
      }

      setState(() {
        progress = 1.0; // Progreso completo
        isLoading = false;
        statusMessage = 'Copia de seguridad descargada exitosamente';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          progress = 0.0; // Resetear el progreso en caso de error
          statusMessage = 'Error al descargar la copia de seguridad: $e';
        });
      }
      print("Error durante la descarga del backup: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Copia de seguridad').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.04),
        child: Column(
          children: [
            // Título y botones de acción
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showConfirmation = true;
                        actionMessage = tr(context,
                            '¿Seguro que quieres hacer la copia de seguridad?');
                        subActionMessage =
                            tr(context, 'Sobreescribirás tu copia anterior');
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01),
                      side: BorderSide(
                          width: screenWidth * 0.001,
                          color: const Color(0xFF2be4f3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, 'Hacer copia').toUpperCase(),
                      style: TextStyle(
                          color: const Color(0xFF2be4f3),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showConfirmation = true;
                        actionMessage = tr(context,
                            '¿Seguro que quieres restaurar la copia de seguridad?');
                        subActionMessage = tr(context,
                            'La aplicación se reiniciará después de la descarga');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                      backgroundColor: const Color(0xFF2be4f3),
                    ),
                    child: Text(
                      tr(context, 'Recuperar copia').toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Verificación de estado de progreso o confirmación
            if (isLoading) ...[
              SizedBox(height: screenHeight * 0.05),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2be4f3)),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                statusMessage,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
                textAlign: TextAlign.center,
              ),
            ] else if (showConfirmationUpload) ...[
              SizedBox(height: screenHeight * 0.05),
              Text(
                confirmationMessage,
                style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              if (showConfirmation) ...[
                SizedBox(height: screenHeight * 0.02),
                Text(
                  actionMessage,
                  style: TextStyle(fontSize: 25.sp, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subActionMessage,
                  style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          if (actionMessage.contains('hacer la copia')) {
                            await _uploadBackup(); // Subir backup
                            setState(() {
                              // Después de la subida, mostramos el mensaje de éxito
                              showConfirmationUpload = true;
                              actionMessage =
                                  "COPIA DE SEGURIDAD SUBIDA EXITOSAMENTE";
                              subActionMessage = "";
                            });
                          } else {
                            await _downloadBackup(); // Descargar backup
                            await Restart.restartApp();
                          }
                          setState(() {
                            showConfirmationUpload =
                                true; // Ocultar confirmación después de la acción
                          });
                        } catch (e) {
                          print('Error al procesar la copia de seguridad: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                            vertical: screenHeight * 0.01),
                        side: BorderSide(
                            width: screenWidth * 0.001, color: Colors.green),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        tr(context, 'Sí').toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showConfirmation = false; // Ocultar la confirmación
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                            vertical: screenHeight * 0.01),
                        side: BorderSide(
                            width: screenWidth * 0.001, color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        tr(context, 'No').toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }
}

class OverlayIdioma extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayIdioma({super.key, required this.onClose});

  @override
  _OverlayIdiomaState createState() => _OverlayIdiomaState();
}

class _OverlayIdiomaState extends State<OverlayIdioma> {
  String? _selectedLanguage;
  Map<String, String> _translations = {};
  Map<String, Map<String, String>> _translationsCache =
      {}; // Caché de traducciones
  final SyncService _syncService = SyncService();
  final DatabaseHelperTraducciones _dbHelperTraducciones =
      DatabaseHelperTraducciones();

  final Map<String, String> _languageMap = {
    'ESPAÑOL': 'es',
    'ENGLISH': 'en',
    'ITALIANO': 'it',
    'FRANÇAIS': 'fr',
    'PORTUGÛES': 'pt',
    'DEUTSCH': 'dt',
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = AppStateIdioma.instance.currentLanguage;
    _loadTranslations();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _loadTranslations() async {
    // Sincronizar datos de Firebase a SQLite
    await _syncService.syncFirebaseToSQLite();
    if (_selectedLanguage != null) {
      // Cargar traducciones desde la caché o la base de datos
      _fetchLocalTranslations(_selectedLanguage!);
    }
  }

  // Consultar el caché y luego la base de datos si es necesario
  void _fetchLocalTranslations(String language) async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    await provider
        .changeLanguage(language); // Cambiar el idioma usando el provider
    if (mounted) {
      setState(() {
        _translations =
            provider.translations; // Obtener las traducciones actualizadas
      });
    }
  }

  void _changeAppLanguage(String language) {
    AppStateIdioma.instance.currentLanguage = language;
    AppStateIdioma.instance.saveLanguage(language);

    final provider = context.read<TranslationProvider>(); // 🔹 Obtener Provider correctamente
    provider.changeLanguage(language).then((_) { // 🔹 Esperamos a que se actualicen las traducciones
      if (mounted) {
        setState(() {}); // 🔹 Forzamos la actualización de la UI inmediatamente
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslationProvider>(); // 🔹 Escucha cambios del provider
    final translations = provider.translations;

    return MainOverlay(
      title: Text(
        translations['Idioma']?.toUpperCase() ?? 'IDIOMA',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // 🔹 Hace la lista deslizable si es necesario
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _languageMap.keys.take(3).map((language) {
                          return buildCustomCheckboxTile(language);
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _languageMap.keys.skip(3).map((language) {
                          return buildCustomCheckboxTile(language);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.00001,
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_selectedLanguage != null) {
                        _changeAppLanguage(_selectedLanguage!);
                      }
                      setState(() {});
                      widget.onClose();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      side: BorderSide(
                        width: MediaQuery.of(context).size.width * 0.001,
                        color: const Color(0xFF2be4f3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: const Color(0xFF2be4f3),
                    ),
                    child: Text(
                      translations['Seleccionar']?.toUpperCase() ??
                          'SELECCIONAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }


  Widget buildCustomCheckboxTile(String language) {
    return Column(
      children: [
        ListTile(
          leading: customCheckbox(language),
          title: Text(
            language,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedLanguage = _languageMap[language];
              _changeAppLanguage(_selectedLanguage!);
            });
          },
        ),
      ],
    );
  }

  Widget customCheckbox(String language) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = _languageMap[language];
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.05,
        height: MediaQuery.of(context).size.height * 0.05,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.001, vertical: screenHeight * 0.001),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedLanguage == _languageMap[language]
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: _selectedLanguage == _languageMap[language]
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: screenWidth * 0.001,
          ),
        ),
      ),
    );
  }
}

class OverlayServicio extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayServicio({super.key, required this.onClose});

  @override
  _OverlayServicioState createState() => _OverlayServicioState();
}

class _OverlayServicioState extends State<OverlayServicio>
    with SingleTickerProviderStateMixin {
  bool isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleOverlay() {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
    });

    debugPrint('isOverlayVisible después de toggleOverlay: $isOverlayVisible');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        MainOverlay(
          title: Text(
            tr(context, 'Servicio técnico').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2be4f3),
            ),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, vertical: screenHeight * 0.03),
            child: Column(
              children: [
                // Título "Contacto"
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Text(
                    tr(context, 'Contacto').toUpperCase(),
                    style: TextStyle(
                        color: const Color(0xFF28E2F5),
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                // Descripción del servicio
                Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: Text(
                    tr(context,
                        'Estamos listos para ayudarte, contacta con nuestro servicio técnico y obtén asistencia profesional'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Contenedor con el contacto y el botón de engranaje
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        // Contenedor de Información de Contacto
                        Container(
                          width: screenWidth * 0.8,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 46, 46, 46),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.03),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "E-MAIL: technical_service@i-motiongroup.com",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                "WHATSAPP: (+34) 618 112 271",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Botón de engranaje en la esquina inferior derecha
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon:
                            Icon(Icons.settings, color: Colors.white, size: 30),
                            onPressed: () {
                              toggleOverlay(); // Muestra el overlay de servicio
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          onClose: widget.onClose,
        ),

        // Overlay de Servicio Técnico (se muestra si isOverlayVisible es true)
        if (isOverlayVisible)
          Positioned.fill(
            child: OverlayOperacion(
              onClose: () {
                toggleOverlay(); // Oculta el overlay cuando se cierra
              },
            ),
          ),
      ],
    );
  }
}

class OverlayOperacion extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayOperacion({super.key, required this.onClose});

  @override
  _OverlayOperacionState createState() => _OverlayOperacionState();
}

class _OverlayOperacionState extends State<OverlayOperacion>
    with SingleTickerProviderStateMixin {
  final _operationController = TextEditingController();
  List<int> _randomNumbers = [];
  int _correctSum = 0;
  String _errorMessage = '';
  bool _isVerified = false; // Nueva variable de estado

  @override
  void initState() {
    super.initState();
    _generateRandomNumbers();
  }

  void _generateRandomNumbers() {
    final random = Random();
    _randomNumbers = List.generate(4, (_) => random.nextInt(10) + 1);
    _correctSum = _randomNumbers.reduce((a, b) => a + b);
    setState(() {});
  }

  void _verifySum() {
    if (int.tryParse(_operationController.text) == _correctSum) {
      setState(() {
        _errorMessage = '';
        _isVerified = true; // Cambia la vista a la nueva pantalla
      });
      debugPrint('Verificación correcta');
    } else {
      setState(() {
        _errorMessage = 'Resultado erróneo';
      });
    }
  }

  @override
  void dispose() {
    _operationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        _isVerified
            ? tr(context, 'Soporte técnico')
                .toUpperCase() // Título cambia si se verifica
            : tr(context, 'Verificación de seguridad').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenHeight * 0.03),
        child: SingleChildScrollView(
          child: _isVerified
              ? _buildSuccessContent()
              : _buildVerificationContent(),
        ),
      ),
      onClose: widget.onClose,
    );
  }

// Nueva pantalla cuando la verificación es correcta
  Widget _buildSuccessContent() {
    double buttonSize = 120.sp; // Tamaño uniforme para los botones
    double spacing = 15.sp; // Espaciado entre botones
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<String> buttonTexts = [
      tr(context, 'Importar cliente'),
      tr(context, 'Recargar programas'),
      tr(context, 'Recargar MCI 18000'),
      tr(context, 'Buscar MyBodyPro'),
      tr(context, 'Tiempo a 100'),
    ];
    // Lista de funciones correspondientes a cada botón
    List<VoidCallback> buttonActions = [
      () => debugPrint("Importar cliente presionado"),
      () => debugPrint("Recargar programas presionado"),
      () => debugPrint("Recargar MCI 18000 presionado"),
      () => debugPrint("Buscar MyBodyPro presionado"),
      () => debugPrint("Tiempo a 100 presionado"),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primera fila con 3 botones
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: OutlinedButton(
                    onPressed: buttonActions[index],
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01),
                      side: BorderSide(
                        width: screenWidth * 0.001,
                        color: const Color(0xFF2be4f3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Color.fromARGB(255, 46, 46, 46),
                    ),
                    child: Text(
                      tr(context, buttonTexts[index]).toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: spacing),
          // Segunda fila con 2 botones centrados entre los espacios de la fila superior
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing * 1.5),
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: OutlinedButton(
                    onPressed: buttonActions[index + 3],
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01),
                      side: BorderSide(
                        width: screenWidth * 0.001,
                        color: const Color(0xFF2be4f3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Color.fromARGB(255, 46, 46, 46),
                    ),
                    child: Text(
                      tr(context, buttonTexts[index + 3]).toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Pantalla original con el formulario de verificación
  Widget _buildVerificationContent() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          tr(context, 'Para continuar resuelva:'),
          style: TextStyle(
              color: Colors.white,
              fontSize: 25.sp,
              fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.05),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _randomNumbers.join('  '),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _operationController,
                    style: _inputTextStyle,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecorationStyle(
                      hintText: tr(context, 'Introduce el resultado'),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14.sp),
                      ),
                    ),
                  OutlinedButton(
                    onPressed: _verifySum,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                          vertical: screenHeight * 0.01),
                      side: BorderSide(
                        width: screenWidth * 0.001,
                        color: const Color(0xFF2be4f3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, 'Verificar').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
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
      ],
    );
  }

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: Colors.transparent,
      isDense: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
      enabled: enabled,
    );
  }

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);
}

class OverlayAdmins extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayAdmins({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayAdminsState createState() => _OverlayAdminsState();
}

class _OverlayAdminsState extends State<OverlayAdmins>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedAdminData;
  bool isInfoVisible = false;
  late TabController _tabController;

  void selectAdmin(Map<String, dynamic> adminData) {
    setState(() {
      selectedAdminData = adminData;
      isInfoVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, 'Administradores').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedAdminData != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
              ],
            )
          : AdminsListView(
              onAdminTap: (adminData) {
                selectAdmin(adminData);
              },
            ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {});
        },
        tabs: [
          _buildTab(tr(context, 'Datos personales').toUpperCase(), 0),
          _buildTab(tr(context, 'Bonos').toUpperCase(), 1),
          _buildTab(tr(context, 'Actividad').toUpperCase(), 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.black,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            decoration: _tabController.index == index
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        AdminsData(
          adminData: selectedAdminData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
        AdminsBonos(userDataBonos: selectedAdminData!),
        AdminsActivity(adminDataActivity: selectedAdminData!),
      ],
    );
  }
}

class OverlayCrearNuevo extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayCrearNuevo({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayCrearNuevoState createState() => _OverlayCrearNuevoState();
}

class _OverlayCrearNuevoState extends State<OverlayCrearNuevo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isUserSaved = false; // Variable to check if the client has been saved
  Map<String, dynamic>?
      selectedUserData; // Nullable Map, no late initialization required

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Crear nuevo').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
      onClose: widget.onClose,
    );
  }

  Future<void> _showAlert(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Aquí defines el ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.01,
                vertical: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr(context, '¡Alerta!').toUpperCase(),
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    tr(context, 'Debes completar el formulario para continuar')
                        .toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.01),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10.0),
                      side: BorderSide(
                        width: MediaQuery.of(context).size.width * 0.001,
                        color: const Color(0xFF2be4f3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      tr(context, '¡Entendido!').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          if (!isUserSaved) {
            _showAlert(context);
          }
        },
        child: AbsorbPointer(
          absorbing: !isUserSaved,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index != 0 && !isUserSaved) {
                return; // Don't switch tabs if not saved
              } else {
                setState(() {
                  _tabController.index = index;
                });
              }
            },
            tabs: [
              _buildTab(tr(context, 'Datos personales').toUpperCase(), 0),
              _buildTab(tr(context, 'Bonos').toUpperCase(), 1),
            ],
            indicator: const BoxDecoration(
              color: Color(0xFF494949),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
            ),
            dividerColor: Colors.black,
            labelColor: const Color(0xFF2be4f3),
            labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            decoration: _tabController.index == index
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        UserDataForm(
          onDataChanged: (data) {
            print(data); // Verify that the data is arriving correctly
            setState(() {
              isUserSaved = true; // Client has been saved
              selectedUserData = data; // Save the client data
            });
          },
        ),
        // Check if selectedClientData is not null before passing it to ClientsFormBonos
        selectedUserData != null
            ? UsersFormBonos(userDataBonos: selectedUserData!)
            : Center(child: Text("No client data available.")),
      ],
    );
  }
}

class OverlayVita extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayVita({super.key, required this.onClose});

  @override
  _OverlayVitaState createState() => _OverlayVitaState();
}

class _OverlayVitaState extends State<OverlayVita>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _userName = '';
  String? _clientName = '';
  String? _clientAge = '';
  String? _clientGender = '';
  int? _clientHeight;
  int? _clientWeight;
  String _userProfileType = '';
  String resumenRespuestas = "";
  bool hideOptions = false;
  bool hidePdf = true;
  bool isOverlayVisible = false; // Controla la visibilidad del overlay
  bool isClientSelected = false; // Controla la visibilidad del overlay
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  int currentQuestion = 0;
  List<Map<String, dynamic>> chatMessages = [];
  Map<String, dynamic> answers = {};
  double scaleFactorCliente = 1.0;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  List<Map<String, dynamic>> questions = [];
  late AnimationController _controller;
  bool _isVisible = false;
  List<String> messages = [
  ];
  int _currentMessageIndex = -1;
  bool _isCompleted = false;
  List<Map<String, dynamic>> allIndividualPrograms = [];
  List<Map<String, dynamic>> allRecoPrograms = [];
  List<Map<String, dynamic>> allAutoPrograms = [];

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4), // Misma duración que los mensajes
    );
    fetchAllPrograms();
    requestManageStoragePermission();
    requestStoragePermission();
    messages = [
      tr(context, 'Procesando información...'),
      tr(context, 'Obteniendo datos del cliente...'),
      tr(context, 'Creando rutinas personalizadas...'),
    ];
  }


  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      print("✅ Permiso de almacenamiento ya concedido.");
      return true;
    }

    var status = await Permission.storage.request();
    if (status.isGranted) {
      print("✅ Permiso de almacenamiento concedido.");
      return true;
    } else if (status.isDenied) {
      print("❌ Permiso de almacenamiento denegado.");
      return false;
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Permiso permanentemente denegado. Abriendo configuración...");
      await openAppSettings();
      return false;
    }
    return false;
  }

  Future<bool> requestManageStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      print("✅ Permiso de almacenamiento completo ya concedido.");
      return true;
    }

    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      print("✅ Permiso de almacenamiento completo concedido.");
      return true;
    } else if (status.isDenied) {
      print("❌ Permiso de almacenamiento denegado.");
      return false;
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Permiso permanentemente denegado. Abriendo configuración...");
      await openAppSettings();
      return false;
    }
    return false;
  }



  @override
  void dispose() {
    // Liberar recursos y reiniciar estados
    _scrollController.dispose();
    chatMessages.clear();
    answers.clear();
    questions.clear();
    currentQuestion = 0;
    isClientSelected = false;
    _controller.dispose();
    super.dispose();
  }

  void checkAndStartAnimation() {
    if (_allQuestionsAnswered()) {
      setState(() {
        _isVisible = true;
        _startMessageSequence();
      });
      _controller.forward().whenComplete(() {
        setState(() {
          _isCompleted = true;
          hidePdf = false;
        });
      });
    }
  }

  void _startMessageSequence() async {
    for (int i = 0; i < messages.length; i++) {
      await Future.delayed(Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentMessageIndex = i;
        });
      }
    }
  }

  Future<void> _checkUserLoginStatus() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Obtener el userId desde SharedPreferences
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      // Obtener los detalles del usuario
      Map<String, dynamic>? user = await dbHelper.getUserById(userId);
      if (user != null) {
        setState(() {
          _userName = user['name']; // Guardar el nombre en la variable
        });

        // Obtener el tipo de perfil del usuario
        String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId);
        setState(() {
          _userProfileType =
              tipoPerfil ?? "Tipo no encontrado"; // Guardar el tipo de perfil
        });
      } else {
        print('No se encontró el usuario con ID $userId');
      }
    } else {
      print('No se encontró un user_id guardado en SharedPreferences');
    }
  }

  void toggleOverlay(int index) {
    if (mounted) {
      setState(() {
        isOverlayVisible = !isOverlayVisible;
        overlayIndex = isOverlayVisible ? index : -1;
        if (!isOverlayVisible) {
          updateClientData(); // Actualizar datos al cerrar el overlay
          // Cambiamos el estado para reflejar que el cliente está seleccionado
        }
      });
    }
  }

  List<Map<String, dynamic>> getQuestions(BuildContext context) {
    return [
      {
        "question": _clientName!.isNotEmpty
            ? tr(
                context,
                "¡Hola {name}! Vamos a crear tu informe y rutina i-motion personalizada de EMS. Primero, ¿cuál es tu objetivo principal?",
                namedArgs: {"name": _clientName!},
              )
            : tr(
                context,
                "¡Hola! Vamos a crear tu informe y rutina i-motion personalizada de EMS. Primero, ¿cuál es tu objetivo principal?",
              ),
        "options": [
          tr(context, "Tonificar"),
          tr(context, "Perder grasa"),
          tr(context, "Mejorar resistencia"),
          tr(context, "Mejorar todo"),
          tr(context, "Recuperación muscular"),
        ],
        "key": tr(context, "Objetivo"),
        "type": tr(context, "text"), // Tipo de pregunta
      },
      {
        "question": tr(context,
            "¿Tienes experiencia previa con electroestimulación o entrenamiento físico?"),
        "options": [
          tr(context, "Sí"),
          tr(context, "No"),
        ],
        "key": tr(context, "Experiencia"),
        "type": tr(context, "text"),
      },
      {
        "question": tr(
            context, "¿Cómo describirías tu nivel de condición física actual?"),
        "options": [
          tr(context, "Principiante"),
          tr(context, "Intermedio"),
          tr(context, "Avanzado"),
        ],
        "key": tr(context, "Nivel"),
        "type": tr(context, "text"),
      },
      {
        "question": tr(context,
            "¿Cuántos días a la semana puedes dedicar a entrenar con i-motion?"),
        "options": [
          tr(context, "1 día"),
          tr(context, "2 días"),
          tr(context, "3 días"),
        ],
        "key": tr(context, "Días"),
        "type": tr(context, "text"),
      },
    ];
  }

  void updateClientData() {
    if (selectedBioClient != null && selectedBioClient!.isNotEmpty) {
      setState(() {
        // 📌 Actualizar datos del cliente
        _clientName = selectedBioClient?['name'] ?? '';
        String birthdate = selectedBioClient?['birthdate'] ?? '';
        _clientGender = selectedBioClient?['gender'] ?? '';

        // 📌 Convertir fecha de nacimiento a edad
        try {
          _clientAge = calculateAge(birthdate).toString();
        } catch (e) {
          print('Error al calcular la edad: $e');
          _clientAge = 'Fecha inválida';
        }

        _clientHeight = selectedBioClient?['height'];
        _clientWeight = selectedBioClient?['weight'];

        // 📌 Reiniciar preguntas y chat
        resetQuestions();
        chatMessages.clear(); // Limpiar mensajes anteriores

        // 📌 Reiniciar animación y estado de generación
        _isVisible = false; // Oculta la animación
        _isCompleted = false; // Reinicia el estado de finalización
        hidePdf = true; // Oculta el PDF
        _currentMessageIndex = -1; // Reinicia los mensajes

        // 📌 Reiniciar animación
        _controller.reset(); // Detiene la animación y la reinicia

        // 📌 Asegurar que la primera pregunta se muestre
        if (questions.isNotEmpty) {
          chatMessages.add({
            "text": questions[0]["question"], // Primera pregunta
            "isBot": true,
          });
        }

        isClientSelected = true; // Cambiar el estado del cliente
      });
    } else {
      print("No se seleccionó un cliente");
      setState(() {
        isClientSelected = false;
      });
    }
  }

  void resetQuestions() {
    setState(() {
      // Limpia las preguntas y respuestas anteriores
      questions = getQuestions(context);
      answers.clear();
      chatMessages.clear();
      currentQuestion = 0;
      hideOptions = false; // Hacer visibles las opciones nuevamente
    });
  }

  int calculateAge(String birthdate) {
    try {
      // Formato de la fecha esperada: dd/mm/yyyy
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime birthDate = dateFormat.parse(birthdate);

      final DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      // Verifica si el cumpleaños aún no ha pasado este año
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      throw const FormatException(
          'Fecha inválida: asegúrate de usar el formato dd/mm/yyyy');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void handleResponse(dynamic response) {
    final key = questions[currentQuestion]["key"];
    if (key != null) {
      answers[key] = response; // Guarda la respuesta
    }

    setState(() {
      chatMessages.add(
          {"text": response.toString(), "isBot": false}); // Muestra respuesta
    });

    // Desplazar después de agregar la respuesta del usuario
    _scrollToBottom();

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        chatMessages.add(
          {"text": questions[currentQuestion]["question"], "isBot": true},
        );
      });

      // Desplazar después de agregar la pregunta del bot
      _scrollToBottom();
    } else {
      setState(() {
        chatMessages.add({
          "text":
              tr(context, "¡Gracias! Tu rutina personalizada ha sido generada"),
          "isBot": true,
        });
        hideOptions = true;
        checkAndStartAnimation();
      });

      // Desplazar al final después del mensaje final
      _scrollToBottom();

      // Llamar a mostrarResumen para calcular y preparar el resumen
      mostrarResumen();
    }
  }

  List<Map<String, String>> mostrarResumen() {
    // Crear una lista de títulos para las respuestas en orden
    List<String> titles = [
      tr(context, 'Objetivo'),
      tr(context, 'Experiencia en EMS'),
      tr(context, 'Condición física actual'),
      tr(context, 'Días de entrenamiento a la semana'),
    ];

    // Verificar si no hay respuestas
    if (answers.isEmpty) {
      return []; // Retornar una lista vacía si no hay respuestas
    }

    // Convertir las entradas del Map en una lista estructurada
    List<Map<String, String>> resumen = [];

    // Combinar títulos y respuestas
    answers.entries.toList().asMap().forEach((index, entry) {
      if (entry.value != null && entry.value.toString().isNotEmpty) {
        String title =
            titles.length > index ? titles[index] : "Respuesta $index";
        resumen.add({"title": title, "value": entry.value.toString()});
      }
    });

    return resumen;
  }

  Future<Map<String, dynamic>> obtenerRecomendacion(
      BuildContext context,
      Map<String, dynamic> answers,
      List<Map<String, dynamic>> allIndividualPrograms,
      List<Map<String, dynamic>> allRecoPrograms,
      List<Map<String, dynamic>> allAutoPrograms) async {

    // Obtener valores sin traducir directamente de `answers`
    String experiencia = answers[tr(context,"Experiencia")] ?? "";
    String condicion = answers[tr(context,"Nivel")] ?? "";
    String diasEntrenamientoStr = answers[tr(context,"Días")] ?? "0";
    int diasEntrenamiento =
        int.tryParse(RegExp(r'\d+').stringMatch(diasEntrenamientoStr) ?? "0") ?? 0;
    String objetivo = answers[tr(context,"Objetivo")] ?? "";

    print("🔍 Valores originales obtenidos:");
    print("Experiencia: $experiencia");
    print("Condición: $condicion");
    print("Días de entrenamiento: $diasEntrenamiento");
    print("Objetivo: $objetivo");

    // Obtener recomendación sin traducir
    FitnessRecommendation? recomendacionOriginal =
    getRecommendation(context, experiencia, condicion, diasEntrenamiento, objetivo);

    if (recomendacionOriginal == null) {
      return {
        "title": tr(context, "Recomendación"),
        "value": tr(context, "No disponible"),
        "images": [],
        "original": {
          "title": "Recomendación",
          "value": "No disponible",
        }
      };
    }

    // Aplicar traducción a la recomendación antes de devolverla
    FitnessRecommendation recomendacionTraducida = recomendacionOriginal.translated(context);

    print("✅ Recomendación original encontrada:");
    print(recomendacionOriginal.toString());

    print("🌍 Recomendación traducida:");
    print(recomendacionTraducida.toString());

    // Lista para almacenar los programas con sus imágenes en versión original y traducida
    List<Map<String, String>> programData = [];

    // Obtener nombres de los programas recomendados (versión original)
    List<String> programNamesOriginal = recomendacionOriginal.programas.split(', ');

    for (String program in programNamesOriginal) {
      Map<String, dynamic>? foundProgram;

      // Buscar en los programas automáticos
      foundProgram = allAutoPrograms.firstWhere(
            (p) => p["nombre"].toString().trim().toLowerCase() == program.trim().toLowerCase(),
        orElse: () => {},
      );

      // Si no se encuentra en automáticos, buscar en individuales
      if (foundProgram.isEmpty) {
        foundProgram = allIndividualPrograms.firstWhere(
              (p) => p["nombre"].toString().trim().toLowerCase() == program.trim().toLowerCase(),
          orElse: () => {},
        );
      }

      // Si no se encuentra en individuales, buscar en recovery
      if (foundProgram.isEmpty) {
        foundProgram = allRecoPrograms.firstWhere(
              (p) => p["nombre"].toString().trim().toLowerCase() == program.trim().toLowerCase(),
          orElse: () => {},
        );
      }

      // Si se encontró el programa, agregarlo a la lista
      if (foundProgram.isNotEmpty) {
        programData.add({
          "name_original": foundProgram["nombre"], // Nombre original del programa
          "name_translated": tr(context, foundProgram["nombre"]),
          "image": foundProgram["imagen"],
        });
      } else {
        print("❌ No se encontró imagen para el programa: $program");
      }
    }

    return {
      "title": tr(context, "Recomendación"),
      "value": recomendacionTraducida.toString(),
      "intensidad": recomendacionTraducida.intensidad,
      "duracion": recomendacionTraducida.duracion,
      "images": programData, // Lista con nombres de programas en versión original y traducida
      "original": {
        "title": "Recomendación",
        "value": recomendacionOriginal.toString(),
        "intensidad": recomendacionOriginal.intensidad,
        "duracion": recomendacionOriginal.duracion,
      }
    };
  }


  bool _allQuestionsAnswered() {
    return questions.every((q) => answers.containsKey(q['key']));
  }

  Map<String, dynamic> calcularIMC({
    required double peso,
    required double altura,
    required String genero,
  }) {
    if (peso > 0 && altura > 0 && genero.isNotEmpty) {
      double imc = peso / pow(altura / 100, 2);
      String classification = "";
      Color color = Colors.black;

      // Clasificación del IMC basada en _buildLegend()
      if (imc < 18.5) {
        classification = tr(context, 'Bajo peso');
        color = Colors.blue;
      } else if (imc >= 18.5 && imc < 24.9) {
        classification = tr(context, 'Normal');
        color = Colors.green;
      } else if (imc >= 25.0 && imc < 29.9) {
        classification = tr(context, 'Sobrepeso');
        color = Colors.yellow;
      } else {
        classification = tr(context, 'Obesidad');
        color = Colors.orange;
      }

      return {
        "imc": imc,
        "classification": classification,
        "color": color,
      };
    } else {
      return {
        "imc": 0.0,
        "classification": "",
        "color": Colors.grey,
      };
    }
  }

  // Captura el gráfico y la leyenda como una imagen
  Future<ui.Image> _captureWidget() async {
    final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    return image;
  }

  Future<Uint8List> _captureAsBytes() async {
    final image = await _captureWidget();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> fetchAllPrograms() async {
    final db = await DatabaseHelper().database;

    try {
      allAutoPrograms =
          await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);
      print("✅ Programas automáticos cargados: ${allAutoPrograms.length}");
    } catch (e) {
      print("❌ Error cargando programas automáticos: $e");
    }

    try {
      allIndividualPrograms = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoIndividual(db);
      print(
          "✅ Programas individuales cargados: ${allIndividualPrograms.length}");
    } catch (e) {
      print("❌ Error cargando programas individuales: $e");
    }

    try {
      allRecoPrograms = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoRecovery(db);
      print("✅ Programas de recuperación cargados: ${allRecoPrograms.length}");
    } catch (e) {
      print("❌ Error cargando programas de recuperación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final result = (_clientWeight != null &&
            _clientHeight != null &&
            _clientGender != null)
        ? calcularIMC(
            peso: _clientWeight!.toDouble(), // Peso en kg
            altura: _clientHeight!.toDouble(), // Altura en cm
            genero: _clientGender!, // Género
          )
        : {
            "imc": 0.0,
            "classification": tr(context, ''),
            // Mensaje para datos incompletos
            "color": Colors.grey,
          };

    Widget buildAnswerSection() {
      // Verificamos si un cliente ha sido seleccionado
      if (questions.isEmpty ||
          currentQuestion >= questions.length ||
          selectedBioClient == null ||
          selectedBioClient!.isEmpty) {
        return Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01,
              vertical: screenHeight * 0.02,
            ),
            child: Text(
              tr(context, "Seleccione un cliente para empezar").toUpperCase(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              color: const Color(0xFF2be4f3),
            ),
            ),
          ),
        );
      }
      if (questions[currentQuestion]["options"] != null) {
        // Dividir las opciones en filas con un máximo de 3 elementos por fila
        List<String> options = questions[currentQuestion]["options"];
        List<List<String>> rows = [];
        for (int i = 0; i < options.length; i += 3) {
          rows.add(options.skip(i).take(3).toList());
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
            vertical: screenHeight * 0.01,
          ),
          height: screenHeight * 0.15,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              top: BorderSide(
                color: const Color(0xFF2be4f3),
                width: screenWidth * 0.001,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows.map<Widget>((row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map<Widget>((option) {
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.005),
                      child: OutlinedButton(
                        onPressed: () => handleResponse(option),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                            vertical: screenHeight * 0.01,
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor:
                              const Color(0xFF2be4f3).withOpacity(0.5),
                          side: BorderSide(
                            color: const Color(0xFF2be4f3),
                            width: screenWidth * 0.001,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      } else {
        return const SizedBox();
      }
    }

    return isOverlayVisible
        ? _getOverlayWidget(overlayIndex)
        : MainOverlay(
            title: Text(
              tr(context, 'Asistente virtual').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2be4f3),
              ),
            ),
            content: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: screenHeight * 0.01),
              child: Row(
                children: [
                  // Primer Expanded: Contenedor del chat con imagen de fondo
                  Expanded(
                    flex: 1, // Proporción del espacio asignado al chat
                    child: Stack(
                      children: [
                        // Imagen de fondo
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 46, 46, 46),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              bottomLeft: Radius.circular(7),
                            ),
                          ),
                        ),
                        // Contenido del chat
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: screenHeight * 0.01),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                    vertical: screenHeight * 0.01),
                                height: screenHeight * 0.1,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                        height: screenHeight * 0.1,
                                        'assets/images/i-icon.png',
                                        fit: BoxFit.scaleDown),
                                    VerticalDivider(
                                      color: Colors.white,
                                      thickness: screenWidth * 0.001,
                                      width: screenWidth * 0.03,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          _userName,
                                          style: TextStyle(
                                              fontSize: 17.sp,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          _userProfileType == 'Ambos'
                                              ? tr(context, 'Ambos')
                                              : _userProfileType == 'Entrenador'
                                                  ? tr(context, 'Entrenador')
                                                  : _userProfileType ==
                                                          'Administrador'
                                                      ? tr(context,
                                                          'Administrador')
                                                      : _userProfileType,
                                          // Esto es por si el valor no coincide con ninguno de los anteriores
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          toggleOverlay(0);
                                        });
                                      },
                                      child: AnimatedScale(
                                        scale: scaleFactorCliente,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        child: Container(
                                          height: screenWidth * 0.05,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF494949),
                                            shape: BoxShape
                                                .circle, // Forma circular
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              height: screenHeight * 0.05,
                                              child: ClipOval(
                                                child: Image.asset(
                                                  'assets/images/cliente_ia.png',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: chatMessages.length,
                                itemBuilder: (context, index) {
                                  final message = chatMessages[index];
                                  return Align(
                                    alignment: message["isBot"]
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.25,
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.01,
                                        vertical: screenHeight * 0.03,
                                      ),
                                      padding:
                                          EdgeInsets.all(screenHeight * 0.01),
                                      decoration: BoxDecoration(
                                        color: message["isBot"]
                                            ? const Color(0xFF2be4f3)
                                            : Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: message["isBot"]
                                            ? [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right:
                                                          screenWidth * 0.01),
                                                  child: Image.asset(
                                                    'assets/images/icono-vita.png',
                                                    height: screenHeight * 0.07,
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    message["text"],
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                    textAlign: TextAlign.start,
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ]
                                            : [
                                                Expanded(
                                                  child: Text(
                                                    message["text"],
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: Colors.white),
                                                    textAlign: TextAlign.end,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: screenWidth * 0.01),
                                                  child: Image.asset(
                                                    'assets/images/cliente_ia.png',
                                                    height: screenHeight * 0.07,
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (!hideOptions) buildAnswerSection(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  //VerticalDivider(  color: Color(0xFF2be4f3).withOpacity(0.5),),
                  Expanded(
                    flex: 1, // Proporción del espacio asignado
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 46, 46, 46),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // 📌 SECCIÓN: TÍTULO
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.001),
                            child: Text(
                              tr(context, "Tus resultados").toUpperCase(),
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF2be4f3),
                                color: const Color(0xFF2be4f3),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // 📌 SECCIÓN: INFORMACIÓN DEL USUARIO
                          Table(
                            border: TableBorder.all(color: Color(0xFF2be4f3).withOpacity(0.5), width: screenWidth * 0.001),
                            columnWidths: {
                              0: IntrinsicColumnWidth(),
                              1: IntrinsicColumnWidth(),
                              2: IntrinsicColumnWidth(),
                              3: IntrinsicColumnWidth(flex: 2),
                              4: IntrinsicColumnWidth(),
                            },
                            children: [
                              // Fila de encabezados
                              TableRow(
                                decoration: BoxDecoration(color: Colors.black),
                                children: [
                                  for (var item in [
                                    {'label': tr(context, 'Nombre').toUpperCase()},
                                    {'label': tr(context, 'Género').toUpperCase()},
                                    {'label': tr(context, 'Edad').toUpperCase()},
                                    {'label': tr(context, 'Altura (cm)').toUpperCase()},
                                    {'label': tr(context, 'Peso (kg)').toUpperCase()},
                                  ])
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.008,
                                          vertical: screenHeight * 0.02,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          item['label']!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              // Fila de valores
                              TableRow(
                                children: [
                                  for (var item in [
                                    {'value': _clientName},
                                    {'value': _clientGender ?? ''},
                                    {'value': _clientAge?.toString() ?? ''},
                                    {'value': _clientHeight != null ? '$_clientHeight cm' : ''},
                                    {'value': _clientWeight != null ? '$_clientWeight kg' : ''},
                                  ])
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.002,
                                          vertical: screenHeight * 0.02,
                                        ),
                                        color: Color(0xFF2be4f3).withOpacity(0.1),
                                        alignment: Alignment.center,
                                        child: Text(
                                          item['value']!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          // 📌 SECCIÓN: IMC (GRÁFICO + LEYENDA)
                          RepaintBoundary(
                            key: _repaintBoundaryKey,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.01,
                                vertical: screenHeight * 0.02,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.12,
                                        height: screenHeight * 0.08,
                                        child: CustomPaint(
                                          painter: IMCLinearGaugePainter(
                                              imcValue: result['imc']),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'IMC: ${result['imc'].toStringAsFixed(1)}',
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                          ),
                                          SizedBox(width: screenWidth * 0.03),
                                          Text(
                                            result['classification'],
                                            // Muestra "Normal", "Sobrepeso", etc.
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: result[
                                                  'color'], // Color obtenido de calcularIMC()
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildLegend(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          // 📌 SECCIÓN RESERVADA PARA LA ANIMACIÓN
                          Container(
                            height: screenHeight * 0.2,
                            // Espacio fijo para la animación
                            alignment: Alignment.center,
                            child: _isVisible
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (!_isCompleted)
                                        AnimatedBuilder(
                                          animation: _controller,
                                          builder: (context, child) {
                                            return CustomPaint(
                                              size: Size(screenHeight * 0.1,
                                                  screenHeight * 0.1),
                                              painter: CircleFillPainter(
                                                  _controller.value),
                                            );
                                          },
                                        ),
                                      SizedBox(width: screenWidth * 0.01),

                                      // 📌 SECCIÓN FIJA: MENSAJES
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if (!_isCompleted)
                                              Text(
                                                tr(context, 'Generando tu pdf')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            if (_isCompleted)
                                              Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  tr(context,
                                                          "Pdf generado correctamente")
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.lightGreen,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            else
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: List.generate(
                                                  _currentMessageIndex + 1,
                                                  (index) => Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical:
                                                                screenHeight *
                                                                    0.001),
                                                    child: Text(
                                                      messages[index],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ),

                          // 📌 SECCIÓN FIJA: BOTONES
                          if (!hidePdf) ...[
                            Column(
                              children: [
                                Text(
                                  tr(context, "Consulte aquí sus resultados")
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: (selectedBioClient != null && _allQuestionsAnswered())
                                          ? () async {
                                        final resumen = mostrarResumen();
                                              final recomendacion =
                                                  await obtenerRecomendacion(
                                                    context,
                                                      answers,
                                                      allIndividualPrograms,
                                                      allRecoPrograms,
                                                      allAutoPrograms);
                                              final imageBytes =
                                                  await _captureAsBytes();
                                              final result = calcularIMC(
                                                  peso:
                                                      _clientWeight!.toDouble(),
                                                  altura:
                                                      _clientHeight!.toDouble(),
                                                  genero: _clientGender!);

                                              final generator = CustomPdfGenerator();
                                        final sanitizedClientName =
                                        _clientName!
                                            .replaceAll(
                                            RegExp(r'[^\w\s]'),
                                            '')
                                            .replaceAll(' ', '_');
                                              final pdfFileName =
                                                  'Informe_${sanitizedClientName.toLowerCase()}.pdf';

                                              await generator
                                            .generateAndSavePdf(
                                          context,
                                          pdfFileName,
                                          _clientName!,
                                          _clientGender!,
                                          _clientAge!,
                                          _clientHeight!,
                                          _clientWeight!,
                                          resumen,
                                          recomendacion,
                                          imageBytes,
                                          result,
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                                  content: Text(
                                                    tr(context,
                                                            'Pdf guardado en descargas')
                                                        .toUpperCase(),
                                                    style: TextStyle(color: Colors.white, fontSize: 17.sp),
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.02),
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        side: BorderSide(
                                            color: const Color(0xFF2be4f3),
                                            width: screenWidth * 0.001),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                      ),
                                      child: Text(
                                          tr(context, 'Descargar PDF')
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              color: Colors.white)),
                                    ),
                                    OutlinedButton(
                                      onPressed: (selectedBioClient != null &&
                                              _allQuestionsAnswered())
                                          ? () async {
                                              final resumen = mostrarResumen();
                                              final recomendacion =
                                                  await obtenerRecomendacion(
                                                    context,
                                                      answers,
                                                      allIndividualPrograms,
                                                      allRecoPrograms,
                                                      allAutoPrograms);
                                              final result = calcularIMC(
                                                  peso:
                                                      _clientWeight!.toDouble(),
                                                  altura:
                                                      _clientHeight!.toDouble(),
                                                  genero: _clientGender!);
                                              final imageBytes =
                                                  await _captureAsBytes();
                                              final generator =
                                                  CustomPdfGenerator();
                                              final sanitizedClientName =
                                                  _clientName!
                                                      .replaceAll(
                                                          RegExp(r'[^\w\s]'),
                                                          '')
                                                      .replaceAll(' ', '_');
                                              final pdfFileName =
                                                  'informe_${sanitizedClientName.toLowerCase()}.pdf';
                                              await generator
                                                  .generateAndOpenPdf(
                                                      context,
                                                      pdfFileName,
                                                      _clientName!,
                                                      _clientGender!,
                                                      _clientAge!,
                                                      _clientHeight!,
                                                      _clientWeight!,
                                                      resumen,
                                                      recomendacion,
                                                      imageBytes,
                                                      result);
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.02),
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            const Color(0xFF2be4f3),
                                        side: BorderSide(
                                            color: const Color(0xFF2be4f3),
                                            width: screenWidth * 0.001),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                      ),
                                      child: Text(
                                          tr(context, 'Ver PDF').toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onClose: widget.onClose,
          );
  }

// Generar la leyenda
  List<Widget> _buildLegend() {
    final colors = [
      Colors.blue, // Bajo peso
      Colors.green, // Normal
      Colors.yellow, // Sobrepeso
      Colors.orange, // Obesidad
    ];

    final labels = [
      '${tr(context, 'Bajo peso')}  (<18,5)',
      '${tr(context, 'Normal')} (18,5-24,9)',
      '${tr(context, 'Sobrepeso')} (25-29,9)',
      '${tr(context, 'Obesidad')} (>30)',
    ];

    return List.generate(colors.length, (index) {
      return Row(
        children: [
          // Círculo de color
          Container(
            width: MediaQuery.of(context).size.width * 0.02,
            height: MediaQuery.of(context).size.height * 0.02,
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.001,
          ),

          Text(
            labels[index],
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
          ),
        ],
      );
    });
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlaySeleccionarClienteBio(
          onClose: () => toggleOverlay(0),
        );
      default:
        return Container();
    }
  }
}

class OverlayMciInfo extends StatefulWidget {
  final String mac;
  final bool macBle;
  final String estado;
  final VoidCallback onClose;

  const OverlayMciInfo({
    Key? key,
    required this.mac,
    required this.macBle,
    required this.estado,
    required this.onClose,
  }) : super(key: key);

  @override
  _OverlayMciInfoState createState() => _OverlayMciInfoState();
}

class _OverlayMciInfoState extends State<OverlayMciInfo> {
  late String selectedEstado;

  @override
  void initState() {
    super.initState();
    selectedEstado = widget.estado;
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        'MCI',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.02,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Ensures Column takes only required space
            children: [
              // 🔹 Primer Row: MAC y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'MAC. ${widget.mac}',
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose, // Allows it to size itself properly
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado'.toUpperCase(),
                          style: _labelStyle,
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: _inputDecoration(),
                          child: AbsorbPointer(
                            child: DropdownButton<String>(
                              hint:
                                  Text('Seleccione', style: _dropdownHintStyle),
                              value: selectedEstado,
                              items: [
                                DropdownMenuItem(
                                  value: 'Activa',
                                  child:
                                      Text('Activa', style: _dropdownItemStyle),
                                ),
                                DropdownMenuItem(
                                  value: 'Inactiva',
                                  child: Text('Inactiva',
                                      style: _dropdownItemStyle),
                                ),
                              ],
                              onChanged: null,
                              dropdownColor: const Color(0xFF313030),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF2be4f3),
                                size: screenHeight * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // 🔹 Contenedor de Info y Recarga (Ambos en una fila)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Columna de Información
                  Flexible(
                    fit: FlexFit.loose, // Prevents infinite height error
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side: BorderSide(
                              width: screenWidth * 0.001,
                              color: const Color(0xFF2be4f3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            tr(context, 'Info').toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 46, 46, 46),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                // Allows it to take only necessary space
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildInfoRow('C: ', ''),
                                    _buildInfoRow('T: ', ''),
                                    _buildInfoRow('CT: ', ''),
                                    _buildInfoRow('CP: ', ''),
                                  ],
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildInfoRow('V: ', ''),
                                    _buildInfoRow('LS: ', ''),
                                    _buildInfoRow('FS: ', ''),
                                    _buildInfoRow('TS: ', ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.05),

                  // 🔹 Columna de Recarga
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            side: BorderSide(
                              width: screenWidth * 0.001,
                              color: const Color(0xFF2be4f3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            tr(context, 'Recarga').toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        // 🔹 Contenedor de recarga
                        Container(
                          height: screenHeight * 0.2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 46, 46, 46),
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          padding: EdgeInsets.all(screenWidth * 0.02),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Ajustes de estilos para simplificar
  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _dropdownHintStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownItemStyle =>
      TextStyle(color: Colors.white, fontSize: 15.sp);

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}

class OverlayLicenciaBloc extends StatefulWidget {
  final VoidCallback onClose;

  ///final Function() onNavigateToLogin;

  const OverlayLicenciaBloc({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  _OverlayLicenciaBlocState createState() => _OverlayLicenciaBlocState();
}

class _OverlayLicenciaBlocState extends State<OverlayLicenciaBloc> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Aviso').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.02,
        ),
        child: SingleChildScrollView(
          // 🔹 Permite desplazamiento
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // 🔹 Evita que el contenido ocupe espacio extra
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Mensaje principal
              Text(
                tr(context,
                    'Su licencia está bloqueada, por favor contacte con el servicio técnico'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.03),

              // 🔹 Contenedor con la información de contacto
              Container(
                width: screenWidth * 0.8,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenHeight * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "E-MAIL: technical_service@i-motiongroup.com",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "WHATSAPP: (+34) 618 112 271",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // 🔹 Botón de cerrar siempre accesible
              Align(
                alignment: Alignment.bottomRight,
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClose();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.01,
                      vertical: screenHeight * 0.01,
                    ),
                    side: BorderSide(
                        width: screenHeight * 0.001, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, 'Cerrar').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onClose: widget.onClose,
      isBloc: true,
    );
  }
}
