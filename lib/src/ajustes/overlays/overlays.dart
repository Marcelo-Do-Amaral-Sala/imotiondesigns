import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/form/user_form_bonos.dart';
import 'package:imotion_designs/src/ajustes/info/admins_activity.dart';
import 'package:imotion_designs/src/ajustes/info/admins_list_view.dart';
import 'package:intl/intl.dart';
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
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
      await dbHelper.initializeDatabase();

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
      await dbHelper.initializeDatabase();

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
      await dbHelper.initializeDatabase();
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

    final provider = Provider.of<TranslationProvider>(context, listen: false);
    provider.changeLanguage(language); // Cambiar el idioma usando el provider

    // Recargar las traducciones inmediatamente
    _fetchLocalTranslations(language);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Idioma').toUpperCase(),
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
            // Fila para las dos columnas
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Distribuye uniformemente
                children: [
                  // Primera columna con parte de los ListTiles
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Distribuye uniformemente
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _languageMap.keys.take(3).map((language) {
                        return buildCustomCheckboxTile(language);
                      }).toList(),
                    ),
                  ),
                  // Segunda columna con el resto de los ListTiles
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Distribuye uniformemente
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _languageMap.keys.skip(3).map((language) {
                        return buildCustomCheckboxTile(language);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Botón de selección en la parte inferior
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.03),
              child: Align(
                alignment: Alignment.bottomRight,
                child: OutlinedButton(
                  onPressed: () {
                    if (_selectedLanguage != null) {
                      _changeAppLanguage(
                          _selectedLanguage!); // Cambia el idioma seleccionado
                      setState(() {});
                    }
                    widget.onClose();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.01,
                        vertical: screenHeight * 0.01),
                    side: BorderSide(
                        width: screenWidth * 0.001,
                        color: const Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: const Color(0xFF2be4f3),
                  ),
                  child: Text(
                    tr(context, 'Seleccionar').toUpperCase(),
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
            });
          },
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height *
                0.02), // Espacio entre filas
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
            horizontal: screenWidth * 0.005, vertical: screenHeight * 0.001),
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
  bool isBodyPro = true;
  String? selectedGender;

  @override
  void initState() {
    super.initState();
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

            // Contenedor con el contacto
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: screenWidth * 0.8, // Ajuste de ancho
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 46, 46, 46),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Alineación vertical
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Alineación horizontal
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
                        // Espacio entre las líneas
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
                ),
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
    double screenWidth = MediaQuery.of(context).size.width;

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
                vertical: MediaQuery.of(context).size.height * 0.01,
                horizontal: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, '¡Alerta!').toUpperCase(),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  tr(context, 'Debes completar el formulario para continuar')
                      .toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side: BorderSide(
                      width: MediaQuery.of(context).size.height * 0.001,
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
  bool isOverlayVisible = false; // Controla la visibilidad del overlay
  bool isClientSelected = false; // Controla la visibilidad del overlay
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  int currentQuestion = 0;
  List<Map<String, dynamic>> chatMessages = [];
  Map<String, dynamic> answers = {};
  double scaleFactorCliente = 1.0;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
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

    super.dispose();
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
      print("Cliente seleccionado: $selectedBioClient");

      setState(() {
        // Actualizar datos del cliente
        _clientName = selectedBioClient?['name'] ?? '';
        String birthdate = selectedBioClient?['birthdate'] ?? '';
        _clientGender = selectedBioClient?['gender'] ?? '';

        // Convertir fecha de nacimiento a edad
        try {
          _clientAge = calculateAge(birthdate).toString();
        } catch (e) {
          print('Error al calcular la edad: $e');
          _clientAge = 'Fecha inválida';
        }

        _clientHeight = selectedBioClient?['height'];
        _clientWeight = selectedBioClient?['weight'];

        // Reiniciar preguntas y chat
        resetQuestions();

        // Asegurar que la primera pregunta se muestre
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

      // Clasificación del IMC para hombres y mujeres
      if (genero == 'Hombre') {
        if (imc < 17) {
          classification = tr(context, 'Desnutrición');
          color = Colors.purple;
        } else if (imc >= 17 && imc < 20) {
          classification = tr(context, 'Bajo peso');
          color = Colors.blue;
        } else if (imc >= 20 && imc < 25) {
          classification = tr(context, 'Normal');
          color = Colors.green;
        } else if (imc >= 25 && imc < 30) {
          classification = tr(context, 'Sobrepeso');
          color = Colors.yellow;
        } else if (imc >= 30 && imc < 35) {
          classification = tr(context, 'Obesidad');
          color = Colors.orange;
        } else if (imc >= 35 && imc < 40) {
          classification = tr(context, 'Obesidad marcada');
          color = Colors.red;
        } else {
          classification = tr(context, 'Obesidad mórbida');
          color = Colors.red[900]!;
        }
      } else if (genero == tr(context, 'Mujer')) {
        if (imc < 16) {
          classification = tr(context, 'Desnutrición');
          color = Colors.purple;
        } else if (imc >= 16 && imc < 21) {
          classification = tr(context, 'Bajo peso');
          color = Colors.blue;
        } else if (imc >= 21 && imc < 24) {
          classification = tr(context, 'Normal');
          color = Colors.green;
        } else if (imc >= 24 && imc < 30) {
          classification = tr(context, 'Sobrepeso');
          color = Colors.yellow;
        } else if (imc >= 30 && imc < 35) {
          classification = tr(context, 'Obesidad');
          color = Colors.orange;
        } else if (imc >= 35 && imc < 40) {
          classification = tr(context, 'Obesidad marcada');
          color = Colors.red;
        } else {
          classification = tr(context, 'Obesidad mórbida');
          color = Colors.red[900]!;
        }
      } else {
        classification = "N/A";
        color = Colors.grey;
      }

      return {
        "imc": imc,
        "classification": classification,
        "color": color,
      };
    } else {
      return {
        "imc": 0.0,
        "classification": "Datos incompletos",
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
            "classification": tr(context, 'Datos incompletos'),
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
                                                  ? tr(context, 'Tr entrenador')
                                                  : _userProfileType ==
                                                          'Administrador'
                                                      ? tr(context,
                                                          'Tr administrador')
                                                      : _userProfileType,
                                          // Esto es por si el valor no coincide con ninguno de los anteriores
                                          style: TextStyle(
                                            fontSize: 15.sp,
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
                  // Segundo Expanded: Contenedor vacío
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
                        children: [
                          // Título
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
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
                            ),
                          ),

                          // Información del cliente
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (var item in [
                                  {
                                    'label':
                                        tr(context, 'Nombre').toUpperCase(),
                                    'value': _clientName
                                  },
                                  {
                                    'label': tr(context, 'Género').toUpperCase(),
                                    'value': (_clientGender == null || _clientGender!.isEmpty)
                                        ? '' // Si _clientGender es nulo o está vacío, se asigna una cadena vacía
                                        : (_clientGender == 'Hombre'
                                        ? tr(context, 'Hombre') // Si es Hombre, se traduce como 'Hombre'
                                        : tr(context, 'Mujer')), // Si es Mujer, se traduce como 'Mujer'
                                  }
                                  ,

                                  {
                                    'label': tr(context, 'Edad').toUpperCase(),
                                    'value': _clientAge != null
                                        ? _clientAge.toString()
                                        : "",
                                    // Si _clientAge es nulo, muestra un texto vacío
                                  },
                                  {
                                    'label': tr(context, 'Altura (cm)')
                                        .toUpperCase(),
                                    'value': _clientHeight != null
                                        ? '$_clientHeight cm'
                                        : "",
                                    // Si _clientHeight es nulo, muestra un texto vacío
                                  },
                                  {
                                    'label':
                                        tr(context, 'Peso (kg)').toUpperCase(),
                                    'value': _clientWeight != null
                                        ? '$_clientWeight kg'
                                        : "",
                                    // Si _clientWeight es nulo, muestra un texto vacío
                                  },
                                ])
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        tr(context, item['label']!)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item['value']!,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Gráfico y leyenda
                          Expanded(
                            flex: 3,
                            child: RepaintBoundary(
                              key: _repaintBoundaryKey,
                              // Clave para capturar este widget
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01,
                                  vertical: screenHeight * 0.05,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.02,
                                          ),
                                          width: screenWidth * 0.2,
                                          height: screenHeight * 0.15,
                                          child: CustomPaint(
                                            painter: IMCGaugePainter(
                                                imcValue: result['imc']),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Text(
                                          'IMC: ${result['imc'].toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: _buildLegend(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.001),
                                child: Text(
                                  tr(context,
                                          "Según tus datos te recomendamos:")
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Botones
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: (selectedBioClient != null &&
                                          _allQuestionsAnswered())
                                      ? () async {
                                          final resumen = mostrarResumen();
                                          final result = calcularIMC(
                                            peso: _clientWeight!.toDouble(),
                                            altura: _clientHeight!.toDouble(),
                                            genero: _clientGender!,
                                          );
                                          final imageBytes =
                                              await _captureAsBytes();
                                          final generator =
                                              CustomPdfGenerator();
                                          final sanitizedClientName =
                                              _clientName!
                                                  .replaceAll(
                                                      RegExp(r'[^\w\s]'), '')
                                                  .replaceAll(' ', '_');
                                          final pdfFileName =
                                              'informe_${sanitizedClientName.toLowerCase()}.pdf';

                                          await generator.generateAndOpenPdf(
                                            context,
                                            pdfFileName,
                                            _clientName!,
                                            _clientGender!,
                                            _clientAge!,
                                            _clientHeight!,
                                            _clientWeight!,
                                            resumen,
                                            imageBytes,
                                            result,
                                          );
                                        }
                                      : null,
                                  // Botón desactivado si las condiciones no se cumplen
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF2be4f3),
                                    side: BorderSide(
                                      color: const Color(0xFF2be4f3),
                                      width: screenWidth * 0.001,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  child: Text(
                                    tr(context, 'Ver PDF').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors
                                          .white, // Mismo color para botón deshabilitado
                                    ),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: (selectedBioClient != null &&
                                          _allQuestionsAnswered())
                                      ? () async {
                                          final resumen = mostrarResumen();
                                          final imageBytes =
                                              await _captureAsBytes();
                                          final result = calcularIMC(
                                            peso: _clientWeight!.toDouble(),
                                            altura: _clientHeight!.toDouble(),
                                            genero: _clientGender!,
                                          );
                                          final generator =
                                              CustomPdfGenerator();
                                          final sanitizedClientName =
                                              _clientName!
                                                  .replaceAll(
                                                      RegExp(r'[^\w\s]'), '')
                                                  .replaceAll(' ', '_');
                                          final pdfFileName =
                                              'informe_${sanitizedClientName.toLowerCase()}.pdf';

                                          final file = await generator
                                              .generateAndSavePdf(
                                            context,
                                            pdfFileName,
                                            // Nombre dinámico con un número agregado si es necesario
                                            _clientName!,
                                            _clientGender!,
                                            _clientAge!,
                                            _clientHeight!,
                                            _clientWeight!,
                                            resumen,
                                            imageBytes,
                                            result,
                                          );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                tr(context,
                                                        'PDF guardado en DESCARGAS')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17.sp),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      : null,
                                  // Botón desactivado si las condiciones no se cumplen
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.02,
                                    ),
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.black,
                                    side: BorderSide(
                                      color: const Color(0xFF2be4f3),
                                      width: screenWidth * 0.001,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                  child: Text(
                                    tr(context, 'Descargar PDF').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      color: Colors
                                          .white, // Mismo color para botón deshabilitado
                                    ),
                                  ),
                                ),
                              ],
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
          );
  }

// Generar la leyenda
  List<Widget> _buildLegend() {
    final colors = [
      Colors.purple, // Desnutrición
      Colors.blue, // Bajo peso
      Colors.green, // Normal
      Colors.yellow, // Sobrepeso
      Colors.orange, // Obesidad
      Colors.red, // Obesidad marcada
      Colors.red[900]!, // Obesidad mórbida
    ];

    final labels = [
      tr(context, 'Desnutrición'),
      tr(context, 'Bajo peso'),
      tr(context, 'Normal'),
      tr(context, 'Sobrepeso'),
      tr(context, 'Obesidad'),
      tr(context, 'Obesidad marcada'),
      tr(context, 'Obesidad mórbida'),
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
            width: MediaQuery.of(context).size.width * 0.01,
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
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.02),
        child: Column(
          children: [
            // Primer Expanded para MAC y Dropdown de estado
            Expanded(
              flex: 1,
              child: Row(
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
                  Expanded(
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
                            // Bloquea la interacción
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
                              // Bloquea la acción de cambio
                              dropdownColor: const Color(0xFF313030),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF2be4f3),
                                size: screenHeight * 0.05,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  // Contenedor oscuro 1
                  Expanded(
                      child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(10.0),
                          side: BorderSide(
                              width: screenWidth * 0.001,
                              color: const Color(0xFF2be4f3)),
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
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 46, 46, 46),
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.01),
                          child: Row(
                            children: [
                              // Primera columna
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fila para C:
                                    Row(
                                      children: [
                                        Text(
                                          'C: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          // Espacio vacío para agregar el dato
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espacio entre las filas
                                    // Fila para T:
                                    Row(
                                      children: [
                                        Text(
                                          'T: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Fila para CT:
                                    Row(
                                      children: [
                                        Text(
                                          'CT: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Fila para CP:
                                    Row(
                                      children: [
                                        Text(
                                          'CP: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Espacio entre columnas
                              SizedBox(width: screenWidth * 0.01),
                              // Espacio entre la primera y segunda columna
                              // Segunda columna
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fila para V:
                                    Row(
                                      children: [
                                        Text(
                                          'V: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Row(
                                      children: [
                                        Text(
                                          'LS: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Fila para FS:
                                    Row(
                                      children: [
                                        Text(
                                          'FS: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Fila para TS:
                                    Row(
                                      children: [
                                        Text(
                                          'TS: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
                  SizedBox(width: screenWidth * 0.05),
                  Expanded(
                      child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(10.0),
                          side: BorderSide(
                              width: screenWidth * 0.001,
                              color: const Color(0xFF2be4f3)),
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
                      Container(
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 46, 46, 46),
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.01,
                              vertical: screenHeight * 0.01),
                          child: Container(),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }

  // Ajustes de estilos para simplificar
  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownHintStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  TextStyle get _dropdownItemStyle =>
      TextStyle(color: Colors.white, fontSize: 15.sp);

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
