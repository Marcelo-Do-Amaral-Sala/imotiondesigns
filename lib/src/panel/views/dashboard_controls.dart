import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:imotion_designs/src/panel/overlays/overlay_panel.dart';
import 'package:imotion_designs/src/panel/views/panel_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/translation_utils.dart';
import '../../data_management/licencia_state.dart';
import '../../data_management/provider.dart';
import '../../db/db_helper.dart';
import '../../servicios/bluetooth.dart';
import '../../servicios/bluetooth_commands.dart';
import '../../servicios/video_controller.dart';
import '../custom/custom_button.dart';
import '../custom/linear_custom.dart';

class ExpandedContentWidget extends StatefulWidget {
  final String? selectedKey;
  final int? index;
  final String? macAddress;
  final ValueNotifier<List<String>> groupedA;
  final ValueNotifier<List<String>> groupedB;
  final ValueNotifier<List<String>> macAddresses;
  final ValueChanged<int> onSelectEquip;
  final ValueChanged<Map<String, dynamic>?> onClientSelected;
  final ValueChanged<bool> isFullChanged;
  final ValueNotifier<Map<String, dynamic>> clientSelectedMap;

  const ExpandedContentWidget({
    super.key,
    required this.index,
    required this.macAddress,
    this.selectedKey,
    required this.onSelectEquip,
    required this.onClientSelected,
    required this.isFullChanged,
    required this.macAddresses,
    required this.groupedA,
    required this.groupedB,
    required this.clientSelectedMap,
  });

  @override
  _ExpandedContentWidgetState createState() => _ExpandedContentWidgetState();
}

class _ExpandedContentWidgetState extends State<ExpandedContentWidget>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final BleConnectionService bleConnectionService;
  final BleCommandService bleCommandService = BleCommandService();
  late ClientsProvider? _clientsProvider;
  late PanelView panelView = PanelView(
    key: panelViewKey,
    onBack: () {
      // Acción para el callback onBack
    },
    onReset: () {
      // Acción para el callback onReset
    },
    screenWidth: 0,
    screenHeight: 0,
  );

  PageController _pageController = PageController();
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  late Timer _timer;
  late DateTime startTime;
  Timer? _phaseTimer;
  Timer? timerSub;
  String currentStatus = '';
  bool isPauseStarted = false;
  bool isTimeless = false;
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;
  bool isFullScreen = false;
  bool isPantalonSelected = false;
  bool isOverlayVisible = false;
  bool isRunning = false;
  bool isRunningSub = false;
  bool isContractionPhase = true;
  bool isSessionStarted = false;
  bool isElectroOn = false;
  bool _isImagesLoaded = false;
  bool showTrainerInfo = false;
  bool _isLoading = true;
  bool _showVideo = false;
  bool _isImageOne = true;
  bool _hideControls = false;
  bool _isPauseActive = false;
  bool _pauseTimerStarted = false;
  bool _contraTimerStarted = false;
  GlobalKey<PanelViewState> panelViewKey = GlobalKey<PanelViewState>();
  String modulo =
      "imotion21"; // Cambia "moduloEjemplo" por el valor real del módulo.
  List<String> prvideos = List.filled(
      30, ""); // Inicializamos la lista prvideos con 30 elementos vacíos.
  List<String> invideos = List.filled(30, "");
  String? selectedProgram;
  String? selectedCycle;
  Map<String, dynamic>? selectedIndivProgram;
  Map<String, dynamic>? selectedRecoProgram;
  Map<String, dynamic>? selectedAutoProgram;
  List<Map<String, dynamic>> selectedCronaxias = [];
  List<Map<String, dynamic>> selectedGrupos = [];

  Map<String, dynamic>? selectedClient;
  int overlayIndex = -1;
  int selectedIndexEquip = 0;
  int totalTime = 25 * 60;
  int previousTotalTime = 0;
  int time = 25;
  int _currentImageIndex = 0;
  int? selectedIndex = 0;
  int remainingTime = 0;
  int totalBonos = 0;
  int? selectedIndivProgramIndex;
  int currentSubprogramIndex = 0;
  int pausedSubprogramIndex = 0;
  double scaleFactorFull = 1.0;
  double scaleFactorCliente = 1.0;
  double scaleFactorRepeat = 1.0;
  double scaleFactorTrainer = 1.0;
  double scaleFactorRayo = 1.0;
  double scaleFactorReset = 1.0;
  double scaleFactorMas = 1.0;
  double scaleFactorMenos = 1.0;
  double rotationAngle1 = 0.0;
  double rotationAngle2 = 0.0;
  double rotationAngle3 = 0.0;
  double progress = 1.0;
  double strokeWidth = 20.0;
  double strokeHeight = 20.0;
  double elapsedTime = 0.0;
  double elapsedTimeSub = 0.0;
  double pausedTime = 0.0;
  double seconds = 0.0;
  double progressContraction = 0.0;
  double progressPause = 0.0;
  double elapsedTimePause = 0.0;
  double pausedTimePause = 0.0;
  double elapsedTimeContraction = 0.0;
  double pausedTimeContraction = 0.0;
  double valueContraction = 1.0;
  double valueRampa = 1.0;
  double valuePause = 1.0;
  double valueFrecuency = 80.0;
  double valuePulse = 350.0;
  double contractionDuration = 0.0;
  Map<String, bool> procesosActivos = {};
  Map<int, double> subprogramElapsedTime =
      {}; // Almacena elapsedTimeSub para cada subprograma
  Map<int, int> subprogramRemainingTime = {};
  List<Map<String, dynamic>> selectedClients = [];
  List<Map<String, dynamic>> allIndividualPrograms = [];
  List<Map<String, dynamic>> allRecoveryPrograms = [];
  List<Map<String, dynamic>> allAutomaticPrograms = [];
  List<Map<String, dynamic>> allClients = [];
  List<String> respuestaTroceada = [];

  final List<bool> _isMusculoTrajeInactivo = [
    false, //PECHO
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //TRAPECIOS
    false, //DORSALES
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoPantalonInactivo = [
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoTrajeBloqueado = [
    false, //PECHO
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //TRAPECIOS
    false, //DORSALES
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoPantalonBloqueado = [
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];
  List<List<int>> porcentajesPorGrupoTraje = [
    [0, 10, 20, 35], // Pecho
    [0, 10, 20, 35], // Brazo
    [0, 25, 45, 70], // Abdomen
    [0, 20, 40, 60], // Cuadriceps
    [0, 10, 20, 35], // Gemelo
    [0, 10, 20, 35], // Trapecio
    [0, 15, 30, 50], // Dorsal
    [0, 15, 30, 50], // Lumbar
    [0, 25, 45, 70], // Glúteo
    [0, 15, 30, 50], // Isquiotibial
  ];
  List<List<int>> porcentajesPorGrupoPantalon = [
    [0, 10, 20, 35], // Brazo
    [0, 25, 45, 70], // Abdomen
    [0, 20, 40, 60], // Cuadriceps
    [0, 10, 20, 35], // Gemelo
    [0, 15, 30, 50], // Lumbar
    [0, 25, 45, 70], // Glúteo
    [0, 15, 30, 50], // Isquiotibial
  ];

  // **Definir las asignaciones de IDs según el equipamiento seleccionado**
  final Map<int, int> muscleIdToIndexClienteTraje = {
    1: 0,
    2: 5,
    3: 6,
    4: 8,
    5: 9,
    6: 7,
    7: 2,
    8: 3,
    9: 1,
    10: 4
  };

  final Map<int, int> muscleIdToIndexClientePantalon = {
    4: 5, 5: 6, 6: 4, 7: 1, 8: 2,
    9: 0, 10: 3 // Solo 7 elementos
  };

  final Map<int, int> muscleIdToIndexProgramaTraje = {
    1: 5,
    2: 6,
    3: 7,
    4: 8,
    5: 9,
    6: 0,
    7: 2,
    8: 3,
    9: 1,
    10: 4
  };

  final Map<int, int> muscleIdToIndexProgramaPantalon = {
    1: 4, 2: 5, 3: 6, 4: 1, 5: 2,
    6: 0, 7: 3 // Solo 7 elementos
  };

  final List<int> porcentajesMusculoTraje = List.filled(10, 0);
  final List<int> porcentajesMusculoPantalon = List.filled(7, 0);

  Map<int, String> imagePaths = {
    1: 'assets/images/31.png',
    2: 'assets/images/30.png',
    3: 'assets/images/29.png',
    4: 'assets/images/28.png',
    5: 'assets/images/27.png',
    6: 'assets/images/26.png',
    7: 'assets/images/25.png',
    8: 'assets/images/24.png',
    9: 'assets/images/23.png',
    10: 'assets/images/22.png',
    11: 'assets/images/21.png',
    12: 'assets/images/20.png',
    13: 'assets/images/19.png',
    14: 'assets/images/18.png',
    15: 'assets/images/17.png',
    16: 'assets/images/16.png',
    17: 'assets/images/15.png',
    18: 'assets/images/14.png',
    19: 'assets/images/13.png',
    20: 'assets/images/12.png',
    21: 'assets/images/11.png',
    22: 'assets/images/10.png',
    23: 'assets/images/9.png',
    24: 'assets/images/8.png',
    25: 'assets/images/7.png',
    26: 'assets/images/6.png',
    27: 'assets/images/5.png',
    28: 'assets/images/4.png',
    29: 'assets/images/3.png',
    30: 'assets/images/2.png',
    31: 'assets/images/1.png',
  };

  // Lista de imágenes alternantes
  List<String> rayo = [
    'assets/images/rayoaz.png',
    'assets/images/rayoverd.png',
  ];
  List<String> controlImages = [
    'assets/images/play.png',
    'assets/images/pause.png',
  ];

  Color selectedColor = const Color(0xFF2be4f3);
  Color unselectedColor = const Color(0xFF494949);
  ValueNotifier<String> imagePauseNotifier =
      ValueNotifier<String>('assets/images/PAUSA.png');

  @override
  void initState() {
    super.initState();
    bleConnectionService = BleConnectionService();
    currentStatus = 'Estado inicial para ${widget.macAddress}';
    _currentImageIndex = imagePaths.length - time;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    // Crear el controlador de animación de opacidad
    _opacityController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Hace que la animación repita y reverse

    // Crear la animación de opacidad
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _clientsProvider = Provider.of<ClientsProvider>(context, listen: false);
      });
    });
    loadCachedPrograms();
    widget.groupedA.addListener(() {
      debugPrint(
        "🛠️ Grupos actualizados A: ${widget.groupedA.value}",
      );
    });
    widget.groupedB.addListener(() {
      debugPrint(
        "🛠️ Grupos actualizados B: ${widget.groupedB.value}",
      );
    });
    // Imprime el valor inicial
    print(
        "Valor inicial de clientSelectedMap: ${widget.clientSelectedMap.value}");

    widget.clientSelectedMap.addListener(_onClientSelectedMapChanged);
    initializeDataProgram();
    if (selectedIndivProgram != null &&
        selectedIndivProgram!['video'] != null &&
        selectedIndivProgram!['video'].isNotEmpty) {
      _initializeVideoController(selectedIndivProgram!['video']);
    }
    _loadTiempoSesion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  } // Verificar que BLE esté inicializado correctamente

  @override
  void didUpdateWidget(covariant ExpandedContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar cambios en selectedIndivProgram y actualizar el controlador si cambia la URL del video.
    if (selectedIndivProgram != null &&
        selectedIndivProgram!['video'] != selectedIndivProgram?['video']) {
      _initializeVideoController(selectedIndivProgram!['video']);
    }
  }

  Future<void> _loadTiempoSesion() async {
    await AppState.instance
        .loadState(); // 🔹 Cargar estado desde SharedPreferences

    // 🔹 Asignar tiempo desde SharedPreferences
    int tiempoSesionCargado = AppState.instance.tiempoSesion.toInt();

    setState(() {
      totalTime = tiempoSesionCargado * 60; // Convertir minutos a segundos
      print(
          "✅ Tiempo de sesión cargado: $tiempoSesionCargado minutos (${totalTime} segundos)");
    });

    // 🔹 Actualizar la UI correctamente
    _updateTime(tiempoSesionCargado);
  }

  Future<void> _preloadImages() async {
    // Itera sobre las claves del mapa y precarga las imágenes principales
    for (int key in imagePaths.keys) {
      String path = imagePaths[key]!; // Obtiene la ruta de la imagen
      await precacheImage(AssetImage(path), context); // Pre-carga la imagen
    }

    for (String imgPath in rayo) {
      await precacheImage(AssetImage(imgPath), context);
    }
    for (String imgPath in controlImages) {
      await precacheImage(AssetImage(imgPath), context);
    }

    // Cambia el estado una vez que todas las imágenes estén precargadas
    setState(() {
      _isImagesLoaded = true;
    });
  }

  Future<void> _initializeVideoController(String videoUrl) async {
    try {
      await GlobalVideoControllerManager.instance
          .initializeVideo(videoUrl, widget.macAddress!);

      setState(() {
        _isLoading = false;
        _showVideo = true;
      });

      print("✅ Video inicializado con éxito: $videoUrl");
    } catch (e) {
      print("❌ Error al inicializar el video: $e");
      setState(() {
        _isLoading = false;
        _showVideo = false;
      });
    }
  }

  Future<void> _cancelVideoController() async {
    try {
      await GlobalVideoControllerManager.instance
          .cancelVideo(widget.macAddress!);
      setState(() {
        _showVideo = false;
      });
      print("✅ Video cancelado y recursos liberados.");
    } catch (e) {
      print("❌ Error al cancelar el video: $e");
    }
  }

  void playBeep() async {
    // Asegúrate de que la ruta del archivo sea correcta
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  Future<void> initializeDataProgram() async {
    // Esperar a que se obtengan los datos
    _fetchClients();
    await obtenerDatos();
    await _fetchIndividualPrograms(); // Esperar a que se asigne la información
    await _fetchRecoveryPrograms();
    await _fetchAutoPrograms();
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      if (mounted) {
        setState(() {
          allClients = clientData; // Asigna a la lista original
        });
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    }
  }

  Future<void> obtenerDatos() async {
    try {
      List<String> datos = await getTrainer("imotion21");

      List<String> datosFiltrados =
          datos.where((element) => element.isNotEmpty).toList();

      setState(() {
        respuestaTroceada = datosFiltrados;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }

  String encrip(String wcadena) {
    String xkkk =
        'ABCDE0FGHIJ1KLMNO2PQRST3UVWXY4Zabcd5efghi6jklmn7opqrs8tuvwx9yz(),-.:;@';
    String xkk2 = '[]{}<>?¿!¡*#';
    int wp = 0, wd = 0, we = 0, wr = 0;
    String wa = '', wres = '';
    int wl = xkkk.length;
    var wcont = Random().nextInt(10);

    if (wcadena.isNotEmpty) {
      wres = xkkk.substring(wcont, wcont + 1);
      for (int wx = 0; wx < wcadena.length; wx++) {
        wa = wcadena.substring(wx, wx + 1);
        wp = xkkk.indexOf(wa);
        if (wp == -1) {
          wd = wa.codeUnitAt(0);
          we = wd ~/ wl;
          wr = wd % wl;
          wcont += wr;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkk2.substring(we, we + 1) + xkkk.substring(wcont, wcont + 1);
        } else {
          wcont += wp;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkkk.substring(wcont, wcont + 1);
        }
      }
    }

    print("Cadena encriptada: $wres"); // Imprime la cadena encriptada
    return wres;
  }

  Future<List<String>> getTrainer(String modulo) async {
    // Encripta el módulo
    String datos = encrip("18<#>$modulo");
    // Construye la URL
    Uri url = Uri.parse("https://imotionems.es/lic2.php?a=$datos");

    try {
      // Realiza la solicitud GET
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Trocea la respuesta por "|"
        return response.body.split('|');
      } else {
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ocurrió un error: $e");
    }
  }

  Future<void> _fetchIndividualPrograms() async {
    var db = await DatabaseHelper().database;
    try {
      final individualProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoIndividual(db);

      if (respuestaTroceada.isEmpty) {
        throw Exception(
            "No se han cargado los datos de videos. Ejecuta 'obtenerDatos()' primero.");
      }

      for (int i = 0; i < individualProgramData.length; i++) {
        var program = Map<String, dynamic>.from(individualProgramData[i]);
        var video =
            (i < respuestaTroceada.length) ? respuestaTroceada[i] : null;
        program['video'] = video;

        // Añadir cronaxias y grupos al programa
        program['cronaxias'] = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, program['id_programa']);
        program['grupos'] = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, program['id_programa']);

        individualProgramData[i] = program;
      }

      if (mounted) {
        setState(() {
          allIndividualPrograms = individualProgramData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchRecoveryPrograms() async {
    var db = await DatabaseHelper().database;
    try {
      final recoveryProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoRecovery(db);

      for (var program in recoveryProgramData) {
        // Añadir cronaxias y grupos al programa
        program['cronaxias'] = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, program['id_programa']);
        program['grupos'] = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, program['id_programa']);
      }

      if (mounted) {
        setState(() {
          allRecoveryPrograms = recoveryProgramData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchAutoPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      final autoProgramData =
          await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);

      List<Map<String, dynamic>> groupedPrograms =
          _groupProgramsWithSubprograms(autoProgramData);

      if (mounted) {
        setState(() {
          allAutomaticPrograms =
              groupedPrograms; // Asigna los programas obtenidos a la lista
        });
        _saveProgramsToCache(groupedPrograms);
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  List<Map<String, dynamic>> _groupProgramsWithSubprograms(
      List<Map<String, dynamic>> autoProgramData) {
    List<Map<String, dynamic>> groupedPrograms = [];

    for (var autoProgram in autoProgramData) {
      List<Map<String, dynamic>> subprogramas =
          autoProgram['subprogramas'] ?? [];

      Map<String, dynamic> groupedProgram = {
        'id_programa_automatico': autoProgram['id_programa_automatico'],
        'nombre_programa_automatico': autoProgram['nombre'],
        'imagen': autoProgram['imagen'],
        'descripcion_programa_automatico': autoProgram['descripcion'],
        'duracionTotal': autoProgram['duracionTotal'],
        'tipo_equipamiento': autoProgram['tipo_equipamiento'],
        'subprogramas': subprogramas,
      };

      groupedPrograms.add(groupedProgram);
    }

    return groupedPrograms;
  }

  void onClientSelected(Map<String, dynamic>? client) async {
    if (client == null) {
      setState(() {
        selectedClient = null; // 🔥 Eliminar la referencia interna
        totalBonos = 0;

        // 🔥 Reiniciar listas de músculos
        _isMusculoTrajeInactivo.setAll(
            0, List.filled(_isMusculoTrajeInactivo.length, false));
        _isMusculoPantalonInactivo.setAll(
            0, List.filled(_isMusculoPantalonInactivo.length, false));
      });

      // 🔥 Asegurar que también se elimine de `clientSelectedMap`
      widget.clientSelectedMap.value =
          Map<String, dynamic>.from(widget.clientSelectedMap.value)
            ..remove(widget.macAddress);

      // 🔥 Notificar al padre que el cliente se eliminó
      widget.onClientSelected(null);

      // 🔥 Imprimir para verificar la eliminación
      debugPrint(
          "✅ selectedClient en el hijo después de eliminación: $selectedClient");

      return;
    }

    setState(() {
      selectedClient = client;
      totalBonos = 0;
      _isMusculoTrajeInactivo.setAll(
          0, List.filled(_isMusculoTrajeInactivo.length, false));
      _isMusculoPantalonInactivo.setAll(
          0, List.filled(_isMusculoPantalonInactivo.length, false));
    });

    final db = await openDatabase('my_database.db');

    final List<Map<String, dynamic>> clientGroupsResult = await db.rawQuery(
      '''
    SELECT cantidad FROM bonos
    WHERE cliente_id = ? AND estado = 'Disponible'
    ''',
      [client['id']],
    );

    totalBonos = clientGroupsResult.fold(0, (total, bono) {
      final int cantidad = (bono['cantidad'] as num?)?.toInt() ?? 0;
      return total + cantidad;
    });

    final nuevoMapa = Map<String, dynamic>.from(widget.clientSelectedMap.value);
    final datosPrevios =
        (nuevoMapa[widget.macAddress] as Map<String, dynamic>?) ?? {};

    nuevoMapa[widget.macAddress!] = {
      ...datosPrevios,
      ...client,
      'bonos': totalBonos,
    };

    widget.clientSelectedMap.value = nuevoMapa;
    widget.onClientSelected(
        nuevoMapa[widget.macAddress] as Map<String, dynamic>?);

    // 🔥 Asegurar que se actualicen los músculos cada vez que se seleccione un cliente
    updateMuscleLists();
    updateMuscleListsForProgramsOnly();
  }

  void _onClientSelectedMapChanged() {
    print(
        "🔄 Listener activado: Nuevo valor de clientSelectedMap: ${widget.clientSelectedMap.value}");

    if (!mounted) return;

    // 🔥 Si el cliente fue eliminado, actualizar el estado en el widget hijo
    if (!widget.clientSelectedMap.value.containsKey(widget.macAddress)) {
      setState(() {
        selectedClient = null;
        totalBonos = 0;
        _isMusculoTrajeInactivo.setAll(
            0, List.filled(_isMusculoTrajeInactivo.length, false));
        _isMusculoPantalonInactivo.setAll(
            0, List.filled(_isMusculoPantalonInactivo.length, false));
      });

      // 🔥 Forzar la reconstrucción de la UI después del cambio
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });

      print("🚀 Cliente eliminado desde el padre en el hijo.");
    }
  }

  void updateMuscleLists() {
    if (selectedClient == null) return;

    final clientId = selectedClient!['id'];

    openDatabase('my_database.db').then((db) async {
      final List<Map<String, dynamic>> clientGroupsResult =
          await db.rawQuery('''
      SELECT g.id
      FROM grupos_musculares g
      INNER JOIN clientes_grupos_musculares cg ON g.id = cg.grupo_muscular_id
      WHERE cg.cliente_id = ?
    ''', [clientId]);

      final Map<int, int> selectedMuscleIdToIndex = selectedIndexEquip == 0
          ? muscleIdToIndexClienteTraje
          : muscleIdToIndexClientePantalon;

      final Set<int> clientMuscleIndexes = clientGroupsResult
          .map((group) => selectedMuscleIdToIndex[group['id'] as int])
          .where((index) => index != null)
          .cast<int>()
          .toSet();

      setState(() {
        if (selectedIndexEquip == 0) {
          for (int i = 0; i < _isMusculoTrajeInactivo.length; i++) {
            _isMusculoTrajeInactivo[i] =
                _isMusculoTrajeInactivo[i] || !clientMuscleIndexes.contains(i);
          }
        } else if (selectedIndexEquip == 1) {
          for (int i = 0; i < _isMusculoPantalonInactivo.length; i++) {
            _isMusculoPantalonInactivo[i] = _isMusculoPantalonInactivo[i] ||
                !clientMuscleIndexes.contains(i);
          }
        }
      });
    });
  }

  void onProgramSelected(String program) {
    setState(() {
      selectedProgram = program;

      // Reinicia las listas a su estado inicial
      _isMusculoTrajeInactivo.setAll(
          0, List.filled(_isMusculoTrajeInactivo.length, false));
      _isMusculoPantalonInactivo.setAll(
          0, List.filled(_isMusculoPantalonInactivo.length, false));
    });

    updateContractionAndPauseValues();
    print("Programa seleccionado: $selectedProgram");

    // 🔥 Asegurar que la UI se actualice con la nueva selección
    updateMuscleLists();
    updateMuscleListsForProgramsOnly();
  }

  void onIndivProgramSelected(Map<String, dynamic>? programI) async {
    if (programI == null) return;

    setState(() {
      selectedIndivProgram = programI;
      _isMusculoTrajeInactivo.setAll(
          0, List.filled(_isMusculoTrajeInactivo.length, false));
      _isMusculoPantalonInactivo.setAll(
          0, List.filled(_isMusculoPantalonInactivo.length, false));
    });

    var db = await DatabaseHelper().database;
    try {
      List<Map<String, dynamic>> cronaxias = (await DatabaseHelper()
              .obtenerCronaxiasPorPrograma(db, programI['id_programa']))
          .map((c) =>
              {'id': c['id'], 'nombre': c['nombre'], 'valor': c['valor']})
          .toList();
      List<Map<String, dynamic>> grupos = (await DatabaseHelper()
              .obtenerGruposPorPrograma(db, programI['id_programa']))
          .map((g) => {'id': g['id']})
          .toList();

      setState(() {
        selectedCronaxias = cronaxias;
        selectedGrupos = grupos;
      });

      updateContractionAndPauseValues();
      updateMuscleLists();
      updateMuscleListsForProgramsOnly();
    } catch (e) {
      debugPrint("❌ Error en onIndivProgramSelected: $e");
    }
  }

  void onRecoProgramSelected(Map<String, dynamic>? programR) async {
    if (programR == null) return;

    setState(() {
      selectedRecoProgram = programR;
      _isMusculoTrajeInactivo.setAll(
          0, List.filled(_isMusculoTrajeInactivo.length, false));
      _isMusculoPantalonInactivo.setAll(
          0, List.filled(_isMusculoPantalonInactivo.length, false));
    });

    var db = await DatabaseHelper().database;

    try {
      var cronaxias = await DatabaseHelper()
          .obtenerCronaxiasPorPrograma(db, programR['id_programa']);
      var grupos = await DatabaseHelper()
          .obtenerGruposPorPrograma(db, programR['id_programa']);

      setState(() {
        selectedCronaxias = cronaxias;
        selectedGrupos = grupos;
      });

      updateContractionAndPauseValues();
      updateMuscleLists();
      updateMuscleListsForProgramsOnly();
    } catch (e) {
      debugPrint("❌ Error en onRecoProgramSelected: $e");
    }
  }

  void onAutoProgramSelected(Map<String, dynamic>? programA) async {
    if (programA == null) return;

    setState(() {
      selectedAutoProgram = Map<String, dynamic>.from(programA);
    });

    var db = await DatabaseHelper().database;
    try {
      List<Map<String, dynamic>> subprogramas =
          (programA['subprogramas'] as List<dynamic>?)
                  ?.map((sp) => Map<String, dynamic>.from(sp))
                  .toList() ??
              [];

      for (var i = 0; i < subprogramas.length; i++) {
        var subprograma = Map<String, dynamic>.from(subprogramas[i]);

        if (subprograma['id_programa_relacionado'] == null) continue;

        int idPrograma = subprograma['id_programa_relacionado'] as int;

        List<Map<String, dynamic>> cronaxias =
            (await DatabaseHelper().obtenerCronaxiasPorPrograma(db, idPrograma))
                .map((c) => {
                      'id': c['id'],
                      'nombre': c['nombre'] ?? 'Desconocido',
                      'valor': c['valor'] ?? 0.0
                    })
                .toList();

        List<Map<String, dynamic>> grupos = (await DatabaseHelper()
                .obtenerGruposPorPrograma(db, idPrograma))
            .map((g) => {'id': g['id'], 'nombre': g['nombre'] ?? 'Desconocido'})
            .toList();

        subprogramas[i] = {
          ...subprograma,
          'cronaxias': cronaxias,
          'grupos': grupos
        };
      }

      setState(() {
        selectedAutoProgram?['subprogramas'] =
            List<Map<String, dynamic>>.from(subprogramas);
      });

      updateContractionAndPauseValues();
      updateMuscleLists();
      updateMuscleListsForProgramsOnly();
    } catch (e) {
      debugPrint("❌ Error en onAutoProgramSelected: $e");
    }
  }

  void updateMuscleListsForProgramsOnly() {
    if (selectedGrupos.isEmpty) return;

    openDatabase('my_database.db').then((db) async {
      try {
        List<Map<String, dynamic>> grupos = [];
        debugPrint("🔹 Iniciando actualización de músculos para programas");

        if (selectedProgram == null ||
            selectedProgram == tr(context, 'Libre').toUpperCase() ||
            (selectedProgram == tr(context, 'Individual').toUpperCase() &&
                selectedIndivProgram == null) ||
            (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
                selectedRecoProgram == null) ||
            (selectedProgram == tr(context, 'Automáticos').toUpperCase() &&
                selectedAutoProgram == null)) {
          debugPrint(
              "📌 Programa no seleccionado o Libre, manteniendo todos los músculos activos");
          return;
        }

        if (selectedProgram == tr(context, 'Individual').toUpperCase() &&
            selectedIndivProgram != null) {
          grupos = (await DatabaseHelper().obtenerGruposPorPrograma(
                  db, selectedIndivProgram!['id_programa']))
              .map((g) => {'id': g['id']})
              .toList();
        } else if (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
            selectedRecoProgram != null) {
          grupos = (await DatabaseHelper().obtenerGruposPorPrograma(
                  db, selectedRecoProgram!['id_programa']))
              .map((g) => {'id': g['id']})
              .toList();
        } else if (selectedProgram ==
                tr(context, 'Automáticos').toUpperCase() &&
            selectedAutoProgram != null) {
          List<Map<String, dynamic>> subprogramas =
              (selectedAutoProgram!['subprogramas'] as List<dynamic>?)
                      ?.map((sp) => Map<String, dynamic>.from(sp))
                      .toList() ??
                  [];

          for (var subprograma in subprogramas) {
            if (subprograma['id_programa_relacionado'] == null) continue;
            int idPrograma = subprograma['id_programa_relacionado'] as int;
            grupos.addAll((await DatabaseHelper()
                    .obtenerGruposPorPrograma(db, idPrograma))
                .map((g) => {'id': g['id']})
                .toList());
          }
        }

        final Map<int, int> selectedMuscleIdToIndex = selectedIndexEquip == 0
            ? muscleIdToIndexProgramaTraje
            : muscleIdToIndexProgramaPantalon;

        final Set<int> activeMuscleIndexes = grupos
            .map((g) => selectedMuscleIdToIndex[g['id'] as int])
            .where((index) => index != null)
            .cast<int>()
            .toSet();

        setState(() {
          if (selectedIndexEquip == 0) {
            for (int i = 0; i < _isMusculoTrajeInactivo.length; i++) {
              _isMusculoTrajeInactivo[i] = _isMusculoTrajeInactivo[i] ||
                  !activeMuscleIndexes.contains(i);
            }
          } else if (selectedIndexEquip == 1) {
            for (int i = 0; i < _isMusculoPantalonInactivo.length; i++) {
              _isMusculoPantalonInactivo[i] = _isMusculoPantalonInactivo[i] ||
                  !activeMuscleIndexes.contains(i);
            }
          }
        });
        updateMuscleLists();
      } catch (e) {
        debugPrint("❌ Error en updateMuscleListsForProgramsOnly: $e");
      }
    });
  }

  void onCycleSelected(String cycle) {
    setState(() {
      selectedCycle = cycle; // Actualizar el ciclo seleccionado
      imagePauseNotifier.value = 'assets/images/PAUSA.png';
      _isPauseActive = false;

      // 🔥 Asignar valores del ciclo
      if (selectedCycle == "${tr(context, 'Ciclo')} D") {
        selectedRecoProgram = allRecoveryPrograms[3];
      } else if (selectedCycle == "${tr(context, 'Ciclo')} A") {
        valueRampa = 1.0;
        valuePause = 1.0;
        valueContraction = 3.0;
      } else if (selectedCycle == "${tr(context, 'Ciclo')} B") {
        valueRampa = 1.0;
        valuePause = 1.0;
        valueContraction = 6.0;
      } else if (selectedCycle == "${tr(context, 'Ciclo')} C") {
        valueRampa = 1.0;
        valuePause = 1.0;
        valueContraction = 4.0;
      }

      if (selectedCycle == '') {
        selectedCycle = null;
      }

      updateContractionAndPauseValues(); // Llamar a la función para actualizar valores
    });

    print("Ciclo seleccionado: $selectedCycle");
  }

  void updateContractionAndPauseValues() {
    // 🔥 Si hay un ciclo seleccionado, no permitir que el programa lo sobrescriba
    if (selectedCycle != null) {
      return; // Salir sin cambiar los valores
    }

    if (selectedProgram == tr(context, 'Individual').toUpperCase() &&
        selectedIndivProgram != null) {
      valueContraction =
          (selectedIndivProgram!['contraccion'] as double?) ?? valueContraction;
      valuePause = (selectedIndivProgram!['pausa'] as double?) ?? valuePause;
      valueRampa = (selectedIndivProgram!['rampa'] as double?) ?? valueRampa;
    } else if (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
        selectedRecoProgram != null) {
      valueContraction =
          (selectedRecoProgram!['contraccion'] as double?) ?? valueContraction;
      valuePause = (selectedRecoProgram!['pausa'] as double?) ?? valuePause;
      valueRampa = (selectedRecoProgram!['rampa'] as double?) ?? valueRampa;
    } else if (selectedProgram == tr(context, 'Automáticos').toUpperCase() &&
        selectedAutoProgram != null) {
      totalTime = (selectedAutoProgram!['duracion']) ?? totalTime;
      valueContraction = (selectedAutoProgram!['subprogramas']
              [currentSubprogramIndex]['contraccion'] as double?) ??
          valueContraction;
      valuePause = (selectedAutoProgram!['subprogramas'][currentSubprogramIndex]
              ['pausa'] as double?) ??
          valuePause;
      valueRampa = (selectedAutoProgram!['subprogramas'][currentSubprogramIndex]
              ['rampa'] as double?) ??
          valueRampa;
    } else if (selectedProgram == tr(context, 'Libre').toUpperCase()) {
      valueContraction = 1.0;
      valuePause = 1.0;
      valueRampa = 1.0;
    }
  }

  Map<String, dynamic> getProgramSettings(String? selectedProgram) {
    debugPrint(
        "🔹 getProgramSettings() - Iniciando con selectedProgram: $selectedProgram");

    double frecuencia = 0;
    double rampa = valueRampa;
    double pulso = 0;
    double pause = valuePause;
    double contraction = valueContraction;

    Map<String, dynamic>? selectedProgramData;
    List<Map<String, dynamic>> cronaxias = [];
    List<Map<String, dynamic>> grupos = [];

    if (selectedProgram == tr(context, 'Individual').toUpperCase()) {
      selectedProgramData = selectedIndivProgram;
      cronaxias = selectedCronaxias;
      grupos = selectedGrupos;
    } else if (selectedProgram == tr(context, 'Recovery').toUpperCase()) {
      selectedProgramData = selectedRecoProgram;
      cronaxias = selectedCronaxias;
      grupos = selectedGrupos;
    } else if (selectedProgram == tr(context, 'Automáticos').toUpperCase()) {
      selectedProgramData =
          selectedAutoProgram?['subprogramas'][currentSubprogramIndex];
      cronaxias = (selectedAutoProgram?['subprogramas'][currentSubprogramIndex]
                  ['cronaxias'] as List<dynamic>?)
              ?.map((c) =>
                  {'id': c['id'], 'nombre': c['nombre'], 'valor': c['valor']})
              .toList() ??
          [];
      grupos = (selectedAutoProgram?['subprogramas'][currentSubprogramIndex]
                  ['grupos'] as List<dynamic>?)
              ?.map((g) => {'id': g['id']})
              .toList() ??
          [];
    } else if (selectedProgram == tr(context, 'Libre').toUpperCase()) {
      frecuencia = valueFrecuency;
      rampa = valueRampa;
      pulso = valuePulse;
      pause = valuePause;
      contraction = valueContraction;
    }

    if (selectedProgramData != null) {
      frecuencia = selectedProgramData['frecuencia'] ?? 0;
      rampa = selectedProgramData['rampa'] ?? 0;
      pulso = selectedProgramData['pulso'] ?? 0;
    }

    // 🔥 Evitar devolver `selectedClient` si ya fue eliminado
    Map<String, dynamic>? clienteData = selectedClient;
    if (selectedClient == null ||
        !widget.clientSelectedMap.value.containsValue(selectedClient)) {
      clienteData = null;
    }

    debugPrint("📊 Datos obtenidos en getProgramSettings:");
    debugPrint(
        "   - Cliente: ${clienteData != null ? clienteData['name'] : 'Ninguno'}");
    debugPrint("   - Frecuencia: $frecuencia");
    debugPrint("   - Rampa: $rampa");
    debugPrint("   - Pulso: $pulso");
    debugPrint("   - Cronaxias: $cronaxias");
    debugPrint("   - Grupos musculares: $grupos");

    return {
      'cliente': clienteData,
      // 🔥 Solo devuelve el cliente si aún está en `clientSelectedMap`
      'frecuencia': frecuencia,
      'rampa': rampa,
      'pulso': pulso,
      'pausa': pause,
      'contraccion': contraction,
      'cronaxias': cronaxias,
      'grupos': grupos,
    };
  }

  Future<void> _saveProgramsToCache(List<Map<String, dynamic>> programs) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertir la lista de programas a formato JSON y guardarla
    String jsonPrograms = jsonEncode(programs);
    await prefs.setString('cachedPrograms', jsonPrograms);
  }

  Future<List<Map<String, dynamic>>> _loadProgramsFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener los datos guardados en caché
    String? cachedData = prefs.getString('cachedPrograms');

    if (cachedData != null) {
      // Si hay datos en caché, convertirlos de JSON a lista de Map<String, dynamic>
      List<dynamic> decodedData = jsonDecode(cachedData);
      return List<Map<String, dynamic>>.from(decodedData);
    }
    return [];
  }

  void loadCachedPrograms() async {
    List<Map<String, dynamic>> cachedPrograms = await _loadProgramsFromCache();
    if (cachedPrograms.isNotEmpty) {
      if (mounted) {
        setState(() {
          allAutomaticPrograms = cachedPrograms;
        });
      }
    } else {
      // Si no hay programas en caché, puedes optar por llamar a _fetchAutoPrograms nuevamente.
      await _fetchAutoPrograms();
    }
  }

  // La función toggleFullScreen se define aquí, pero será ejecutada por el hijo
  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
    widget.isFullChanged(isFullScreen);
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  void selectEquip(int index) {
    if (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
        selectedRecoProgram?['id_programa'] == 21) {
      debugPrint(
          "⚠️ Bloqueo de ejecución: selectedProgram es Recovery y el id_programa es 21");
      return;
    }

    setState(() {
      selectedIndexEquip = index; // Actualizar índice local
      updateMuscleLists();
      updateMuscleListsForProgramsOnly();
    });

    widget.onSelectEquip(index); // Notificar cambio a PanelView
    print("🔄 Cambiado al equipo $index para clave: ${widget.selectedKey}");
  }

  void _togglePlayPause(String macAddress) {
    final globalManager = GlobalVideoControllerManager.instance;
    final videoController = globalManager.videoController;

    if (videoController == null ||
        !videoController.value.isInitialized ||
        globalManager.activeMacAddress != macAddress) {
      debugPrint(
          "⚠️ No hay un video activo o el video no pertenece a este macAddress.");
      return;
    }

    if (videoController.value.isPlaying) {
      videoController.pause();
      debugPrint("⏸️ Video pausado para macAddress: $macAddress");
    } else {
      videoController.play();
      debugPrint("▶️ Video reproduciéndose para macAddress: $macAddress");
    }

    setState(() {});
  }

  void _startTimer(String macAddress, List<int> porcentajesMusculoTraje,
      List<int> porcentajesMusculoPantalon) {
    if (isRunning) return; // Evita iniciar si ya está corriendo
    if (mounted) {
      setState(() {
        isRunning = true;
        isSessionStarted = true;
        // Para el temporizador principal, reiniciamos el startTime
        startTime = DateTime.now();
        // Al reanudar, elapsedTime se calculará sumando el tiempo acumulado al nuevo lapso
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              elapsedTime = pausedTime +
                  DateTime.now().difference(startTime).inSeconds.toDouble();
              progress =
                  1.0 - (elapsedTime / totalTime); // Actualiza el progreso

              seconds = (totalTime - elapsedTime).toInt() % 60;
              time = (totalTime - elapsedTime).toInt() ~/ 60;

              if ((totalTime - elapsedTime) % 60 == 0) {
                _currentImageIndex = imagePaths.length - time;
              }

              // Detiene el temporizador principal al llegar al total
              if (elapsedTime >= totalTime) {
                _stopAllTimersAndReset(widget.macAddress!);
              }
            });
          }
        });

        // Si se debe iniciar el temporizador del subprograma, se arranca
        if (selectedProgram != null && selectedAutoProgram != null) {
          startSubprogramTimer(widget.macAddress!);
        }

        // Reanudar la fase en la que se pausó:
        if (isContractionPhase) {
          // Restaurar el tiempo transcurrido de la contracción
          elapsedTimeContraction = pausedTimeContraction;
          _startContractionTimer(valueContraction, widget.macAddress!,
              porcentajesMusculoTraje, porcentajesMusculoPantalon);
        } else {
          // Restaurar el tiempo transcurrido de la pausa
          elapsedTimePause = pausedTimePause;
          _startPauseTimer(valuePause, widget.macAddress!,
              porcentajesMusculoTraje, porcentajesMusculoPantalon);
        }
      });
    }
  }

  void _pauseTimer(String macAddress) {
    if (mounted) {
      setState(() {
        stopElectrostimulationProcess(widget.macAddress!);

        isRunning = false;
        isSessionStarted = false;
        pausedTime = elapsedTime; // Guarda el tiempo del temporizador principal

        // Guarda el estado de la fase actual
        pausedTimePause = elapsedTimePause;
        pausedTimeContraction = elapsedTimeContraction;

        _timer.cancel();
        stopSubprogramTimer(widget.macAddress!);
        _phaseTimer?.cancel();
      });
    }
  }

  void _updateTime(int newTime) {
    if (mounted) {
      setState(() {
        if (newTime < 1) newTime = 1; // Tiempo mínimo de 1 minuto
        if (newTime > 30) newTime = 30; // Tiempo máximo de 30 minutos

        // Reinicia el tiempo transcurrido
        //elapsedTime = 0;

        // Actualiza el tiempo en minutos
        time = newTime;

        // Actualiza totalTime a segundos (newTime en minutos * 60)
        totalTime = time * 60;

        // Reinicia el startTime para que el temporizador comience desde cero
        startTime = DateTime.now();

        // Calcula el nuevo índice de la imagen según el tiempo
        _currentImageIndex = 31 - time;
      });
    }
  }

  void _stopAllTimersAndReset(String macAddress) {
    if (mounted) {
      // Pausa el temporizador antes de reiniciar las variables globales
      _pauseTimer(widget.macAddress!);
      playBeep();
      toggleOverlay(5);
      // Espera 2 segundos antes de reiniciar las variables globales
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _clearGlobals(); // Reinicia las variables globales
            debugPrint(
                "🔄 Variables globales reiniciadas después de la pausa.");
          });
        }
      });
    }
  }

  void _startContractionTimer(
    double contractionDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer?.cancel(); // Cancela cualquier timer previo

    // Verifica el estado de la electroestimulación y actúa según corresponda
    if (isElectroOn == false) {
      if (selectedIndexEquip == 0) {
        startFullElectrostimulationTrajeProcess(
                widget.macAddress!, porcentajesMusculoTraje, selectedProgram)
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                isElectroOn = true;
              });
            }
            // Una vez confirmada, inicia la fase de contracción
            _startContractionPhase(contractionDuration, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          } else {
            debugPrint(
                "❌ Error al iniciar la electroestimulación para traje durante la fase de contracción.");
          }
        });
      } else if (selectedIndexEquip == 1) {
        startFullElectrostimulationPantalonProcess(
                widget.macAddress!, porcentajesMusculoPantalon, selectedProgram)
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                isElectroOn = true;
              });
            }
            _startContractionPhase(contractionDuration, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          } else {
            debugPrint(
                "❌ Error al iniciar la electroestimulación para pantalón durante la fase de contracción.");
          }
        });
      } else {
        debugPrint("❌ Índice seleccionado no válido: $selectedIndex");
      }
    } else {
      // Si ya está activo, arranca directamente la fase
      _startContractionPhase(contractionDuration, widget.macAddress!,
          porcentajesMusculoTraje, porcentajesMusculoPantalon);
    }
  }

  void _startContractionPhase(
    double contractionDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // Si es la primera iteración, marcamos que ya inició el timer
          if (!_contraTimerStarted) {
            _contraTimerStarted = true;
          }

          // Se acumula el tiempo transcurrido en la fase de contracción
          elapsedTimeContraction += 0.1;
          progressContraction = elapsedTimeContraction / contractionDuration;

          if (elapsedTimeContraction >= contractionDuration) {
            // Al finalizar la fase de contracción se reinician los contadores y se pasa a la fase de pausa
            elapsedTimeContraction = 0.0;
            pausedTimeContraction = 0.0;
            _contraTimerStarted = false; // reiniciamos la bandera
            isContractionPhase = false;
            _startPauseTimer(
              valuePause,
              widget.macAddress!,
              porcentajesMusculoTraje,
              porcentajesMusculoPantalon,
            );
          }
        });
      }
    });
  }

  Future<void> _startPauseTimer(
    double pauseDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) async {
    _phaseTimer?.cancel();

    try {
      bool success = await stopElectrostimulationProcess(widget.macAddress!);

      if (success) {
        debugPrint(
            "✅ Electroestimulación detenida correctamente antes de la pausa.");
      } else {
        debugPrint(
            "⚠️ No había electroestimulación activa para detener. Se continúa con la pausa.");
      }

      // Se inicia la fase de pausa de todas formas:
      _startPausePhase(pauseDuration, widget.macAddress!,
          porcentajesMusculoTraje, porcentajesMusculoPantalon);
    } catch (e) {
      debugPrint(
          "❌ Error al detener la electroestimulación antes de la pausa: $e");
    }
  }

  void _startPausePhase(
    double pauseDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // Si es la primera vez que entra, marcamos que el timer ya inició
          if (!_pauseTimerStarted) {
            _pauseTimerStarted = true;
          }

          // Acumulamos el tiempo transcurrido en la pausa
          elapsedTimePause += 0.1;
          progressPause = elapsedTimePause / pauseDuration;

          if (elapsedTimePause >= pauseDuration) {
            // Reinicia los contadores y pasa a la fase de contracción
            elapsedTimePause = 0.0;
            pausedTimePause = 0.0;
            _pauseTimerStarted = false;
            isContractionPhase = true;
            _startContractionTimer(
              valueContraction,
              widget.macAddress!,
              porcentajesMusculoTraje,
              porcentajesMusculoPantalon,
            );
          }
        });
      }
    });
  }

  void startSubprogramTimer(String macAddress) {
    // Verificar si selectedAutoProgram es nulo y usar allAutoPrograms[0] si es el caso
    var programToUse = selectedAutoProgram ?? allAutomaticPrograms[0];

    // Verificar si la lista 'subprogramas' está vacía
    if (programToUse['subprogramas'].isEmpty) {
      print("La lista de subprogramas está vacía.");
      return; // Salir de la función si la lista está vacía
    }

    // Validar que el índice actual está dentro de la lista de subprogramas
    if (currentSubprogramIndex < programToUse['subprogramas'].length) {
      // Obtener la duración en minutos del subprograma actual y convertirla a segundos
      double durationInMinutes = programToUse['subprogramas']
          [currentSubprogramIndex]['duracion'] as double;

      // Si el subprograma es el primero (índice 0), no restar nada
      // Para los subprogramas posteriores, restar 1 segundo
      int durationInSeconds;
      if (currentSubprogramIndex > 0) {
        durationInSeconds = (durationInMinutes * 60).toInt() -
            1; // Restar 1 segundo solo a partir del segundo subprograma
      } else {
        durationInSeconds = (durationInMinutes * 60)
            .toInt(); // No restar nada en el primer subprograma
      }

      // Inicializar o recuperar los tiempos para el subprograma actual
      if (!subprogramElapsedTime.containsKey(currentSubprogramIndex)) {
        subprogramElapsedTime[currentSubprogramIndex] =
            0.0; // Si no tiene valor, inicializar
      }
      if (!subprogramRemainingTime.containsKey(currentSubprogramIndex)) {
        subprogramRemainingTime[currentSubprogramIndex] =
            durationInSeconds; // Duración en segundos
      }

      // Actualizar remainingTime y elapsedTimeSub para el subprograma actual
      remainingTime = subprogramRemainingTime[currentSubprogramIndex]!;
      elapsedTimeSub = subprogramElapsedTime[currentSubprogramIndex]!;

      print(
          "Iniciando subprograma $currentSubprogramIndex con duración: $remainingTime segundos");

      if (isContractionPhase &&
          selectedAutoProgram != null &&
          !isPauseStarted) {
        // Iniciar primero el temporizador de pausa solo si las tres condiciones son verdaderas
        _startPauseTimer(valuePause, widget.macAddress!,
            porcentajesMusculoTraje, porcentajesMusculoPantalon);
        isPauseStarted = true; // Marcar que la pausa ha comenzado
      }

      // Iniciar temporizador para este subprograma
      timerSub = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          if (mounted) {
            setState(() {
              remainingTime--;
              elapsedTimeSub +=
                  1.0; // Aumentar el tiempo transcurrido en segundos
              subprogramRemainingTime[currentSubprogramIndex] =
                  remainingTime; // Actualizar remainingTime en el mapa
              subprogramElapsedTime[currentSubprogramIndex] =
                  elapsedTimeSub; // Actualizar elapsedTime en el mapa
            });
          }
        } else {
          timer.cancel();
          print("Subprograma $currentSubprogramIndex completado.");

          // Pasar al siguiente subprograma
          currentSubprogramIndex++;
          updateContractionAndPauseValues();
          updateMuscleLists();
          updateMuscleListsForProgramsOnly();
          startSubprogramTimer(
              widget.macAddress!); // Iniciar el siguiente subprograma
        }
      });
    } else {
      // Si se terminaron todos los subprogramas
      print("Todos los subprogramas completados.");
      // Aquí puedes agregar una acción al finalizar todos los subprogramas
    }
  }

  void stopSubprogramTimer(String macAddress) {
    timerSub?.cancel();
    if (mounted) {
      setState(() {
        isRunning = false;
      });
    }

    // Guardar el estado actual del subprograma
    var programToUse = selectedAutoProgram ?? allAutomaticPrograms[0];

    // Guardar el tiempo transcurrido en el mapa para el subprograma actual
    subprogramElapsedTime[currentSubprogramIndex] = elapsedTimeSub;
    subprogramRemainingTime[currentSubprogramIndex] = remainingTime;

    print(
        "Temporizador detenido. Tiempo transcurrido: $elapsedTimeSub segundos.");
  }

  void resetSubprogramState() {
    if (mounted) {
      setState(() {
        // Reiniciar el índice actual de subprograma
        currentSubprogramIndex = 0;

        // Reiniciar el temporizador del subprograma si está activo
        timerSub?.cancel();
        timerSub = null;

        // Reiniciar tiempos transcurridos y restantes
        elapsedTimeSub = 0.0;
        remainingTime = 0;

        // Vaciar los mapas de tiempo para subprogramas
        subprogramElapsedTime.clear();
        subprogramRemainingTime.clear();

        print("Estado del subprograma reiniciado.");
      });
    }
  }

  Future<void> printElectrostimulationValues(String macAddress,
      List<int> porcentajesMusculoTraje, String? selectedProgram) async {
    try {
      debugPrint("🔹 printElectrostimulationValues() - Iniciando");

      if (porcentajesMusculoTraje.length != 10) {
        debugPrint(
            "❌ La lista porcentajesMusculoTraje debe tener exactamente 10 elementos.");
        return;
      }

      List<int> valoresCanalesTraje = [
        porcentajesMusculoTraje[5],
        porcentajesMusculoTraje[6],
        porcentajesMusculoTraje[7],
        porcentajesMusculoTraje[8],
        porcentajesMusculoTraje[9],
        porcentajesMusculoTraje[0],
        porcentajesMusculoTraje[2],
        porcentajesMusculoTraje[3],
        porcentajesMusculoTraje[1],
        porcentajesMusculoTraje[4],
      ];

      debugPrint("📊 Valores de canales configurados: $valoresCanalesTraje");

      Map<String, dynamic> settings = getProgramSettings(selectedProgram);
      double frecuencia = settings['frecuencia'] ?? 50;
      double rampa = settings['rampa'] ?? 30;
      double pulso = settings['pulso'] ?? 20;
      List<Map<String, dynamic>> cronaxias = settings['cronaxias'] ?? [];
      List<Map<String, dynamic>> grupos = settings['grupos'] ?? [];

      debugPrint("📊 Datos obtenidos en printElectrostimulationValues:");
      debugPrint("   - Frecuencia: $frecuencia");
      debugPrint("   - Rampa: $rampa");
      debugPrint("   - Pulso: $pulso");
      debugPrint("   - Cronaxias: $cronaxias");
      debugPrint("   - Grupos musculares: $grupos");

      rampa *= 10;
      pulso /= 5;

      debugPrint("⚙️ Configuración ajustada:");
      debugPrint("   - Frecuencia: $frecuencia");
      debugPrint("   - Rampa: $rampa");
      debugPrint("   - Pulso: $pulso");
    } catch (e) {
      debugPrint("❌ Error en printElectrostimulationValues: $e");
    }
  }

  Future<bool> startFullElectrostimulationTrajeProcess(
    String macAddress,
    List<int> porcentajesMusculoTraje,
    String? selectedProgram,
  ) async {
    try {
      if (porcentajesMusculoTraje.length != 10) {
        debugPrint(
            "❌ La lista porcentajesMusculoTraje debe tener exactamente 10 elementos.");
        return false;
      }

      // Configurar los valores de los canales del traje
      List<int> valoresCanalesTraje = List.filled(10, 0);
      valoresCanalesTraje[0] = porcentajesMusculoTraje[5];
      valoresCanalesTraje[1] = porcentajesMusculoTraje[6];
      valoresCanalesTraje[2] = porcentajesMusculoTraje[7];
      valoresCanalesTraje[3] = porcentajesMusculoTraje[8];
      valoresCanalesTraje[4] = porcentajesMusculoTraje[9];
      valoresCanalesTraje[5] = porcentajesMusculoTraje[0];
      valoresCanalesTraje[6] = porcentajesMusculoTraje[2];
      valoresCanalesTraje[7] = porcentajesMusculoTraje[3];
      valoresCanalesTraje[8] = porcentajesMusculoTraje[1];
      valoresCanalesTraje[9] = porcentajesMusculoTraje[4];

      debugPrint("📊 Valores de canales configurados: $valoresCanalesTraje");

      // Obtener configuraciones del programa seleccionado
      Map<String, dynamic> settings = getProgramSettings(selectedProgram);
      double frecuencia = settings['frecuencia'] ?? 50;
      double rampa = settings['rampa'] ?? 30;
      double pulso = settings['pulso'] ?? 20;

      // Validar y convertir la lista de cronaxias
      List<Map<String, dynamic>> cronaxias = [];
      if (settings['cronaxias'] is List) {
        cronaxias = (settings['cronaxias'] as List)
            .where((e) => e is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList();
      }

      for (var cronaxia in cronaxias) {
        debugPrint(
            "Cronaxia: ${cronaxia['nombre']}, Valor: ${cronaxia['valor']}");
      }

      // Ajustes de conversión
      rampa *= 1000;
      pulso /= 5;

      debugPrint(
          "⚙️ Configuración del programa: Frecuencia: $frecuencia Hz, Rampa: $rampa ms, Pulso: $pulso µs");

      // Iniciar sesión de electroestimulación
      final isElectroOn =
          await bleCommandService.startElectrostimulationSession(
        widget.macAddress!,
        valoresCanalesTraje,
        frecuencia,
        rampa,
        pulso: pulso,
      );

      if (!isElectroOn) {
        debugPrint("❌ Error al iniciar la electroestimulación en $macAddress.");
        return false;
      }

      // Controlar todos los canales del dispositivo
      final response = await bleCommandService.controlAllChannels(
        widget.macAddress!,
        1, // Endpoint
        0, // Modo
        valoresCanalesTraje,
      );

      if (response['resultado'] != "OK") {
        debugPrint("❌ Error al configurar los canales: $response");
        return false;
      }

      debugPrint(
          "✅ Proceso completo de electroestimulación iniciado correctamente en $macAddress.");
      return true;
    } catch (e) {
      debugPrint("❌ Error en el proceso completo de electroestimulación: $e");
      return false;
    }
  }

  Future<bool> startFullElectrostimulationPantalonProcess(
    String macAddress,
    List<int> porcentajesMusculoPantalon,
    String? selectedProgram,
  ) async {
    try {
      // Verificar que la lista tiene exactamente 7 elementos
      if (porcentajesMusculoPantalon.length != 7) {
        debugPrint(
            "❌ La lista porcentajesMusculoPantalon debe tener exactamente 7 elementos.");
        return false;
      }

      List<int> valoresCanalesPantalon = List.filled(
          10, 0); // Inicializamos la lista de valoresCanales con ceros.

// Asignar los valores de porcentajesMusculoPantalon a los canales
      valoresCanalesPantalon[0] = 0; // Forzar valor 0 en el índice 0
      valoresCanalesPantalon[1] = 0; // Forzar valor 0 en el índice 1
      valoresCanalesPantalon[2] = porcentajesMusculoPantalon[4];
      valoresCanalesPantalon[3] = porcentajesMusculoPantalon[5];
      valoresCanalesPantalon[4] = porcentajesMusculoPantalon[6];
      valoresCanalesPantalon[5] = 0; // Forzar valor 0 en el índice 5
      valoresCanalesPantalon[6] = porcentajesMusculoPantalon[1];
      valoresCanalesPantalon[7] = porcentajesMusculoPantalon[2];
      valoresCanalesPantalon[8] = porcentajesMusculoPantalon[0];
      valoresCanalesPantalon[9] = porcentajesMusculoPantalon[3];

// Debug: Mostrar los valores asignados
      for (int i = 0; i < valoresCanalesPantalon.length; i++) {
        debugPrint(
            "🔢 Canal ${i + 1}: ${valoresCanalesPantalon[i]} (Porcentaje: ${i < porcentajesMusculoPantalon.length ? porcentajesMusculoPantalon[i] : 0}%)");
      }

      // Paso 2: Obtener configuración del programa seleccionado
      Map<String, dynamic> settings = getProgramSettings(selectedProgram);
      double frecuencia = settings['frecuencia'] ?? 50; // Valor por defecto
      double rampa = settings['rampa'] ?? 30; // Valor por defecto
      double pulso = settings['pulso'] ?? 20; // Valor por defecto
      List<Map<String, dynamic>> cronaxias = settings['cronaxias'] ?? [];
      for (var cronaxia in cronaxias) {
        debugPrint(
            "Cronaxia: ${cronaxia['nombre']}, Valor: ${cronaxia['valor']}");
      }
      // Ajustar los valores según las conversiones necesarias
      rampa *= 1000;
      pulso /= 5;

      debugPrint(
          "✅ Frecuencia: $frecuencia Hz, Rampa: $rampa ms, Anchura de pulso: $pulso µs");

      // Paso 3: Iniciar la sesión de electroestimulación
      bool isElectroOn = await bleCommandService.startElectrostimulationSession(
        widget.macAddress!,
        valoresCanalesPantalon,
        frecuencia,
        rampa,
        pulso: pulso,
      );

      if (isElectroOn) {
        // Paso 4: Controlar los canales
        Map<String, dynamic> response =
            await bleCommandService.controlAllChannels(
          widget.macAddress!,
          1,
          0,
          valoresCanalesPantalon,
        );

        debugPrint(
            "📡 Respuesta de controlAllElectrostimulatorChannels: $response");

        if (response['resultado'] != "OK") {
          debugPrint("❌ Error al configurar los canales.");
          return false;
        }
        if (mounted) {
          setState(() {
            isElectroOn = true;
          });
        }
        return true;
      } else {
        debugPrint(
            "❌ Error al iniciar el proceso completo de electroestimulación.");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error en el proceso completo: $e");
      return false;
    }
  }

  Future<bool> stopElectrostimulationProcess(String macAddress) async {
    try {
      // Verificar si la electroestimulación está activa
      if (isElectroOn) {
        debugPrint(
            "🛑 Deteniendo la electroestimulación en el dispositivo ${widget.macAddress!}...");

        // Llamar al servicio para detener la sesión de electroestimulación
        await bleCommandService
            .stopElectrostimulationSession(widget.macAddress!);

        if (mounted) {
          // Actualizar el estado de la UI
          setState(() {
            isElectroOn =
                false; // Cambiar la bandera para reflejar que está detenida
          });
        }

        debugPrint(
            "✅ Electroestimulación detenida correctamente en ${widget.macAddress!}.");
        return true; // Operación exitosa
      } else {
        debugPrint(
            "⚠️ No hay ninguna sesión de electroestimulación activa para detener.");
        return false; // No había una sesión activa para detener
      }
    } catch (e) {
      debugPrint(
          "❌ Error al detener la electroestimulación en ${widget.macAddress!}: $e");
      return false; // Error durante la operación
    }
  }

  void _clearGlobals() async {
    if (mounted) {
      setState(() {
        // Cancelar controladores de video y otros timers asociados
        _cancelVideoController();

        // Cancelar timer de fase (usado en contracción y pausa)
        _phaseTimer?.cancel();
        _phaseTimer = null;

        // Cancelar timer de suscripción (u otro timer similar)
        timerSub?.cancel();
        timerSub = null;

        // Cancelar el timer principal (asegúrate de que _timer sea nullable)
        _timer.cancel();

        // Reiniciar todas las variables globales de control de la sesión
        isElectroOn = false;
        _isLoading = false;

        // Restablecer valores de programas y selección
        selectedProgram = null;
        selectedAutoProgram = null;
        selectedIndivProgram = null;
        selectedRecoProgram = null;
        selectedClient = null;

        // Reiniciar estado de sesión
        isSessionStarted = false;
        _isImagesLoaded = false;
        isRunning = false;
        isContractionPhase = true;
        isPantalonSelected = false;
        selectedIndexEquip = 0;

        // Restablecer valores de escala
        scaleFactorFull = 1.0;
        scaleFactorCliente = 1.0;
        scaleFactorRepeat = 1.0;
        scaleFactorTrainer = 1.0;
        scaleFactorRayo = 1.0;
        scaleFactorReset = 1.0;
        scaleFactorMas = 1.0;
        scaleFactorMenos = 1.0;

        // Restablecer ángulos de rotación
        rotationAngle1 = 0.0;
        rotationAngle2 = 0.0;
        rotationAngle3 = 0.0;

        // Reiniciar expansión
        _isExpanded1 = false;
        _isExpanded2 = false;
        _isExpanded3 = false;

        // Restablecer imágenes y temporizador principal
        _currentImageIndex = 31 - 25;
        currentSubprogramIndex = 0;
        remainingTime = 0;

        // Restablecer estados de músculos
        _isMusculoTrajeInactivo.fillRange(0, 10, false);
        _isMusculoPantalonInactivo.fillRange(0, 7, false);
        _isMusculoTrajeBloqueado.fillRange(0, 10, false);
        _isMusculoPantalonBloqueado.fillRange(0, 7, false);

        // Reiniciar tiempos de subprogramas
        subprogramElapsedTime = {};
        subprogramRemainingTime = {};

        // Restablecer porcentajes de músculos
        porcentajesMusculoTraje.fillRange(0, 10, 0);
        porcentajesMusculoPantalon.fillRange(0, 7, 0);

        // Reiniciar temporizadores generales y variables asociadas
        elapsedTime = 0.0;
        elapsedTimeSub = 0.0;
        time = 25;
        seconds = 0.0;
        progress = 1.0;

        elapsedTimeContraction = 0.0;
        pausedTimeContraction = 0.0;
        elapsedTimePause = 0.0;
        pausedTimePause = 0.0;
        progressContraction = 0.0;
        progressPause = 0.0;
        startTime = DateTime.now();
        pausedTime = 0.0;

        valueRampa = 1.0;
        valuePause = 1.0;
        valueContraction = 1.0;

        // Reiniciar las banderas de inicio de los timers de fase
        _pauseTimerStarted = false;
        _contraTimerStarted = false;

        _isPauseActive = false;
        _hideControls = false;
        _showVideo = false;
        isFullScreen = false;
        isOverlayVisible = false;
      });
    }
  }

  Future<void> _resetScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: const BorderSide(color: Color(0xFF28E2F5)),
          ),
          backgroundColor: const Color(0xFF494949),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.3,
              maxHeight: MediaQuery.of(context).size.height *
                  0.3, // 🔹 Fija altura máxima
            ),
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
              horizontal: MediaQuery.of(context).size.width * 0.02,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // 🔹 Se ajusta al contenido
                children: [
                  // ✅ Título
                  Text(
                    tr(context, 'Aviso').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 30.sp,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF28E2F5),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // ✅ Mensaje de confirmación
                  Text(
                    tr(context, '¿Quieres resetear todo?').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  // ✅ Fila de botones con `Expanded`
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // 🔹 Cierra el diálogo sin hacer nada
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2be4f3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text(
                          tr(context, 'Cancelar').toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontSize: 17.sp,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          playBeep();
                          Navigator.of(context).pop();
                          _clearGlobals();
                          await bleCommandService.stopElectrostimulationSession(
                              widget.macAddress!);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          tr(context, '¡Sí, quiero resetear!').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("🧹 Limpiando recursos del widget...");
    }
    // Cancelar el temporizador principal
    _timer.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador principal cancelado.");
    }

    // Cancelar el temporizador de fase (contracción/pausa)
    _phaseTimer?.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador de fase cancelado.");
    }

    timerSub?.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador de subprogramas cancelado.");
    }

    // Liberar el controlador de opacidad
    _opacityController.dispose();
    if (kDebugMode) {
      print("🔧 Controlador de opacidad liberado.");
    }
    widget.clientSelectedMap.removeListener(_onClientSelectedMapChanged);
    // Limpiar la lista de clientes seleccionados del Provider
    if (_clientsProvider != null) {
      _clientsProvider!.clearSelectedClientsSilently(); // Limpia sin notificar
      if (kDebugMode) {
        print(
            "📋 Lista de clientes seleccionados borrada desde el Provider (sin notificación).");
      }
    }
    bleCommandService.disposeSubs();
    imagePauseNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> selectedClients =
        Provider.of<ClientsProvider>(context).selectedClients;
    return SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            Column(
              children: [
                if (!isFullScreen) ...[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded1 =
                                    !_isExpanded1; // Cambia el estado de expansión
                                rotationAngle1 = _isExpanded1
                                    ? 3.14159
                                    : 0.0; // Cambia la dirección de la flecha (180 grados)
                              });
                            },
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: rotationAngle1 / (2 * 3.14159),
                              child: SizedBox(
                                height: screenHeight * 0.15,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/flderecha.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.01,
                                    horizontal: screenWidth * 0.01),
                                width: _isExpanded1 ? screenWidth * 0.25 : 0,
                                height: screenHeight * 0.2,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Container con el cliente y el texto
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTapDown: widget.selectedKey == null
                                              ? null
                                              : (_) => setState(() =>
                                                  scaleFactorCliente = 0.90),
                                          onTapUp: widget.selectedKey == null
                                              ? null
                                              : (_) => setState(() =>
                                                  scaleFactorCliente = 1.0),
                                          onTap: widget.selectedKey == null ||
                                                  isRunning
                                              ? null
                                              : () {
                                                  setState(() {
                                                    toggleOverlay(0);
                                                  });
                                                },
                                          child: Opacity(
                                            opacity: widget.selectedKey == null
                                                ? 1.0
                                                : 1.0,
                                            child: AnimatedScale(
                                              scale: scaleFactorCliente,
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              child: Container(
                                                width: screenHeight * 0.1,
                                                height: screenWidth * 0.1,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF494949),
                                                  shape: BoxShape.circle,
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
                                        ),
                                        Visibility(
                                          visible: widget
                                              .clientSelectedMap.value
                                              .containsKey(widget.macAddress),
                                          child: Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            // Se usa para que el `Align` funcione correctamente
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: ValueListenableBuilder<
                                                  Map<String, dynamic>>(
                                                valueListenable:
                                                    widget.clientSelectedMap,
                                                builder: (context, clientMap,
                                                    child) {
                                                  final client = clientMap[
                                                      widget.macAddress];

                                                  if (client == null)
                                                    return SizedBox(); // Si el cliente no existe, no mostrar nada

                                                  final int? bonos = client[
                                                          'bonos']
                                                      as int?; // Asegurar que sea un int

                                                  if (bonos == null ||
                                                      bonos == 0)
                                                    return SizedBox(); // 🔥 Si bonos es 0 o null, ocultar el texto

                                                  return Text(
                                                    "$bonos",
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(width: screenWidth * 0.01),
                                    // Botón "Equipo 0"
                                    Expanded(
                                      child: AbsorbPointer(
                                        absorbing: widget.selectedKey == null ||
                                            isRunning,
                                        child: GestureDetector(
                                          onTap: () {
                                            selectEquip(0);
                                          },
                                          child: Opacity(
                                            opacity: widget.selectedKey == null
                                                ? 1.0
                                                : 1.0,
                                            child: Container(
                                              width: screenWidth * 0.1,
                                              height: screenHeight * 0.1,
                                              decoration: BoxDecoration(
                                                color: selectedIndexEquip == 0
                                                    ? selectedColor
                                                    : unselectedColor,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  bottomLeft:
                                                      Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/images/chalecoblanco.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Botón "Equipo 1"
                                    Expanded(
                                      child: AbsorbPointer(
                                        absorbing: widget.selectedKey == null ||
                                            isRunning,
                                        child: GestureDetector(
                                          onTap: () {
                                            selectEquip(1);
                                          },
                                          child: Opacity(
                                            opacity: widget.selectedKey == null
                                                ? 1.0
                                                : 1.0,
                                            child: Container(
                                              width: screenWidth * 0.1,
                                              height: screenHeight * 0.1,
                                              decoration: BoxDecoration(
                                                color: selectedIndexEquip == 1
                                                    ? selectedColor
                                                    : unselectedColor,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(10.0),
                                                  bottomRight:
                                                      Radius.circular(10.0),
                                                ),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/images/pantalonblanco.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: screenWidth * 0.01),

                                    // Botón "Repetir"
                                    Expanded(
                                      child: GestureDetector(
                                        onTapDown: widget.selectedKey == null
                                            ? null
                                            : (_) => setState(
                                                () => scaleFactorRepeat = 0.90),
                                        onTapUp: widget.selectedKey == null
                                            ? null
                                            : (_) => setState(
                                                () => scaleFactorRepeat = 1.0),
                                        onTap: widget.selectedKey == null ||
                                                isRunning
                                            ? null
                                            : () {
                                                // Acción para botón repetir
                                              },
                                        child: Opacity(
                                          opacity: widget.selectedKey == null
                                              ? 1.0
                                              : 1.0,
                                          child: AnimatedScale(
                                            scale: scaleFactorRepeat,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: Container(
                                              width: screenHeight * 0.1,
                                              height: screenWidth * 0.1,
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: SizedBox(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/images/repeat.png',
                                                      width: screenHeight * 0.1,
                                                      height: screenWidth * 0.1,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.02),
                            height: screenHeight * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: widget.selectedKey == null ||
                                          isRunning
                                      ? null // Inhabilitar el botón si selectedKey es null
                                      : () {
                                          setState(() {
                                            toggleOverlay(
                                                1); // Suponiendo que toggleOverlay abre el overlay
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.01),
                                    side: BorderSide(
                                      width: screenWidth * 0.001,
                                      color: const Color(0xFF2be4f3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    backgroundColor: const Color(
                                        0xFF2be4f3), // Mantener color de fondo
                                  ),
                                  child: Text(
                                    (tr(context,
                                            selectedProgram ?? 'Programas'))
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      // Mantener color del texto
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Column(
                                  children: [
                                    if (selectedProgram == null)
                                      Column(
                                        children: [
                                          Text(
                                            tr(context, 'Nombre programa')
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/programacreado.png',
                                            // Imagen predeterminada
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            fit: BoxFit.contain,
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Individual').toUpperCase())
                                      Column(
                                        children: [
                                          Text(
                                            tr(
                                              context,
                                              selectedIndivProgram?['nombre'] ??
                                                  'Nombre programa', // Traduce el nombre si existe, si no, usa 'Nombre programa'
                                            ).toUpperCase(),
                                            // Convierte el resultado en mayúsculas
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: widget.selectedKey == null ||
                                                    isRunning
                                                ? null // Deshabilitar el clic si `selectedKey` es null
                                                : () {
                                                    setState(() {
                                                      _cancelVideoController();
                                                      toggleOverlay(2);
                                                    });
                                                  },
                                            child: Image.asset(
                                              selectedIndivProgram?['imagen'] ??
                                                  'assets/images/programacreado.png',
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Recovery').toUpperCase())
                                      Column(
                                        children: [
                                          Text(
                                            (selectedRecoProgram?['nombre'])
                                                    ?.toUpperCase() ??
                                                tr(context, 'Nombre programa')
                                                    .toUpperCase(),
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: (widget.selectedKey ==
                                                        null ||
                                                    isRunning ||
                                                    selectedCycle ==
                                                        "${tr(context, 'Ciclo')} D")
                                                ? null // 🔥 Disabled when it's "Ciclo D"
                                                : () {
                                                    setState(() {
                                                      _cancelVideoController();
                                                      toggleOverlay(3);
                                                    });
                                                  },
                                            child: Image.asset(
                                              selectedRecoProgram?['imagen'] ??
                                                  'assets/images/programacreado.png',
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Libre').toUpperCase())
                                      Column(
                                        children: [
                                          buildControlRow2(
                                            value: valueFrecuency,
                                            // Valor de la contracción
                                            imagePathIncrement:
                                                'assets/images/mas.png',
                                            // Imagen del botón de "Más"
                                            imagePathDecrement:
                                                'assets/images/menos.png',
                                            // Imagen del botón de "Menos"
                                            imagePathDisplay:
                                                'assets/images/frec.png',
                                            // Imagen que se muestra (Contracción)
                                            onIncrement: () {
                                              setState(() {
                                                valueFrecuency +=
                                                    1.0; // Lógica de incremento
                                              });
                                            },
                                            onDecrement: () {
                                              setState(() {
                                                if (valueFrecuency > 0) {
                                                  valueFrecuency -=
                                                      1.0; // Lógica de decremento
                                                }
                                              });
                                            },
                                            suffix: " Hz",
                                            // Sufijo para mostrar en el texto
                                            screenWidth: screenWidth,
                                            // Ancho de pantalla
                                            screenHeight:
                                                screenHeight, // Altura de pantalla
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          buildControlRow2(
                                            value: valuePulse,
                                            imagePathIncrement:
                                                'assets/images/mas.png',
                                            imagePathDecrement:
                                                'assets/images/menos.png',
                                            imagePathDisplay:
                                                'assets/images/pulso.png',
                                            onIncrement: () {
                                              setState(() {
                                                valuePulse +=
                                                    1.0; // Incremento en decimales
                                              });
                                            },
                                            onDecrement: () {
                                              setState(() {
                                                if (valuePulse > 0) {
                                                  valuePulse -=
                                                      1.0; // Decremento en decimales
                                                }
                                              });
                                            },
                                            suffix: " ms",
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Automáticos')
                                            .toUpperCase())
                                      Column(
                                        children: [
                                          if (isRunning &&
                                              selectedAutoProgram != null)
                                            Column(
                                              children: [
                                                Text(
                                                  tr(
                                                          context,
                                                          selectedAutoProgram?[
                                                                  'nombre_programa_automatico'] ??
                                                              'Nombre programa')
                                                      .toUpperCase(),
                                                  // Convierte el texto traducido en mayúsculas
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF2be4f3),
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: widget.selectedKey ==
                                                              null ||
                                                          isRunning
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            _cancelVideoController();
                                                            _showVideo = false;
                                                            toggleOverlay(4);
                                                          });
                                                        },
                                                  child: Image.asset(
                                                    selectedAutoProgram![
                                                                    'subprogramas']
                                                                [
                                                                currentSubprogramIndex]
                                                            ['imagen'] ??
                                                        'assets/images/programacreado.png',
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              children: [
                                                Text(
                                                  tr(
                                                          context,
                                                          selectedAutoProgram?[
                                                                  'nombre_programa_automatico'] ??
                                                              'Nombre programa')
                                                      .toUpperCase(),
                                                  // Convierte el texto traducido en mayúsculas
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF2be4f3),
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: widget.selectedKey ==
                                                              null ||
                                                          isRunning
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            toggleOverlay(4);
                                                          });
                                                        },
                                                  child: Image.asset(
                                                    selectedAutoProgram?[
                                                            'imagen'] ??
                                                        'assets/images/programacreado.png',
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.005),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (selectedProgram == null)
                                      Container() // No se muestra nada
                                    else if (selectedProgram ==
                                        tr(context, 'Individual').toUpperCase())
                                      Column(
                                        children: [
                                          Text(
                                            selectedIndivProgram != null
                                                ? "${selectedIndivProgram!['frecuencia'] != null ? formatNumber(selectedIndivProgram!['frecuencia'] as double) : ''} Hz"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Text(
                                            selectedIndivProgram != null
                                                ? "${selectedIndivProgram!['pulso'] != null ? formatNumber(selectedIndivProgram!['pulso'] as double) : ''} ms"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Recovery').toUpperCase())
                                      Column(
                                        children: [
                                          Text(
                                            selectedRecoProgram != null
                                                ? "${selectedRecoProgram!['frecuencia'] != null ? formatNumber(selectedRecoProgram!['frecuencia'] as double) : ''} Hz"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Text(
                                            selectedRecoProgram != null
                                                ? "${selectedRecoProgram!['pulso'] != null ? formatNumber(selectedRecoProgram!['pulso'] as double) : ''} ms"
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                        tr(context, 'Automáticos')
                                            .toUpperCase())
                                      Column(
                                        children: [
                                          if (selectedAutoProgram != null &&
                                              selectedAutoProgram![
                                                      'subprogramas']
                                                  .isNotEmpty)
                                            Column(
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['orden'] ?? tr(context, 'Subprograma desconocido')}. ',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: tr(
                                                                context,
                                                                selectedAutoProgram?['subprogramas']
                                                                            [
                                                                            currentSubprogramIndex]
                                                                        [
                                                                        'nombre'] ??
                                                                    'Subprograma desconocido')
                                                            .toUpperCase(),
                                                        // Traducir y convertir a mayúsculas
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            decorationColor:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  "${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['frecuencia'] != null ? formatNumber(selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['frecuencia'] as double) : 'N/A'} Hz",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                                Text(
                                                  "${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['pulso'] != null ? formatNumber(selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['pulso'] as double) : 'N/A'} ms",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                                Text(
                                                  formatTime(remainingTime),
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF2be4f3),
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else if (selectedAutoProgram != null)
                                            Text(
                                              "${selectedAutoProgram!['duracionTotal'] != null ? formatNumber(selectedAutoProgram!['duracionTotal'] as double) : 'N/A'} min",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                if (selectedIndexEquip == 0 &&
                                    selectedProgram ==
                                        tr(context, 'Recovery').toUpperCase())
                                  OutlinedButton(
                                    onPressed: selectedProgram == null
                                        ? null // Si selectedProgram es nulo, se deshabilita el botón
                                        : () {
                                            if (mounted) {
                                              setState(() {
                                                toggleOverlay(6);
                                              });
                                            }
                                          },
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
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
                                      (selectedCycle == null
                                              ? tr(context, 'Ciclos')
                                              : selectedCycle!)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: const Color(0xFF2be4f3),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("VIRTUAL TRAINER",
                                      style: TextStyle(
                                        color: const Color(0xFF2be4f3),
                                        fontSize: 15.sp,
                                      )),
                                  GestureDetector(
                                    onTap: () async {
                                      final videoUrl =
                                          selectedIndivProgram?['video'];
                                      if (videoUrl != null &&
                                          videoUrl.isNotEmpty) {
                                        final globalManager =
                                            GlobalVideoControllerManager
                                                .instance;

                                        // Verificar si ya hay un video inicializado para este macAddress
                                        if (globalManager.videoController !=
                                                null &&
                                            globalManager.videoController!.value
                                                .isInitialized &&
                                            globalManager.activeMacAddress ==
                                                widget.macAddress!) {
                                          // En lugar de alternar la visibilidad, cancela el video
                                          try {
                                            await _cancelVideoController();
                                            setState(() {
                                              _showVideo =
                                                  false; // Ocultar el video tras cancelar
                                            });
                                            debugPrint(
                                                "Video cancelado y oculto para macAddress: ${widget.macAddress!}");
                                          } catch (e) {
                                            debugPrint(
                                                "Error al cancelar el video: $e");
                                          }
                                        } else {
                                          // Inicializar el video si no está inicializado o no pertenece a este macAddress
                                          setState(() {
                                            _isLoading =
                                                true; // Mostrar el indicador de carga
                                          });

                                          try {
                                            await _initializeVideoController(
                                                videoUrl);

                                            setState(() {
                                              _isLoading =
                                                  false; // Ocultar el indicador de carga
                                              _showVideo =
                                                  true; // Mostrar el video tras la inicialización
                                            });

                                            debugPrint(
                                                "Video inicializado y visible para macAddress: ${widget.macAddress!}");
                                          } catch (e) {
                                            setState(() {
                                              _isLoading =
                                                  false; // Ocultar el indicador si falla la inicialización
                                            });
                                            debugPrint(
                                                "Error al inicializar el video: $e");
                                          }
                                        }
                                      } else {
                                        debugPrint(
                                            "No se proporcionó una URL válida.");
                                      }
                                    },
                                    child: AnimatedScale(
                                      scale: 1.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/virtualtrainer.png',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorRayo = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorRayo = 1.0),
                                onTap: () {
                                  setState(() {
                                    printElectrostimulationValues(
                                        widget.macAddress!,
                                        porcentajesMusculoTraje,
                                        selectedProgram);
                                    _isImageOne =
                                        !_isImageOne; // Alterna entre las dos imágenes
                                  });
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorRayo,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        child: Image.asset(
                                          height: screenHeight * 0.1,
                                          _isImageOne ? rayo[0] : rayo[1],
                                          // Alterna entre las imágenes precargadas
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Expanded(
                  flex: isFullScreen ? 1 : 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: isFullScreen
                            ? screenHeight * 0.05
                            : screenHeight * 0.005),
                    child: Row(
                      children: [
                        Expanded(
                          flex: isFullScreen ? 1 : 6,
                          child: GestureDetector(
                            onTap: () {
                              if (_showVideo == true) {
                                setState(() {
                                  _hideControls = !_hideControls;
                                });
                              }
                            },
                            child: Stack(children: [
                              if (_showVideo &&
                                  GlobalVideoControllerManager
                                          .instance.activeMacAddress ==
                                      widget.macAddress!)
                                Positioned.fill(
                                  child: _isLoading
                                      ? Center(
                                          child: Container(),
                                        )
                                      : (GlobalVideoControllerManager.instance
                                                      .videoController !=
                                                  null &&
                                              GlobalVideoControllerManager
                                                  .instance
                                                  .videoController!
                                                  .value
                                                  .isInitialized)
                                          ? SizedBox(
                                              width: screenWidth,
                                              height: screenHeight,
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: SizedBox(
                                                  width:
                                                      GlobalVideoControllerManager
                                                          .instance
                                                          .videoController!
                                                          .value
                                                          .size
                                                          .width,
                                                  height:
                                                      GlobalVideoControllerManager
                                                          .instance
                                                          .videoController!
                                                          .value
                                                          .size
                                                          .height,
                                                  child: VideoPlayer(
                                                    GlobalVideoControllerManager
                                                        .instance
                                                        .videoController!,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Center(
                                              child: Text(
                                                "No video available",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                ),
                              if (_hideControls == false)
                                Row(
                                  children: [
                                    if (selectedIndexEquip == 0) ...[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 0,
                                              imagePathEnabled:
                                                  'assets/images/pec_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/pecazul.png',
                                              imagePathInactive:
                                                  'assets/images/pec_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 1,
                                              imagePathEnabled:
                                                  'assets/images/biceps_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/bicepsazul.png',
                                              imagePathInactive:
                                                  'assets/images/biceps_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 2,
                                              imagePathEnabled:
                                                  'assets/images/abs_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/absazul.png',
                                              imagePathInactive:
                                                  'assets/images/abs_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 3,
                                              imagePathEnabled:
                                                  'assets/images/cua_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/cuazul.png',
                                              imagePathInactive:
                                                  'assets/images/cua_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 4,
                                              imagePathEnabled:
                                                  'assets/images/gemelos_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gemelosazul.png',
                                              imagePathInactive:
                                                  'assets/images/gemelos_gris.png',
                                            ),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 0,
                                              imagePathEnabled:
                                                  'assets/images/pec_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/pec_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/pec_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 1,
                                              imagePathEnabled:
                                                  'assets/images/biceps_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/biceps_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/biceps_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 2,
                                              imagePathEnabled:
                                                  'assets/images/abs_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/abs_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/abs_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 3,
                                              imagePathEnabled:
                                                  'assets/images/cua_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/cua_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/cua_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 4,
                                              imagePathEnabled:
                                                  'assets/images/gemelos_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gemelos_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/gemelos_gris.png',
                                            ),
                                          ]
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/avatar_frontal.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_pecho_azul.png",
                                                                // Imagen para el estado animado
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        1]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja.png",
                                                          // Imagen bloqueada para bíceps
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_biceps_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        2]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        3]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_cua_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        4]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gem_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        0]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        1]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        2]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        3]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        4]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelo_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        imagePaths[
                                                            _currentImageIndex]!,
                                                        // Accede al valor en el mapa usando la clave _currentImageIndex
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Column(
                                                        children: [
                                                          // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time < 30) {
                                                                  // Máximo valor de time es 30
                                                                  time++; // Aumentar el tiempo
                                                                  _updateTime(
                                                                      time);
                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-arriba.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                            style: TextStyle(
                                                              fontSize: 25.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: const Color(
                                                                  0xFF2be4f3), // Color para la sección seleccionada
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  // Mínimo valor de time es 1
                                                                  time--; // Disminuir el tiempo
                                                                  _updateTime(
                                                                      time);

                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-abajo.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.01),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter(
                                                          progress2:
                                                              progressContraction,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02, // Aumentar altura si isFullScreen es verdadero
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            _contraTimerStarted
                                                                ? (valueContraction -
                                                                    elapsedTimeContraction
                                                                        .floor()) // Muestra el valor decreciente
                                                                : valueContraction // Antes de iniciar, muestra el valor inicial
                                                            ),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .lightGreenAccent
                                                              .shade400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter2(
                                                          progress3:
                                                              progressPause,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            _pauseTimerStarted
                                                                ? (valuePause -
                                                                    elapsedTimePause
                                                                        .floor()) // Muestra el valor decreciente
                                                                : valuePause // Antes de iniciar, muestra el valor inicial
                                                            ),
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: isFullScreen
                                                        ? screenHeight * 0.02
                                                        : screenHeight *
                                                            0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "AVERAGE",
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 23.sp
                                                              : 18.sp,
                                                          // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                        ),
                                                      ),
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.15
                                                              : screenWidth *
                                                                  0.15,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.05
                                                              : screenHeight *
                                                                  0.05, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter:
                                                            AverageLineWithTextPainter(
                                                          average: calculateAverage(
                                                                  porcentajesMusculoTraje) /
                                                              100.0,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02,
                                                          // Aumentar altura si isFullScreen es verdadero
                                                          textStyle: TextStyle(
                                                            fontSize:
                                                                isFullScreen
                                                                    ? 23.sp
                                                                    : 18.sp,
                                                            // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/avatar_post.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_trap_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_dorsal_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        7]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris.png",
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        7]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_lumbar_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        8]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        8]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gluteo_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        9]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        9]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_isquio_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        7]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        7]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        8]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        8]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        9]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        9]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            children: [
                                              // Botón "Menos"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Disminuir el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoTrajeBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoTrajeBloqueado[
                                                                    i] &&
                                                                !_isMusculoTrajeInactivo[
                                                                    i]) {
                                                              porcentajesMusculoTraje[
                                                                      i] =
                                                                  (porcentajesMusculoTraje[
                                                                              i] -
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/menos.png',
                                                size: screenHeight * 0.1,
                                              ),

                                              SizedBox(
                                                  width: screenWidth * 0.01),
                                              // Botón de control de sesión (Reproducir/Pausar)
                                              GestureDetector(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          if (isRunning) {
                                                            // Pausa el temporizador si está corriendo
                                                            _pauseTimer(widget
                                                                .macAddress!);
                                                          } else {
                                                            _startTimer(
                                                                widget
                                                                    .macAddress!,
                                                                porcentajesMusculoTraje,
                                                                porcentajesMusculoPantalon);
                                                          }
                                                          _togglePlayPause(
                                                              widget
                                                                  .macAddress!);
                                                          debugPrint(
                                                              'INCIIANDO SESION ELECTRO PARA: ${widget.macAddress!}');
                                                        });
                                                      },
                                                child: SizedBox(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      height:
                                                          screenHeight * 0.15,
                                                      isRunning
                                                          ? controlImages[1]
                                                          : controlImages[0],
                                                      // Alterna entre Play y Pause
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),

                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Aumentar el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoTrajeBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoTrajeBloqueado[
                                                                    i] &&
                                                                !_isMusculoTrajeInactivo[
                                                                    i]) {
                                                              porcentajesMusculoTraje[
                                                                      i] =
                                                                  (porcentajesMusculoTraje[
                                                                              i] +
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/mas.png',
                                                size: screenHeight * 0.1,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 5,
                                              imagePathEnabled:
                                                  'assets/images/trap_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/trapazul.png',
                                              imagePathInactive:
                                                  'assets/images/trap_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 6,
                                              imagePathEnabled:
                                                  'assets/images/dorsal_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/dorsalazul.png',
                                              imagePathInactive:
                                                  'assets/images/dorsal_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 7,
                                              imagePathEnabled:
                                                  'assets/images/lumbar_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/lumbarazul.png',
                                              imagePathInactive:
                                                  'assets/images/lumbar_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 8,
                                              imagePathEnabled:
                                                  'assets/images/gluteo_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gluteoazul.png',
                                              imagePathInactive:
                                                  'assets/images/gluteo_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 9,
                                              imagePathEnabled:
                                                  'assets/images/isquio_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/isquioazul.png',
                                              imagePathInactive:
                                                  'assets/images/isquio_gris.png',
                                            ),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 5,
                                              imagePathEnabled:
                                                  'assets/images/trap_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/trap_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/trap_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 6,
                                              imagePathEnabled:
                                                  'assets/images/dorsal_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/dorsal_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/dorsal_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 7,
                                              imagePathEnabled:
                                                  'assets/images/lumbar_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/lumbar_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/lumbar_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 8,
                                              imagePathEnabled:
                                                  'assets/images/gluteo_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gluteo_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/gluteo_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 9,
                                              imagePathEnabled:
                                                  'assets/images/isquio_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/isquio_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/isquio_gris.png',
                                            ),
                                          ]
                                        ],
                                      ),
                                    ] else if (selectedIndexEquip == 1) ...[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 0,
                                                imagePathEnabled:
                                                    'assets/images/biceps_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/bicepsazul.png',
                                                imagePathInactive:
                                                    'assets/images/biceps_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 1,
                                                imagePathEnabled:
                                                    'assets/images/abs_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/absazul.png',
                                                imagePathInactive:
                                                    'assets/images/abs_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 2,
                                                imagePathEnabled:
                                                    'assets/images/cua_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/cuazul.png',
                                                imagePathInactive:
                                                    'assets/images/cua_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 3,
                                                imagePathEnabled:
                                                    'assets/images/gemelos_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gemelosazul.png',
                                                imagePathInactive:
                                                    'assets/images/gemelos_gris.png'),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 0,
                                                imagePathEnabled:
                                                    'assets/images/biceps_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/biceps_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/biceps_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 1,
                                                imagePathEnabled:
                                                    'assets/images/abs_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/abs_blanco.png',
                                                imagePathInactive:
                                                    'assets/images/abs_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 2,
                                                imagePathEnabled:
                                                    'assets/images/cua_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/cua_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/cua_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 3,
                                                imagePathEnabled:
                                                    'assets/images/gemelos_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gemelo_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/gemelos_gris.png'),
                                          ]
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/pantalon_frontal.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_biceps_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        1]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_inf_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_sup_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        2]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_cua_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        3]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gem_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        1]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_blanco.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        2]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        3]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gem_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        imagePaths[
                                                            _currentImageIndex]!,
                                                        // Accede al valor en el mapa usando la clave _currentImageIndex
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Column(
                                                        children: [
                                                          // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time < 30) {
                                                                  // Máximo valor de time es 30
                                                                  time++; // Aumentar el tiempo
                                                                  _updateTime(
                                                                      time);

                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-arriba.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                            style: TextStyle(
                                                              fontSize: 25.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: const Color(
                                                                  0xFF2be4f3), // Color para la sección seleccionada
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  // Mínimo valor de time es 1
                                                                  time--; // Disminuir el tiempo
                                                                  _updateTime(
                                                                      time);
                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-abajo.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.01),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter(
                                                          progress2:
                                                              progressContraction,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02, // Aumentar altura si isFullScreen es verdadero
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            _contraTimerStarted
                                                                ? (valueContraction -
                                                                    elapsedTimeContraction
                                                                        .floor()) // Muestra el valor decreciente
                                                                : valueContraction // Antes de iniciar, muestra el valor inicial
                                                            ),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .lightGreenAccent
                                                              .shade400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter2(
                                                          progress3:
                                                              progressPause,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            _pauseTimerStarted
                                                                ? (valuePause -
                                                                    elapsedTimePause
                                                                        .floor()) // Muestra el valor decreciente
                                                                : valuePause // Antes de iniciar, muestra el valor inicial
                                                            ),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: isFullScreen
                                                        ? screenHeight * 0.02
                                                        : screenHeight *
                                                            0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "AVERAGE",
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 23.sp
                                                              : 18.sp,
                                                          // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                        ),
                                                      ),
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.15
                                                              : screenWidth *
                                                                  0.15,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.05
                                                              : screenHeight *
                                                                  0.05, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter:
                                                            AverageLineWithTextPainter(
                                                          average: calculateAverage(
                                                                  porcentajesMusculoPantalon) /
                                                              100.0,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02,
                                                          // Aumentar altura si isFullScreen es verdadero
                                                          textStyle: TextStyle(
                                                            fontSize:
                                                                isFullScreen
                                                                    ? 23.sp
                                                                    : 18.sp,
                                                            // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/pantalon_posterior.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        4]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_lumbar_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_glut_inf_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_glut_sup_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_isquio_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        4]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_blanco_pantalon.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_blanco.png",
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_blanco_pantalon.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            children: [
                                              // Botón "Menos"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Disminuir el porcentaje de los músculos no bloqueados
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoPantalonBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoPantalonBloqueado[
                                                                    i] &&
                                                                !_isMusculoPantalonInactivo[
                                                                    i]) {
                                                              porcentajesMusculoPantalon[
                                                                      i] =
                                                                  (porcentajesMusculoPantalon[
                                                                              i] -
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/menos.png',
                                                size: screenHeight * 0.1,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),

                                              // Botón de control de sesión (Reproducir/Pausar)
                                              GestureDetector(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          if (isRunning) {
                                                            // Pausa el temporizador si está corriendo
                                                            _pauseTimer(widget
                                                                .macAddress!);
                                                          } else {
                                                            _startTimer(
                                                                widget
                                                                    .macAddress!,
                                                                porcentajesMusculoTraje,
                                                                porcentajesMusculoPantalon);
                                                          }
                                                          _togglePlayPause(
                                                              widget
                                                                  .macAddress!);
                                                          debugPrint(
                                                              'INCIIANDO SESION ELECTRO PARA: ${widget.macAddress!}');
                                                        });
                                                      },
                                                child: SizedBox(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      height:
                                                          screenHeight * 0.15,
                                                      isRunning
                                                          ? controlImages[1]
                                                          : controlImages[0],
                                                      // Alterna entre Play y Pause
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),
                                              // Botón "Más"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Aumentar el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoPantalonBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoPantalonBloqueado[
                                                                    i] &&
                                                                !_isMusculoPantalonInactivo[
                                                                    i]) {
                                                              porcentajesMusculoPantalon[
                                                                      i] =
                                                                  (porcentajesMusculoPantalon[
                                                                              i] +
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/mas.png',
                                                size: screenHeight * 0.1,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 4,
                                                imagePathEnabled:
                                                    'assets/images/lumbar_naranja_pantalon.png',
                                                imagePathDisabled:
                                                    'assets/images/lumbar_pantalon_azul.png',
                                                imagePathInactive:
                                                    'assets/images/lumbar_gris_pantalon.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 5,
                                                imagePathEnabled:
                                                    'assets/images/gluteo_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gluteoazul.png',
                                                imagePathInactive:
                                                    'assets/images/gluteo_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 6,
                                                imagePathEnabled:
                                                    'assets/images/isquio_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/isquioazul.png',
                                                imagePathInactive:
                                                    'assets/images/isquio_gris.png'),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 4,
                                                imagePathEnabled:
                                                    'assets/images/lumbar_naranja_pantalon.png',
                                                imagePathDisabled:
                                                    'assets/images/lumbar_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/lumbar_gris_pantalon.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 5,
                                                imagePathEnabled:
                                                    'assets/images/gluteo_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gluteo_blanco.png',
                                                imagePathInactive:
                                                    'assets/images/gluteo_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 6,
                                                imagePathEnabled:
                                                    'assets/images/isquio_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/isquio_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/isquio_gris.png'),
                                          ]
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              if (isFullScreen)
                                Positioned(
                                  bottom: 0,
                                  // Distancia desde el borde superior
                                  right: 0,
                                  // Distancia desde el borde derecho
                                  child: GestureDetector(
                                    onTap: () {
                                      toggleFullScreen(); // Llamamos a la función toggleFullScreen
                                    },
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/fullscreen.png',
                                        width: screenWidth * 0.08,
                                        // Ajusta el tamaño según sea necesario
                                        height: screenHeight * 0.08,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ),
                        if (!isFullScreen)
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Primera sección (con las imágenes y el diseño de la primera parte)
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Contenedor para las imágenes flizquierda alineadas a la derecha
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              // Alineación hacia la derecha
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpanded2 =
                                                        !_isExpanded2; // Cambia el estado de expansión
                                                    rotationAngle2 = _isExpanded2
                                                        ? 3.14159
                                                        : 0.0; // Flecha rota 180 grados
                                                  });
                                                },
                                                child: AnimatedRotation(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  turns: rotationAngle2 /
                                                      (2 * 3.14159),
                                                  child: SizedBox(
                                                    height: screenHeight * 0.15,
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/flizquierda.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          AnimatedSize(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Consumer<ClientsProvider>(
                                              builder: (context,
                                                  clientsProvider, child) {
                                                List<Map<String, dynamic>>
                                                    selectedClients =
                                                    clientsProvider
                                                        .selectedClients;

                                                // Dividir dinámicamente los clientes en dos páginas
                                                List<Map<String, dynamic>>
                                                    clientsPage1 =
                                                    selectedClients.length >= 4
                                                        ? selectedClients
                                                            .sublist(0, 4)
                                                        : selectedClients;

                                                List<Map<String, dynamic>>
                                                    clientsPage2 =
                                                    selectedClients.length > 4
                                                        ? selectedClients
                                                            .sublist(4)
                                                        : [];

                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          screenWidth * 0.005,
                                                      vertical:
                                                          screenHeight * 0.005),
                                                  width: _isExpanded2
                                                      ? screenWidth * 0.2
                                                      : 0,
                                                  height: screenHeight * 0.2,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: _isExpanded2
                                                      ? PageView(
                                                          controller:
                                                              _pageController,
                                                          children: [
                                                            // Página 1: 2 columnas con 2 filas cada una
                                                            GridView.builder(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                vertical:
                                                                    screenHeight *
                                                                        0.015,
                                                                horizontal:
                                                                    screenWidth *
                                                                        0.001,
                                                              ),
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              gridDelegate:
                                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                mainAxisSpacing:
                                                                    screenWidth *
                                                                        0.001,
                                                                crossAxisSpacing:
                                                                    screenHeight *
                                                                        0.001,
                                                                childAspectRatio:
                                                                    1.8,
                                                              ),
                                                              itemCount:
                                                                  clientsPage1
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return _buildClientCard(
                                                                    clientsPage1[
                                                                        index],
                                                                    screenWidth);
                                                              },
                                                            ),

                                                            // Página 2: 2 columnas (una con 2 filas, otra con 1 fila)
                                                            GridView.builder(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                vertical:
                                                                    screenHeight *
                                                                        0.015,
                                                                horizontal:
                                                                    screenWidth *
                                                                        0.001,
                                                              ),
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              shrinkWrap: true,
                                                              gridDelegate:
                                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                mainAxisSpacing:
                                                                    screenWidth *
                                                                        0.001,
                                                                crossAxisSpacing:
                                                                    screenHeight *
                                                                        0.001,
                                                                childAspectRatio:
                                                                    1.8,
                                                              ),
                                                              itemCount:
                                                                  clientsPage2
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return _buildClientCard(
                                                                    clientsPage2[
                                                                        index],
                                                                    screenWidth);
                                                              },
                                                            ),
                                                          ],
                                                        )
                                                      : SizedBox.shrink(),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        children: [
                                          // Contenedor para las imágenes flizquierda alineadas a la derecha
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              // Alineación hacia la derecha
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpanded3 =
                                                        !_isExpanded3; // Cambia el estado de expansión
                                                    rotationAngle3 = _isExpanded3
                                                        ? 3.14159
                                                        : 0.0; // Flecha rota 180 grados
                                                  });
                                                },
                                                child: AnimatedRotation(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  turns: rotationAngle3 /
                                                      (2 * 3.14159),
                                                  child: SizedBox(
                                                    height: screenHeight * 0.15,
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/flizquierda.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          AnimatedSize(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      screenHeight * 0.015,
                                                  horizontal:
                                                      screenWidth * 0.001),
                                              width: _isExpanded3
                                                  ? screenWidth * 0.2
                                                  : 0,
                                              height: screenHeight * 0.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  buildControlRow(
                                                    value: valueContraction,
                                                    // Valor de la contracción
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/CONTRACCION.png',
                                                    // Imagen que se muestra (Contracción)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valueContraction +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valueContraction >
                                                            0) {
                                                          valueContraction -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight:
                                                        screenHeight, // Altura de pantalla
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                  buildControlRow(
                                                    value: valuePause,
                                                    // Valor de pausa
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/PAUSA.png',
                                                    // Imagen que se muestra (Pausa)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valuePause +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valuePause > 0) {
                                                          valuePause -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight: screenHeight,
                                                    isPausa: true,
                                                    imageNotifier:
                                                        imagePauseNotifier,
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                  buildControlRow(
                                                    value: valueRampa,
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    imagePathDisplay:
                                                        'assets/images/RAMPA.png',
                                                    onIncrement: () {
                                                      setState(() {
                                                        valueRampa +=
                                                            0.1; // Incremento en decimales
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valueRampa > 0) {
                                                          valueRampa -=
                                                              0.1; // Decremento en decimales
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    screenWidth: screenWidth,
                                                    screenHeight: screenHeight,
                                                    isRampa:
                                                        true, // Indica que es Rampa, se usarán decimales
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Usamos Expanded para que ocupe el espacio disponible
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Aquí puedes poner otros widgets dentro del Stack si lo necesitas
                                      Positioned(
                                        bottom: 0,
                                        left: screenWidth * 0.02,
                                        child: GestureDetector(
                                          onTapDown: (_) => setState(
                                              () => scaleFactorReset = 0.90),
                                          onTapUp: (_) => setState(
                                              () => scaleFactorReset = 1.0),
                                          onTap: () {
                                            _resetScreen(context);
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorReset,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  'assets/images/RESET.png',
                                                  width: screenWidth * 0.1,
                                                  height: screenHeight * 0.1,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Aquí está la imagen de fullscreen en la esquina
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTapDown: (_) => setState(
                                              () => scaleFactorFull = 0.90),
                                          onTapUp: (_) => setState(
                                              () => scaleFactorFull = 1.0),
                                          onTap: () {
                                            toggleFullScreen();
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorFull,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/fullscreen.png',
                                                width: screenWidth * 0.08,
                                                height: screenHeight * 0.08,
                                                fit: BoxFit.scaleDown,
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
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
            if (isOverlayVisible)
              Positioned(
                top: overlayIndex == 6
                    ? screenHeight * 0.1
                    : (overlayIndex == 1 ? screenHeight * 0.2 : 0),
                bottom: overlayIndex == 6
                    ? screenHeight * 0.1
                    : (overlayIndex == 1 ? screenHeight * 0.2 : 0),
                left: overlayIndex == 6
                    ? screenWidth * 0.2
                    : (overlayIndex == 1 ? screenWidth * 0.2 : 0),
                right: overlayIndex == 6
                    ? screenWidth * 0.2
                    : (overlayIndex == 1 ? screenWidth * 0.2 : 0),
                child: Align(
                  alignment: Alignment.center,
                  child: _getOverlayWidget(
                      overlayIndex,
                      onProgramSelected,
                      onIndivProgramSelected,
                      onRecoProgramSelected,
                      onAutoProgramSelected,
                      onClientSelected,
                      onCycleSelected),
                ),
              ),
          ],
        ));
  }

  Widget _getOverlayWidget(
      int overlayIndex,
      Function(String) onProgramSelected,
      Function(Map<String, dynamic>?) onIndivProgramSelected,
      Function(Map<String, dynamic>?) onRecoProgramSelected,
      Function(Map<String, dynamic>?) onAutoProgramSelected,
      Function(Map<String, dynamic>?) onClientSelected,
      Function(String) onCycleSelected,
      ) {
    switch (overlayIndex) {
      case 0:
        return OverlaySeleccionarCliente(
          onClose: () => toggleOverlay(0),
          onClientSelected: onClientSelected,
        );
      case 1:
        return OverlayTipoPrograma(
          onClose: () => toggleOverlay(1),
          onProgramSelected:
          onProgramSelected, // Solo OverlayTipoPrograma recibe este callback
        );
      case 2:
        return OverlaySeleccionarProgramaIndividual(
          onClose: () => toggleOverlay(2),
          onIndivProgramSelected: onIndivProgramSelected,
        );
      case 3:
        return OverlaySeleccionarProgramaRecovery(
          onClose: () => toggleOverlay(3),
          onRecoProgramSelected: onRecoProgramSelected,
        );
      case 4:
        return OverlaySeleccionarProgramaAutomatic(
          onClose: () => toggleOverlay(4),
          onAutoProgramSelected: onAutoProgramSelected,
        );
    /*     case 5:
        return OverlayResumenSesion(
          onClose: () => toggleOverlay(5),
          onClientSelected: onClientSelected,
        );*/
      case 6:
        return OverlayCiclos(
          onClose: () => toggleOverlay(6),
          onCycleSelected: onCycleSelected,
          selectedCycle: selectedCycle ?? '',
        );
      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildClientCard(Map<String, dynamic> client, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.008),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            client['name'].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF2be4f3),
            ),
          ),
          Row(
            children: [
              Image.asset(
                width: screenWidth * 0.05,
                'assets/images/EKCAL.png',
                fit: BoxFit.scaleDown,
              ),
              SizedBox(width: screenWidth * 0.01),
              Text(
                client['counter1']?.toString() ?? '0',
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleRow({
    required int index,
    required String imagePathEnabled,
    required String imagePathDisabled,
    required String imagePathInactive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.height * 0.002),
          decoration: BoxDecoration(
            color: _isMusculoTrajeInactivo[index]
                ? Colors.grey.withOpacity(0.5) // Gris si está inactivo
                : _isMusculoTrajeBloqueado[index]
                ? const Color(0xFFFFA500)
                .withOpacity(0.3) // Naranja si está bloqueado
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null
                    : () {
                  setState(() {
                    if (!_isMusculoTrajeBloqueado[index] &&
                        !_isMusculoTrajeInactivo[index]) {
                      porcentajesMusculoTraje[index] =
                          (porcentajesMusculoTraje[index] + 1)
                              .clamp(0, 100);
                      // Llamar a la función con modo 1 (Más)
                    } else if (_isMusculoTrajeInactivo[index]) {
                      // Si está inactivo, poner el porcentaje a 0
                      porcentajesMusculoTraje[index] = 0;
                    }
                  });
                },
                imagePath: 'assets/images/mas.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Columna que contiene el GestureDetector y el porcentaje
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_isMusculoTrajeInactivo[index]) {
                          _isMusculoTrajeBloqueado[index] =
                          !_isMusculoTrajeBloqueado[index];
                        }
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        if (_isMusculoTrajeBloqueado[index]) {
                          _isMusculoTrajeBloqueado[index] = false;
                        }
                        _isMusculoTrajeInactivo[index] =
                        !_isMusculoTrajeInactivo[index];

                        // Si se pone inactivo, poner el porcentaje a 0
                        if (_isMusculoTrajeInactivo[index]) {
                          porcentajesMusculoTraje[index] = 0;
                        }
                      });
                    },
                    child: SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height * 0.09
                          : MediaQuery.of(context).size.height * 0.08,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Capa de color sobre la imagen, solo si no está inactivo
                            if (!_isMusculoTrajeInactivo[index])
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Forma circular
                                    color: _getColorForPercentage(
                                        porcentajesMusculoTraje[index],
                                        isRunning,
                                        index),
                                  ),
                                ),
                              ),
                            // Imagen sobre la capa de color
                            Image.asset(
                              // Lógica de selección de la imagen
                              _isMusculoTrajeBloqueado[index]
                                  ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                                  : (_isMusculoTrajeInactivo[index]
                                  ? imagePathInactive // Mostrar la imagen inactiva si está inactivo
                                  : imagePathDisabled),
                              // Mostrar la imagen deshabilitada
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${porcentajesMusculoTraje[index]}%',
                    style: TextStyle(
                      fontSize: isFullScreen ? 18.0.sp : 17.0.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),
              // Botón "Menos"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null
                    : () {
                  setState(() {
                    if (!_isMusculoTrajeBloqueado[index] &&
                        !_isMusculoTrajeInactivo[index]) {
                      porcentajesMusculoTraje[index] =
                          (porcentajesMusculoTraje[index] - 1)
                              .clamp(0, 100);
                      // Llamar a la función con modo 2 (Menos)
                    } else if (_isMusculoTrajeInactivo[index]) {
                      // Si está inactivo, poner el porcentaje a 0
                      porcentajesMusculoTraje[index] = 0;
                    }
                  });
                },
                imagePath: 'assets/images/menos.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForPercentage(int percentage, bool isRunning, int index) {
    if (!isRunning) {
      return Colors.transparent; // Si no está en ejecución, no se muestra color
    }

    // Obtiene los umbrales de porcentaje del grupo muscular correspondiente
    List<int> umbrales = porcentajesPorGrupoTraje[index];

    // Compara el porcentaje con los umbrales del grupo muscular
    if (percentage >= umbrales[3]) {
      return Colors.red.withOpacity(0.6); // Rojo con opacidad del 60%
    } else if (percentage >= umbrales[2]) {
      return Colors.yellow.withOpacity(0.9); // Amarillo con opacidad del 60%
    } else if (percentage >= umbrales[1]) {
      return Colors.lightGreenAccent.shade400
          .withOpacity(0.8); // Verde claro con opacidad del 60%
    } else {
      return Colors.green.withOpacity(0.6); // Verde con opacidad del 60%
    }
  }

  double calculateAverage(List<int> porcentajesMusculoTraje) {
    double sum =
    porcentajesMusculoTraje.fold(0, (prev, element) => prev + element);
    return sum / porcentajesMusculoTraje.length;
  }

  Widget _buildMuscleRow2({
    required int index,
    required String imagePathEnabled,
    required String imagePathDisabled,
    required String imagePathInactive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: _isMusculoPantalonInactivo[index]
                ? Colors.grey.withOpacity(0.3) // Si está inactivo, color gris
                : _isMusculoPantalonBloqueado[index]
                ? const Color(0xFFFFA500)
                .withOpacity(0.3) // Si está bloqueado, color naranja
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7.0), // Redondea las esquinas
          ),
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                  setState(() {
                    if (!_isMusculoPantalonBloqueado[index] &&
                        !_isMusculoPantalonInactivo[index]) {
                      porcentajesMusculoPantalon[index] =
                          (porcentajesMusculoPantalon[index] + 1)
                              .clamp(0, 100);
                    } else if (_isMusculoPantalonInactivo[index]) {
                      // Si está inactivo, poner el porcentaje a 0
                      porcentajesMusculoPantalon[index] = 0;
                    }
                  });
                },
                imagePath: 'assets/images/mas.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Columna que contiene el GestureDetector y el porcentaje
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_isMusculoPantalonInactivo[index]) {
                          _isMusculoPantalonBloqueado[index] =
                          !_isMusculoPantalonBloqueado[index];
                        }
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        if (_isMusculoPantalonBloqueado[index]) {
                          // Cambiar el estado de bloqueado a desbloqueado
                          _isMusculoPantalonBloqueado[index] = false;
                        }
                        // Cambiar el estado de inactivo
                        _isMusculoPantalonInactivo[index] =
                        !_isMusculoPantalonInactivo[index];
                        // Si se pone inactivo, poner el porcentaje a 0
                        if (_isMusculoPantalonInactivo[index]) {
                          porcentajesMusculoPantalon[index] = 0;
                        }
                      });
                    },
                    child: SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height * 0.09
                          : MediaQuery.of(context).size.height * 0.08,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Capa de color sobre la imagen, solo si no está inactivo
                            if (!_isMusculoPantalonInactivo[index])
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Forma circular
                                    color: _getColorForPercentagePantalon(
                                        porcentajesMusculoPantalon[index],
                                        isRunning,
                                        index), // Si está activo, aplicar el color basado en porcentaje
                                  ),
                                ),
                              ),
                            // Imagen sobre la capa de color
                            Image.asset(
                              // Lógica de selección de la imagen
                              _isMusculoPantalonBloqueado[index]
                                  ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                                  : (_isMusculoPantalonInactivo[index]
                                  ? imagePathInactive // Si está inactivo
                                  : imagePathDisabled), // Si está deshabilitado
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Texto que muestra el porcentaje
                  Text(
                    '${porcentajesMusculoPantalon[index]}%',
                    style: TextStyle(
                      fontSize: isFullScreen ? 18.0.sp : 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Botón "Menos"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                  setState(() {
                    if (!_isMusculoPantalonBloqueado[index] &&
                        !_isMusculoPantalonInactivo[index]) {
                      porcentajesMusculoPantalon[index] =
                          (porcentajesMusculoPantalon[index] - 1)
                              .clamp(0, 100);
                    } else if (_isMusculoPantalonInactivo[index]) {
                      // Si está inactivo, poner el porcentaje a 0
                      porcentajesMusculoPantalon[index] = 0;
                    }
                  });
                },
                imagePath: 'assets/images/menos.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForPercentagePantalon(
      int percentage, bool isRunning, int index) {
    if (!isRunning) {
      return Colors.transparent; // Si no está en ejecución, no se muestra color
    }

    // Obtiene los umbrales de porcentaje del grupo muscular correspondiente
    List<int> umbrales = porcentajesPorGrupoPantalon[index];

    // Compara el porcentaje con los umbrales del grupo muscular
    if (percentage >= umbrales[3]) {
      return Colors.red.withOpacity(0.6); // Rojo con opacidad del 60%
    } else if (percentage >= umbrales[2]) {
      return Colors.yellow.withOpacity(0.9); // Amarillo con opacidad del 60%
    } else if (percentage >= umbrales[1]) {
      return Colors.lightGreenAccent.shade400
          .withOpacity(0.8); // Verde claro con opacidad del 60%
    } else {
      return Colors.green.withOpacity(0.6); // Verde con opacidad del 60%
    }
  }

  double calculateAverage2(List<int> porcentajesMusculoPantalon) {
    double sum =
    porcentajesMusculoPantalon.fold(0, (prev, element) => prev + element);
    return sum / porcentajesMusculoPantalon.length;
  }

  Widget buildControlRow({
    required double value,
    required String imagePathIncrement,
    required String imagePathDecrement,
    required String imagePathDisplay,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required String suffix,
    required double screenWidth,
    required double screenHeight,
    bool isRampa = false,
    bool isPausa = false,
    ValueNotifier<String>? imageNotifier, // Agregar esto
  }) {
    imageNotifier ??= ValueNotifier<String>(
        imagePathDisplay); // Usa el pasado o crea uno nuevo

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onIncrement,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathIncrement,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.005),
        Text(
          isRampa
              ? "${value.toStringAsFixed(1)}$suffix"
              : "${value.toStringAsFixed(0)}$suffix",
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(width: screenWidth * 0.005),
        GestureDetector(
          onTap: onDecrement,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathDecrement,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.001),
        if (isPausa)
          GestureDetector(
            onTap: () {
              if (selectedCycle != null) {
                imageNotifier!.value =
                    imagePathDisplay; // 🔹 Mantiene imagen original
                _isPauseActive =
                false; // 🔹 Asegura que se desactive la pausa activa
                return; // 🔥 Evita que se ejecute el cambio de imagen
              }

              setState(() {
                _isPauseActive =
                !_isPauseActive; // 🔥 Cambia el estado solo si no hay ciclo
                imageNotifier!.value = _isPauseActive
                    ? 'assets/images/pausaactiva.png' // Imagen cuando está activa la pausa
                    : imagePathDisplay; // Imagen inicial
                debugPrint('${_isPauseActive}');
              });
            },
            child: ValueListenableBuilder<String>(
              valueListenable: imageNotifier,
              builder: (context, imagePath, child) {
                return Image.asset(
                  imagePath,
                  width: screenWidth * 0.05,
                  height: screenHeight * 0.05,
                );
              },
            ),
          )
        else
          Image.asset(
            imagePathDisplay,
            width: screenWidth * 0.05,
            height: screenHeight * 0.05,
          ),
      ],
    );
  }

  Widget buildControlRow2({
    required double value,
    required String imagePathIncrement,
    required String imagePathDecrement,
    required String imagePathDisplay,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required String suffix,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onIncrement,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathIncrement,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.005),
        Text(
          "${value.toStringAsFixed(0)}$suffix",
          style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(width: screenWidth * 0.005),
        GestureDetector(
          onTap: onDecrement,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathDecrement,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.001),
        Image.asset(
          imagePathDisplay,
          width: screenWidth * 0.05,
          height: screenHeight * 0.05,
        ),
      ],
    );
  }
}
