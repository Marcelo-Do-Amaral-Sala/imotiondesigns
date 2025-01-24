import 'dart:math';

import 'package:flutter/material.dart';
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
import '../../servicios/licencia_state.dart';
import '../../servicios/sync.dart';
import '../../servicios/translation_provider.dart';
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
            horizontal: screenWidth * 0.02, vertical: screenHeight * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, 'Hacer copia').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
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
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.01,
                        vertical: screenHeight * 0.01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: const Color(0xFF2be4f3),
                  ),
                  child: Text(
                    tr(context, 'Recuperar copia').toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (isLoading) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              LinearProgressIndicator(
                value: progress, // Aquí se usa el valor del progreso
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2be4f3)),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                statusMessage,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
                textAlign: TextAlign.center,
              ),
            ] else if (showConfirmationUpload) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                confirmationMessage, // Mostramos el mensaje dinámico
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              if (showConfirmation) ...[
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  actionMessage, // Mostramos el mismo mensaje dinámico
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subActionMessage, // Mostramos el mismo mensaje dinámico
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: Colors.orange,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                              subActionMessage =
                                  ""; // Limpiar el mensaje adicional si es necesario
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
                          borderRadius: BorderRadius.circular(7),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        tr(context, 'Sí').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
                          borderRadius: BorderRadius.circular(7),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        tr(context, 'No').toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Primera columna con parte de los ListTiles
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _languageMap.keys.take(3).map((language) {
                      return Column(
                        children: [
                          buildCustomCheckboxTile(language),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.02), // Espacio entre filas
                        ],
                      );
                    }).toList(),
                  ),
                ),
                // Segunda columna con el resto de los ListTiles
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _languageMap.keys.skip(3).map((language) {
                      return Column(
                        children: [
                          buildCustomCheckboxTile(language),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Expanded(
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
    return ListTile(
      leading: customCheckbox(language),
      title: Text(
        language,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedLanguage = _languageMap[language];
        });
      },
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
        width: MediaQuery.of(context).size.width * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
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
            Text(
              tr(context, 'Contacto').toUpperCase(),
              style: TextStyle(
                  color: const Color(0xFF28E2F5),
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              tr(context,
                  'Estamos listos para ayudarte, contacta con nuestro servicio técnico y obtén asistencia profesional'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 46, 46),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.03),
                child: Column(
                  children: [
                    Text(
                      "E-MAIL: technical_service@i-motiongroup.com",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
  String _clientName = '';
  String _clientAge = '';
  int _clientHeight = 0;
  int _clientWeight = 0;
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
    if(mounted) {
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

  List<Map<String, dynamic>> getQuestions() {
    return [
      {
        "question": _clientName.isNotEmpty
            ? "¡Hola $_clientName! Vamos a crear tu informe y rutina i-motion personalizada de EMS. Primero, ¿cuál es tu objetivo principal?"
            : "¡Hola! Vamos a crear tu informe y rutina i-motion personalizada de EMS. Primero, ¿cuál es tu objetivo principal?",
        "options": [
          "Tonificar",
          "Perder grasa",
          "Mejorar resistencia",
          "Mejorar todo",
          "Recuperación muscular"
        ],
        "key": "Objetivo",
        "type": "text" // Tipo de pregunta
      },
      {
        "question": "¿Cuál es tu edad?",
        "range": [18, 60], // Rango de opciones dinámicas
        "key": "Edad",
        "type": "dropdown" // Indica que es un menú desplegable
      },
      {
        "question": "¿Cuál es tu peso?",
        "range": [30, 200], // Cambiado a int
        "key": "Peso",
        "type": "dropdown"
      },
      {
        "question": "¿Cuál es tu altura?",
        "range": [120, 210], // Cambiado a int
        "key": "Altura",
        "type": "dropdown"
      },
      {
        "question":
            "¿Tienes experiencia previa con electroestimulación o entrenamiento físico?",
        "options": ["Sí", "No"],
        "key": "Experiencia",
        "type": "text"
      },
      {
        "question": "¿Cómo describirías tu nivel de condición física actual?",
        "options": ["Principiante", "Intermedio", "Avanzado"],
        "key": "Nivel",
        "type": "text"
      },
      {
        "question":
            "¿Cuántos días a la semana puedes dedicar a entrenar con i-motion?",
        "options": ["1 día", "2 días", "3 días"],
        "key": "Días",
        "type": "text"
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
      questions = getQuestions();
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        chatMessages.add(
          {"text": questions[currentQuestion]["question"], "isBot": true},
        );
      });
      _scrollToBottom();
    } else {
      // Generar el mensaje final del chat
      setState(() {
        chatMessages.add({
          "text": "¡Gracias! Tu rutina personalizada ha sido generada.",
          "isBot": true,
        });
        hideOptions = true;
      });
      _scrollToBottom();

      // Llamar a mostrarResumen para calcular y preparar el resumen
      mostrarResumen();
    }
  }

  void mostrarResumen() {
    // Construir el resumen de las respuestas del usuario
    String resumen =
        answers.entries.map((entry) => "${entry.value}").join("\n");

    // Verificar si los datos de peso y altura existen
    if (answers.containsKey('Peso') && answers.containsKey('Altura')) {
      try {
        // Asegurarse de que los valores sean convertidos a double
        double peso = (answers['Peso'] as int).toDouble();
        double altura = (answers['Altura'] as int).toDouble() /
            100; // Convertir cm a metros

        // Calcular el IMC
        double imc = peso / (altura * altura);
        resumen += "\nIMC: ${imc.toStringAsFixed(2)}";

        // Clasificación del IMC (opcional)
        if (imc < 18.5) {
          resumen += " (Bajo peso)";
        } else if (imc >= 18.5 && imc < 24.9) {
          resumen += " (Peso normal)";
        } else if (imc >= 25 && imc < 29.9) {
          resumen += " (Sobrepeso)";
        } else {
          resumen += " (Obesidad)";
        }
      } catch (e) {
        resumen += "\nError al calcular el IMC: $e";
      }
    } else {
      resumen += "\nIMC: No calculado (faltan datos de peso o altura)";
    }

    // Actualizar la variable del resumen
    setState(() {
      resumenRespuestas = resumen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget buildAnswerSection() {
      // Verificamos si un cliente ha sido seleccionado
      if (questions.isEmpty || currentQuestion >= questions.length || selectedBioClient == null || selectedBioClient!.isEmpty) {
        return Center(
          child: Text(
            tr(context, "Seleccione un cliente para empezar").toUpperCase(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2be4f3),
            ),
          ),
        );
      }

      if (questions[currentQuestion]["type"] == "dropdown") {
        // Código para el tipo dropdown
        final range = questions[currentQuestion]["range"] as List<int>;
        String key = questions[currentQuestion]["key"];
        int initialValue = answers[key] ?? range[0];
        FixedExtentScrollController controller =
            FixedExtentScrollController(initialItem: initialValue - range[0]);

        return Container(
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
          alignment: Alignment.center,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: screenHeight * 0.06,
            physics: const FixedExtentScrollPhysics(),
            useMagnifier: true,
            magnification: 1.4,
            onSelectedItemChanged: (index) {
              setState(() {
                // Asegurarse de que el valor sea convertido a int
                answers[key] = (range[0] + index).toInt();
              });
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                // Convertir el valor a int
                final value = (range[0] + index).toInt();

                String unit = "";
                if (key == "Edad") {
                  unit = "años";
                } else if (key == "Peso") {
                  unit = "kg";
                } else if (key == "Altura") {
                  unit = "cm";
                }

                return GestureDetector(
                  onTap: () {
                    // Pasar el valor como int al método handleResponse
                    handleResponse(value);
                  },
                  child: Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: Text(
                        "$value $unit",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: range[1] - range[0] + 1,
            ),
          ),
        );
      } else if (questions[currentQuestion]["options"] != null) {
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
              "ASISTENCIA VIRTUAL ",
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
                                        'assets/images/cliente_ia.png',
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
                                          _userProfileType,
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white),
                                        ),
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
                                              width: screenWidth * 0.05,
                                              height: screenHeight * 0.05,
                                              child: ClipOval(
                                                child: Image.asset(
                                                  'assets/images/cliente.png',
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
                                        maxWidth: screenWidth *
                                            0.25, // Limitar el ancho máximo del contenedor
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
                    flex:
                        1, // Proporción del espacio asignado al contenedor vacío
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.03),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 46, 46, 46),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Centrar el título en el Expanded
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.001,
                              ),
                              child: Text(
                                tr(context, "Tus resultados:").toUpperCase(),
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
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              // Distribuye horizontalmente
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr(context, 'Nombre').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _clientName,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr(context, 'Edad').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _clientAge,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr(context, 'Altura').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$_clientHeight cm',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr(context, 'Peso').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$_clientWeight kg',
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

                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01,
                                  vertical: screenHeight * 0.01),
                              child: Text(
                                resumenRespuestas.isNotEmpty
                                    ? resumenRespuestas
                                    : "",
                                style: TextStyle(
                                    fontSize: 17.sp, color: Colors.white),
                              ),
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {},
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
                              style: TextStyle(fontSize: 20.sp),
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
                      Text(
                        'INFO',
                        style: TextStyle(
                          color: const Color(0xFF2be4f3),
                          fontSize: 25.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
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
