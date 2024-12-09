import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:imotion_designs/src/panel/overlays/overlay_panel.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../db/db_helper.dart';
import '../../servicios/licencia_state.dart';
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

  String? selectedProgram;
  List<Map<String, dynamic>> allIndividualPrograms = [];
  List<Map<String, dynamic>> allRecoveryPrograms = [];
  List<Map<String, dynamic>> allAutomaticPrograms = [];
  List<Map<String, dynamic>> allClients = []; // Lista original de clientes
  List<Map<String, dynamic>> selectedClients = [];

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

  int timePause = 0;
  int timeRampa = 0;

  double valueContraction = 1.0;
  double valueRampa = 1.0;
  double valuePause = 1.0;

  bool isSessionStarted = false;

  // Lista de imágenes según los minutos
  List<String> imagePaths = [
    'assets/images/30.png',
    'assets/images/29.png',
    'assets/images/28.png',
    'assets/images/27.png',
    'assets/images/26.png',
    'assets/images/25.png',
    'assets/images/24.png',
    'assets/images/23.png',
    'assets/images/22.png',
    'assets/images/21.png',
    'assets/images/20.png',
    'assets/images/19.png',
    'assets/images/18.png',
    'assets/images/17.png',
    'assets/images/16.png',
    'assets/images/15.png',
    'assets/images/14.png',
    'assets/images/13.png',
    'assets/images/12.png',
    'assets/images/11.png',
    'assets/images/10.png',
    'assets/images/9.png',
    'assets/images/8.png',
    'assets/images/7.png',
    'assets/images/6.png',
    'assets/images/5.png',
    'assets/images/4.png',
    'assets/images/3.png',
    'assets/images/2.png',
    'assets/images/1.png',
    'assets/images/0.png',
  ];

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

  @override
  void initState() {
    super.initState();
    _updateImageIndex();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    bleConnectionService = BleConnectionService([]);

    // Cargar los datos de AppState y actualizar el servicio BLE cuando estén disponibles
    AppState.instance.loadState().then((_) {
      // Obtener las direcciones MAC desde el AppState
      List<String> macAddresses =
          AppState.instance.macList; // O puedes usar macBleList si lo prefieres

      // Actualizar el servicio de conexión BLE con las direcciones MAC obtenidas
      setState(() {
        bleConnectionService.updateMacAddresses(macAddresses);
      });

      // Escuchar el estado de la conexión
      bleConnectionService.connectionStateStream.listen((connected) {
        setState(() {
          isConnected = connected;
          connectionStatus = connected ? 'conectado' : 'desconectado';
        });
      });

      // Recargar la UI después de cargar el estado
      setState(() {});
    });

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
    AppState.instance.loadState().then((_) {
      // Una vez cargado el estado, actualizamos la UI
      setState(() {});
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
      print('Error fetching clients: $e');
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
      print('Error fetching programs: $e');
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
      print('Error fetching programs: $e');
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
      print('Error fetching programs: $e');
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
    _updateImageIndex();

    setState(() {
      isRunning = true;
      startTime = DateTime.now();

      // Inicia el temporizador con un intervalo de 1 segundo
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          // Calcula el tiempo transcurrido
          elapsedTime = pausedTime +
              DateTime.now().difference(startTime).inSeconds.toDouble();

          // Progreso del tiempo restante
          progress = 1.0 - (elapsedTime / totalTime).clamp(0.0, 1.0);

          // Actualizar tiempo restante en minutos y segundos
          int remainingTime = (totalTime - elapsedTime).toInt();
          seconds = remainingTime % 60;
          time = remainingTime ~/ 60;

          // Calcular índice de la imagen basado en el tiempo restante
          int maxIndex = imagePaths.length - time; // Índice máximo de imágenes
          if (elapsedTime >= 60) {
            // Actualizar el índice basado en el tiempo transcurrido (por minutos completos)
            _currentImageIndex = ((elapsedTime - 60) / (totalTime - 60) * maxIndex).floor().clamp(0, maxIndex);
          }
          // Pausa el temporizador si el tiempo ha terminado
          if (elapsedTime >= totalTime) {
            _pauseTimer();
          }
        });
      });
    });
  }

// Función que pausa el temporizador
  void _pauseTimer() {
    setState(() {
      isRunning = false;
      pausedTime = elapsedTime; // Guardar el tiempo actual cuando se pausa
      _timer.cancel(); // Detener el temporizador
    });
  }

  @override
  void dispose() {
    bleConnectionService.dispose();
    _timer.cancel(); // Detenemos el timer al salir de la pantalla
    _opacityController.dispose(); // Liberar recursos al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isConnected = bleConnectionService.isConnected;

    return Scaffold(
      body: Stack(
        key: ValueKey(selectedIndexEquip), // Clave única para el índice
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
                                      // Mapeamos las MACs almacenadas
                                      ...AppState.instance.mcis.map((mci) {
                                        String macAddress = mci[
                                            'mac']; // Obtener la MAC de cada dispositivo

                                        return GestureDetector(
                                          onTap: () async {
                                            // Intentamos conectar al dispositivo correspondiente usando la MAC
                                            bool success =
                                                await bleConnectionService
                                                    ._connectToDeviceByMac(
                                                        macAddress);

                                            // Si la conexión fue exitosa, cambia el estado
                                            setState(() {
                                              isConnected = success;
                                              connectionStatus = success
                                                  ? 'conectado'
                                                  : 'desconectado';
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: SizedBox(
                                              width: screenWidth * 0.1,
                                              height: screenHeight * 0.1,
                                              child: CustomPaint(
                                                painter: NeonBorderPainter(
                                                    neonColor: _getBorderColor(
                                                        connectionStatus)),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    // Fondo transparente
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7), // Bordes redondeados
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      selectedClientsGlobal
                                                              .isEmpty
                                                          ? '' // Si la lista está vacía, mostrar un texto vacío
                                                          : selectedClientsGlobal[
                                                                  0]['name'] ??
                                                              'No Name',
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        color: Color(
                                                            0xFF28E2F5), // Color del texto
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
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
                                        child: const Text(
                                          'DEFINIR GRUPOS',
                                          style: TextStyle(
                                            color: Color(0xFF2be4f3),
                                            fontSize: 17,
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
                                          padding: EdgeInsets.all(10.0),
                                          width: _isExpanded1
                                              ? screenWidth * 0.25
                                              : 0,
                                          height: screenHeight * 0.1,
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
                                              Expanded(
                                                child: GestureDetector(
                                                  onTapDown: (_) => setState(
                                                      () => scaleFactorCliente =
                                                          0.90),
                                                  onTapUp: (_) => setState(() =>
                                                      scaleFactorCliente = 1.0),
                                                  onTap: () {
                                                    setState(() {
                                                      toggleOverlay(
                                                          0); // Suponiendo que toggleOverlay abre el overlay
                                                    });
                                                  },
                                                  child: AnimatedScale(
                                                    scale: scaleFactorCliente,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    child: Container(
                                                      width: screenHeight * 0.1,
                                                      height: screenWidth * 0.1,
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
                                                          height: screenHeight *
                                                              0.05,
                                                          child: ClipOval(
                                                            child: Image.asset(
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
                                              SizedBox(
                                                  width: screenWidth * 0.005),
                                              Expanded(
                                                child: AbsorbPointer(
                                                  absorbing: isSessionStarted,
                                                  // Bloquea las interacciones si la sesión está activa
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIndexEquip =
                                                            0; // Sección 1 seleccionada
                                                      });
                                                    },
                                                    child: Container(
                                                      width: screenWidth * 0.1,
                                                      height:
                                                          screenHeight * 0.1,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            selectedIndexEquip ==
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
                                              Expanded(
                                                child: AbsorbPointer(
                                                  absorbing: isSessionStarted,
                                                  // Bloquea las interacciones si la sesión está activa
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIndexEquip =
                                                            1; // Sección 2 seleccionada
                                                      });
                                                    },
                                                    child: Container(
                                                      width: screenWidth * 0.1,
                                                      height:
                                                          screenHeight * 0.1,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            selectedIndexEquip ==
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
                                              SizedBox(
                                                  width: screenWidth * 0.005),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTapDown: (_) => setState(
                                                      () => scaleFactorRepeat =
                                                          0.90),
                                                  onTapUp: (_) => setState(() =>
                                                      scaleFactorRepeat = 1.0),
                                                  onTap: () {},
                                                  child: AnimatedScale(
                                                    scale: scaleFactorRepeat,
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    child: Container(
                                                      width: screenHeight * 0.1,
                                                      height: screenWidth * 0.1,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        shape: BoxShape
                                                            .circle, // Forma circular
                                                      ),
                                                      child: Center(
                                                        child: SizedBox(
                                                          child: ClipOval(
                                                            child: Image.asset(
                                                              width:
                                                                  screenHeight *
                                                                      0.1,
                                                              height:
                                                                  screenWidth *
                                                                      0.1,
                                                              'assets/images/repeat.png',
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
                                              onPressed: () {
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
                                                backgroundColor:
                                                    const Color(0xFF2be4f3),
                                              ),
                                              child: Text(
                                                globalSelectedProgram ??
                                                    'PROGRAMAS',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
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
                                                      const Text(
                                                        "NOMBRE PROGRAMA",
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF2be4f3),
                                                          fontSize: 15,
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
                                                        'INDIVIDUAL' &&
                                                    allIndividualPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedIndivProgram !=
                                                                null
                                                            ? selectedIndivProgram![
                                                                    'nombre'] ??
                                                                "NOMBRE PROGRAMA"
                                                            : allIndividualPrograms
                                                                    .isNotEmpty
                                                                ? allIndividualPrograms[
                                                                            0][
                                                                        'nombre'] ??
                                                                    "NOMBRE PROGRAMA"
                                                                : "No hay programas disponibles",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF2be4f3),
                                                          fontSize: 15,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            toggleOverlay(2);
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
                                                        'RECOVERY' &&
                                                    allRecoveryPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedRecoProgram !=
                                                                null
                                                            ? selectedRecoProgram![
                                                                    'nombre'] ??
                                                                "NOMBRE PROGRAMA"
                                                            : allRecoveryPrograms
                                                                    .isNotEmpty
                                                                ? allRecoveryPrograms[
                                                                            0][
                                                                        'nombre'] ??
                                                                    "NOMBRE PROGRAMA"
                                                                : "No hay programas disponibles",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF2be4f3),
                                                          fontSize: 15,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            toggleOverlay(3);
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
                                                        'AUTOMÁTICOS' &&
                                                    allAutomaticPrograms
                                                        .isNotEmpty)
                                                  Column(
                                                    children: [
                                                      // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                                      Text(
                                                        selectedAutoProgram !=
                                                                null
                                                            ? selectedAutoProgram![
                                                                    'nombre_programa_automatico'] ??
                                                                "NOMBRE PROGRAMA"
                                                            : allAutomaticPrograms
                                                                    .isNotEmpty
                                                                ? allAutomaticPrograms[
                                                                            0][
                                                                        'nombre_programa_automatico'] ??
                                                                    "NOMBRE PROGRAMA"
                                                                : "No hay programas disponibles",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF2be4f3),
                                                          fontSize: 15,
                                                        ),
                                                      ),

                                                      // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            toggleOverlay(4);
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
                                                  const Column(
                                                    children: [
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        'INDIVIDUAL' &&
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
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
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
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        'RECOVERY' &&
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
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
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
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                else if (globalSelectedProgram ==
                                                        'AUTOMÁTICOS' &&
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
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
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
                                              child: const Text(
                                                'CICLOS',
                                                style: TextStyle(
                                                  color: Color(0xFF2be4f3),
                                                  fontSize: 15,
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
                                              const Text("VIRTUAL TRAINER",
                                                  style: TextStyle(
                                                    color: Color(0xFF2be4f3),
                                                    fontSize: 13,
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
                                                  // Mostrar las imágenes según el índice ajustado
                                                  ...imagePaths
                                                      .sublist(
                                                          _currentImageIndex)
                                                      .reversed
                                                      .map((imagePath) {
                                                    return Image.asset(
                                                      imagePath,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.25,
                                                      fit: BoxFit.cover,
                                                    );
                                                  }).toList(),
                                                  Column(
                                                    children: [
                                                      // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  time++; // Aumenta el tiempo (en minutos)
                                                                  totalTime = time *
                                                                      60; // Actualiza el tiempo total en segundos
                                                                  _updateImageIndex(); // Actualiza el índice de la imagen según el tiempo
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
                                                        style: const TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
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
                                                                    _updateImageIndex(); // Actualiza el índice de la imagen según el tiempo
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
                                                        progress: progress,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    timeRampa
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20,
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
                                                        progress: progress,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    timePause
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: const TextStyle(
                                                        fontSize: 20,
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
                                            onTap: () {
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
                                                    porcentajesMusculoTraje[i] =
                                                        (porcentajesMusculoTraje[
                                                                    i] -
                                                                1)
                                                            .clamp(0, 100);
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
                                            onTap: () {
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
                                                print(
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
                                            onTap: () {
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
                                                    porcentajesMusculoTraje[i] =
                                                        (porcentajesMusculoTraje[
                                                                    i] +
                                                                1)
                                                            .clamp(0, 100);
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
                                                  // Mostrar las imágenes según el índice ajustado
                                                  ...imagePaths
                                                      .sublist(
                                                          _currentImageIndex)
                                                      .reversed
                                                      .map((imagePath) {
                                                    return Image.asset(
                                                      imagePath,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.25,
                                                      fit: BoxFit.cover,
                                                    );
                                                  }).toList(),
                                                  Column(
                                                    children: [
                                                      // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                      GestureDetector(
                                                        onTap: isRunning
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  time++; // Aumenta el tiempo (en minutos)
                                                                  totalTime = time *
                                                                      60; // Actualiza el tiempo total en segundos
                                                                  _updateImageIndex(); // Actualiza el índice de la imagen según el tiempo
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
                                                        // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                        style: const TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
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
                                                                    _updateImageIndex(); // Actualiza el índice de la imagen según el tiempo
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
                                                        progress: progress,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    timeRampa
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: TextStyle(
                                                        fontSize: 20,
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
                                                        progress: progress,
                                                        strokeHeight: 20),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          screenWidth * 0.01),
                                                  Text(
                                                    timePause
                                                        .toString()
                                                        .padLeft(1, '0'),
                                                    // Convierte seconds a entero y usa padLeft para formato mm:ss
                                                    style: const TextStyle(
                                                        fontSize: 20,
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
                                            onTap: () {
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
                                                            .clamp(0, 100);
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
                                            onTap: () {
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
                                                print(
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
                                            onTap: () {
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
                                                            .clamp(0, 100);
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
                                bottom: 0, // Distancia desde el borde superior
                                right: 0, // Distancia desde el borde derecho
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
                                              padding: EdgeInsets.all(10.0),
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
                                              child: Row(
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
                                              padding: EdgeInsets.all(10.0),
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
                                            const Text(
                                              "AVERAGE",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(
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
                ),
              ],
            ),
          ),
          if (isOverlayVisible)
            Positioned(
              top: overlayIndex == 1 ? screenHeight * 0.3 : 0,
              bottom: overlayIndex == 1 ? screenHeight * 0.3 : 0,
              left: overlayIndex == 1 ? screenWidth * 0.3 : 0,
              right: overlayIndex == 1 ? screenWidth * 0.3 : 0,
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
                const Text(
                  'AVISO',
                  style: TextStyle(
                      color: Color(0xFF2be4f3),
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿QUIERES RESETEAR TODO?',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
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
                      ),
                      child: const Text(
                        'CANCELAR',
                        style:
                            TextStyle(color: Color(0xFF2be4f3), fontSize: 20),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _clearGlobals();
                        bleConnectionService
                            .dispose(); // Llamar al método dispose de tu servicio BLE
                        widget.onReset();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          backgroundColor: Colors.red),
                      child: const Text(
                        '¡SÍ, QUIERO RESETEAR!',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
                const Text(
                  'AVISO',
                  style: TextStyle(
                      color: Color(0xFF2be4f3),
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿QUIERES SALIR DEL PANEL?',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
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
                      ),
                      child: const Text(
                        'CANCELAR',
                        style:
                            TextStyle(color: Color(0xFF2be4f3), fontSize: 20),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _clearGlobals();
                        bleConnectionService.dispose();
                        widget.onBack();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          backgroundColor: Colors.red),
                      child: const Text(
                        'SALIR DEL PANEL',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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

  void _updateImageIndex() {
    int maxIndex = imagePaths.length - 1; // Último índice
    int index = maxIndex -
        (time * maxIndex ~/ 30); // Calcula el índice en función del tiempo

    // Nos aseguramos de que el índice esté dentro del rango
    if (index >= 0 && index < imagePaths.length) {
      setState(() {
        _currentImageIndex = index; // Actualizamos el índice de la imagen
      });
    }
  }

  Color _getBorderColor(String status) {
    switch (status) {
      case 'conectado':
        return Color(0xFF2be4f3); // Color para el estado "conectado"
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
                  ? Color(0xFFFFA500).withOpacity(0.3)
                  : Colors.transparent,
          // Si no está bloqueado ni inactivo, fondo transparente
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: () {
                  setState(() {
                    // Si no está bloqueado ni inactivo, se puede aumentar el contador
                    if (!_isMusculoTrajeBloqueado[index] &&
                        !_isMusculoTrajeInactivo[index]) {
                      porcentajesMusculoTraje[index] =
                          (porcentajesMusculoTraje[index] + 1).clamp(0, 100);
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
                      fontSize: _isFullScreen ? 15.0 : 13.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

              // Botón "Menos"
              CustomIconButton(
                onTap: () {
                  setState(() {
                    if (!_isMusculoTrajeBloqueado[index] &&
                        !_isMusculoTrajeInactivo[index]) {
                      porcentajesMusculoTraje[index] =
                          (porcentajesMusculoTraje[index] - 1).clamp(0, 100);
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
                      ? Color(0xFFFFA500).withOpacity(0.3)
                      : Colors.transparent,
          // Si no está bloqueado ni inactivo, fondo transparente
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: () {
                  setState(() {
                    // Si no está bloqueado ni inactivo, se puede aumentar el contador
                    if (!_isMusculoPantalonBloqueado[index] &&
                        !_isMusculoPantalonInactivo[index]) {
                      porcentajesMusculoPantalon[index] =
                          (porcentajesMusculoPantalon[index] + 1).clamp(0, 100);
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
                      fontSize: _isFullScreen ? 15.0 : 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),

              // Botón "Menos"
              CustomIconButton(
                onTap: () {
                  setState(() {
                    if (!_isMusculoPantalonBloqueado[index] &&
                        !_isMusculoPantalonInactivo[index]) {
                      porcentajesMusculoPantalon[index] =
                          (porcentajesMusculoPantalon[index] - 1).clamp(0, 100);
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
          style: const TextStyle(
            fontSize: 15,
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
  final VoidCallback onTap; // Acción al soltar el botón
  final VoidCallback? onTapDown; // Acción al presionar el botón
  final VoidCallback? onTapUp; // Acción al levantar el botón
  final String imagePath; // Ruta de la imagen del botón
  final double size; // Tamaño del botón
  final bool isDisabled; // Condición para deshabilitar el botón

  const CustomIconButton({
    Key? key,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    required this.imagePath,
    this.size = 40.0, // Valor por defecto para el tamaño
    this.isDisabled = false, // Condición por defecto que no está deshabilitado
  }) : super(key: key);

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
          child: Container(
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
      ),
    );
  }
}

class BleConnectionService {
  // Variables de estado
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;
  Timer? _connectionCheckTimer; // Timer para el chequeo periódico de conexión
  List<String> targetDeviceIds = []; // Lista para almacenar las direcciones MAC

  // Stream para notificar cambios en el estado de la conexión
  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  // Variables relacionadas con Bluetooth
  late DiscoveredDevice _ubiqueDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late StreamSubscription<ConnectionStateUpdate>
      _connectionStream; // Inicializado correctamente.

  // Lista de UUIDs de servicios que queremos detectar
  List<Uuid> serviceUuids = [
    Uuid.parse("49535343-FE7D-4AE5-8FA9-9FAFD205E455"),
    Uuid.parse("49535343-8841-43F4-A8D4-ECBE34729BB4"),
    Uuid.parse("49535343-1E4D-4BD9-BA61-23C647249617"),
  ];

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

  // Este stream es lo que el widget escucha
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Iniciar el escaneo (escaneo automático al iniciar)
// Método de escaneo modificado para conectar exactamente al dispositivo encontrado
  void _startScan() async {
    if (kDebugMode) {
      print("Iniciando el escaneo...");
    }

    bool permGranted = false;

    // Solicitar permisos de ubicación en Android/iOS
    if (Platform.isAndroid || Platform.isIOS) {
      if (kDebugMode) {
        print("Solicitando permisos de ubicación...");
      }
      PermissionStatus permission = await Permission.location.request();
      if (permission == PermissionStatus.granted) {
        permGranted = true;
        if (kDebugMode) {
          print("Permiso de ubicación concedido.");
        }
      } else {
        if (kDebugMode) {
          print("Permiso de ubicación denegado.");
        }
        return; // Salir si no hay permisos
      }
    }

    // Iniciar el escaneo solo si los permisos están otorgados
    if (permGranted) {
      if (kDebugMode) {
        print("Iniciando escaneo BLE...");
      }
      _scanStream = flutterReactiveBle.scanForDevices(
          withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
        if (kDebugMode) {
          print("Dispositivo encontrado: ${device.name}, ID: ${device.id}");
        }

        // Verificar si el ID o el nombre del dispositivo es el que estamos buscando
        if (targetDeviceIds.contains(device.id)) {
          // Si la dirección MAC coincide, detener el escaneo y conectarse
          _ubiqueDevice = device;
          _foundDeviceWaitingToConnect = true;
          _scanStarted = false;

          // Detener el escaneo una vez que se encuentra el dispositivo
          _scanStream.cancel();
          if (kDebugMode) {
            print("Escaneo detenido.");
          }
        }
      });
    }
  }

// Función para conectarse al dispositivo encontrado
  Future<bool> _connectToDeviceByMac(String macAddress) async {
    if (macAddress.isEmpty) {
      if (kDebugMode) {
        print("Dirección MAC vacía.");
      }
      return false;
    }

    if (kDebugMode) {
      print("Conectando al dispositivo con la MAC: $macAddress...");
    }

    bool success = false;

    // Conectar al dispositivo BLE utilizando la MAC proporcionada
    _connectionStream = flutterReactiveBle.connectToAdvertisingDevice(
        id: macAddress, // Usamos la MAC proporcionada
        prescanDuration: const Duration(seconds: 1),
        withServices: [] // Aquí puedes agregar los UUIDs de los servicios si es necesario
        ).listen((event) async {
      if (kDebugMode) {
        print("Estado de la conexión: ${event.connectionState}");
      }

      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          if (kDebugMode) {
            print("Dispositivo conectado exitosamente.");
          }
          _connected = true;
          success = true; // Se marca la conexión como exitosa

          // Iniciar el chequeo periódico de la conexión
          _startConnectionCheckTimer();
          break;
        case DeviceConnectionState.disconnected:
          if (kDebugMode) {
            print("Conexión desconectada.");
          }
          _connected = false;
          success = false; // Se marca como desconectado

          // Reiniciar el escaneo si se pierde la conexión
          _restartScan();
          break;
        default:
          if (kDebugMode) {
            print("Estado de la conexión desconocido.");
          }
          break;
      }

      // Emitir el estado de la conexión a través del stream
      if (!_connectionStateController.isClosed) {
        _connectionStateController.add(_connected);
      }
    });

    // Esperar a que se complete la conexión y devolver el resultado
    await Future.delayed(const Duration(
        seconds:
            2)); // Esperar un poco para que la conexión tenga tiempo de completarse
    return success; // Retorna si la conexión fue exitosa o no
  }

  // Iniciar el timer para el chequeo de la conexión
  void _startConnectionCheckTimer() {
    _connectionCheckTimer ??=
        Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_connected) {
        print("Chequeo de conexión: El dispositivo está conectado.");
      } else {
        print(
            "Chequeo de conexión: El dispositivo está desconectado. Reiniciando escaneo...");
        // Si la conexión está perdida, reiniciar el escaneo
        _restartScan();
      }
    });
  }

  // Reiniciar el escaneo
  void _restartScan() async {
    // Solo reiniciar el escaneo si no estamos actualmente escaneando
    if (!_scanStarted) {
      if (kDebugMode) {
        print("Reiniciando el escaneo...");
      }
      _scanStarted = true;
      _startScan(); // Llamar al método _startScan para comenzar nuevamente
    }
  }

  // Desconectar del dispositivo
  void disconnect() async {
    if (_connected) {
      if (kDebugMode) {
        print("Desconectando del dispositivo: ${_ubiqueDevice.id}");
      }

      // Cancelar la suscripción del stream de conexión
      await _connectionStream.cancel(); // Ahora está cancelada correctamente.

      // Deinitialize para liberar los recursos y finalizar la conexión correctamente.
      flutterReactiveBle.deinitialize(); // Liberar los recursos BLE.

      _connected = false; // Actualiza el estado de conexión
      // Emitir el estado actualizado solo si el stream está abierto
      if (!_connectionStateController.isClosed) {
        _connectionStateController
            .add(_connected); // Emitir el estado actualizado.
      }

      // Detener el chequeo periódico de la conexión
      _connectionCheckTimer?.cancel();
      _connectionCheckTimer = null;

      _restartScan();
    } else {
      if (kDebugMode) {
        print("No hay dispositivo conectado.");
      }
    }
  }

  void dispose() {
    if (_connected) {
      disconnect(); // Llamar a disconnect() para desconectar el dispositivo si está conectado
      print("Desconectando dispositivo...");
    }

    // Cerrar el stream controller correctamente
    if (!_connectionStateController.isClosed) {
      _connectionStateController
          .close(); // Cerrar el stream controller solo si no está cerrado
      print("Stream controller cerrado");
    }
  }

  bool get isConnected => _connected;
}

class NeonBorderPainter extends CustomPainter {
  final Color neonColor;

  NeonBorderPainter({required this.neonColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(
          BlurStyle.solid, 2); // Efecto de resplandor hacia afuera

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect roundedRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(7));

    canvas.drawRRect(roundedRect, paint); // Dibuja el borde con resplandor
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
