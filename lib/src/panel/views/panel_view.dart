import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/panel/overlays/overlay_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';
import '../../servicios/licencia_state.dart';
import '../custom/border_neon.dart';
import '../custom/linear_custom.dart';

class PanelView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReset; // Nuevo callback para reiniciar

  const PanelView({super.key, required this.onBack, required this.onReset});

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView>
    with SingleTickerProviderStateMixin {
  late BleConnectionService bleConnectionService;

  bool isDisconnected = true;
  bool isConnected = false;
  bool isActive = false;
  bool isTimeless = false;
  String connectionStatus = "desconectado";
  bool _isConnecting = false;
  List<String> successfullyConnectedDevices = [];
  late StreamSubscription _subscription;
  String? selectedProgram;
  List<Map<String, dynamic>> allIndividualPrograms = [];
  List<Map<String, dynamic>> allRecoveryPrograms = [];
  List<Map<String, dynamic>> allAutomaticPrograms = [];
  List<Map<String, dynamic>> allClients = []; // Lista original de clientes
  Map<String, String> clientsNames = {};
  Map<String, String> bluetoothNames = {};
  Map<String, int> batteryStatuses = {};
  final Map<String, bool> isMciSelected = {};
  final Map<String, Key> mciKeys =
      {}; // Mapa para almacenar Keys únicas por MCI
  String? selectedKey; // Key seleccionada
  Map<String, int> mciEquipMapping = {};
  Map<String, Map<String, dynamic>> mciStates = {}; // Estado por MCI
  Map<String, Map<String, dynamic>> deviceStates = {};

  double scaleFactorBack = 1.0;
  double scaleFactorFull = 1.0;
  double scaleFactorCliente = 1.0;
  double scaleFactorRepeat = 1.0;
  double scaleFactorTrainer = 1.0;
  double scaleFactorReset = 1.0;
  double scaleFactorMas = 1.0;
  double scaleFactorMenos = 1.0;

  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;

  double rotationAngle1 = 0.0; // Controla el ángulo de rotación de la flecha
  double rotationAngle2 = 0.0; // Controla el ángulo de rotación de la flecha
  double rotationAngle3 = 0.0; // Controla el ángulo de rotación de la flecha
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;

  int selectedIndexEquip = 0;
  bool _isFullScreen = false;
  bool isPantalonSelected = false;
  Color selectedColor =
      const Color(0xFF2be4f3); // Color para la sección seleccionada
  Color unselectedColor = const Color(0xFF494949);

  double progress = 1.0; // El progreso del círculo
  final double strokeWidth = 20.0; // Grosor del borde
  double strokeHeight = 20.0; // Altura de la barra
  int totalTime =
      25 * 60; // Tiempo total en segundos (seleccionado por el usuario)
  late Timer _timer; // Para gestionar el tiempo
  double elapsedTime = 0.0; // Tiempo transcurrido en segundos
  bool isRunning = false;
  late DateTime startTime; // Hora en que comenzó el temporizador
  late double pausedTime = 0.0; // Tiempo acumulado antes de la pausa
  int time = 25;
  double seconds = 0.0;

  double progressContraction = 0.0;
  double progressPause = 0.0;
  bool isContractionPhase = true; // Indica si está en fase de contracción
  double elapsedTimeContraction = 0.0; // Tiempo transcurrido de contracción
  double elapsedTimePause = 0.0; // Tiempo transcurrido de pausa
  Timer? _phaseTimer;

  double valueContraction = 1.0;
  double valueRampa = 1.0;
  double valuePause = 1.0;

  bool isSessionStarted = false;
  bool _isImagesLoaded = false;

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



  int _currentImageIndex = 0;
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
  final List<int> porcentajesMusculoTraje = List.filled(10, 0);
  final List<int> porcentajesMusculoPantalon = List.filled(7, 0);

  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  final Map<String, String> deviceConnectionStatus =
      {}; // To store connection status per MAC

  @override
  void initState() {
    super.initState();
    initializeAndConnectBLE();
    _subscription = bleConnectionService.deviceUpdates.listen((update) {
      final macAddress = update['macAddress'];

      setState(() {
        if (update.containsKey('bluetoothName')) {
          bluetoothNames[macAddress] = update['bluetoothName'];
        }
        if (update.containsKey('batteryStatus')) {
          batteryStatuses[macAddress] = update['batteryStatus'];
        }
        if (!isMciSelected.containsKey(macAddress)) {
          isMciSelected[macAddress] = false; // Inicializa en falso
        }
      });
    });
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

    _fetchClients();
    _fetchIndividualPrograms();
    _fetchRecoveryPrograms();
    _fetchAutoPrograms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  } // Verificar que BLE esté inicializado correctamente

  Future<void> initializeAndConnectBLE() async {
    // Inicializar el servicio BLE con una lista vacía
    bleConnectionService = BleConnectionService([]);
    bleConnectionService.isWidgetActive = true;

    // Cargar los datos de AppState y actualizar el servicio BLE
    await AppState.instance.loadState();

    // Obtener las direcciones MAC desde el AppState
    List<String> macAddresses =
        AppState.instance.mcis.map((mci) => mci['mac'] as String).toList();

    debugPrint("🔍--->>>Direcciones MAC obtenidas: $macAddresses");

    for (var mci in AppState.instance.mcis) {
      String macAddress = mci['mac'];
      mciKeys[macAddress] = ValueKey(macAddress); // Generar y asignar ValueKey
    }
    // Actualizar la lista de direcciones MAC en el servicio BLE
    if (mounted) {
      setState(() {
        bleConnectionService.updateMacAddresses(macAddresses);
      });
    }

    // Esperar un breve espacio de tiempo para procesar las conexiones actuales
    await Future.delayed(const Duration(seconds: 2));

    successfullyConnectedDevices.clear();

    // Intentar conectar a los dispositivos
    for (final macAddress in macAddresses) {
      bool success =
          await bleConnectionService._connectToDeviceByMac(macAddress);

      if (mounted) {
        setState(() {
          // Actualizar el estado de conexión en la UI
          deviceConnectionStatus[macAddress] =
              success ? 'conectado' : 'desconectado';
          success ? 'conectado' : 'desconectado';
        });
      }

      if (success) {
        debugPrint("✅--->>>Dispositivo $macAddress conectado correctamente.");
        successfullyConnectedDevices.add(macAddress);
      } else {
        debugPrint("❌--->>>No se pudo conectar al dispositivo $macAddress.");
      }

      // Esperar brevemente entre intentos para evitar conflictos
      await Future.delayed(const Duration(seconds: 1));
    }

    debugPrint("🔚--->>>Proceso de conexión BLE finalizado.");

    // Continuar si al menos un dispositivo se conectó exitosamente
    if (successfullyConnectedDevices.isNotEmpty) {
      debugPrint(
          "✅--->>>Iniciando inicialización de seguridad para dispositivos conectados: $successfullyConnectedDevices");

      await Future.delayed(const Duration(seconds: 2));

      await bleConnectionService.processConnectedDevices();

      await Future.delayed(const Duration(seconds: 4));

      // Iniciar la verificación periódica de conexión
      debugPrint("⌚--->>>Iniciando verificación de conexión periódica");
      bleConnectionService
          .startPeriodicConnectionCheck((macAddress, isConnected) {
        if (mounted) {
          setState(() {
            // Actualizar el estado de conexión en la UI
            deviceConnectionStatus[macAddress] =
                isConnected ? 'conectado' : 'desconectado';
            isConnected ? 'conectado' : 'desconectado';
          });
        }
      });
    } else {
      debugPrint(
          "⚠️--->>>Ningún dispositivo fue conectado exitosamente. Saltando inicialización de seguridad y operaciones.");
    }
  }

  Future<void> _preloadImages() async {
    // Itera sobre las claves del mapa (1 a 31)
    for (int key in imagePaths.keys) {
      String path = imagePaths[key]!; // Obtiene la ruta de la imagen
      await precacheImage(AssetImage(path), context); // Pre-carga la imagen
    }

    // Cambia el estado una vez que todas las imágenes estén precargadas
    setState(() {
      _isImagesLoaded = true;
    });
  }

  void _clearGlobals() {
    setState(() {
      globalSelectedProgram = null;
      selectedClientsGlobal = [];
    });
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        allClients = clientData; // Asigna a la lista original
      });
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    }
  }

  Future<void> _fetchIndividualPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final individualProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoIndividual(db);

      for (var individualProgram in individualProgramData) {
        // Obtener cronaxias
        var cronaxias = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, individualProgram['id_programa']);
        var grupos = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, individualProgram['id_programa']);
      }

      // Actualizamos el estado con los programas obtenidos
      setState(() {
        allIndividualPrograms =
            individualProgramData; // Asignamos los programas obtenidos a la lista
      });
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchRecoveryPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas de la base de datos filtrados por tipo 'Individual'
      final recoveryProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoRecovery(db);

      // Iteramos sobre los programas y obtenemos las cronaxias y los grupos de las tablas intermedias
      for (var recoveryProgram in recoveryProgramData) {
        // Obtener cronaxias
        var cronaxias = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, recoveryProgram['id_programa']);
        var grupos = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, recoveryProgram['id_programa']);
      }

      // Actualizamos el estado con los programas obtenidos
      setState(() {
        allRecoveryPrograms =
            recoveryProgramData; // Asignamos los programas obtenidos a la lista
      });
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchAutoPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      // Llamamos a la función que obtiene los programas automáticos y sus subprogramas
      final autoProgramData =
          await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);

      // Agrupamos los subprogramas por programa automático
      List<Map<String, dynamic>> groupedPrograms =
          _groupProgramsWithSubprograms(autoProgramData);

      setState(() {
        allAutomaticPrograms =
            groupedPrograms; // Asigna los programas obtenidos a la lista
      });
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

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  void _startTimer() {
    if (isRunning) return; // Evita iniciar si ya está corriendo

    setState(() {
      isRunning = true;

      // Si pausedTime tiene un valor previo, reanuda desde donde quedó
      startTime = DateTime.now();

      // Inicia o reanuda el temporizador principal
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          // Calcula el tiempo transcurrido y el progreso
          elapsedTime = pausedTime +
              DateTime.now().difference(startTime).inSeconds.toDouble();
          progress = 1.0 - (elapsedTime / totalTime); // Reducir el progreso

          // Actualiza los minutos y segundos
          seconds = (totalTime - elapsedTime).toInt() % 60;
          time = (totalTime - elapsedTime).toInt() ~/ 60;

          if ((totalTime - elapsedTime) % 60 == 0) {
            _currentImageIndex = imagePaths.length - time;
          }

          // Detiene el temporizador al alcanzar el tiempo total
          if (elapsedTime >= totalTime) {
            _pauseTimer();
          }
        });
      });

      // Reanuda el temporizador de contracción o pausa
      if (isContractionPhase) {
        _startContractionTimer(valueContraction);
      } else {
        _startPauseTimer(valuePause);
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      isRunning = false;
      pausedTime = elapsedTime; // Guarda el tiempo del temporizador principal

      // Pausa el temporizador actual y guarda su estado
      _pausePhaseTimer();

      // Detiene el temporizador principal
      _timer.cancel();
    });
  }

  void _startContractionTimer(double contractionDuration) {
    _phaseTimer?.cancel(); // Detiene cualquier temporizador previo

    // Calcula el progreso restante
    final remainingTime = contractionDuration - elapsedTimeContraction;

    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        elapsedTimeContraction += 0.1;
        progressContraction =
            elapsedTimeContraction / contractionDuration; // Progreso ascendente

        // Si se completó el tiempo de contracción, pasa a la pausa
        if (elapsedTimeContraction >= contractionDuration) {
          elapsedTimeContraction = 0.0; // Reinicia el tiempo de contracción
          isContractionPhase = false;
          _startPauseTimer(valuePause);
        }
      });
    });

    if (remainingTime <= 0) {
      // Si no queda tiempo en esta fase, pasa inmediatamente a la siguiente
      elapsedTimeContraction = 0.0;
      isContractionPhase = false;
      _startPauseTimer(valuePause);
    }
  }

  void _startPauseTimer(double pauseDuration) {
    _phaseTimer?.cancel(); // Detiene cualquier temporizador previo

    // Calcula el progreso restante
    final remainingTime = pauseDuration - elapsedTimePause;

    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        elapsedTimePause += 0.1;
        progressPause = elapsedTimePause / pauseDuration; // Progreso ascendente

        // Si se completó el tiempo de pausa, pasa a la contracción
        if (elapsedTimePause >= pauseDuration) {
          elapsedTimePause = 0.0; // Reinicia el tiempo de pausa
          isContractionPhase = true;
          _startContractionTimer(valueContraction);
        }
      });
    });

    if (remainingTime <= 0) {
      // Si no queda tiempo en esta fase, pasa inmediatamente a la siguiente
      elapsedTimePause = 0.0;
      isContractionPhase = true;
      _startContractionTimer(valueContraction);
    }
  }

  // Pausa el temporizador actual
  void _pausePhaseTimer() {
    _phaseTimer?.cancel();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("🧹 Limpiando recursos del widget...");
    }

    // Cancelar el timer
    _timer.cancel();
    if (kDebugMode) {
      print("⏲️ Timer cancelado.");
    }

    // Liberar el controlador de opacidad
    _opacityController.dispose();
    if (kDebugMode) {
      print("🔧 Controlador de opacidad liberado.");
    }

    // Cancelar la suscripción
    _subscription.cancel();
    if (kDebugMode) {
      print("📡 Suscripción cancelada.");
    }

    // Liberar recursos BLE
    bleConnectionService.disposeBleResources();
    if (kDebugMode) {
      print("💡 Recursos BLE liberados.");
    }

    super.dispose();
    if (kDebugMode) {
      print("🚀 dispose() ejecutado correctamente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isConnected = bleConnectionService.isConnected;
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la imagen
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenedor blanco semi-translúcido por encima del fondo
          Container(
            color: Colors.transparent,
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02, horizontal: screenWidth * 0.02),
            child: Column(
              children: [
                if (!_isFullScreen)
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ...AppState.instance.mcis.map((mci) {
                                        String macAddress = mci[
                                            'mac']; // Obtener la MAC de cada dispositivo
                                        // Inicializa el equipo seleccionado para la MCI si no existe
                                        if (!mciEquipMapping
                                            .containsKey(macAddress)) {
                                          mciEquipMapping[macAddress] =
                                              0; // Por defecto, equipo 0
                                        }
                                        return GestureDetector(
                                          key: mciKeys[macAddress],
                                          onTap: () {
                                            if (deviceConnectionStatus[
                                                    macAddress] ==
                                                'conectado') {
                                              setState(() {
                                                // Actualizar la Key seleccionada
                                                selectedKey = macAddress;
                                                selectedIndexEquip =
                                                    mciEquipMapping[
                                                            macAddress] ??
                                                        0;
                                              });

                                              print(
                                                  "✅ Dispositivo $macAddress seleccionado. Equipo asociado: $selectedIndexEquip");
                                              print(
                                                  "✅ Dispositivo $macAddress seleccionado.");
                                              print(
                                                  "🔑 Key seleccionada: ${mciKeys[macAddress]}");
                                            } else {
                                              print(
                                                  "❌ Dispositivo $macAddress no está conectado.");
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: SizedBox(
                                                  width: screenWidth * 0.15,
                                                  // Ancho dividido en dos secciones
                                                  height: screenHeight * 0.1,
                                                  child: CustomPaint(
                                                    painter: NeonBorderPainter(
                                                      neonColor: _getBorderColor(
                                                          deviceConnectionStatus[
                                                              macAddress]),
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                7), // Bordes redondeados
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Sección izquierda
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    Image.asset(
                                                                  // Mostrar la imagen según el equipo seleccionado para esta MCI
                                                                  (mciEquipMapping[macAddress] ??
                                                                              0) ==
                                                                          0
                                                                      ? 'assets/images/chalecoblanco.png' // Equipo 0
                                                                      : 'assets/images/pantalonblanco.png',
                                                                  // Equipo 1
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // Sección derecha: Nombres y barras de batería
                                                          Expanded(
                                                            flex: 2,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                // Nombre del cliente
                                                                Text(
                                                                  selectedClientsGlobal
                                                                          .isEmpty
                                                                      ? '' // Si la lista está vacía, mostrar texto vacío
                                                                      : selectedClientsGlobal[0]
                                                                              [
                                                                              'name'] ??
                                                                          'No Name',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: const Color(
                                                                        0xFF28E2F5), // Color del texto
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                                // Nombre del Bluetooth
                                                                Text(
                                                                  bluetoothNames[
                                                                          macAddress] ??
                                                                      "",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: const Color(
                                                                        0xFF28E2F5), // Color del texto
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: List
                                                                      .generate(
                                                                    5,
                                                                    // Siempre 5 niveles posibles de batería
                                                                    (index) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                2.0),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              20,
                                                                          // Ancho de cada raya
                                                                          height:
                                                                              5,
                                                                          // Altura de cada raya
                                                                          color: index <= (batteryStatuses[macAddress] ?? -1)
                                                                              ? _lineColor(macAddress) // Color si el nivel es válido
                                                                              : Colors.grey.withOpacity(0.1), // Color gris si no alcanza ese nivel
                                                                        ),
                                                                      );
                                                                    },
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
                                              ),
                                              // Imagen en la esquina superior derecha
                                              if (selectedKey == macAddress)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 30,
                                                    // Tamaño de la imagen
                                                    height: 30,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      // Fondo circular
                                                      color: Colors
                                                          .white, // Color de fondo
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/cliente.png',
                                                      // Ruta de la imagen
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),

                                      const Spacer(),

                                      // Botón para definir grupos
                                      OutlinedButton(
                                        onPressed: () {
                                          // Define tu acción para el botón aquí
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(10.0),
                                          side: const BorderSide(
                                            width: 1.0,
                                            color: Color(0xFF2be4f3),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          tr(context, 'Definir grupos')
                                              .toUpperCase(),
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
                              Expanded(
                                flex: 2,
                                child: Container(
                                  key: ValueKey(selectedKey),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                          duration:
                                              const Duration(milliseconds: 200),
                                          turns: rotationAngle1 / (2 * 3.14159),
                                          child: SizedBox(
                                            height: screenHeight * 0.1,
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/flderecha.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      AnimatedSize(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        child: Container(
                                          padding: const EdgeInsets.all(10.0),
                                          width: _isExpanded1
                                              ? screenWidth * 0.25
                                              : 0,
                                          height: screenHeight * 0.2,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              // Botón "Cliente"
                                              Expanded(
                                                child: GestureDetector(
                                                  onTapDown: selectedKey == null
                                                      ? null
                                                      : (_) => setState(() =>
                                                          scaleFactorCliente =
                                                              0.90),
                                                  onTapUp: selectedKey == null
                                                      ? null
                                                      : (_) => setState(() =>
                                                          scaleFactorCliente =
                                                              1.0),
                                                  onTap: selectedKey == null
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            toggleOverlay(
                                                                0); // Abre el overlay
                                                          });
                                                        },
                                                  child: Opacity(
                                                    opacity: selectedKey == null
                                                        ? 1.0
                                                        : 1.0,
                                                    // Indicación visual
                                                    child: AnimatedScale(
                                                      scale: scaleFactorCliente,
                                                      duration: const Duration(
                                                          milliseconds: 100),
                                                      child: Container(
                                                        width:
                                                            screenHeight * 0.1,
                                                        height:
                                                            screenWidth * 0.1,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              Color(0xFF494949),
                                                          shape: BoxShape
                                                              .circle, // Forma circular
                                                        ),
                                                        child: Center(
                                                          child: SizedBox(
                                                            width: screenWidth *
                                                                0.05,
                                                            height:
                                                                screenHeight *
                                                                    0.05,
                                                            child: ClipOval(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/cliente.png',
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.005),

                                              // Botón "Equipo 0"
                                              Expanded(
                                                child: AbsorbPointer(
                                                  absorbing:
                                                      selectedKey == null,
                                                  // Bloquear interacción si no hay selección
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedKey !=
                                                            null) {
                                                          mciEquipMapping[
                                                                  selectedKey!] =
                                                              0; // Asocia el equipo 0
                                                        }
                                                        selectedIndexEquip = 0;
                                                      });

                                                      print(
                                                          "🔄 Cambiado al equipo 0 para MCI: $selectedKey");
                                                    },
                                                    child: Opacity(
                                                      opacity:
                                                          selectedKey == null
                                                              ? 1.0
                                                              : 1.0,
                                                      // Indicación visual
                                                      child: Container(
                                                        width:
                                                            screenWidth * 0.1,
                                                        height:
                                                            screenHeight * 0.1,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: selectedIndexEquip ==
                                                                  0
                                                              ? selectedColor
                                                              : unselectedColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10.0),
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
                                                  absorbing:
                                                      selectedKey == null,
                                                  // Bloquear interacción si no hay selección
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedKey !=
                                                            null) {
                                                          mciEquipMapping[
                                                                  selectedKey!] =
                                                              1; // Asocia el equipo 1
                                                        }
                                                        selectedIndexEquip = 1;
                                                      });

                                                      print(
                                                          "🔄 Cambiado al equipo 1 para MCI: $selectedKey");
                                                    },
                                                    child: Opacity(
                                                      opacity:
                                                          selectedKey == null
                                                              ? 1.0
                                                              : 1.0,
                                                      // Indicación visual
                                                      child: Container(
                                                        width:
                                                            screenWidth * 0.1,
                                                        height:
                                                            screenHeight * 0.1,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: selectedIndexEquip ==
                                                                  1
                                                              ? selectedColor
                                                              : unselectedColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0),
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
                                              SizedBox(
                                                  width: screenWidth * 0.005),

                                              // Botón "Repetir"
                                              Expanded(
                                                child: GestureDetector(
                                                  onTapDown: selectedKey == null
                                                      ? null
                                                      : (_) => setState(() =>
                                                          scaleFactorRepeat =
                                                              0.90),
                                                  onTapUp: selectedKey == null
                                                      ? null
                                                      : (_) => setState(() =>
                                                          scaleFactorRepeat =
                                                              1.0),
                                                  onTap: selectedKey == null
                                                      ? null
                                                      : () {
                                                          // Acción para botón repetir
                                                        },
                                                  child: Opacity(
                                                    opacity: selectedKey == null
                                                        ? 1.0
                                                        : 1.0,
                                                    // Indicación visual
                                                    child: AnimatedScale(
                                                      scale: scaleFactorRepeat,
                                                      duration: const Duration(
                                                          milliseconds: 100),
                                                      child: Container(
                                                        width:
                                                            screenHeight * 0.1,
                                                        height:
                                                            screenWidth * 0.1,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: SizedBox(
                                                            child: ClipOval(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/repeat.png',
                                                                width:
                                                                    screenHeight *
                                                                        0.1,
                                                                height:
                                                                    screenWidth *
                                                                        0.1,
                                                                fit: BoxFit
                                                                    .contain,
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
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Container(
                                        padding: const EdgeInsets.all(20.0),
                                        height: screenHeight * 0.2,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            OutlinedButton(
                                              onPressed: selectedKey == null
                                                  ? null // Inhabilitar el botón si selectedKey es null
                                                  : () {
                                                      setState(() {
                                                        toggleOverlay(
                                                            1); // Suponiendo que toggleOverlay abre el overlay
                                                      });
                                                    },
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                side: const BorderSide(
                                                  width: 1.0,
                                                  color: Color(0xFF2be4f3),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                backgroundColor: const Color(
                                                    0xFF2be4f3), // Mantener color de fondo
                                              ),
                                              child: Text(
                                                (tr(
                                                        context,
                                                        globalSelectedProgram ??
                                                            'Programas'))
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
                                            SizedBox(
                                                width: screenWidth * 0.005),
                                            Column(
                                              children: [
                                                // Condicional: Si globalSelectedProgram es null, muestra una imagen y texto predeterminados
                                                if (globalSelectedProgram ==
                                                    null)
                                                  Column(
                                                    children: [
                                                      // Texto predeterminado si no se ha seleccionado ningún programa
                                                      Text(
                                                        tr(context,
                                                                'Nombre programa')
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                      // Imagen predeterminada si no se ha seleccionado ningún programa
                                                      Image.asset(
                                                        'assets/images/cliente.png',
                                                        // Imagen predeterminada
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ],
                                                  ),

                                                if (globalSelectedProgram ==
                                                        tr(context,
                                                                'Individual')
                                                            .toUpperCase() &&
                                                    allIndividualPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedIndivProgram?[
                                                                    'nombre']
                                                                ?.toUpperCase() ??
                                                            (allIndividualPrograms
                                                                    .isNotEmpty
                                                                ? (allIndividualPrograms[0]
                                                                            [
                                                                            'nombre']
                                                                        ?.toUpperCase() ??
                                                                    tr(context,
                                                                            'NOMBRE PROGRAMA')
                                                                        .toUpperCase())
                                                                : tr(context,
                                                                        'No hay programas disponibles')
                                                                    .toUpperCase()),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: selectedKey ==
                                                                null
                                                            ? null // Deshabilitar el pulsado si selectedKey es null
                                                            : () {
                                                                setState(() {
                                                                  toggleOverlay(
                                                                      2);
                                                                });
                                                              },
                                                        child: Image.asset(
                                                          selectedIndivProgram !=
                                                                  null
                                                              ? selectedIndivProgram![
                                                                      'imagen'] ??
                                                                  'assets/images/cliente.png'
                                                              : allIndividualPrograms
                                                                      .isNotEmpty
                                                                  ? allIndividualPrograms[
                                                                              0]
                                                                          [
                                                                          'imagen'] ??
                                                                      'assets/images/cliente.png'
                                                                  : 'assets/images/cliente.png',
                                                          // Imagen por defecto
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        tr(context, 'Recovery')
                                                            .toUpperCase() &&
                                                    allRecoveryPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedRecoProgram?[
                                                                    'nombre']
                                                                ?.toUpperCase() ??
                                                            (allRecoveryPrograms
                                                                    .isNotEmpty
                                                                ? (allRecoveryPrograms[0]
                                                                            [
                                                                            'nombre']
                                                                        ?.toUpperCase() ??
                                                                    tr(context,
                                                                            'NOMBRE PROGRAMA')
                                                                        .toUpperCase())
                                                                : tr(context,
                                                                        'No hay programas disponibles')
                                                                    .toUpperCase()),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: selectedKey ==
                                                                null
                                                            ? null // Deshabilitar el pulsado si selectedKey es null
                                                            : () {
                                                                setState(() {
                                                                  toggleOverlay(
                                                                      3);
                                                                });
                                                              },
                                                        child: Image.asset(
                                                          selectedRecoProgram !=
                                                                  null
                                                              ? selectedRecoProgram![
                                                                      'imagen'] ??
                                                                  'assets/images/cliente.png'
                                                              : allRecoveryPrograms
                                                                      .isNotEmpty
                                                                  ? allRecoveryPrograms[
                                                                              0]
                                                                          [
                                                                          'imagen'] ??
                                                                      'assets/images/cliente.png'
                                                                  : 'assets/images/cliente.png',
                                                          // Imagen por defecto
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        tr(context,
                                                                'Automáticos')
                                                            .toUpperCase() &&
                                                    allAutomaticPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedAutoProgram?[
                                                                    'nombre_programa_automatico']
                                                                ?.toUpperCase() ??
                                                            (allAutomaticPrograms
                                                                    .isNotEmpty
                                                                ? (allAutomaticPrograms[0]
                                                                            [
                                                                            'nombre_programa_automatico']
                                                                        ?.toUpperCase() ??
                                                                    tr(context,
                                                                            'NOMBRE PROGRAMA')
                                                                        .toUpperCase())
                                                                : tr(context,
                                                                        'No hay programas disponibles')
                                                                    .toUpperCase()),
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: selectedKey ==
                                                                null
                                                            ? null // Deshabilitar el pulsado si selectedKey es null
                                                            : () {
                                                                setState(() {
                                                                  toggleOverlay(
                                                                      4);
                                                                });
                                                              },
                                                        child: Image.asset(
                                                          selectedAutoProgram !=
                                                                  null
                                                              ? selectedAutoProgram![
                                                                      'imagen'] ??
                                                                  'assets/images/cliente.png'
                                                              : allAutomaticPrograms
                                                                      .isNotEmpty
                                                                  ? allAutomaticPrograms[
                                                                              0]
                                                                          [
                                                                          'imagen'] ??
                                                                      'assets/images/cliente.png'
                                                                  : 'assets/images/cliente.png',
                                                          // Imagen por defecto
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ],
                                            ),
                                            SizedBox(
                                                width: screenWidth * 0.005),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (globalSelectedProgram ==
                                                    null)
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        tr(context,
                                                                'Individual')
                                                            .toUpperCase() &&
                                                    allIndividualPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      Text(
                                                        selectedIndivProgram !=
                                                                null
                                                            ? "${selectedIndivProgram!['frecuencia'] != null ? formatNumber(selectedIndivProgram!['frecuencia'] as double) : 'N/A'} Hz"
                                                            : allIndividualPrograms
                                                                    .isNotEmpty
                                                                ? "${formatNumber(allIndividualPrograms[0]['frecuencia'] as double)} Hz"
                                                                : " N/A",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                      Text(
                                                        selectedIndivProgram !=
                                                                null
                                                            ? "${selectedIndivProgram!['pulso'] != null ? formatNumber(selectedIndivProgram!['pulso'] as double) : 'N/A'} ms"
                                                            : allIndividualPrograms
                                                                    .isNotEmpty
                                                                ? "${formatNumber(allIndividualPrograms[0]['pulso'] as double)} ms"
                                                                : "N/A",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        tr(context, 'Recovery')
                                                            .toUpperCase() &&
                                                    allRecoveryPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      Text(
                                                        selectedRecoProgram !=
                                                                null
                                                            ? "${selectedRecoProgram!['frecuencia'] != null ? formatNumber(selectedRecoProgram!['frecuencia'] as double) : 'N/A'} Hz"
                                                            : allRecoveryPrograms
                                                                    .isNotEmpty
                                                                ? "${formatNumber(allRecoveryPrograms[0]['frecuencia'] as double)} Hz"
                                                                : "N/A",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                      Text(
                                                        selectedRecoProgram !=
                                                                null
                                                            ? "${selectedRecoProgram!['pulso'] != null ? formatNumber(selectedIndivProgram!['pulso'] as double) : 'N/A'} ms"
                                                            : allRecoveryPrograms
                                                                    .isNotEmpty
                                                                ? "${formatNumber(allRecoveryPrograms[0]['pulso'] as double)} ms"
                                                                : "N/A",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        tr(context,
                                                                'Automáticos')
                                                            .toUpperCase() &&
                                                    allAutomaticPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      Text(
                                                        selectedAutoProgram !=
                                                                null
                                                            ? "${selectedAutoProgram!['duracionTotal'] != null ? formatNumber(selectedAutoProgram!['duracionTotal'] as double) : 'N/A'} min"
                                                            : allAutomaticPrograms
                                                                    .isNotEmpty
                                                                ? "${formatNumber(allAutomaticPrograms[0]['duracionTotal'] as double)} min"
                                                                : "N/A",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                                width: screenWidth * 0.005),
                                            OutlinedButton(
                                              onPressed: () {},
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                side: const BorderSide(
                                                    width: 1.0,
                                                    color: Color(0xFF2be4f3)),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                              child: Text(
                                                tr(context, 'Ciclos')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF2be4f3),
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("VIRTUAL TRAINER",
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF2be4f3),
                                                    fontSize: 15.sp,
                                                  )),
                                              GestureDetector(
                                                onTapDown: (_) => setState(() =>
                                                    scaleFactorTrainer = 0.90),
                                                onTapUp: (_) => setState(() =>
                                                    scaleFactorTrainer = 1.0),
                                                onTap: () {},
                                                child: AnimatedScale(
                                                  scale: scaleFactorTrainer,
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.transparent,
                                                    ),
                                                    child: Center(
                                                      child: SizedBox(
                                                        child: Image.asset(
                                                          height: screenHeight *
                                                              0.1,
                                                          'assets/images/virtualtrainer.png',
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          Image.asset(
                                            height: screenHeight * 0.1,
                                            'assets/images/rayoaz.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            key: ValueKey(selectedKey),
                            children: [
                              Positioned(
                                top: screenHeight * 0.02,
                                // Distancia desde la parte superior
                                right: 0,
                                // Distancia desde la derecha
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => scaleFactorBack = 0.90),
                                  onTapUp: (_) =>
                                      setState(() => scaleFactorBack = 1.0),
                                  onTap: () {
                                    _exitScreen(context);
                                  },
                                  child: AnimatedScale(
                                    scale: scaleFactorBack,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
                                      child: ClipOval(
                                        child: Image.asset(
                                          width: screenWidth * 0.1,
                                          // Ajusta el tamaño como sea necesario
                                          height: screenHeight * 0.1,
                                          'assets/images/back.png',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0, // Distancia desde la parte superior
                                right: 0, // Distancia desde la derecha
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => scaleFactorFull = 0.90),
                                  onTapUp: (_) =>
                                      setState(() => scaleFactorFull = 1.0),
                                  onTap: () {
                                    setState(() {
                                      _isFullScreen =
                                          !_isFullScreen; // Cambia el estado de pantalla completa
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale: scaleFactorFull,
                                    duration: const Duration(milliseconds: 100),
                                    child: SizedBox(
                                      child: ClipOval(
                                        child: Image.asset(
                                          width: screenWidth * 0.1,
                                          // Ajusta el tamaño como sea necesario
                                          height: screenHeight * 0.1,
                                          'assets/images/fullscreen.png',
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
                Expanded(
                  flex: _isFullScreen ? 1 : 2,
                  child: Padding(
                    padding: EdgeInsets.only(top: _isFullScreen ? 50.0 : 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: _isFullScreen ? 1 : 6,
                          child: Stack(children: [
                            Row(
                              children: [
                                if (selectedIndexEquip == 0) ...[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 1,
                                          imagePathEnabled:
                                              'assets/images/biceps_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/bicepsazul.png',
                                          imagePathInactive:
                                              'assets/images/biceps_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 2,
                                          imagePathEnabled:
                                              'assets/images/abs_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/absazul.png',
                                          imagePathInactive:
                                              'assets/images/abs_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 3,
                                          imagePathEnabled:
                                              'assets/images/cua_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/cuazul.png',
                                          imagePathInactive:
                                              'assets/images/cua_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 1,
                                          imagePathEnabled:
                                              'assets/images/biceps_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/biceps_blanco.png',
                                          imagePathInactive:
                                              'assets/images/biceps_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 2,
                                          imagePathEnabled:
                                              'assets/images/abs_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/abs_blanco.png',
                                          imagePathInactive:
                                              'assets/images/abs_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 3,
                                          imagePathEnabled:
                                              'assets/images/cua_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/cua_blanco.png',
                                          imagePathInactive:
                                              'assets/images/cua_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
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
                                                height: _isFullScreen
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_pecho_azul.png",
                                                            // Imagen para el estado animado
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_biceps_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_abs_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_cua_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_gem_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                    imagePaths[_currentImageIndex]!, // Accede al valor en el mapa usando la clave _currentImageIndex
                                                    height: MediaQuery.of(context).size.height * 0.25,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Column(
                                                    children: [
                                                      // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                          setState(() {
                                                            if (time < 30) { // Máximo valor de time es 30
                                                              time++; // Aumentar el tiempo
                                                              totalTime = time * 60; // Actualiza el tiempo total en segundos
                                                              // Calcula el índice de la imagen con el nuevo tiempo
                                                              _currentImageIndex = 31 - time;
                                                            }
                                                          });
                                                        },
                                                        child: Image.asset(
                                                          'assets/images/flecha-arriba.png',
                                                          height: screenHeight * 0.04,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                        style: TextStyle(
                                                          fontSize: 25.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: const Color(0xFF2be4f3), // Color para la sección seleccionada
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                          setState(() {
                                                            if (time > 1) { // Mínimo valor de time es 1
                                                              time--; // Disminuir el tiempo
                                                              totalTime = time * 60; // Actualiza el tiempo total en segundos
                                                              // Calcula el índice de la imagen con el nuevo tiempo
                                                              _currentImageIndex = 31 - time;
                                                            }
                                                          });
                                                        },
                                                        child: Image.asset(
                                                          'assets/images/flecha-abajo.png',
                                                          height: screenHeight * 0.04,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),


                                              SizedBox(
                                                  height: screenHeight * 0.01),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomPaint(
                                                    size: const Size(110, 40),
                                                    painter: LinePainter(
                                                        progress2:
                                                            progressContraction,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    valueContraction
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .lightGreenAccent
                                                            .shade400 // Color para la sección seleccionada
                                                        ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                  height: screenHeight * 0.01),
                                              // Barra de progreso secundaria
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomPaint(
                                                    size: const Size(110, 40),
                                                    painter: LinePainter2(
                                                        progress3:
                                                            progressPause,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    valuePause
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .red // Color para la sección seleccionada
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
                                                height: _isFullScreen
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_trap_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_dorsal_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_lumbar_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_gluteo_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_isquio_azul.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ],
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          // Botón "Menos"
                                          CustomIconButton(
                                            onTap: selectedKey == null
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
                                                                  .clamp(
                                                                      0, 100);
                                                        }
                                                      }
                                                    });
                                                  },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: screenHeight * 0.1,
                                          ),

                                          SizedBox(width: screenWidth * 0.01),
                                          // Botón de control de sesión (Reproducir/Pausar)
                                          GestureDetector(
                                            onTap: selectedKey == null
                                                ? null // Si selectedKey es null, el botón estará deshabilitado
                                                : () {
                                                    setState(() {
                                                      if (isRunning) {
                                                        // Pausa el temporizador si está corriendo
                                                        _pauseTimer();
                                                      } else {
                                                        // Inicia o reanuda el temporizador si está pausado
                                                        _startTimer();
                                                      }
                                                      isSessionStarted =
                                                          !isSessionStarted;
                                                      debugPrint(
                                                          'isSessionStarted: $isSessionStarted');
                                                    });
                                                  },
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          // Botón "Más"
                                          CustomIconButton(
                                            onTap: selectedKey == null
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
                                                                  .clamp(
                                                                      0, 100);
                                                        }
                                                      }
                                                    });
                                                  },
                                            imagePath: 'assets/images/mas.png',
                                            size: screenHeight * 0.1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 6,
                                          imagePathEnabled:
                                              'assets/images/dorsal_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/dorsalazul.png',
                                          imagePathInactive:
                                              'assets/images/dorsal_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 7,
                                          imagePathEnabled:
                                              'assets/images/lumbar_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/lumbarazul.png',
                                          imagePathInactive:
                                              'assets/images/lumbar_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 8,
                                          imagePathEnabled:
                                              'assets/images/gluteo_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/gluteoazul.png',
                                          imagePathInactive:
                                              'assets/images/gluteo_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 6,
                                          imagePathEnabled:
                                              'assets/images/dorsal_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/dorsal_blanco.png',
                                          imagePathInactive:
                                              'assets/images/dorsal_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 7,
                                          imagePathEnabled:
                                              'assets/images/lumbar_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/lumbar_blanco.png',
                                          imagePathInactive:
                                              'assets/images/lumbar_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow(
                                          index: 8,
                                          imagePathEnabled:
                                              'assets/images/gluteo_naranja.png',
                                          imagePathDisabled:
                                              'assets/images/gluteo_blanco.png',
                                          imagePathInactive:
                                              'assets/images/gluteo_gris.png',
                                        ),
                                        SizedBox(height: screenHeight * 0.005),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 1,
                                            imagePathEnabled:
                                                'assets/images/abs_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/absazul.png',
                                            imagePathInactive:
                                                'assets/images/abs_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 2,
                                            imagePathEnabled:
                                                'assets/images/cua_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/cuazul.png',
                                            imagePathInactive:
                                                'assets/images/cua_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 1,
                                            imagePathEnabled:
                                                'assets/images/abs_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/abs_blanco.png',
                                            imagePathInactive:
                                                'assets/images/abs_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 2,
                                            imagePathEnabled:
                                                'assets/images/cua_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/cua_blanco_pantalon.png',
                                            imagePathInactive:
                                                'assets/images/cua_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
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
                                                height: _isFullScreen
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_biceps_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_sup_gris_pantalon.png",
                                                      // Imagen para el estado inactivo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_abs_inf_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_abs_sup_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_cua_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_gem_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_biceps_blanco_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_sup_gris_pantalon.png",
                                                      // Imagen para el estado inactivo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_inf_blanco.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    // Ajusta la posición de la superposición
                                                    child: Image.asset(
                                                      "assets/images/capa_abs_sup_blanco.png",
                                                      // Reemplaza con la ruta de la imagen del músculo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_cua_blanco_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_gem_blanco_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                    imagePaths[_currentImageIndex]!, // Accede al valor en el mapa usando la clave _currentImageIndex
                                                    height: MediaQuery.of(context).size.height * 0.25,
                                                    fit: BoxFit.cover,
                                                  ),

                                                  Column(
                                                    children: [
                                                      // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  if (time <
                                                                      30) {
                                                                    time++; // Disminuye el tiempo si es mayor que 1
                                                                    totalTime =
                                                                        time *
                                                                            60; // Actualiza el tiempo total en segundos
                                                                    _currentImageIndex =
                                                                        imagePaths.length -
                                                                            time;
                                                                  }
                                                                });
                                                              },
                                                        child: Image.asset(
                                                          'assets/images/flecha-arriba.png',
                                                          height: screenHeight *
                                                              0.04,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                        style: TextStyle(
                                                          fontSize: 25.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF2be4f3), // Color para la sección seleccionada
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  if (time >
                                                                      1) {
                                                                    time--; // Disminuye el tiempo si es mayor que 1
                                                                    totalTime =
                                                                        time *
                                                                            60; // Actualiza el tiempo total en segundos
                                                                    _currentImageIndex =
                                                                        imagePaths.length -
                                                                            time;
                                                                  }
                                                                });
                                                              },
                                                        child: Image.asset(
                                                          'assets/images/flecha-abajo.png',
                                                          height: screenHeight *
                                                              0.04,
                                                          fit: BoxFit.scaleDown,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                  height: screenHeight * 0.01),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomPaint(
                                                    size: const Size(110, 40),
                                                    painter: LinePainter(
                                                        progress2:
                                                            progressContraction,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    valueContraction
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .lightGreenAccent
                                                            .shade400 // Color para la sección seleccionada
                                                        ),
                                                  ),
                                                ],
                                              ),

                                              SizedBox(
                                                  height: screenHeight * 0.01),
                                              // Barra de progreso secundaria
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomPaint(
                                                    size: const Size(110, 40),
                                                    painter: LinePainter2(
                                                        progress3:
                                                            progressPause,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    valuePause
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .red // Color para la sección seleccionada
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
                                                height: _isFullScreen
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_lumbar_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_inf_gris_pantalon.png",
                                                      // Imagen para el estado inactivo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_glut_inf_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_glut_sup_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                          child: Image.asset(
                                                            "assets/images/capa_isquio_azul_pantalon.png",
                                                            height: _isFullScreen
                                                                ? screenHeight *
                                                                    0.65
                                                                : screenHeight *
                                                                    0.4,
                                                            fit: BoxFit.cover,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_inf_gris_pantalon.png",
                                                      // Imagen para el estado inactivo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                      // Imagen para el estado bloqueado
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Positioned(
                                                    top: 0,
                                                    // Ajusta la posición de la superposición
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_sup_blanco.png",
                                                      // Reemplaza con la ruta de la imagen del músculo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    // Ajusta la posición de la superposición
                                                    child: Image.asset(
                                                      "assets/images/capa_glut_inf_blanco.png",
                                                      // Reemplaza con la ruta de la imagen del músculo
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
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
                                                      height: _isFullScreen
                                                          ? screenHeight * 0.65
                                                          : screenHeight * 0.4,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ],
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          // Botón "Menos"
                                          CustomIconButton(
                                            onTap: selectedKey == null
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
                                                                  .clamp(
                                                                      0, 100);
                                                        }
                                                      }
                                                    });
                                                  },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: screenHeight * 0.1,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),

                                          // Botón de control de sesión (Reproducir/Pausar)
                                          GestureDetector(
                                            onTap: selectedKey == null
                                                ? null // Si selectedKey es null, el botón estará deshabilitado
                                                : () {
                                                    setState(() {
                                                      if (isRunning) {
                                                        // Pausa el temporizador si está corriendo
                                                        _pauseTimer();
                                                      } else {
                                                        // Inicia o reanuda el temporizador si está pausado
                                                        _startTimer();
                                                      }
                                                      isSessionStarted =
                                                          !isSessionStarted;
                                                      debugPrint(
                                                          'isSessionStarted: $isSessionStarted');
                                                    });
                                                  },
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),

                                          // Botón "Más"
                                          CustomIconButton(
                                            onTap: selectedKey == null
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
                                                                  .clamp(
                                                                      0, 100);
                                                        }
                                                      }
                                                    });
                                                  },
                                            imagePath: 'assets/images/mas.png',
                                            size: screenHeight * 0.1,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 5,
                                            imagePathEnabled:
                                                'assets/images/gluteo_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/gluteoazul.png',
                                            imagePathInactive:
                                                'assets/images/gluteo_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
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
                                        SizedBox(height: screenHeight * 0.005),
                                        _buildMuscleRow2(
                                            index: 5,
                                            imagePathEnabled:
                                                'assets/images/gluteo_naranja.png',
                                            imagePathDisabled:
                                                'assets/images/gluteo_blanco.png',
                                            imagePathInactive:
                                                'assets/images/gluteo_gris.png'),
                                        SizedBox(height: screenHeight * 0.005),
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
                            if (_isFullScreen)
                              Positioned(
                                bottom: 0,
                                // Distancia desde el borde superior
                                right: 0,
                                // Distancia desde el borde derecho
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isFullScreen =
                                          false; // Cambia el estado para ocultar este botón
                                    });
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
                        if (!_isFullScreen)
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
                                                    height: screenHeight * 0.1,
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
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              width: _isExpanded2
                                                  ? screenWidth * 0.2
                                                  : 0,
                                              height: screenHeight * 0.15,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [],
                                              ),
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
                                                    height: screenHeight * 0.1,
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
                                              padding:
                                                  const EdgeInsets.all(10.0),
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
                                                    suffix: " S",
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
                                                    suffix: " S",
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
                                                    value: valueRampa,
                                                    // Valor de pausa
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/RAMPA.png',
                                                    // Imagen que se muestra (Pausa)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valueRampa +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valueRampa > 0) {
                                                          valueRampa -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " S",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight:
                                                        screenHeight, // Altura de pantalla
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
                                // Segunda sección independiente
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ClipOval(
                                              child: Image.asset(
                                                'assets/images/average.png',
                                                width: screenWidth * 0.1,
                                                height: screenHeight * 0.1,
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                            Text(
                                              "AVERAGE",
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(
                                                    0xFF2be4f3), // Color para la sección seleccionada
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTapDown: (_) => setState(
                                            () => scaleFactorReset = 0.90),
                                        onTapUp: (_) => setState(
                                            () => scaleFactorReset = 1.0),
                                        onTap: () {
                                          _resetScreen(context);
                                        },
                                        child: AnimatedScale(
                                          scale: scaleFactorReset,
                                          duration:
                                              const Duration(milliseconds: 100),
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
          ),
          if (isOverlayVisible)
            Positioned(
              top: overlayIndex == 1 ? screenHeight * 0.3 : 0,
              bottom: overlayIndex == 1 ? screenHeight * 0.3 : 0,
              left: overlayIndex == 1 ? screenWidth * 0.2 : 0,
              right: overlayIndex == 1 ? screenWidth * 0.2 : 0,
              child: Align(
                alignment: Alignment.center,
                child: _getOverlayWidget(overlayIndex),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _resetScreen(BuildContext context) async {
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
                  tr(context, 'Aviso').toUpperCase(),
                  style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  tr(context, '¿Quieres resetear todo?').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Cierra el diálogo sin hacer nada
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
                            color: const Color(0xFF2be4f3), fontSize: 17.sp),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _clearGlobals();
                        widget.onReset();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.red),
                      child: Text(
                        tr(context, '¡Sí, quiero resetear!').toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 17.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exitScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
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
                  tr(context, 'Aviso').toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF2be4f3),
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  tr(context, '¿Quieres salir del panel?').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Cierra el diálogo sin hacer nada
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
                        _clearGlobals();
                        widget.onBack();
                        Navigator.of(context)
                            .pop(); // Cierra el diálogo de confirmación
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        tr(context, 'Salir del panel').toUpperCase(),
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
        );
      },
    );
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  Color _lineColor(String? macAddress) {
    // Obtener el estado de la batería de la dirección MAC proporcionada
    final int? batteryStatus = batteryStatuses[macAddress];

    // Determinar el color basado en el estado de la batería
    switch (batteryStatus) {
      case 0: // Muy baja
        return Colors.red;
      case 1: // Baja
        return Colors.orange;
      case 2: // Media
        return Colors.yellow;
      case 3: // Alta
        return Colors.lightGreenAccent;
      case 4: // Llena
        return Colors.green;
      default: // Desconocido o no disponible
        return Colors.transparent;
    }
  }

  Color _getBorderColor(String? status) {
    switch (status) {
      case 'conectado':
        return const Color(0xFF2be4f3); // Color para el estado "conectado"
      case 'desconectado':
        return Colors.grey; // Color para el estado "desconectado"
      case 'inactivo':
        return Colors.white; // Color para el estado "inactivo"
      case 'sinTiempo':
        return Colors.orange; // Color para el estado "sin tiempo"
      default:
        return Colors
            .grey; // Color predeterminado (gris si no coincide con ningún estado)
    }
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlaySeleccionarCliente(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlayTipoPrograma(
          onClose: () => toggleOverlay(1),
        );
      case 2:
        return OverlaySeleccionarProgramaIndividual(
          onClose: () => toggleOverlay(2),
        );
      case 3:
        return OverlaySeleccionarProgramaRecovery(
          onClose: () => toggleOverlay(3),
        );
      case 4:
        return OverlaySeleccionarProgramaAutomatic(
          onClose: () => toggleOverlay(4),
        );
      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
  }

  Widget _buildMuscleRow({
    required int index,
    required String imagePathEnabled,
    required String imagePathDisabled,
    required String imagePathInactive, // Imagen inactiva propia para cada fila
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          color: _isMusculoTrajeInactivo[index] // Si está inactivo, color gris
              ? Colors.grey.withOpacity(0.5) // Color gris cuando inactivo
              : _isMusculoTrajeBloqueado[
                      index] // Si está bloqueado, color naranja
                  ? const Color(0xFFFFA500).withOpacity(0.3)
                  : Colors.transparent,
          // Si no está bloqueado ni inactivo, fondo transparente
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          // Si no está bloqueado ni inactivo, se puede aumentar el contador
                          if (!_isMusculoTrajeBloqueado[index] &&
                              !_isMusculoTrajeInactivo[index]) {
                            porcentajesMusculoTraje[index] =
                                (porcentajesMusculoTraje[index] + 1)
                                    .clamp(0, 100);
                          }
                        });
                      },
                imagePath: 'assets/images/mas.png',
                size: _isFullScreen ? 50.0 : 40.0,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

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
                          // Cambiar el estado de bloqueado a desbloqueado
                          _isMusculoTrajeBloqueado[index] = false;
                        }
                        // Cambiar el estado de inactivo
                        _isMusculoTrajeInactivo[index] =
                            !_isMusculoTrajeInactivo[index];
                      });
                    },
                    child: SizedBox(
                      width: _isFullScreen ? 80.0 : 70.0,
                      height: _isFullScreen ? 80.0 : 70.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          // Lógica de selección de la imagen
                          _isMusculoTrajeBloqueado[index]
                              ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                              : (_isMusculoTrajeInactivo[
                                      index] // Si está inactivo
                                  ? imagePathInactive // Mostrar la imagen inactiva
                                  : imagePathDisabled), // Si está deshabilitado
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Texto que muestra el porcentaje
                  Text(
                    '${porcentajesMusculoTraje[index]}%',
                    style: TextStyle(
                      fontSize: _isFullScreen ? 15.0.sp : 13.0.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

              // Botón "Menos"
              CustomIconButton(
                onTap: selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          if (!_isMusculoTrajeBloqueado[index] &&
                              !_isMusculoTrajeInactivo[index]) {
                            porcentajesMusculoTraje[index] =
                                (porcentajesMusculoTraje[index] - 1)
                                    .clamp(0, 100);
                          }
                        });
                      },
                imagePath: 'assets/images/menos.png',
                size: _isFullScreen ? 50.0 : 40.0,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
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
          color:
              _isMusculoPantalonInactivo[index] // Si está inactivo, color gris
                  ? Colors.grey.withOpacity(0.5) // Color gris cuando inactivo
                  : _isMusculoPantalonBloqueado[
                          index] // Si está bloqueado, color naranja
                      ? const Color(0xFFFFA500).withOpacity(0.3)
                      : Colors.transparent,
          // Si no está bloqueado ni inactivo, fondo transparente
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          // Si no está bloqueado ni inactivo, se puede aumentar el contador
                          if (!_isMusculoPantalonBloqueado[index] &&
                              !_isMusculoPantalonInactivo[index]) {
                            porcentajesMusculoPantalon[index] =
                                (porcentajesMusculoPantalon[index] + 1)
                                    .clamp(0, 100);
                          }
                        });
                      },
                imagePath: 'assets/images/mas.png',
                size: _isFullScreen ? 50.0 : 40.0,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

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
                      });
                    },
                    child: SizedBox(
                      width: _isFullScreen ? 80.0 : 70.0,
                      height: _isFullScreen ? 80.0 : 70.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          // Lógica de selección de la imagen
                          _isMusculoPantalonBloqueado[index]
                              ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                              : (_isMusculoPantalonInactivo[
                                      index] // Si está inactivo
                                  ? imagePathInactive // Mostrar la imagen inactiva
                                  : imagePathDisabled), // Si está deshabilitado
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Texto que muestra el porcentaje
                  Text(
                    '${porcentajesMusculoPantalon[index]}%',
                    style: TextStyle(
                      fontSize: _isFullScreen ? 15.0.sp : 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

              // Botón "Menos"
              CustomIconButton(
                onTap: selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          if (!_isMusculoPantalonBloqueado[index] &&
                              !_isMusculoPantalonInactivo[index]) {
                            porcentajesMusculoPantalon[index] =
                                (porcentajesMusculoPantalon[index] - 1)
                                    .clamp(0, 100);
                          }
                        });
                      },
                imagePath: 'assets/images/menos.png',
                size: _isFullScreen ? 50.0 : 40.0,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildControlRow({
    required double value, // El valor que se va a mostrar y modificar
    required String imagePathIncrement, // Ruta de la imagen para el botón "Más"
    required String
        imagePathDecrement, // Ruta de la imagen para el botón "Menos"
    required String
        imagePathDisplay, // Ruta de la imagen para mostrar (como la imagen de CONTRACCION)
    required Function onIncrement, // Lógica de incremento
    required Function onDecrement, // Lógica de decremento
    required String
        suffix, // Sufijo para el valor (por ejemplo: "S" para contracción)
    required double screenWidth, // El ancho de la pantalla
    required double screenHeight, // El alto de la pantalla
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de "Más"
        GestureDetector(
          onTap: () => onIncrement(),
          child: SizedBox(
            width: 45.0,
            height: 45.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathIncrement, // Imagen para el botón "Más"
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        // Texto con el valor y el sufijo
        Text(
          "$value$suffix",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        // Botón de "Menos"
        GestureDetector(
          onTap: () => onDecrement(),
          child: SizedBox(
            width: 45.0,
            height: 45.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathDecrement, // Imagen para el botón "Menos"
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        // Imagen que se muestra en el lado derecho (por ejemplo: "CONTRACCION.png")
        Image.asset(
          imagePathDisplay, // Imagen personalizada
          width: screenWidth * 0.05,
          height: screenHeight * 0.05,
        ),
      ],
    );
  }
}

class CustomIconButton extends StatefulWidget {
  final VoidCallback? onTap; // Acción al soltar el botón
  final VoidCallback? onTapDown; // Acción al presionar el botón
  final VoidCallback? onTapUp; // Acción al levantar el botón
  final String imagePath; // Ruta de la imagen del botón
  final double size; // Tamaño del botón
  final bool isDisabled; // Condición para deshabilitar el botón

  const CustomIconButton({
    super.key,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    required this.imagePath,
    this.size = 40.0, // Valor por defecto para el tamaño
    this.isDisabled = false, // Condición por defecto que no está deshabilitado
  });

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double scaleFactor = 1.0; // Factor de escala para la animación

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isDisabled,
      // Deshabilita el botón si isDisabled es true
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            scaleFactor = 0.9; // Escala al presionar
          });
          if (widget.onTapDown != null) {
            widget
                .onTapDown!(); // Llama a la acción de onTapDown si está definida
          }
        },
        onTapUp: (_) {
          setState(() {
            scaleFactor = 1.0; // Regresa a la escala normal al soltar
          });
          if (widget.onTapUp != null) {
            widget.onTapUp!(); // Llama a la acción de onTapUp si está definida
          }
        },
        onTap: widget.onTap, // Llama a la acción de onTap
        child: AnimatedScale(
          scale: scaleFactor,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Image.asset(
              widget.imagePath, // Imagen que se pasa al widget
              height: widget.size,
              width: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class BleConnectionService {
  // Variables de estado
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  final bool _connected = false;
  Timer? _connectionCheckTimer; // Timer para el chequeo periódico de conexión
  List<String> targetDeviceIds = []; // Lista para almacenar las direcciones MAC
  final List<String> foundDevices = [];
  List<String> disconnectedDevices = [];
  bool isWidgetActive = true;
  StreamSubscription<List<int>>? subscription;

  // Mapa para almacenar los StreamControllers de conexión por dispositivo
  final Map<String, StreamController<bool>> _deviceConnectionStateControllers =
      {};

  // Variables relacionadas con Bluetooth
  late DiscoveredDevice _ubiqueDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanStream;
  final Map<String, StreamSubscription<ConnectionStateUpdate>>
      _connectionStreams = {};
  final List<String> connectedDevices = []; // Lista de MACs conectadas
  final Uuid serviceUuid = Uuid.parse("49535343-FE7D-4AE5-8FA9-9FAFD205E455");
  final Uuid rxCharacteristicUuid =
      Uuid.parse("49535343-8841-43F4-A8D4-ECBE34729BB4");
  final Uuid txCharacteristicUuid =
      Uuid.parse("49535343-1E4D-4BD9-BA61-23C647249617");
  StreamSubscription<List<int>>? notificationSubscription;

  BleConnectionService(List<String> macAddresses) {
    targetDeviceIds =
        macAddresses; // Inicializamos con la lista vacía o los valores proporcionados
    _startScan();
  }

  // Método para actualizar las direcciones MAC
  void updateMacAddresses(List<String> macAddresses) {
    targetDeviceIds = macAddresses;
    if (_foundDeviceWaitingToConnect) {
      _startScan(); // Reinicia el escaneo con la nueva lista de MACs
    }
  }

  // Este stream es lo que el widget escucha, pero ahora cada dispositivo tiene su propio stream
  Stream<bool> connectionStateStream(String macAddress) {
    if (!_deviceConnectionStateControllers.containsKey(macAddress)) {
      _deviceConnectionStateControllers[macAddress] =
          StreamController<bool>.broadcast();
    }
    return _deviceConnectionStateControllers[macAddress]!.stream;
  }

  void _updateDeviceConnectionState(String macAddress, bool isConnected) {
    if (!_deviceConnectionStateControllers.containsKey(macAddress)) {
      _deviceConnectionStateControllers[macAddress] =
          StreamController<bool>.broadcast();
    }

    final controller = _deviceConnectionStateControllers[macAddress]!;
    if (!controller.isClosed) {
      controller.add(isConnected); // Emitir el nuevo estado
      if (kDebugMode) {
        print(
            "🔄 Estado de conexión actualizado para $macAddress: ${isConnected ? 'conectado' : 'desconectado'}");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ StreamController para $macAddress ya está cerrado.");
      }
    }
  }

  final StreamController<Map<String, dynamic>> _deviceUpdatesController =
      StreamController.broadcast();

// Exponer el Stream para que otros lo escuchen
  Stream<Map<String, dynamic>> get deviceUpdates =>
      _deviceUpdatesController.stream;

  // Método para emitir actualizaciones generales
  void _emitDeviceUpdate(String macAddress, String key, dynamic value) {
    _deviceUpdatesController.add({
      'macAddress': macAddress,
      key: value,
    });
  }

// Llamar esto para actualizar el estado del dispositivo
  void updateBluetoothName(String macAddress, String name) {
    _emitDeviceUpdate(macAddress, 'bluetoothName', name);
  }

  void updateBatteryStatus(String macAddress, int status) {
    _emitDeviceUpdate(macAddress, 'batteryStatus', status);
  }

  Future<void> _startScan() async {
    if (_scanStream != null) {
      await _scanStream?.cancel();
      _scanStream = null;
    }

    if (!isWidgetActive) {
      if (kDebugMode) print("El widget no está activo. Escaneo cancelado.");
      return;
    }

    // Verificar permisos de ubicación
    bool permGranted = false;

    if (Platform.isAndroid || Platform.isIOS) {
      // Verificar los permisos en lugar de solicitar nuevamente
      PermissionStatus permissionWhenInUse =
          await Permission.locationWhenInUse.status;
      PermissionStatus permissionAlways =
          await Permission.locationAlways.status;

      if (permissionWhenInUse == PermissionStatus.granted &&
          permissionAlways == PermissionStatus.granted) {
        permGranted = true;
        if (kDebugMode) print("Permisos de ubicación concedidos.");
      } else {
        if (kDebugMode) print("Permisos de ubicación no concedidos.");
        return; // No iniciar escaneo si los permisos no están concedidos
      }
    }

    if (!permGranted) return;

    foundDevices.clear(); // Reiniciar dispositivos encontrados
    print("🔍 Iniciando escaneo BLE...");

    // Completer para controlar cuándo termina el escaneo
    final Completer<void> scanCompleter = Completer<void>();

    try {
      _scanStream = flutterReactiveBle.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
      ).listen((device) {
        if (!isWidgetActive) {
          print("El widget no está activo. Deteniendo escaneo.");
          _scanStream?.cancel();
          if (!scanCompleter.isCompleted) scanCompleter.complete();
          return;
        }

        print("Dispositivo encontrado: ${device.name}, ID: ${device.id}");

        if (targetDeviceIds.contains(device.id) &&
            !foundDevices.contains(device.id)) {
          foundDevices.add(device.id);
          print("▶️--->>> Dispositivo objetivo encontrado: ${device.id}");

          if (foundDevices.toSet().containsAll(targetDeviceIds)) {
            debugPrint("✅ Todos los dispositivos objetivo encontrados.");
            _scanStream?.cancel();
            if (!scanCompleter.isCompleted) scanCompleter.complete();
          }
        }
      }, onError: (error) {
        print("❌ Error durante el escaneo: $error");
        if (!scanCompleter.isCompleted) scanCompleter.complete();
      });

      // Esperar que termine el escaneo o pase el tiempo límite
      await Future.any([
        scanCompleter.future,
        Future.delayed(const Duration(seconds: 10), () async {
          if (_scanStream != null) {
            await _scanStream?.cancel();
            print(
                "⏳ Escaneo BLE cancelado automáticamente después de 10 segundos.");
          }
          if (!scanCompleter.isCompleted) scanCompleter.complete();
        }),
      ]);

      // Validar dispositivos encontrados
      if (!foundDevices.toSet().containsAll(targetDeviceIds)) {
        print("⚠️ No se encontraron todos los dispositivos objetivo.");
      } else {
        print("✅ Todos los dispositivos objetivo fueron encontrados.");
      }
    } catch (e) {
      print("❌ Error inesperado durante el escaneo: $e");
    }
  }

  Future<bool> _connectToDeviceByMac(String macAddress) async {
    // Validar si no hay dispositivos encontrados
    if (foundDevices.isEmpty) {
      if (kDebugMode) {
        print(
            "⚠️ No se encontraron dispositivos durante el escaneo. Conexión cancelada.");
      }
      return false;
    }

    // Validar si la MAC no está en la lista de dispositivos encontrados
    if (!foundDevices.contains(macAddress)) {
      if (kDebugMode) {
        print(
            "⚠️ No se puede conectar a $macAddress porque no se encontró durante el escaneo.");
      }
      return false;
    }

    // Validar si la MAC está vacía
    if (macAddress.isEmpty) {
      if (kDebugMode) print("⚠️ Dirección MAC vacía.");
      return false;
    }

    if (kDebugMode) {
      print("🚩--->>>Conectando al dispositivo con la MAC: $macAddress...");
    }

    bool success = false;
    int attemptCount = 0;
    const maxAttempts = 5;
    Duration retryDelay = const Duration(seconds: 3);

    // Método interno para intentar conectarse
    Future<void> tryConnect() async {
      _connectionStreams[macAddress] =
          flutterReactiveBle.connectToAdvertisingDevice(
        id: macAddress,
        prescanDuration: const Duration(seconds: 1),
        withServices: [serviceUuid],
      ).listen((event) async {
        switch (event.connectionState) {
          case DeviceConnectionState.connected:
            if (kDebugMode)
              print("🔗--->>> Dispositivo $macAddress conectado.");
            success = true;

            // Descubrir servicios
            final discoveredServices =
                await flutterReactiveBle.discoverServices(macAddress);
            bool hasRequiredService = false;

            for (final service in discoveredServices) {
              if (service.serviceId == serviceUuid) {
                hasRequiredService = true;

                if (kDebugMode) {
                  print("🔍--->>>Servicio principal encontrado: $serviceUuid");
                }

                final characteristicIds = service.characteristics
                    .map((c) => c.characteristicId)
                    .toList();

                if (characteristicIds.contains(rxCharacteristicUuid) &&
                    characteristicIds.contains(txCharacteristicUuid)) {
                  if (kDebugMode) {
                    print("🛠️--->>>Características RX y TX disponibles.");
                  }
                } else {
                  if (kDebugMode) {
                    print("❌ Características RX o TX no encontradas.");
                  }
                }
                break;
              }
            }

            if (!hasRequiredService) {
              if (kDebugMode) print("❌ Servicio principal no encontrado.");
            }

            if (success) connectedDevices.add(macAddress);
            _updateDeviceConnectionState(macAddress, true);

            break;

          case DeviceConnectionState.disconnected:
            if (kDebugMode) {
              print("⛓️‍💥--->>>Dispositivo $macAddress desconectado.");
            }
            _onDeviceDisconnected(macAddress);
            _updateDeviceConnectionState(macAddress, false);
            break;

          default:
            if (kDebugMode) {
              print("⏳--->>>Estado desconocido para $macAddress.");
            }
            break;
        }
      });

      await Future.delayed(const Duration(seconds: 1));

      // Reintentar si no se tuvo éxito
      if (!success && attemptCount < maxAttempts) {
        attemptCount++;
        if (kDebugMode) {
          print("🔄--->>>Reintento $attemptCount para $macAddress...");
        }
        await Future.delayed(retryDelay);
        await tryConnect();
      }
    }

    await tryConnect();
    return success;
  }

  Future<void> processConnectedDevices() async {
    if (connectedDevices.isEmpty) {
      debugPrint("⚠️ Ningún dispositivo conectado. Abortando operaciones.");
      return;
    }

    debugPrint("✅ Dispositivos conectados: $connectedDevices");

    for (final macAddress in connectedDevices) {
      try {
        // Inicialización de seguridad
        await _initializeSecurity(macAddress);
        debugPrint(
            "🔒--->>>Fase de inicialización de seguridad completada para $macAddress.");

        // Obtener la información del dispositivo (FUN_INFO)
        final deviceInfo = await getDeviceInfo(macAddress)
            .timeout(const Duration(seconds: 15));
        final parsedInfo = parseDeviceInfo(deviceInfo);
        debugPrint(parsedInfo);

        // Obtener el nombre del Bluetooth (FUN_GET_NAMEBT)
        final nameBt = await getBluetoothName(macAddress)
            .timeout(const Duration(seconds: 15));
        ;
        debugPrint("🅱️ Nombre del Bluetooth ($macAddress): $nameBt");
        updateBluetoothName(
            macAddress, nameBt.isNotEmpty ? nameBt : "No disponible");

        // Obtener los parámetros de la batería (FUN_GET_PARAMBAT)
        final batteryParameters = await getBatteryParameters(macAddress)
            .timeout(const Duration(seconds: 15));
        ;
        final parsedBattery = parseBatteryParameters(batteryParameters);
        debugPrint(parsedBattery);
        updateBatteryStatus(
            macAddress, batteryParameters['batteryStatusRaw'] ?? -1);

        // Obtener contadores de tarifa
        final counters = await getTariffCounters(macAddress)
            .timeout(const Duration(seconds: 15));
        ;
        final parsedCounters = parseTariffCounters(counters);
        debugPrint(parsedCounters);

        // Operaciones con electroestimulador
        for (int mode = 0; mode < 3; mode++) {
          final state = await getElectrostimulatorState(
              macAddress, 1, mode); // Endpoint 1 como ejemplo
          final parsedState = parseElectrostimulatorState(state, mode);
          debugPrint(parsedState);
        }

        // Ejecutar sesión de electroestimulación
        final runSuccess = await runElectrostimulationSession(
          macAddress: macAddress,
          endpoint: 1,
          limitador: 0,
          rampa: 30,
          frecuencia: 50,
          deshabilitaElevador: 0,
          nivelCanales: 100,
          anchuraPulsoComun: 0,
          anchuraPulsosPorCanal: List.generate(
              10, (index) => 20), // Ancho de pulso para cada canal
        );

        if (runSuccess) {
          debugPrint(
              "✅ Sesión de electroestimulación iniciada correctamente en $macAddress.");
        } else {
          debugPrint(
              "❌ Error al iniciar la sesión de electroestimulación en $macAddress.");
        }

        // Controlar canales individuales
        final response = await controlElectrostimulatorChannel(
          macAddress: macAddress,
          endpoint: 1,
          canal: 1,
          modo: 0,
          valor: 50, // Fijar el nivel en 50%
        );

        final parsedResponse = parseChannelControlResponse(response);
        debugPrint(parsedResponse);

        // Controlar todos los canales
        final response2 = await controlAllElectrostimulatorChannels(
          macAddress: macAddress,
          endpoint: 1,
          modo: 0,
          valoresCanales: [
            50,
            60,
            70,
            80,
            90,
            50,
            60,
            70,
            80,
            90
          ], // Valores para todos los canales
        );

        final parsedResponse2 = parseAllChannelsResponse(response2);
        debugPrint(parsedResponse2);

        // Detener la sesión después de 5 segundos
        await Future.delayed(const Duration(seconds: 5));

        final stopSuccess = await stopElectrostimulationSession(
          macAddress: macAddress,
          endpoint: 1,
        );

        if (stopSuccess) {
          debugPrint(
              "✅ Sesión de electroestimulación detenida correctamente en $macAddress.");
        } else {
          debugPrint(
              "❌ Error al detener la sesión de electroestimulación en $macAddress.");
        }
      } catch (e) {
        debugPrint("❌--->>>Error al procesar el dispositivo $macAddress: $e");
      }
    }
  }

  void startPeriodicConnectionCheck(
      void Function(String macAddress, bool isConnected)
          onConnectionStatusChange) {
    const Duration checkInterval =
        Duration(seconds: 4); // Intervalo de verificación

    _connectionCheckTimer = Timer.periodic(checkInterval, (_) async {
      if (!isWidgetActive) {
        _connectionCheckTimer?.cancel();
        return;
      }

      for (final macAddress in targetDeviceIds) {
        final isConnected = connectedDevices.contains(macAddress);

        if (!isConnected) {
          // Verificar si el dispositivo está publicándose antes de intentar reconectar
          final isAdvertising = await _isDeviceAdvertising(macAddress);

          if (isAdvertising) {
            print(
                "⚠️ Dispositivo $macAddress está encendido pero desconectado. Intentando reconectar...");
            final success = await _connectToDeviceByMac(macAddress);

            onConnectionStatusChange(macAddress, success);
          } else {
            print("🚫 Dispositivo $macAddress parece estar apagado.");
            onConnectionStatusChange(macAddress, false);
          }
        } else {
          print("✅ Dispositivo sigue conectado: $macAddress");
          onConnectionStatusChange(macAddress, true);
        }
      }
    });
  }

  /// Verificar si un dispositivo está publicándose (advertising)
  Future<bool> _isDeviceAdvertising(String macAddress) async {
    bool found = false;

    try {
      print("🔍 Escaneando para verificar si $macAddress está publicándose...");
      final Set<String> discoveredDevices = {};

      final scanSubscription = flutterReactiveBle.scanForDevices(
          withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
        if (device.id == macAddress && !discoveredDevices.contains(device.id)) {
          discoveredDevices.add(device.id);
          found = true;
        }
      });

      // Esperar unos segundos para completar el escaneo
      await Future.delayed(const Duration(seconds: 2));
      await scanSubscription.cancel();
    } catch (e) {
      print("❌ Error durante el escaneo: $e");
    }

    return found;
  }

  void _onDeviceDisconnected(String macAddress) {
    if (kDebugMode)
      print("️‍️‍⛓️‍💥--->>>Dispositivo $macAddress desconectado.");
    connectedDevices.remove(macAddress);

    // Cancelar el stream asociado a la MAC
    _connectionStreams[macAddress]?.cancel();
    _connectionStreams.remove(macAddress);

    // Actualizar el estado en los StreamControllers
    final controller = _deviceConnectionStateControllers[macAddress];
    if (controller != null && !controller.isClosed) {
      controller.add(false); // Estado desconectado
    }
  }

  void disconnect(String macAddress) async {
    if (_deviceConnectionStateControllers.containsKey(macAddress)) {
      if (kDebugMode) {
        print("Desconectando del dispositivo: $macAddress");
      }

      // Cancelar la suscripción del stream de conexión
      if (_connectionStreams.containsKey(macAddress)) {
        await _connectionStreams[macAddress]?.cancel();
        if (kDebugMode) {
          print("⚠️ Suscripción cancelada para el dispositivo $macAddress.");
        }
        _connectionStreams.remove(macAddress);
      }

      // Verificar si el StreamController no está cerrado antes de agregar un evento
      final controller = _deviceConnectionStateControllers[macAddress];
      if (controller != null && !controller.isClosed) {
        controller.add(false); // Estado desconectado
        if (kDebugMode) {
          print(
              "🔴 Evento 'desconectado' agregado al controller del dispositivo $macAddress.");
        }
      } else {
        if (kDebugMode) {
          print(
              "⚠️ El StreamController ya está cerrado para la MAC $macAddress.");
        }
      }

      // Detener el chequeo periódico de la conexión (si existe)
      if (_connectionCheckTimer?.isActive ?? false) {
        _connectionCheckTimer?.cancel();
        _connectionCheckTimer = null;
        if (kDebugMode) {
          print("⏲️ Timer de verificación de conexión cancelado.");
        }
      } else {
        if (kDebugMode) {
          print(
              "⏲️ No había un timer activo para la verificación de conexión.");
        }
      }
    } else {
      if (kDebugMode) {
        print("No hay dispositivo conectado con la MAC $macAddress.");
      }
    }
  }

  void disposeBleResources() {
    if (kDebugMode) {
      debugPrint("🧹 Liberando recursos BLE...");
    }

    isWidgetActive = false;

    // Cancelar el Timer periódico de verificación de conexión
    if (_connectionCheckTimer != null && _connectionCheckTimer!.isActive) {
      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;
      if (kDebugMode) {
        debugPrint("⏲️ Timer de verificación de conexión cancelado.");
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            "⏲️ No había un timer activo para la verificación de conexión.");
      }
    }

    if (_scanStream != null) {
      _scanStream?.cancel();
      if (kDebugMode) {
        debugPrint("🔴 Escaneo BLE cancelado.");
      }
    }
    // Desconectar todos los dispositivos si están conectados
    for (var macAddress in _deviceConnectionStateControllers.keys) {
      disconnect(macAddress);
      if (kDebugMode) {
        debugPrint("🛑 Desconectando dispositivo con MAC: $macAddress");
      }
    }

    // Cerrar todos los StreamControllers de forma segura
    _deviceConnectionStateControllers.forEach((macAddress, controller) {
      if (!controller.isClosed) {
        controller.close();
        if (kDebugMode) {
          debugPrint(
              "🗑️ Stream controller para el dispositivo $macAddress cerrado.");
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              "⚠️ El Stream controller ya estaba cerrado para el dispositivo $macAddress.");
        }
      }
    });

    if (!_deviceUpdatesController.isClosed) {
      _deviceUpdatesController.close();
      if (kDebugMode) {
        debugPrint(
            "🗑️ Stream controller de actualizaciones generales cerrado.");
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            "⚠️ El Stream controller de actualizaciones generales ya estaba cerrado.");
      }
    }

    // Liberar recursos BLE globalmente
    flutterReactiveBle.deinitialize();
    if (kDebugMode) {
      debugPrint("Recursos BLE globalmente liberados.");
    }
  }

  bool get isConnected => _connected;

  // Inicialización de la seguridad
  Future<void> _initializeSecurity(String macAddress) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      // Enviar solicitud de inicialización
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: [0x00, 0x00, 0x00, 0x00, 0x00],
      );

      // Suscripción a notificaciones para recibir el reto
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: txCharacteristicUuid,
          deviceId: macAddress,
        ),
      )
          .listen((data) async {
        if (data.isNotEmpty) {
          await _handleSecurityChallenge(macAddress, data);
        }
      });
    } catch (e) {
      print("Error al inicializar seguridad: $e");
    }
  }

  // Manejo del reto de seguridad
  Future<void> _handleSecurityChallenge(
      String macAddress, List<int> data) async {
    // Proceso XOR para resolver el reto
    final h1 = data[1] ^ 0x2A;
    final h2 = data[2] ^ 0x55;
    final h3 = data[3] ^ 0xAA;
    final h4 = data[4] ^ 0xA2;

    // Responder al dispositivo con el contra-reto
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );
    await flutterReactiveBle.writeCharacteristicWithResponse(
      characteristic,
      value: [0x01, h1, h2, h3, h4],
    );
  }

  // Envío de comandos al dispositivo
  Future<void> sendCommand(String macAddress, List<int> command) async {
    // Validar si el dispositivo está conectado
    if (connectedDevices.isNotEmpty) {
      print(
          "⚠️ El dispositivo $macAddress no está conectado. Comando no enviado.");
      return;
    }

    // Validar que el comando tenga exactamente 20 bytes
    if (command.length != 20) {
      print(
          "⚠️ El comando debe tener exactamente 20 bytes. Comando no enviado.");
      return;
    }

    // Crear la característica cualificada
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      // Enviar el comando al dispositivo
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: command,
      );
      print("✅ Comando enviado correctamente a $macAddress: $command");
    } catch (e) {
      print("❌ Error al enviar comando a $macAddress: $e");
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_INFO
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x02; // FUN_INFO

    try {
      // Cancelar cualquier suscripción activa antes de iniciar una nueva
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completar la operación cuando se reciba la respuesta
      final completer = Completer<Map<String, dynamic>>();
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x03) {
          final Map<String, dynamic> deviceInfo = {
            'mac': data.sublist(1, 7),
            'tariff': data[7],
            'powerType': data[8],
            'hwVersion': data[9],
            'swCommsVersion': data[10],
            'endpoints': [
              {'type': data[11], 'swVersion': data[12]},
              {'type': data[13], 'swVersion': data[14]},
              {'type': data[15], 'swVersion': data[16]},
              {'type': data[17], 'swVersion': data[18]},
            ],
          };

          completer.complete(deviceInfo);
          debugPrint("📥 FUN_INFO_R recibido desde $macAddress: $deviceInfo");
        }
      });

      // Enviar la solicitud FUN_INFO
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_INFO enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final deviceInfo =
          await completer.future.timeout(const Duration(seconds: 15));
      notificationSubscription?.cancel();
      return deviceInfo;
    } catch (e) {
      debugPrint("❌ Error al obtener FUN_INFO de $macAddress: $e");
      notificationSubscription?.cancel();
      rethrow;
    }
  }

  // Función para parsear información en formato texto
  String parseDeviceInfo(Map<String, dynamic> deviceInfo) {
    final mac = (deviceInfo['mac'] as List<int>)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    final tariff = deviceInfo['tariff'] == 0
        ? "Sin tarifa"
        : deviceInfo['tariff'] == 1
            ? "Con tarifa"
            : "Con tarifa agotada";

    final powerType = deviceInfo['powerType'] == 0
        ? "Fuente de alimentación"
        : "Batería de litio (8.4V)";

    final hwVersion = deviceInfo['hwVersion'];
    final swCommsVersion = deviceInfo['swCommsVersion'];

    final endpoints = (deviceInfo['endpoints'] as List<Map<String, dynamic>>)
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final endpoint = entry.value;

      final type = endpoint['type'] == 0
          ? "Ninguno"
          : endpoint['type'] == 1
              ? "Electroestimulador (10 canales normal)"
              : endpoint['type'] == 2
                  ? "Electroestimulador (10 canales + Ctrl Input)"
                  : "Desconocido";

      final swVersion = endpoint['swVersion'];

      return "  Endpoint ${index + 1}: Tipo: $type, Versión SW: $swVersion";
    }).join('\n');

    return '''
📊 Información del dispositivo:
- Dirección MAC: $mac
- Tarifa: $tariff
- Tipo de alimentación: $powerType
- Versión HW: $hwVersion
- Versión SW de comunicaciones: $swCommsVersion
$endpoints
''';
  }

  Future<String> getBluetoothName(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_NAMEBT
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x04; // FUN_GET_NAMEBT

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<String>();

      // Suscribirse a las notificaciones para recibir FUN_GET_NAMEBT_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x05) {
          // FUN_GET_NAMEBT_R recibido
          final nameBytes =
              data.sublist(1).takeWhile((byte) => byte != 0).toList();
          final name =
              String.fromCharCodes(nameBytes); // Convertir bytes a string
          completer.complete(name);
          debugPrint("📥 FUN_GET_NAMEBT_R recibido desde $macAddress: $name");
        }
      });

      // Enviar la solicitud FUN_GET_NAMEBT
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_GET_NAMEBT enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final bluetoothName =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return bluetoothName;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint(
          "❌ Error al obtener el nombre del Bluetooth de $macAddress: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBatteryParameters(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_PARAMBAT
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x08; // FUN_GET_PARAMBAT

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_PARAMBAT_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x09) {
          // FUN_GET_PARAMBAT_R recibido
          final batteryParameters = {
            'batteryStatusRaw': data[3],
            'powerType':
                data[1] == 1 ? "Batería de litio (8.4V)" : "Alimentador AC",
            'batteryModel': data[2] == 0 ? "Por defecto" : "Desconocido",
            'batteryStatus': data[3] == 0
                ? "Muy baja"
                : data[3] == 1
                    ? "Baja"
                    : data[3] == 2
                        ? "Media"
                        : data[3] == 3
                            ? "Alta"
                            : "Llena",
            'temperature': "Sin implementar",
            'compensation': (data[6] << 8) | data[7],
            'voltages': {
              'V1': (data[8] << 8) | data[9],
              'V2': (data[10] << 8) | data[11],
              'V3': (data[12] << 8) | data[13],
              'V4': (data[14] << 8) | data[15],
            },
            'elevatorMax': {
              'endpoint1': data[16],
              'endpoint2': data[17],
              'endpoint3': data[18],
              'endpoint4': data[19],
            },
          };

          completer.complete(batteryParameters);
          debugPrint(
              "📥 FUN_GET_PARAMBAT_R recibido desde $macAddress: $batteryParameters");
        }
      });

      // Enviar la solicitud FUN_GET_PARAMBAT
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_GET_PARAMBAT enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final batteryParameters =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return batteryParameters;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint(
          "❌ Error al obtener los parámetros de la batería de $macAddress: $e");
      rethrow;
    }
  }

  String parseBatteryParameters(Map<String, dynamic> batteryParameters) {
    final powerType = batteryParameters['powerType'];
    final batteryModel = batteryParameters['batteryModel'];
    final batteryStatus = batteryParameters['batteryStatus'];
    final compensation = batteryParameters['compensation'];
    final voltages = batteryParameters['voltages'] as Map<String, int>;
    final elevatorMax = batteryParameters['elevatorMax'] as Map<String, int>;

    return '''
🔋 Parámetros de la batería:
- Tipo de alimentación: $powerType
- Modelo de batería: $batteryModel
- Estado de la batería: $batteryStatus
- Compensación: $compensation
- Voltajes:
  - V1: ${voltages['V1']} mV
  - V2: ${voltages['V2']} mV
  - V3: ${voltages['V3']} mV
  - V4: ${voltages['V4']} mV
- Elevador máximo:
  - Endpoint 1: ${elevatorMax['endpoint1']}
  - Endpoint 2: ${elevatorMax['endpoint2']}
  - Endpoint 3: ${elevatorMax['endpoint3']}
  - Endpoint 4: ${elevatorMax['endpoint4']}
''';
  }

  Future<Map<String, dynamic>> getTariffCounters(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_CONTADOR
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x0C; // FUN_GET_CONTADOR

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();
      // Suscribirse a las notificaciones para recibir FUN_GET_CONTADOR_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x0D) {
          // FUN_GET_CONTADOR_R recibido
          final tariffStatus = data[1] == 0
              ? "Sin tarifa"
              : data[1] == 1
                  ? "Con tarifa"
                  : "Con tarifa agotada";

          final totalSeconds = (data[2] << 24) |
              (data[3] << 16) |
              (data[4] << 8) |
              data[5]; // Contador total (32 bits)

          final remainingSeconds = (data[6] << 24) |
              (data[7] << 16) |
              (data[8] << 8) |
              data[9]; // Contador parcial (32 bits)

          final counters = {
            'tariffStatus': tariffStatus,
            'totalSeconds': totalSeconds,
            'remainingSeconds': remainingSeconds,
          };

          completer.complete(counters);
          debugPrint(
              "📥 FUN_GET_CONTADOR_R recibido desde $macAddress: $counters");
        }
      });

      // Enviar la solicitud FUN_GET_CONTADOR
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_GET_CONTADOR enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final counters =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return counters;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint(
          "❌ Error al obtener los contadores de tarifa de $macAddress: $e");
      rethrow;
    }
  }

  String parseTariffCounters(Map<String, dynamic> counters) {
    final tariffStatus = counters['tariffStatus'];
    final totalSeconds = counters['totalSeconds'];
    final remainingSeconds = counters['remainingSeconds'];

    final totalTime = Duration(seconds: totalSeconds);
    final remainingTime = Duration(seconds: remainingSeconds);

    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      return "${hours}h ${minutes}m ${seconds}s";
    }

    return '''
⏳ Contadores de tarifa:
- Estado de tarifa: $tariffStatus
- Tiempo total utilizado: ${formatDuration(totalTime)} (${totalSeconds}s)
- Tiempo restante de tarifa: ${formatDuration(remainingTime)} (${remainingSeconds}s)
''';
  }

  Future<Map<String, dynamic>> getElectrostimulatorState(
      String macAddress, int endpoint, int mode) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar que el endpoint y el modo sean válidos
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (mode < 0 || mode > 2) {
      throw ArgumentError("El modo debe estar entre 0 y 2.");
    }

    // Crear el paquete de solicitud FUN_GET_ESTADO_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x10; // FUN_GET_ESTADO_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = mode;

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_ESTADO_EMS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x11) {
          // FUN_GET_ESTADO_EMS_R recibido
          final parsedState = _parseElectrostimulatorState(data, mode);
          completer.complete(parsedState);
          debugPrint(
              "📥 FUN_GET_ESTADO_EMS_R recibido desde $macAddress: $parsedState");
        }
      });

      // Enviar la solicitud FUN_GET_ESTADO_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_GET_ESTADO_EMS enviado a $macAddress. Endpoint: $endpoint, Modo: $mode.");

      // Esperar la respuesta con timeout
      final state = await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return state;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint(
          "❌ Error al obtener el estado del electroestimulador de $macAddress: $e");
      rethrow;
    }
  }

// Función para parsear los datos de la respuesta
  Map<String, dynamic> _parseElectrostimulatorState(List<int> data, int mode) {
    final endpoint = data[1];
    final state = data[2];
    final batteryStatus = data[3];
    final frequency = data[4];
    final ramp = data[5];
    final limitador = data[9] == 0 ? "No" : "Sí";

    if (mode == 0) {
      // Modo 0: temperatura y niveles de canal
      return {
        'endpoint': endpoint,
        'state': state,
        'batteryStatus': _mapBatteryStatus(batteryStatus),
        'frequency': frequency,
        'ramp': ramp * 100,
        'temperature': (data[7] << 8) | data[8],
        'limitador': limitador,
        'channelLevels': data.sublist(10, 20),
      };
    } else if (mode == 1 || mode == 2) {
      // Modo 1: tensión batería / Modo 2: tensión elevador
      final voltageType = mode == 1 ? "Tensión batería" : "Tensión elevador";
      return {
        'endpoint': endpoint,
        'state': state,
        'batteryStatus': _mapBatteryStatus(batteryStatus),
        'frequency': frequency,
        'ramp': ramp * 100,
        voltageType: (data[7] << 8) | data[8],
        'limitador': limitador,
        'pulseWidths': data.sublist(10, 20),
      };
    } else {
      throw ArgumentError("Modo inválido.");
    }
  }

// Mapear el estado de la batería
  String _mapBatteryStatus(int status) {
    switch (status) {
      case 0:
        return "Muy baja";
      case 1:
        return "Baja";
      case 2:
        return "Media";
      case 3:
        return "Alta";
      case 4:
        return "Llena";
      default:
        return "Desconocido";
    }
  }

  String parseElectrostimulatorState(Map<String, dynamic> state, int mode) {
    final endpoint = state['endpoint'];
    final batteryStatus = state['batteryStatus'];
    final frequency = state['frequency'];
    final ramp = state['ramp'];
    final limitador = state['limitador'];

    if (mode == 0) {
      final temperature = state['temperature'];
      final channelLevels = state['channelLevels'] as List<int>;
      return '''
⚡ Estado del electroestimulador (Modo 0):
- Endpoint: $endpoint
- Estado batería: $batteryStatus
- Frecuencia: $frequency Hz
- Rampa: ${ramp}ms
- Temperatura: ${temperature / 10} °C
- Limitador: $limitador
- Niveles de canal: ${channelLevels.join(', ')}
''';
    } else {
      final voltageType = mode == 1 ? "Tensión batería" : "Tensión elevador";
      final voltage = state[voltageType];
      final pulseWidths = state['pulseWidths'] as List<int>;
      return '''
⚡ Estado del electroestimulador (Modo $mode):
- Endpoint: $endpoint
- Estado batería: $batteryStatus
- Frecuencia: $frequency Hz
- Rampa: ${ramp}ms
- $voltageType: ${voltage / 10} V
- Limitador: $limitador
- Ancho de pulso (μs): ${pulseWidths.map((v) => v * 5).join(', ')}
''';
    }
  }

  Future<bool> runElectrostimulationSession({
    required String macAddress,
    required int endpoint,
    required int limitador,
    required int rampa,
    required int frecuencia,
    required int deshabilitaElevador,
    required int nivelCanales,
    required int anchuraPulsoComun,
    required List<int> anchuraPulsosPorCanal,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar parámetros
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (anchuraPulsosPorCanal.length != 10) {
      throw ArgumentError(
          "La lista de anchuras de pulso debe contener exactamente 10 valores.");
    }

    // Crear el paquete de solicitud FUN_RUN_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x12; // FUN_RUN_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = limitador;
    requestPacket[3] = rampa;
    requestPacket[4] = frecuencia;
    requestPacket[5] = deshabilitaElevador;
    requestPacket[6] = nivelCanales;
    requestPacket[7] = anchuraPulsoComun;
    for (int i = 0; i < 10; i++) {
      requestPacket[8 + i] = anchuraPulsosPorCanal[i];
    }

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<bool>();

      // Suscribirse a las notificaciones para recibir FUN_RUN_EMS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x13) {
          // FUN_RUN_EMS_R recibido
          final retorno = data[2];
          final result = retorno == 1;
          completer.complete(result);
          debugPrint(
              "📥 FUN_RUN_EMS_R recibido desde $macAddress: ${result ? "OK" : "FAIL"}");
        }
      });

      // Enviar la solicitud FUN_RUN_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_RUN_EMS enviado a $macAddress para endpoint $endpoint.");

      // Esperar la respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return result;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al iniciar sesión de electroestimulación: $e");
      rethrow;
    }
  }

  Future<bool> stopElectrostimulationSession({
    required String macAddress,
    required int endpoint,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar el endpoint
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }

    // Crear el paquete de solicitud FUN_STOP_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x14; // FUN_STOP_EMS
    requestPacket[1] = endpoint;

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<bool>();

      // Suscribirse a las notificaciones para recibir FUN_STOP_EMS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x15) {
          // FUN_STOP_EMS_R recibido
          final retorno = data[2];
          final result = retorno == 1;
          completer.complete(result);
          debugPrint(
              "📥 FUN_STOP_EMS_R recibido desde $macAddress: ${result ? "OK" : "FAIL"}");
        }
      });

      // Enviar la solicitud FUN_STOP_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_STOP_EMS enviado a $macAddress para endpoint $endpoint.");

      // Esperar la respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return result;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al detener sesión de electroestimulación: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> controlElectrostimulatorChannel({
    required String macAddress,
    required int endpoint,
    required int canal,
    required int modo,
    required int valor,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar parámetros
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (canal < 0 || canal > 9) {
      throw ArgumentError("El canal debe estar entre 0 y 9.");
    }
    if (modo < 0 || modo > 3) {
      throw ArgumentError(
          "El modo debe ser 0 (absoluto), 1 (incrementa), 2 (decrementa), o 3 (solo retorna valor).");
    }
    if (valor < 0 || valor > 100) {
      throw ArgumentError("El valor debe estar entre 0 y 100.");
    }

    // Crear el paquete de solicitud FUN_CANAL_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x16; // FUN_CANAL_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = canal;
    requestPacket[3] = modo;
    requestPacket[4] = valor;

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_CANAL_EMS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x17) {
          // FUN_CANAL_EMS_R recibido
          final endpointResp = data[1];
          final canalResp = data[2];
          final resultado = data[3] == 1 ? "OK" : "FAIL";
          final valorResp = data[4];

          final response = {
            'endpoint': endpointResp,
            'canal': canalResp,
            'resultado': resultado,
            'valor': valorResp == 200 ? "Limitador activado" : "$valorResp%",
          };

          completer.complete(response);
          debugPrint(
              "📥 FUN_CANAL_EMS_R recibido desde $macAddress: $response");
        }
      });

      // Enviar la solicitud FUN_CANAL_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_CANAL_EMS enviado a $macAddress. Endpoint: $endpoint, Canal: $canal, Modo: $modo, Valor: $valor.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al controlar el canal del electroestimulador: $e");
      rethrow;
    }
  }

  String parseChannelControlResponse(Map<String, dynamic> response) {
    final endpoint = response['endpoint'];
    final canal = response['canal'];
    final resultado = response['resultado'];
    final valor = response['valor'];

    return '''
🎛️ Control del canal del electroestimulador:
- Endpoint: $endpoint
- Canal: $canal
- Resultado: $resultado
- Valor: $valor
''';
  }

  Future<Map<String, dynamic>> controlAllElectrostimulatorChannels({
    required String macAddress,
    required int endpoint,
    required int modo,
    required List<int> valoresCanales,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar parámetros
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (modo < 0 || modo > 3) {
      throw ArgumentError(
          "El modo debe ser 0 (absoluto), 1 (incrementa), 2 (decrementa), o 3 (solo retorna valores).");
    }
    if (valoresCanales.length != 10) {
      throw ArgumentError(
          "Debe haber exactamente 10 valores para los canales.");
    }
    if (valoresCanales.any((valor) => valor < 0 || valor > 100)) {
      throw ArgumentError(
          "Todos los valores de los canales deben estar entre 0 y 100.");
    }

    // Crear el paquete de solicitud FUN_ALL_CANAL_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x18; // FUN_ALL_CANAL_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = modo;
    for (int i = 0; i < 10; i++) {
      requestPacket[3 + i] = valoresCanales[i];
    }

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_ALL_CANAL_EMS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x19) {
          // FUN_ALL_CANAL_EMS_R recibido
          final endpointResp = data[1];
          final resultado = data[2] == 1 ? "OK" : "FAIL";
          final valoresResp = data.sublist(3, 13).map((v) {
            return v == 200 ? "Limitador activado" : "$v%";
          }).toList();

          final response = {
            'endpoint': endpointResp,
            'resultado': resultado,
            'valoresCanales': valoresResp,
          };

          completer.complete(response);
          debugPrint(
              "📥 FUN_ALL_CANAL_EMS_R recibido desde $macAddress: $response");
        }
      });

      // Enviar la solicitud FUN_ALL_CANAL_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_ALL_CANAL_EMS enviado a $macAddress. Endpoint: $endpoint, Modo: $modo, Valores: $valoresCanales.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint(
          "❌ Error al controlar todos los canales del electroestimulador: $e");
      rethrow;
    }
  }

  String parseAllChannelsResponse(Map<String, dynamic> response) {
    final endpoint = response['endpoint'];
    final resultado = response['resultado'];
    final valoresCanales = response['valoresCanales'] as List<String>;

    final canales = valoresCanales
        .asMap()
        .entries
        .map((entry) => "  Canal ${entry.key + 1}: ${entry.value}")
        .join('\n');

    return '''
🎚️ Control de todos los canales del electroestimulador:
- Endpoint: $endpoint
- Resultado: $resultado
$canales
''';
  }

  Future<bool> performShutdown({
    required String macAddress,
    int temporizado = 0, // Shutdown inmediato por defecto
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      debugPrint(
          "🔄 Enviando comando de shutdown al dispositivo $macAddress...");

      // Construir el paquete de shutdown
      final List<int> shutdownPacket = List.filled(20, 0);
      shutdownPacket[0] = 0x1A; // FUN_RESET
      shutdownPacket[1] = 0x66; // Shutdown
      shutdownPacket[2] = temporizado; // Temporizado (0 para inmediato)

      // Enviar el paquete
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: shutdownPacket,
      );

      debugPrint("✅ Comando de shutdown enviado correctamente.");
      return true;
    } catch (e) {
      debugPrint("❌ Error al enviar el comando de shutdown: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getFreeMemory({
    required String macAddress,
    required int pagina,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar la página
    if (pagina < 0 || pagina > 31) {
      throw ArgumentError("La página debe estar entre 0 y 31.");
    }

    // Crear el paquete de solicitud FUN_GET_MEM
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x1C; // FUN_GET_MEM
    requestPacket[1] = pagina;

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_MEM_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x1D) {
          // FUN_GET_MEM_R recibido
          final response = {
            'status': data[1] == 1 ? "OK" : "FAIL",
            'pagina': data[2],
            'datos': data.sublist(3, 19),
          };
          completer.complete(response);
          debugPrint("📥 FUN_GET_MEM_R recibido desde $macAddress: $response");
        }
      });

      // Enviar la solicitud FUN_GET_MEM
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_GET_MEM enviado a $macAddress. Página: $pagina.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al obtener memoria libre: $e");
      rethrow;
    }
  }

  Future<bool> setFreeMemory({
    required String macAddress,
    required int pagina,
    required List<int> datos,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar la página y los datos
    if (pagina < 0 || pagina > 31) {
      throw ArgumentError("La página debe estar entre 0 y 31.");
    }
    if (datos.length != 16) {
      throw ArgumentError("Los datos deben tener exactamente 16 bytes.");
    }

    // Crear el paquete de solicitud FUN_SET_MEM
    final List<int> requestPacket = [0x1E, pagina, ...datos];

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<bool>();

      // Suscribirse a las notificaciones para recibir FUN_SET_MEM_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x1F) {
          // FUN_SET_MEM_R recibido
          completer.complete(data[1] == 1); // OK: 1
          debugPrint(
              "📥 FUN_SET_MEM_R recibido desde $macAddress: ${data[1] == 1 ? "OK" : "FAIL"}");
        }
      });

      // Enviar la solicitud FUN_SET_MEM
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_SET_MEM enviado a $macAddress. Página: $pagina, Datos: $datos.");

      // Esperar la respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return result;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al escribir en memoria libre: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPulseMeter({
    required String macAddress,
    required int endpoint,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar el endpoint
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }

    // Crear el paquete de solicitud FUN_GET_PULSOS
    final List<int> requestPacket = [0x20, endpoint];

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_PULSOS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x21) {
          // FUN_GET_PULSOS_R recibido
          final response = {
            'endpoint': data[1],
            'status': _mapPulseMeterStatus(data[2]),
            'bps': (data[3] << 8) | data[4], // Pulsaciones por segundo
            'SpO2': (data[5] << 8) | data[6], // Saturación de oxígeno
          };
          completer.complete(response);
          debugPrint(
              "📥 FUN_GET_PULSOS_R recibido desde $macAddress: $response");
        }
      });

      // Enviar la solicitud FUN_GET_PULSOS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_GET_PULSOS enviado a $macAddress. Endpoint: $endpoint.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al obtener datos del pulsómetro: $e");
      rethrow;
    }
  }

  String _mapPulseMeterStatus(int status) {
    switch (status) {
      case 0:
        return "No existe";
      case 1:
        return "Sensor desconectado o con error";
      case 2:
        return "Sensor no capta";
      case 3:
        return "OK";
      default:
        return "Desconocido";
    }
  }
}
