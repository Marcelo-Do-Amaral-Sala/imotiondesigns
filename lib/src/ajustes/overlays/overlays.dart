import 'package:flutter/material.dart';
import 'package:imotion_designs/src/ajustes/form/user_form_bonos.dart';
import 'package:imotion_designs/src/ajustes/info/admins_list_view.dart';
import 'package:imotion_designs/src/ajustes/info/entrenadores_list_view.dart';
import 'package:restart_app/restart_app.dart';

import '../../clients/overlays/main_overlay.dart';
import '../../db/db_helper.dart';
import '../../db/db_helper_traducciones.dart';
import '../../servicios/sync.dart';
import '../form/user_form.dart';

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
  bool showConfirmation =
      false; // Nuevo estado para mostrar mensaje de confirmación
  bool isLoading = false;
  String statusMessage = 'Listo para hacer la copia de seguridad';
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _uploadBackup() async {
    try {
      setState(() {
        isLoading = true;
        statusMessage = 'Subiendo la copia de seguridad a GitHub...';
      });

      // Obtén la instancia del helper
      DatabaseHelper dbHelper = DatabaseHelper();

      await dbHelper.initializeDatabase();

      print('BASE DE DATOS INICIALIZADA');

      // Espera antes de subir el backup
      await Future.delayed(Duration(seconds: 2));

      print('SUBIENDO BACKUP...');

      // Realiza la subida del backup a GitHub
      await DatabaseHelper.uploadDatabaseToGitHub();

      // Reabrir la base de datos después de subir el backup
      await dbHelper.initializeDatabase();

      setState(() {
        isLoading = false;
        statusMessage = 'Copia de seguridad subida exitosamente a GitHub';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = 'Error al subir la copia de seguridad: $e';
      });
    }
  }

  Future<void> _downloadBackup() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Imprimir el estado actual de la base de datos antes de hacer cualquier cosa
      debugPrint(
          "Estado de la base de datos antes de la inicialización: ${db.isOpen ? 'Abierta' : 'Cerrada'}");

      setState(() {
        isLoading = true;
        statusMessage = 'Descargando la copia de seguridad desde GitHub...';
      });

      // Inicializar la base de datos (asegúrate de que esté abierta después de la eliminación)
      await dbHelper.initializeDatabase();

      // Verificar si la base de datos está abierta después de la inicialización
      if (!db.isOpen) {
        throw Exception(
            'La base de datos no se pudo abrir después de la inicialización');
      }

      debugPrint("Database open (after re-opening): ${db.isOpen}");

      // Descargar la copia de seguridad desde GitHub
      await DatabaseHelper.downloadDatabaseFromGitHub();

      // Verificar nuevamente si la base de datos sigue abierta después de la descarga
      final dbAfterDownload = await dbHelper.database;
      debugPrint(
          "Estado de la base de datos después de la descarga: ${dbAfterDownload.isOpen ? 'Abierta' : 'Cerrada'}");

      if (!dbAfterDownload.isOpen) {
        throw Exception('La base de datos está cerrada después de la descarga');
      }

      setState(() {
        isLoading = false;
        statusMessage = 'Copia de seguridad descargada exitosamente';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          statusMessage = 'Error al descargar la copia de seguridad: $e';
        });
      }
      print("Error durante la descarga del backup: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "COPIA DE SEGURIDAD",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
                    _uploadBackup();
                  }, // Mantener vacío para que InkWell funcione
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'HACER COPIA',
                    style: TextStyle(
                      color: Color(0xFF2be4f3),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showConfirmation = true; // Mostrar confirmación al pulsar
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: const Color(0xFF2be4f3),
                  ),
                  child: const Text(
                    'RECUPERAR COPIA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (showConfirmation) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              const Text(
                '¿Seguro que quieres restaurar la copia?',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        // Primero se descarga la base de datos
                        await _downloadBackup();

                        // Después de la descarga, ocultamos la confirmación (si es necesario)
                        setState(() {
                          showConfirmation = false;
                        });

                        // Finalmente, reiniciamos la aplicación
                        await Restart.restartApp();
                      } catch (e) {
                        // Manejo de errores en caso de que algo falle durante la descarga
                        print('Error al descargar la copia de seguridad: $e');
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
                    child: const Text(
                      'SÍ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showConfirmation = false; // Ocultar confirmación
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
                    child: const Text(
                      'NO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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
  bool isLoading = false;
  String statusMessage = 'Listo para hacer la copia de seguridad';

  @override
  void initState() {
    super.initState();
    _showStoredTranslations();
    // Establecer el idioma seleccionado por defecto como 'es'
    _selectedLanguage = 'es';
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
    setState(() {
      _translations = Map<String, String>.from(translations);
      if (_translations.isEmpty) {
        statusMessage =
            "No hay datos disponibles, la base de datos está vacía.";
        print("La base de datos está vacía.");
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "SELECCIONAR IDIOMA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Dropdown para seleccionar idioma
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      hint: Text("Selecciona un idioma"),
                      items: ['es', 'en', 'fr', 'pt', 'it']
                          .map((lang) => DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang.toUpperCase()),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                          _translations.clear();
                        });
                        if (value != null) {
                          _fetchLocalTranslations(value);
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    // Mostrar las traducciones en una lista
                    Expanded(
                      child: _translations.isEmpty
                          ? Center(child: Text("NO HAY DATOS DISPONIBLES"))
                          : ListView.builder(
                        itemCount: _translations.length,
                        itemBuilder: (context, index) {
                          String key =
                          _translations.keys.elementAt(index);
                          return ListTile(
                            title: Text(_translations[key]!),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
      onClose: widget.onClose,
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
      title: const Text(
        "SERVICIO TÉCNICO",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          children: [
            const Text(
              "CONTACTO",
              style: TextStyle(
                  color: Color(0xFF28E2F5),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            const Text(
              "Estamos listos para ayudarte, contacta con nuestro servicio técnico y obtén asistencia profesional",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        "E-MAIL: technical_service@i-motiongroup.com",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      const Text(
                        "WHATSAPP: (+34) 618 112 271",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )),
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
      title: const Text(
        "ADMINISTRADORES",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
      height: MediaQuery.of(context).size.height*0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
          });
        },
        tabs: [
          _buildTab('DATOS PERSONALES', 0),
          _buildTab('BONOS', 1),
          _buildTab('ACTIVIDAD', 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.black,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: const TextStyle(
          fontSize: 15,
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
     /* children: [
        ClientsData(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
        ClientsActivity(clientDataActivity: selectedClientData!),
        ClientsBonos(clientDataBonos: selectedClientData!),
        _showBioSubTab
            ? _buildBioSubTabView()
            : _showEvolutionSubTab
            ? _buildEvolutionSubTabView()
            : ClientsBio(
          onClientTap: (clientData) {
            setState(() {
              _showBioSubTab = true;
              _subTabData = clientData;
            });
          },
          clientDataBio: selectedClientData!,
          onEvolutionPressed: () {
            setState(() {
              _showEvolutionSubTab = true;
              _showBioSubTab = false;
            });
          },
        ),
        ClientsGroups(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
      ],*/
    );
  }

}

class OverlayTrainers extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayTrainers({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayTrainersState createState() => _OverlayTrainersState();
}

class _OverlayTrainersState extends State<OverlayTrainers>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedTrainerData;
  bool isInfoVisible = false;
  late TabController _tabController;

  void selectTrainer(Map<String, dynamic> trainerData) {
    setState(() {
      selectedTrainerData = trainerData;
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
      title: const Text(
        "LISTA DE ENTRENADORES",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedTrainerData != null
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      )
          : EntrenadoresListView(
        onTrainerTap: (trainerData) {
          selectTrainer(trainerData);
        },
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height*0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
          });
        },
        tabs: [
          _buildTab('DATOS PERSONALES', 0),
          _buildTab('BONOS', 1),
          _buildTab('ACTIVIDAD', 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.black,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: const TextStyle(
          fontSize: 15,
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
      /* children: [
        ClientsData(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
        ClientsActivity(clientDataActivity: selectedClientData!),
        ClientsBonos(clientDataBonos: selectedClientData!),
        _showBioSubTab
            ? _buildBioSubTabView()
            : _showEvolutionSubTab
            ? _buildEvolutionSubTabView()
            : ClientsBio(
          onClientTap: (clientData) {
            setState(() {
              _showBioSubTab = true;
              _subTabData = clientData;
            });
          },
          clientDataBio: selectedClientData!,
          onEvolutionPressed: () {
            setState(() {
              _showEvolutionSubTab = true;
              _showBioSubTab = false;
            });
          },
        ),
        ClientsGroups(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
      ],*/
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
      title: const Text(
        "CREAR NUEVO",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
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
        return AlertDialog(
          backgroundColor: const Color(0xFF494949),
          title: const Text(
            '¡ALERTA!',
            style: TextStyle(
                color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Debes completar el formulario para continuar',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2be4f3)),
                  ),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(color: Color(0xFF2be4f3)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height*0.1, // Ajusta la altura según lo necesites
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
              _buildTab('DATOS PERSONALES', 0),
              _buildTab('BONOS', 1),
            ],
            indicator: const BoxDecoration(
              color: Color(0xFF494949),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
            ),
            dividerColor: Colors.black,
            labelColor: const Color(0xFF2be4f3),
            labelStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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


