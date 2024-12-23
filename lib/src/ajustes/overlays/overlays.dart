import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/form/user_form_bonos.dart';
import 'package:imotion_designs/src/ajustes/info/admins_activity.dart';
import 'package:imotion_designs/src/ajustes/info/admins_list_view.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';

import '../../../utils/translation_utils.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
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
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
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
                    padding: const EdgeInsets.all(10.0),
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
                style: const TextStyle(color: Colors.white, fontSize: 18),
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
                        padding: const EdgeInsets.all(10.0),
                        side: const BorderSide(width: 1.0, color: Colors.green),
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
                        padding: const EdgeInsets.all(10.0),
                        side: const BorderSide(width: 1.0, color: Colors.red),
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

class _OverlayIdiomaState extends State<OverlayIdioma>
    with SingleTickerProviderStateMixin {
  String? _selectedLanguage;
  Map<String, String> _translations = {};
  final SyncService _syncService = SyncService();
  final DatabaseHelperTraducciones _dbHelperTraducciones =
      DatabaseHelperTraducciones();
  String statusMessage = 'Listo para hacer la copia de seguridad';

  // Mapa de nombres visibles y sus valores internos
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
    _showStoredTranslations();
    _selectedLanguage = AppStateIdioma.instance.currentLanguage;
    _loadTranslations();
    _fetchLocalTranslations('es'); // Cargar las traducciones en español
  }

  void _loadTranslations() async {
    await _syncService.syncFirebaseToSQLite();
    if (_selectedLanguage != null) {
      _fetchLocalTranslations(_selectedLanguage!);
    }
  }

  void _fetchLocalTranslations(String language) async {
    final translations =
        await _dbHelperTraducciones.getTranslationsByLanguage(language);

    // Verificar si el widget todavía está montado antes de llamar a setState
    if (mounted) {
      setState(() {
        _translations = Map<String, String>.from(translations);
        if (_translations.isEmpty) {
          statusMessage =
              "No hay datos disponibles, la base de datos está vacía.";
          print("La base de datos está vacía.");
        }
      });
    }
  }

  void _showStoredTranslations() async {
    final allTranslations = await _dbHelperTraducciones.getAllTranslations();
    if (allTranslations.isEmpty) {
      print("No hay traducciones almacenadas.");
    } else {
      for (var translation in allTranslations) {
        print(translation);
      }
    }
  }

  void _changeAppLanguage(String language) {
    // Cambiar el idioma seleccionado en AppStateIdioma
    AppStateIdioma.instance.currentLanguage = language;

    // Guardar el idioma en SharedPreferences
    AppStateIdioma.instance.saveLanguage(language);

    // Verificar que el idioma se ha guardado correctamente
    print('Idioma guardado en SharedPreferences: $language');

    // Cambiar el idioma en el TranslationProvider
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    provider.changeLanguage(language);

    // Recargar las traducciones para el idioma seleccionado
    _fetchLocalTranslations(language);
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20.0),
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
                      return buildCustomCheckboxTile(language);
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
                      return buildCustomCheckboxTile(language);
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
                      print("Idioma seleccionado: $_selectedLanguage");
                      _changeAppLanguage(
                          _selectedLanguage!); // Cambia el idioma seleccionado
                    }
                    widget.onClose();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Color(0xFF2be4f3),
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
          fontSize: 22.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedLanguage = _languageMap[
              language]; // Actualiza la selección con el valor interno
        });
      },
    );
  }

  Widget customCheckbox(String language) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = _languageMap[
              language]; // Actualiza la selección con el valor interno
        });
      },
      child: Container(
        width: 22.0,
        height: 22.0,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedLanguage == _languageMap[language]
              ? const Color(0xFF2be4f3)
              : Colors.transparent,
          border: Border.all(
            color: _selectedLanguage == _languageMap[language]
                ? const Color(0xFF2be4f3)
                : Colors.white,
            width: 1.0,
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
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
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
        width: 200,
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: 1,
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
                Text(
                  tr(context, 'Debes completar el formulario para continuar')
                      .toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side: const BorderSide(
                      width: 1.0,
                      color: Color(0xFF2be4f3),
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
        width: 200,
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
  final List<Map<String, String>> _messages = [];
  String currentStage = "inicio";
  String _mensajeIA =
      "Hola, soy VITA, tu asistente personal de entrenamiento. ¿En qué puedo ayudarte hoy?";

  List<String> previousStages = []; // Lista para almacenar etapas previas
  double scaleFactorBack = 1.0;
  String stageName = "";
  bool conversationEnded = false;
  String? ultimoMensaje;
  List<String> mensajesAleatorios = [
    "Claro, ¿en qué más puedo ayudarte hoy?",
    "¿Hay algo más en lo que pueda asistirte?",
    "Perfecto, ¿qué más necesitas ahora?",
    "¡Todo listo! ¿Te gustaría hacer algo más?",
    "Estoy aquí para lo que necesites, ¿qué más puedo hacer por ti?",
    "Si necesitas algo más, solo dime. ¡Estoy aquí para ayudarte!",
    "¡Todo en orden! ¿Hay algo más en lo que pueda colaborarte?",
    "Perfecto, ¿te gustaría saber algo más a tu rutina?",
    "Todo claro, ¿necesitas ayuda con algo más?",
    "Listo para seguir, ¿en qué más te puedo asistir?",
  ];

// Variable para almacenar el último encabezado utilizado
  String? ultimoEncabezado;

  // Lista de encabezados posibles
  List<String> encabezados = [
    "¡Genial!",
    "¡A tope!",
    "¡Muy bien!",
    "¡Toma ya!",
    "¡Perfecto!",
    "¡Excelente!",
    "¡Buenísimo!",
    "¡Qué bien!",
    "¡Fantástico!"
  ];

  // Datos del árbol de decisiones
  Map<String, List<Map<String, String>>> decisionTree = {
    // OPCION INICIAL
    "inicio": [
      {"text": "Consejos de nutrición", "next": "nutrición"},
      {"text": "Rutinas de entrenamiento", "next": "rutinas"},
      {"text": "Mi bioimpedancia", "next": "bioimpedancia"},
    ],

    // OPCIONES MAYORES
    "nutrición": [
      {"text": "Dieta para perder peso", "next": "dieta_perder_peso"},
      {"text": "Dieta para ganar músculo", "next": "dieta_ganar_musculo"},
      {"text": "Dieta para ganar fuerza", "next": "dieta_ganar_fuerza"},
      {"text": "Dieta para ganar agilidad", "next": "dieta_ganar_agilidad"},
      {"text": "Dieta saludable", "next": "dieta_salud"},
    ],
    "rutinas": [
      {"text": "Rutinas para perder peso", "next": "rutinas_perder_peso"},
      {"text": "Rutinas para ganar músculo", "next": "rutinas_ganar_musculo"},
      {"text": "Rutinas para ganar fuerza", "next": "rutinas_fuerza"},
      {"text": "Rutinas para ganar resistencia", "next": "rutinas_resistencia"},
    ],
    "bioimpedancia": [
      {"text": "Revisar mis datos", "next": "revisar_bio"},
      {"text": "Estado de salud", "next": "estado_salud"},
      {"text": "Consejos mi bioimpedancia", "next": "consejos_bio"},
    ],

    // OPCIONES NUTRICION
    "dieta_perder_peso": [
      {"text": "Dieta Mediterránea", "next": "dieta_mediterránea"},
      {"text": "Dieta KETO", "next": "dieta_keto"},
      {"text": "Dieta baja en calorías", "next": "dieta_baja"},
    ],
    "dieta_ganar_musculo": [
      {
        "text": "Dieta alta en proteínas y carbohidratos complejos",
        "next": "dieta_proteinas"
      },
      {
        "text": "Dieta baja en grasas y altos carbohidratos",
        "next": "dieta_grasas"
      },
      {"text": "Dieta flexitaria", "next": "dieta_flexitaria"},
    ],
    "dieta_ganar_fuerza": [
      {
        "text": "Dieta alta en proteínas y carbohidratos",
        "next": "dieta_proteinas_carbohidratos"
      },
      {"text": "Dieta para culturistas", "next": "dieta_culturistas"},
      {
        "text": "Dieta alta en proteínas y grasas",
        "next": "dieta_proteinas_grasas"
      },
    ],
    "dieta_ganar_agilidad": [
      {
        "text": "Dieta alta en carbohidratos y proteínas",
        "next": "dieta_carbohidratos_proteinas"
      },
      {
        "text": "Dieta baja en grasas con enfoque en carbohidratos",
        "next": "dieta_grasas_carbohidratos"
      },
      {
        "text": "Dieta rica en antioxidantes y carbohidratos",
        "next": "dieta_antioxidantes_carbohidratos"
      },
    ],
    "dieta_salud": [
      {"text": "Dieta Mediterránea", "next": "dieta_salud_mediterranea"},
      {"text": "Dieta control presión arterial(DASH)", "next": "dieta_dash"},
      {"text": "Dieta basada en plantas", "next": "dieta_plantas"},
    ],

    // OPCIONES RUTINAS
    "rutinas_perder_peso": [
      {"text": "Entrenamiento HIIT (3 días)", "next": "entrenamiento_hiit"},
      {
        "text": "Entrenamiento Full-Body (4 días)",
        "next": "entrenamiento_full_body"
      },
      {
        "text": "Entrenamiento circuitos cardio-fuerza (5 días)",
        "next": "entrenamiento_circuitos"
      },
    ],
    "rutinas_ganar_musculo": [
      {
        "text": "Entrenamiento Full-Body (3 días)",
        "next": "entrenamiento_full"
      },
      {"text": "Entrenamiento Split (4 días)", "next": "entrenamiento_split"},
      {
        "text": "Entrenamiento Push-Pull-Legs (6 días)",
        "next": "entrenamiento_push"
      },
    ],
    "rutinas_fuerza": [
      {"text": "Entrenamiento de fuerza 5x5", "next": "entrenamiento_fuerza"},
      {
        "text": "Entrenamiento de fuerza Full-Body",
        "next": "entrenamiento_fuerza_full"
      },
      {
        "text": "Entrenamiento de fuerza con periodización (3 días)",
        "next": "entrenamiento_periodización"
      },
    ],
    "rutinas_resistencia": [
      {
        "text": "Entrenamiento de resistencia aeróbica",
        "next": "entrenamiento_aeróbico"
      },
      {
        "text": "Entrenamiento de resistencia HIIT",
        "next": "entrenamiento_resistencia_hiit"
      },
      {
        "text": "Entrenamiento de fuerza y resistencia",
        "next": "entrenamiento_fuerza_resistencia"
      },
    ],
  };

  // Información de las opciones finales (descripciones)
  Map<String, String> information = {
    // Dietas
    "dieta_mediterránea": """
    •Dieta Mediterránea
     La dieta mediterránea es un estilo de vida basado en los hábitos alimenticios tradicionales de los países del sur de Europa, como España, Italia y Grecia.
     •Principales alimentos: Frutas, verduras, cereales integrales, legumbres, aceite de oliva, pescado, frutos secos, lácteos bajos en grasa y una moderada cantidad de vino tinto.
     •Beneficios:
     - Mejora la salud cardiovascular.
     - Ayuda a controlar el colesterol y la presión arterial.
     - Reduce el riesgo de diabetes tipo 2 y enfermedades crónicas.
     - Fomenta una mayor longevidad.
      •Consejo: Incorpora más pescado graso como el salmón y las sardinas para asegurar un buen aporte de ácidos grasos omega-3. Limita las carnes rojas y procesadas.
  """,

    "dieta_keto": """
   •Dieta Keto
    La dieta Keto se caracteriza por un consumo muy bajo de carbohidratos, alto en grasas y moderado en proteínas. Esto induce un estado llamado cetosis, en el cual el cuerpo quema grasa como principal fuente de energía.
      •Principales alimentos: Carnes, pescados grasos, huevos, aguacates, aceite de oliva, mantequilla, nueces y verduras bajas en carbohidratos.
      •Beneficios:
        - Promueve la pérdida de peso rápida debido a la quema de grasa.
        - Mejora el control de la glucosa y reduce los picos de insulina.
        - Aumenta la energía y concentración mental.
        - Puede mejorar la función cerebral y ayudar en el tratamiento de ciertas condiciones neurológicas, como la epilepsia.
      •Consejo: Asegúrate de obtener suficiente fibra de verduras de bajo carbohidrato para evitar problemas digestivos.
  """,

    "dieta_baja": """
   •Dieta Baja en Calorías
    Esta dieta tiene como objetivo crear un déficit calórico, es decir, consumir menos calorías de las que el cuerpo quema, promoviendo así la pérdida de peso.
      •Principales alimentos: Frutas, verduras, proteínas magras (pollo, pescado), cereales integrales, y grasas saludables en porciones controladas.
      •Beneficios:
        - Pérdida de peso efectiva.
        - Mejora la sensibilidad a la insulina.
        - Puede reducir el riesgo de enfermedades crónicas como la hipertensión y la diabetes tipo 2.
      •Consejo: No te enfoques únicamente en reducir calorías, sino también en asegurar que los alimentos que consumes sean ricos en nutrientes.
  """,

    "dieta_proteinas": """
   •Dieta Alta en Proteínas y Carbohidratos Complejos
    Esta dieta se basa en una alta ingesta de proteínas y carbohidratos complejos para promover el crecimiento muscular y la recuperación post-entrenamiento.
      •Principales alimentos: Carnes magras (pollo, pavo), pescado, huevos, legumbres, avena, arroz integral, patatas y vegetales.
      •Beneficios:
        - Promueve la construcción y reparación muscular.
        - Mejora la resistencia durante el entrenamiento.
        - Ayuda en la recuperación post-ejercicio.
      •Consejo: Elige carbohidratos complejos como la avena, el arroz integral o las batatas para mantener niveles de energía estables.
  """,

    "dieta_grasas": """
   •Dieta Baja en Grasas y Alta en Carbohidratos
    Esta dieta se enfoca en reducir las grasas y aumentar el consumo de carbohidratos complejos, promoviendo la energía rápida y mejorando el rendimiento físico.
      •Principales alimentos: Frutas, verduras, cereales integrales, pasta, arroz, patatas, legumbres y lácteos bajos en grasa.
      •Beneficios:
        - Ayuda a mantener el nivel de energía alto durante entrenamientos intensos.
        - Promueve la pérdida de grasa corporal.
        - Aumenta la recuperación muscular.
      •Consejo: Prioriza carbohidratos complejos como los cereales integrales y las legumbres, y evita los azúcares refinados.
  """,

    "dieta_flexitaria": """
   •Dieta Flexitaria
    La dieta flexitaria es una dieta basada principalmente en alimentos vegetales, con el consumo ocasional de productos animales.
      •Principales alimentos: Frutas, verduras, legumbres, frutos secos, semillas, cereales integrales y carne en pequeñas cantidades.
      •Beneficios:
        - Fomenta el consumo de alimentos de origen vegetal, reduciendo el impacto ambiental de la alimentación.
        - Promueve la salud cardiovascular y la longevidad.
        - Ayuda a controlar el peso y reduce el riesgo de enfermedades crónicas.
      •Consejo: Aumenta la ingesta de vegetales y proteínas vegetales como legumbres, tofu y quinoa, y modera el consumo de carne.
  """,

    "dieta_proteinas_carbohidratos": """
   •Dieta Alta en Proteínas y Carbohidratos
    Esta dieta está diseñada para mejorar el rendimiento físico y fomentar la regeneración muscular, especialmente útil para quienes practican deportes de alta intensidad.
      •Principales alimentos: Pollo, pescado, carnes magras, avena, arroz integral, batatas, huevos y legumbres.
      •Beneficios:
        - Optimiza la recuperación muscular después del ejercicio.
        - Aumenta la energía y resistencia durante entrenamientos de alta intensidad.
        - Promueve la síntesis de proteínas musculares.
      •Consejo: Incluye carbohidratos complejos en cada comida para mantener los niveles de energía durante todo el día.
  """,

    "dieta_proteinas_grasas": """
   •Dieta Alta en Proteínas y Grasas
    Esta dieta prioriza las proteínas y las grasas saludables para mejorar el rendimiento en actividades físicas intensas y la regeneración muscular.
      •Principales alimentos: Carnes magras, pescado graso, huevos, aguacates, aceite de oliva, nueces y queso.
      •Beneficios:
        - Apoya la construcción muscular y la pérdida de grasa.
        - Mejora el rendimiento en ejercicios de fuerza y resistencia.
        - Ayuda a mantener la saciedad y controlar el apetito.
      •Consejo: Asegúrate de consumir grasas saludables (como el aguacate y el aceite de oliva) en lugar de grasas saturadas.
  """,

    "dieta_culturistas": """
   •Dieta para Culturistas
    Una dieta orientada a la construcción muscular y el aumento de fuerza, centrada en un consumo elevado de proteínas y un control riguroso de carbohidratos y grasas.
      •Principales alimentos: Pollo, pescado, carne de res magra, huevos, arroz, avena, batatas, verduras y suplementos proteicos.
      •Beneficios:
        - Promueve el crecimiento muscular.
        - Mejora el rendimiento en entrenamientos de fuerza.
        - Favorece la recuperación y reparación muscular.
      •Consejo: Come varias pequeñas comidas durante el día para mantener un flujo constante de nutrientes, especialmente proteínas.
  """,

    "dieta_carbohidratos_proteinas": """
   •Dieta para Culturistas - Carbohidratos y Proteínas
    Esta dieta se centra en el consumo elevado de proteínas y carbohidratos para fomentar el crecimiento muscular y mejorar el rendimiento en entrenamientos intensos.
      •Principales alimentos: Pollo, pescado, avena, arroz, batatas, vegetales, frutas y suplementos.
      •Beneficios:
        - Aumenta la masa muscular.
        - Mejora la resistencia y la energía durante los entrenamientos.
        - Ayuda en la regeneración muscular rápida.
      •Consejo: Asegúrate de consumir una fuente de carbohidratos después de entrenar para recuperar energía rápidamente.
  """,

    "dieta_grasas_carbohidratos": """
   •Dieta Baja en Grasas con Enfoque en Carbohidratos
    Esta dieta se centra en reducir las grasas y promover los carbohidratos como fuente principal de energía, especialmente útil para mantener la energía en entrenamientos largos.
      •Principales alimentos: Frutas, verduras, arroz integral, pasta, patatas, cereales integrales, lácteos bajos en grasa.
      •Beneficios:
        - Aumenta la energía durante el ejercicio prolongado.
        - Ayuda a mantener un peso saludable.
        - Reduce la grasa corporal mientras se mantiene la masa muscular.
      •Consejo: Limita el consumo de grasas saturadas y elige carbohidratos complejos para mantener una energía constante.
  """,

    "dieta_antioxidantes_carbohidratos": """
   •Dieta Rica en Antioxidantes y Carbohidratos
    Esta dieta es ideal para quienes buscan mejorar la recuperación muscular y reducir el estrés oxidativo generado por el ejercicio intenso.
      •Principales alimentos**: Frutas ricas en antioxidantes (arándanos, fresas), verduras, té verde, nueces, semillas, avena, arroz integral.
      •Beneficios:
        - Mejora la recuperación muscular.
        - Reduce la inflamación y el daño celular.
        - Aumenta la capacidad de entrenamiento y la resistencia.
      •Consejo: Incorpora alimentos ricos en vitamina C y E, como cítricos y frutos rojos, para mejorar la protección contra el estrés oxidativo.
  """,

    // Dietas de salud
    "dieta_salud_mediterranea": """
   •Dieta Mediterránea para la Salud
    Ideal para quienes buscan mantener un corazón saludable y reducir el riesgo de enfermedades crónicas, la dieta mediterránea es rica en nutrientes esenciales y baja en grasas saturadas.
      •Principales alimentos: Frutas, verduras, cereales integrales, aceite de oliva, pescado y mariscos, frutos secos, legumbres, y lácteos bajos en grasa.
      •Beneficios:
        - Mejora la salud cardiovascular.
        - Reduce el riesgo de enfermedades crónicas y cáncer.
        - Promueve un peso saludable.
      •Consejo: Incorpora aceite de oliva como principal fuente de grasa y consume pescado al menos dos veces por semana.
  """,

    "dieta_dash": """
   •Dieta DASH
    La dieta DASH (Dietary Approaches to Stop Hypertension) está diseñada para reducir la presión arterial alta, promoviendo una alimentación rica en frutas, verduras, lácteos bajos en grasa y proteínas magras.
      •Principales alimentos: Frutas, verduras, cereales integrales, lácteos bajos en grasa, carnes magras, frutos secos, semillas.
      •Beneficios:
        - Reduce la presión arterial y mejora la salud cardiovascular.
        - Fomenta la pérdida de peso y la reducción del colesterol.
        - Mejora la salud ósea.
      •Consejo: Limita la ingesta de sal y grasas saturadas para maximizar los efectos beneficiosos sobre la presión arterial.
  """,

    "dieta_plantas": """
   •Dieta Basada en Plantas
    Esta dieta se enfoca en alimentos 100% vegetales, con poco o ningún consumo de productos de origen animal, promoviendo la salud general y el bienestar.
      •Principales alimentos: Verduras, frutas, legumbres, granos integrales, frutos secos, semillas, tofu, tempeh, y leche vegetal.
      •Beneficios:
        - Promueve una digestión saludable.
        - Mejora la salud del corazón y reduce el riesgo de cáncer.
        - Ayuda a controlar el peso corporal.
      •Consejo: Asegúrate de obtener suficiente proteína vegetal (quinoa, lentejas, garbanzos) y vitamina B12 si reduces significativamente los productos animales.
  """,

    // Rutinas
    "entrenamiento_hiit": """
   •Entrenamiento HIIT (High-Intensity Interval Training)*
    El HIIT es un tipo de entrenamiento cardiovascular que combina períodos de esfuerzo intenso con breves momentos de descanso o ejercicio de baja intensidad. Ideal para quemar calorías rápidamente y mejorar la resistencia general.
      •Principales beneficios:
        - Quema calorías de forma rápida y efectiva.
        - Mejora la resistencia cardiovascular.
        - Acelera el metabolismo y aumenta la quema de grasa.
      •Consejo: Comienza con sesiones de HIIT cortas (15-20 minutos) y aumenta la intensidad gradualmente a medida que tu resistencia mejora.
  """,

    "entrenamiento_full_body": """
   •Entrenamiento Full-Body
    Un entrenamiento Full-Body trabaja todos los grupos musculares en una sola sesión. Ideal para quienes buscan mejorar la fuerza y tonificación de manera equilibrada.
      •Beneficios:
        - Mejora la fuerza general y la tonificación muscular.
        - Aumenta la quema de calorías al trabajar múltiples músculos a la vez.
        - Ideal para principiantes o personas con tiempo limitado.
      •Consejo: Realiza este entrenamiento entre 2 y 3 veces por semana para obtener los mejores resultados.
  """,

    "entrenamiento_circuitos": """
   •Entrenamiento de Circuitos
    Los circuitos combinan ejercicios de fuerza y cardio en secuencias rápidas para maximizar la quema de grasa y mejorar la resistencia cardiovascular.
      •Beneficios:
        - Mejora la resistencia cardiovascular y la fuerza muscular.
        - Aumenta la quema de calorías debido a la alta intensidad.
        - Puede realizarse en poco tiempo, ideal para quienes tienen poco tiempo.
      •Consejo: Alterna entre ejercicios de fuerza y cardio para mantener alta la frecuencia cardíaca.
  """,

    "entrenamiento_full": """
   •Entrenamiento Full-Body (3 días)
    El entrenamiento Full-Body (3 días) es una rutina estructurada para trabajar todo el cuerpo en cada sesión. Está diseñado para mejorar la fuerza, tonificar los músculos y aumentar la resistencia general.
      •Beneficios:
        - Trabaja todos los grupos musculares en cada sesión.
        - Aumenta la fuerza general y mejora la condición física.
        - Es ideal para quienes buscan un entrenamiento completo y eficiente.
        - Permite una recuperación adecuada entre las sesiones.
      •Consejo: Realiza entre 3 y 4 sesiones por semana, alternando días de descanso para maximizar la recuperación y el rendimiento.
  """,

    "entrenamiento_split": """
   •Entrenamiento Split (4 días)
    El entrenamiento Split divide el cuerpo en diferentes grupos musculares para entrenarlos de forma más intensa en días separados. Es ideal para quienes buscan un enfoque más especializado.
      •Beneficios:
        - Permite trabajar grupos musculares con mayor intensidad y volumen.
        - Ideal para mejorar la fuerza y la hipertrofia muscular.
        - Mayor enfoque en cada grupo muscular, permitiendo mayor recuperación.
      •Consejo: Divide los días en ejercicios de tren superior (pecho, espalda, hombros, brazos) y tren inferior (piernas), para maximizar el trabajo en cada sesión.
  """,

    "entrenamiento_push": """
   •Entrenamiento Push-Pull-Legs (6 días)
    El entrenamiento Push-Pull-Legs (6 días) es un enfoque estructurado que divide los ejercicios en tres grupos: empuje, tracción y piernas. Cada tipo de entrenamiento se realiza en días separados.
      •Beneficios:
        - Permite entrenar con alta frecuencia, maximizando el volumen de trabajo por grupo muscular.
        - Ayuda a mejorar tanto la fuerza como el volumen muscular.
        - Maximiza la recuperación entre sesiones de trabajo para cada grupo muscular.
      •Consejo: Asegúrate de alternar entre ejercicios de empuje (pecho, hombros, tríceps), tracción (espalda, bíceps) y piernas (cuádriceps, isquiotibiales, glúteos) para un enfoque equilibrado.
  """,

    "entrenamiento_fuerza": """
   •Entrenamiento de Fuerza 5x5
    El entrenamiento de fuerza 5x5 es un programa diseñado para aumentar la fuerza máxima mediante levantamiento de pesas pesadas en series de 5 repeticiones.
      •Beneficios:
        - Maximiza la fuerza de forma rápida y efectiva.
        - Se centra en ejercicios compuestos como sentadillas, press de banca y peso muerto.
        - Ideal para quienes desean aumentar su capacidad en levantamientos de fuerza.
      •Consejo: Mantén una forma adecuada en cada levantamiento y asegúrate de descansar entre 2 y 3 minutos entre series para maximizar la recuperación y la fuerza.
  """,

    "entrenamiento_fuerza_full": """
   •Entrenamiento de Fuerza Full-Body
    El entrenamiento de fuerza Full-Body está diseñado para trabajar todos los músculos principales del cuerpo en cada sesión, con el objetivo de desarrollar fuerza general.
      •Beneficios:
        - Mejora la fuerza general y la resistencia física.
        - Se enfoca en ejercicios compuestos para trabajar múltiples grupos musculares a la vez.
        - Es ideal para principiantes o aquellos que no pueden entrenar cada grupo muscular por separado.
      •Consejo: Realiza entre 3 y 4 entrenamientos Full-Body por semana para lograr los mejores resultados sin sobrecargar el cuerpo.
  """,

    "entrenamiento_periodización": """
   •Entrenamiento con Periodización (3 días)
    El entrenamiento con periodización es un enfoque que se estructura en fases de alta y baja intensidad, aumentando la carga de trabajo a medida que avanzas.
      •Beneficios:
        - Aumenta progresivamente la intensidad para maximizar las ganancias de fuerza y resistencia.
        - Permite un tiempo adecuado de recuperación y adaptación entre fases.
        - Ideal para mejorar el rendimiento a largo plazo sin riesgo de lesiones.
      •Consejo: Asegúrate de seguir un plan estructurado que alterne entre fases de volumen (más repeticiones) y fases de fuerza (mayor peso y menos repeticiones).
  """,

    "entrenamiento_aeróbico": """
   •Entrenamiento Aeróbico
    El entrenamiento aeróbico se enfoca en ejercicios de baja a moderada intensidad para mejorar la capacidad cardiovascular y la resistencia física general.
      •Beneficios:
        - Mejora la capacidad cardiovascular y aumenta la eficiencia del sistema respiratorio.
        - Ayuda a quemar grasa y mantener un peso saludable.
        - Ideal para la salud en general y la prevención de enfermedades cardiovasculares.
      •Consejo: Incluye actividades como correr, nadar, andar en bicicleta o caminar rápido, y realiza sesiones de al menos 30 minutos para mejorar la resistencia aeróbica.
  """,

    "entrenamiento_resistencia_hiit": """
   •Entrenamiento HIIT de Resistencia
    El entrenamiento HIIT de resistencia combina intervalos de alta intensidad con periodos de descanso para mejorar tanto la resistencia muscular como la capacidad cardiovascular.
      •Beneficios:
        - Quema calorías rápidamente y mejora el metabolismo.
        - Aumenta la resistencia y la capacidad cardiovascular.
        - Ideal para quienes buscan mejorar su forma física de manera eficiente.
      •Consejo: Realiza entrenamientos de HIIT entre 20 y 30 minutos, alternando entre ejercicios de fuerza (pesas, bodyweight) y cardio (sprints, saltos).
  """,

    "entrenamiento_fuerza_resistencia": """
    •Entrenamiento de Fuerza y Resistencia
    Este tipo de entrenamiento combina levantamiento de pesas con ejercicios cardiovasculares, para mejorar tanto la fuerza máxima como la resistencia general.
    •Beneficios:
    - Desarrolla tanto la fuerza como la resistencia.
    - Mejora la eficiencia cardiovascular mientras trabajas los músculos.
    - Ideal para quienes buscan un enfoque equilibrado entre fuerza y condición física.
    •Consejo: Combina 3-4 días de entrenamiento de fuerza con sesiones de cardio, como correr o nadar, para obtener resultados completos y balanceados.
  """,

// Información adicional
    "revisar_bio": """
     •TUS DATOS DE BIOIMPEDANCIA
      Lectura 1:
      - Índice de Masa Corporal (IMC): 24,2 kg/m²
      - Hidratación sin Grasa: 67 %
      - Equilibrio Hídrico: 0.2 L
      - Masa Grasa: 15,5 kg
      - Masa Muscular: 60 kg
      - Masa Ósea: 2.8 kg'
    """,
    "estado_salud": """
• Índice de Masa Corporal (IMC): 24,2 kg/m²
  - Peso dentro del rango normal (18.5 - 24.9 kg/m²), sin riesgo de sobrepeso u obesidad.

• Hidratación sin Grasa: 67%
  - Hidratación adecuada, dentro del rango saludable del 60-70%.

• Equilibrio Hídrico: 0.2 L
  - Balance hídrico positivo, sin retención significativa de líquidos.

• Masa Grasa: 15,5 kg
  - Rango saludable de grasa corporal para un adulto.

• Masa Muscular: 60 kg
  - Buena masa muscular, indicativo de una constitución activa y saludable.

• Masa Ósea: 2.8 kg
  - Buena densidad ósea, sin riesgo de problemas óseos.
""",

    "consejos_bio": """
• Índice de Masa Corporal (IMC): 24,2 kg/m²
  - Aunque tu IMC está dentro del rango normal, sería beneficioso mantenerlo en el límite inferior (18.5 - 22) para reducir el riesgo de enfermedades. Para lograrlo, considera mantener una dieta equilibrada y realizar ejercicio regular que incluya tanto actividad cardiovascular como entrenamiento de fuerza.

• Hidratación sin Grasa: 67%
  - Tu nivel de hidratación es adecuado, pero sigue asegurándote de mantener una ingesta constante de agua durante el día, especialmente si haces ejercicio o en climas calurosos. Limita el consumo de bebidas azucaradas o con cafeína para optimizar la hidratación.

• Equilibrio Hídrico: 0.2 L
  - Aunque tu equilibrio hídrico es adecuado, es recomendable que sigas monitoreando tu ingesta de líquidos, especialmente si realizas actividades físicas intensas o en condiciones de calor. Mantente bien hidratado para apoyar la función celular y mejorar el rendimiento físico.

• Masa Grasa: 15,5 kg
  - Tienes una cantidad de grasa corporal saludable, pero si tu objetivo es mejorar tu composición corporal, podrías trabajar en reducir aún más tu porcentaje de grasa mediante una combinación de dieta controlada y ejercicio cardiovascular. Los entrenamientos de alta intensidad pueden ser efectivos para quemar grasa de manera eficiente.

• Masa Muscular: 60 kg
  - Tienes una excelente masa muscular, lo cual es un indicio de un cuerpo fuerte y activo. Para seguir mejorando, puedes enfocarte en un entrenamiento de fuerza progresivo, utilizando pesas o ejercicios de resistencia para aumentar la masa muscular y mejorar la salud metabólica.

• Masa Ósea: 2.8 kg
  - Para seguir optimizando tu salud ósea, asegúrate de consumir suficiente calcio y vitamina D en tu dieta, además de realizar ejercicios de impacto y de resistencia (como caminar, correr o levantar pesas). Esto ayudará a mejorar la densidad ósea y a prevenir problemas en el futuro.
""",
  };

  @override
  void initState() {
    super.initState();
    _messages.add({"sender": "ai", "message": _mensajeIA});
  }

  String evaluarEstadoDeSalud(double imc, double masaGrasa, String sexo) {
    // Evaluar el estado según el IMC
    String estadoImc;
    if (imc < 18.5) {
      estadoImc = 'Bajo peso';
    } else if (imc >= 18.5 && imc < 24.9) {
      estadoImc = 'Peso normal';
    } else if (imc >= 25 && imc < 29.9) {
      estadoImc = 'Sobrepeso';
    } else {
      estadoImc = 'Obesidad';
    }

    // Evaluar la masa grasa en función del sexo
    String estadoMasaGrasa;
    if (sexo.toLowerCase() == 'hombre') {
      if (masaGrasa < 6) {
        estadoMasaGrasa = 'Masa grasa baja';
      } else if (masaGrasa >= 6 && masaGrasa <= 24) {
        estadoMasaGrasa = 'Masa grasa normal';
      } else {
        estadoMasaGrasa = 'Masa grasa alta';
      }
    } else if (sexo.toLowerCase() == 'mujer') {
      if (masaGrasa < 16) {
        estadoMasaGrasa = 'Masa grasa baja';
      } else if (masaGrasa >= 16 && masaGrasa <= 30) {
        estadoMasaGrasa = 'Masa grasa normal';
      } else {
        estadoMasaGrasa = 'Masa grasa alta';
      }
    } else {
      estadoMasaGrasa = 'Sexo no válido';
    }

    // Devuelvo una combinación de los estados de salud
    return 'Estado según IMC: $estadoImc\nEstado según Masa Grasa: $estadoMasaGrasa';
  }

  String getRespuestaIA(String respuesta) {
    // Función para obtener un encabezado aleatorio diferente al último usado
    String obtenerEncabezadoAleatorio() {
      List<String> opcionesDisponibles = List.from(encabezados);
      if (ultimoEncabezado != null) {
        opcionesDisponibles.remove(ultimoEncabezado);
      }

      String encabezadoSeleccionado =
          opcionesDisponibles[Random().nextInt(opcionesDisponibles.length)];

      ultimoEncabezado = encabezadoSeleccionado;

      return encabezadoSeleccionado;
    }

    // Dependiendo de la respuesta, seleccionamos el encabezado y la respuesta asociada
    switch (respuesta) {
      case "Consejos de nutrición":
        return "${obtenerEncabezadoAleatorio()} En cuanto a nutrición, puedo ayudarte con dietas para perder peso, ganar músculo, ganar fuerza o ganar agilidad. ¿Cuál te gustaría explorar?";
      case "Rutinas de entrenamiento":
        return "${obtenerEncabezadoAleatorio()} Estaré encantado de ayudarte, ¿estás buscando rutinas para perder peso, ganar músculo, ganar resistencia o ganar fuerza?";
      case "Mi bioimpedancia":
        stageName = "bio"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Puedo ayudarte a revisar tus datos de bioimpedancia, analizar tu estado de salud o ayudarte a mejorar tus datos.";
      case "Dieta para perder peso":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te dejo unas cuantas dietas para bajar de peso";
      case "Dieta para ganar músculo":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Explora estas dietas para ganar masa muscular";
      case "Dieta para ganar peso":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te dejo unas cuantas dietas para subir de peso";
      case "Dieta para ganar fuerza":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Échale un ojo a estas dietas para aumentar tu fuerza";
      case "Dieta para ganar agilidad":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te dejo unas cuantas dietas para ganar agilidad";
      case "Dieta saludable":
        stageName = "dieta"; // Asignamos "dieta" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te dejo unas cuantas dietas saludables para ti";
      case "Rutinas para perder peso":
        stageName = "rutina"; // Asignamos "rutina" a stageName
        return "${obtenerEncabezadoAleatorio()} Estas son algunas de las mejores rutinas para perder peso";
      case "Rutinas para ganar músculo":
        stageName = "rutina"; // Asignamos "rutina" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te van algunas rutinas para ganar masa muscular";
      case "Rutinas para ganar fuerza":
        stageName = "rutina"; // Asignamos "rutina" a stageName
        return "${obtenerEncabezadoAleatorio()} Estas son algunas rutinas para aumentar tu fuerza";
      case "Rutinas para ganar resistencia":
        stageName = "rutina"; // Asignamos "rutina" a stageName
        return "${obtenerEncabezadoAleatorio()} Aquí te van algunas rutinas para mejorar tu resistencia";
      default:
        return "$respuesta. Escoge alguna opción que te interese";
    }
  }

  void _procesarRespuesta(String respuestaUsuario, String nextStage) {
    setState(() {
      // Agregar mensaje del usuario
      _messages.add({"sender": "user", "message": respuestaUsuario});

      // Almacenar la etapa actual antes de avanzar
      if (currentStage != "inicio") {
        previousStages.add(currentStage);
      }
      currentStage = nextStage;

      // Si es una opción final, mostrar la información en lugar de más botones
      if (information.containsKey(nextStage)) {
        _messages.add({
          "sender": "ai",
          "message": information[nextStage]!,
        });
      } else {
        _messages
            .add({"sender": "ai", "message": getRespuestaIA(respuestaUsuario)});
      }
    });
    // Desplazar automáticamente hacia el último mensaje después de que el widget haya sido renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Método para desplazar automáticamente hacia el final de la lista
  void _scrollToBottom() {
    // Se asegura de desplazar la vista solo si el controlador está disponible
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, // Desplazar hasta el final
        duration: const Duration(milliseconds: 300), // Animación suave
        curve: Curves.easeOut, // Curvatura de la animación
      );
    }
  }

// Método para volver al paso anterior
  void _volverAlPasoAnterior() {
    setState(() {
      // Regresar al paso anterior
      if (previousStages.isNotEmpty) {
        currentStage = previousStages.removeLast(); // Volver al último paso
        _messages.add({
          "sender": "ai",
          "message": "Escoge alguna otra opción que te interese"
        });
      }
    });
  }

  // Método para volver al paso anterior (dos etapas atrás)
  void _volverDosPasosAtras() {
    setState(() {
      // Regresar dos pasos atrás
      if (previousStages.length >= 2) {
        currentStage =
            previousStages[previousStages.length - 2]; // Retrocedemos dos pasos
        previousStages.removeRange(previousStages.length - 2,
            previousStages.length); // Eliminamos los dos últimos pasos
        _messages.add({
          "sender": "ai",
          "message": "Escoge alguna otra opción que te interese"
        });
      } else {
        // Si no hay suficiente historial, volvemos al primer paso
        currentStage = "inicio";
        previousStages.clear();
        _messages.add({
          "sender": "ai",
          "message": "No hay pasos anteriores suficientes. Volviendo al inicio."
        });
      }
    });
    // Desplazar automáticamente hacia el último mensaje después de que el widget haya sido renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

// Método para volver al inicio
  void _volverAlInicio() {
    String obtenerMensajeAleatorio() {
      List<String> mensajesDisponibles = List.from(mensajesAleatorios);
      if (ultimoMensaje != null) {
        mensajesDisponibles.remove(ultimoMensaje);
      }

      String mensajeSeleccionado =
          mensajesDisponibles[Random().nextInt(mensajesDisponibles.length)];

      ultimoMensaje = mensajeSeleccionado;

      return mensajeSeleccionado;
    }

    _mensajeIA =
        "Hola, soy VITA, tu asistente personal de entrenamiento. ¿En qué puedo ayudarte hoy?";
    setState(() {
      currentStage = "inicio";
      previousStages.clear(); // Limpiar historial de etapas
      _messages.add({"sender": "ai", "message": obtenerMensajeAleatorio()});
    });
    // Desplazar automáticamente hacia el último mensaje después de que el widget haya sido renderizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _finalizarConversacion() {
    String obtenerMensajeDespedida() {
      List<String> mensajesDespedida = [
        "¡Hasta pronto! Si necesitas algo más, no dudes en volver.",
        "Fue un placer ayudarte. ¡Nos vemos pronto!",
        "Gracias por usar VITA. ¡Que tengas un buen día!",
        "La conversación ha terminado. ¡Cuídate!"
      ];

      return mensajesDespedida[Random().nextInt(mensajesDespedida.length)];
    }

    _mensajeIA = obtenerMensajeDespedida();

    setState(() {
      // Cambiar el estado a 'fin', indicando que la conversación ha terminado
      currentStage = "fin";
      previousStages.clear();
      _messages.add({"sender": "ai", "message": _mensajeIA});

      // Marcar que la conversación ha terminado
      conversationEnded = true;
    });

    // Desplazar hacia el último mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _iniciarNuevaConversacion() {
    setState(() {
      // Resetear la etapa actual a "inicio"
      currentStage = "inicio";

      // Limpiar el historial de mensajes
      _messages.clear(); // Esto limpia todos los mensajes de la conversación

      // Limpiar los estados previos
      previousStages.clear();
      conversationEnded = false; // Habilitar la conversación nuevamente

      _mensajeIA =
          "Hola, soy VITA, tu asistente personal de entrenamiento. ¿En qué puedo ayudarte hoy?";
      // Puedes agregar un mensaje de bienvenida si lo deseas
      _messages.add({"sender": "ai", "message": _mensajeIA});

      // Restablecer cualquier otro estado necesario
      // Ejemplo: Restaurar el estado de los botones si es necesario
    });

    // Desplazar hacia el inicio de la pantalla (si es necesario)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Función para obtener el texto del botón dinámicamente
  String obtenerTextoBoton() {
    if (stageName == "rutina") {
      return "Ver más rutinas"; // Cambia el texto si estamos en la sección de rutinas
    } else if (stageName == "dieta") {
      return "Ver más dietas"; // Cambia el texto si estamos en la sección de dietas
    } else if (stageName == "bio") {
      return "Ver otros datos bio"; // Cambia el texto si estamos en la sección de dietas
    } else {
      return "Ver más opciones"; // Texto por defecto si no estamos en ninguna de las dos categorías
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: const Text(
        "ASISTENCIA VIRTUAL ",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        // Padding añadido aquí
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    // Barra superior del chat
                    Container(
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black, width: 2)),
                          color: Colors.blueAccent,
                        ),
                        height: screenHeight * 0.1,
                        width: screenWidth,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: const Text(
                          "VITA",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        )),
                    // Lista de mensajes
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final sender = message["sender"]!;
                          final messageText = message["message"]!;

                          Color messageColor = sender == "ai"
                              ? Colors.green[500]!
                              : Colors.blue[500]!;
                          Color textColor =
                              sender == "ai" ? Colors.white : Colors.white;

                          return Align(
                            alignment: sender == "ai"
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: sender == "ai"
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                // Imagen fuera del contenedor del mensaje
                                if (sender == "ai")
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    // Ajusta el espaciado a la izquierda
                                    child: Image.asset(
                                      'assets/images/mujer.png',
                                      // Ruta de la imagen para la IA
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                if (sender != "ai")
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    // Ajusta el espaciado a la derecha
                                    child: Image.asset(
                                      'assets/images/hombre.png',
                                      // Ruta de la imagen para el usuario
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                // Contenedor del mensaje
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 20.0),
                                  decoration: BoxDecoration(
                                    color: messageColor,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7, // Limitar el ancho
                                    ),
                                    child: Text(
                                      messageText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            textColor, // Establecer color de texto
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Área de botones con padding
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 1),
                          ),
                          color: Color(0xFF494949),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 40.0),
                        alignment: Alignment.topCenter,
                        height: screenHeight * 0.25,
                        width: screenWidth,
                        child: Column(
                          children: [
                            // El texto permanece fijo
                            const Text(
                              "¿Qué opción te interesa más?",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            // SingleChildScrollView para permitir desplazamiento solo para los botones
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: GridView.count(
                                  childAspectRatio: 3.5,
                                  crossAxisCount: 2,
                                  // Define cuántas columnas tendrá la cuadrícula
                                  crossAxisSpacing: 4.0,
                                  // Espacio entre las columnas
                                  mainAxisSpacing: 4.0,
                                  // Espacio entre las filas
                                  shrinkWrap: true,
                                  // Evita que el GridView ocupe más espacio del necesario
                                  physics: const NeverScrollableScrollPhysics(),
                                  // Desactiva el desplazamiento en el GridView
                                  children: [
                                    // Botón "Ver más opciones"
                                    if (information.containsKey(currentStage) &&
                                        previousStages.isNotEmpty)
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all<
                                              EdgeInsets>(
                                            const EdgeInsets.symmetric(
                                                horizontal: 6.0, vertical: 6.0),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.blueAccent),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  const Size(0, 36)),
                                        ),
                                        onPressed: conversationEnded
                                            ? null
                                            : _volverAlPasoAnterior,
                                        // Deshabilitar si conversationEnded es true
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/more.png',
                                                width: 20,
                                                height: 20),
                                            // Imagen personalizada
                                            const SizedBox(width: 5),
                                            // Espacio entre el icono y el texto
                                            const Text(
                                              "Ver más opciones",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Botón "Volver dos pasos atrás"
                                    if (information.containsKey(currentStage) &&
                                        previousStages.isNotEmpty &&
                                        stageName != "bio")
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all<
                                              EdgeInsets>(
                                            const EdgeInsets.symmetric(
                                                horizontal: 6.0, vertical: 6.0),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.blueAccent),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  const Size(0, 36)),
                                        ),
                                        onPressed: conversationEnded
                                            ? null
                                            : _volverDosPasosAtras,
                                        // Deshabilitar si conversationEnded es true
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/previous.png',
                                                width: 20,
                                                height: 20),
                                            // Imagen personalizada
                                            const SizedBox(width: 5),
                                            Text(
                                              obtenerTextoBoton(),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Botón "Realizar otra consulta"
                                    if (information.containsKey(currentStage))
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all<
                                              EdgeInsets>(
                                            const EdgeInsets.symmetric(
                                                horizontal: 6.0, vertical: 6.0),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.blueAccent),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  const Size(0, 36)),
                                        ),
                                        onPressed: conversationEnded
                                            ? null
                                            : _volverAlInicio,
                                        // Deshabilitar si conversationEnded es true
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/restart.png',
                                                width: 20,
                                                height: 20),
                                            // Imagen personalizada
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Realizar otra consulta",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Botón "Finalizar conversación"
                                    if (information.containsKey(currentStage))
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all<
                                              EdgeInsets>(
                                            const EdgeInsets.symmetric(
                                                horizontal: 6.0, vertical: 6.0),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.blueAccent),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  const Size(0, 36)),
                                        ),
                                        onPressed: conversationEnded
                                            ? null
                                            : _finalizarConversacion,
                                        // Deshabilitar si conversationEnded es true
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/close.png',
                                                width: 20,
                                                height: 20),
                                            // Imagen personalizada
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Finalizar conversación",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Botón "Iniciar nueva conversación" (solo cuando el estado es 'fin')
                                    if (currentStage == "fin")
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all<
                                              EdgeInsets>(
                                            const EdgeInsets.symmetric(
                                                horizontal: 6.0, vertical: 6.0),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  Colors.blueAccent),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                          ),
                                          minimumSize:
                                              WidgetStateProperty.all<Size>(
                                                  const Size(0, 36)),
                                        ),
                                        onPressed: () {
                                          _iniciarNuevaConversacion(); // Llamar a la función para reiniciar la conversación
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/chat.png',
                                                width: 20,
                                                height: 20),
                                            // Imagen personalizada
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Nueva conversación",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),

                                    if (decisionTree[currentStage] != null)
                                      ...decisionTree[currentStage]!.map(
                                        (option) {
                                          // Crear el ElevatedButton con solo el texto correspondiente
                                          return ElevatedButton(
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all<
                                                  EdgeInsets>(
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 6.0),
                                              ),
                                              backgroundColor:
                                                  WidgetStateProperty.all<
                                                      Color>(Colors.blueAccent),
                                              shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                              ),
                                              minimumSize:
                                                  WidgetStateProperty.all<Size>(
                                                      const Size(0, 36)),
                                            ),
                                            onPressed: conversationEnded
                                                ? null
                                                : () {
                                                    _procesarRespuesta(
                                                        option["text"]!,
                                                        option["next"]!);
                                                  },
                                            // Deshabilitar si conversationEnded es true
                                            child: Text(
                                              option["text"]!,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ), // Contenedor para el chat pegado a la izquierda
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }
}
