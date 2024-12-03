import 'dart:async';

import 'package:flutter/material.dart';

import '../custom/linear_custom.dart';
import '../custom/timer_custom.dart';

class PanelView extends StatefulWidget {
  final VoidCallback onBack;

  const PanelView({super.key, required this.onBack});

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView>
    with SingleTickerProviderStateMixin {
  double scaleFactorBack = 1.0;
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

  double valueContraction = 1.0;
  double valueRampa = 1.0;
  double valuePause = 1.0;

  bool isSessionStarted = false;

  List<bool> _isMusculoTrajeBloqueado = [
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

  @override
  void initState() {
    super.initState();
    // Crear el controlador de animación de opacidad
    _opacityController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Hace que la animación repita y reverse

    // Crear la animación de opacidad
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
  }

// Función que inicia o reanuda el temporizador
  void _startTimer() {
    setState(() {
      isRunning = true;
      startTime = DateTime.now();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          elapsedTime = pausedTime +
              DateTime.now().difference(startTime).inSeconds.toDouble();
          progress = 1.0 - (elapsedTime / totalTime); // Reducir el progreso

          // Actualiza los minutos y segundos
          seconds = (totalTime - elapsedTime).toInt() % 60;
          time = (totalTime - elapsedTime).toInt() ~/ 60;

          if (elapsedTime >= totalTime) {
            _pauseTimer(); // Pausar el temporizador cuando se alcanza el tiempo
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

  // Función que reinicia el temporizador
  void _resetTimer() {
    setState(() {
      isRunning = false;
      elapsedTime = 0.0;
      pausedTime = 0.0;
      progress = 1.0; // Reiniciar el progreso a lleno
      seconds = 0; // Reiniciar los segundos
      time = 25; // Reiniciar el tiempo en minutos
      _timer.cancel(); // Detener el temporizador
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Detenemos el timer al salir de la pantalla
    _opacityController.dispose(); // Liberar recursos al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                vertical: screenHeight * 0.04, horizontal: screenWidth * 0.02),
            child: Column(
              children: [
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
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF28E2F5),
                                          width: 1,
                                        ),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Contenedor 1',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    // Cambia el tamaño según sea necesario
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF28E2F5),
                                          width: 1,
                                        ),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Contenedor 2',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.all(10.0),
                                        side: const BorderSide(
                                            width: 1.0,
                                            color: Color(0xFF2be4f3)),
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
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        duration:
                                            const Duration(milliseconds: 200),
                                        turns: rotationAngle1 / (2 * 3.14159),
                                        child: SizedBox(
                                          height: screenHeight * 0.2,
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
                                          color: const Color.fromARGB(
                                              255, 46, 46, 46),
                                          borderRadius:
                                              BorderRadius.circular(7.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTapDown: (_) => setState(() =>
                                                    scaleFactorCliente = 0.90),
                                                onTapUp: (_) => setState(() =>
                                                    scaleFactorCliente = 1.0),
                                                onTap: () {},
                                                child: AnimatedScale(
                                                  scale: scaleFactorCliente,
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  child: Container(
                                                    width: screenHeight * 0.1,
                                                    height: screenWidth * 0.1,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xFF494949),
                                                      shape: BoxShape
                                                          .circle, // Forma circular
                                                    ),
                                                    child: Center(
                                                      child: SizedBox(
                                                        width:
                                                            screenWidth * 0.05,
                                                        height:
                                                            screenHeight * 0.05,
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
                                                    height: screenHeight * 0.1,
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
                                                    height: screenHeight * 0.1,
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
                                                onTapDown: (_) => setState(() =>
                                                    scaleFactorRepeat = 0.90),
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
                                                      color: Colors.transparent,
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
                                                            fit: BoxFit.contain,
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
                                      padding: const EdgeInsets.all(10.0),
                                      height: screenHeight * 0.2,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 46, 46, 46),
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
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
                                                  const Color(0xFF2be4f3),
                                            ),
                                            child: const Text(
                                              'PROGRAMAS',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.005),
                                          Column(children: [
                                            const Text(
                                              "NOMBRE PROGRAMA",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF2be4f3),
                                              ),
                                            ),
                                            Image.asset(
                                              height: screenHeight * 0.06,
                                              'assets/images/cliente.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ]),
                                          SizedBox(width: screenWidth * 0.005),
                                          const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "frecuencia",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              const Text(
                                                "pulso",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: screenWidth * 0.005),
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
                                                fontSize: 13,
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
                                              MainAxisAlignment.start,
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
                                                        height:
                                                            screenHeight * 0.08,
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
                              top: 0, // Distancia desde la parte superior
                              right: 0, // Distancia desde la derecha
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  widget.onBack();
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              if (selectedIndexEquip == 0) ...[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[0] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[0]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[0] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          0], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              0] =
                                                          !_isMusculoTrajeBloqueado[
                                                              0]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 0");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                0]
                                                            ? 'assets/images/pec_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/pecazul.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[0] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          0], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[1] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[1]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[1] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          1], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              1] =
                                                          !_isMusculoTrajeBloqueado[
                                                              1]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 1");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                1]
                                                            ? 'assets/images/biceps_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/bicepsazul.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[1] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          1], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[2] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[2]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[2] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          2], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              2] =
                                                          !_isMusculoTrajeBloqueado[
                                                              2]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 2");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                2]
                                                            ? 'assets/images/abs_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/absazul.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[2] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          2], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[3] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[3]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[3] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          3], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              3] =
                                                          !_isMusculoTrajeBloqueado[
                                                              3]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 3");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                3]
                                                            ? 'assets/images/cua_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/cuazul.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[3] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          3], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[4] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[4]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[4] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          4], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              4] =
                                                          !_isMusculoTrajeBloqueado[
                                                              4]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 4");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                4]
                                                            ? 'assets/images/gemelos_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/gemelosazul.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[4] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          4], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else if (!isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[0] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[0]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[0] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          0], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              0] =
                                                          !_isMusculoTrajeBloqueado[
                                                              0]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 0");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                0]
                                                            ? 'assets/images/pec_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/pec_blanco.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[0] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          0], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[1] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[1]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[1] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          1], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              1] =
                                                          !_isMusculoTrajeBloqueado[
                                                              1]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 1");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                1]
                                                            ? 'assets/images/biceps_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/biceps_blanco.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[1] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          1], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[2] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[2]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[2] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          2], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              2] =
                                                          !_isMusculoTrajeBloqueado[
                                                              2]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 2");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                2]
                                                            ? 'assets/images/abs_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/abs_blanco.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[2] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          2], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[3] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[3]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[3] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          3], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              3] =
                                                          !_isMusculoTrajeBloqueado[
                                                              3]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 3");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                3]
                                                            ? 'assets/images/cua_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/cua_blanco.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[3] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          3], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Contenedor con fondo anaranjado cuando _isMusculoTrajeBloqueado[4] es true
                                          Container(
                                            color: _isMusculoTrajeBloqueado[4]
                                                ? Color(0xFFFFA500)
                                                    .withOpacity(0.3)
                                                : Colors.transparent,
                                            // Fondo anaranjado transparente
                                            child: Row(
                                              children: [
                                                // Botón "Mas" - se deshabilita si _isMusculoTrajeBloqueado[4] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/mas.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          4], // Deshabilitar si es true
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Imagen a la que se le hace el GestureDetector
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isMusculoTrajeBloqueado[
                                                              4] =
                                                          !_isMusculoTrajeBloqueado[
                                                              4]; // Cambia el estado
                                                    });
                                                    print(
                                                        "Imagen tocada en índice 4");
                                                  },
                                                  child: SizedBox(
                                                    width: 70.0,
                                                    height: 70.0,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child: Image.asset(
                                                        _isMusculoTrajeBloqueado[
                                                                4]
                                                            ? 'assets/images/gemelos_naranja.png' // Imagen alternativa cuando es true
                                                            : 'assets/images/gemelos_blanco.png',
                                                        // Imagen original
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.01),
                                                // Botón "Menos" - se deshabilita si _isMusculoTrajeBloqueado[4] es true
                                                CustomIconButton(
                                                  onTap: () {
                                                    setState(() {});
                                                  },
                                                  imagePath:
                                                      'assets/images/menos.png',
                                                  size: 40.0,
                                                  isDisabled:
                                                      _isMusculoTrajeBloqueado[
                                                          4], // Deshabilitar si es true
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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
                                              height: screenHeight * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                            // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                            if (isSessionStarted) ...[
                                              if (_isMusculoTrajeBloqueado[
                                                  0]) ...[
                                                // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_pec_naranja.png",
                                                    // Imagen para el estado bloqueado
                                                    height: screenHeight * 0.4,
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
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity:
                                                            _opacityAnimation
                                                                .value,
                                                        child: Image.asset(
                                                          "assets/images/capa_pecho_azul.png",
                                                          height: screenHeight *
                                                              0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                              // Capa de Bíceps
                                              if (_isMusculoTrajeBloqueado[
                                                  1]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_biceps_naranja.png",
                                                    // Imagen bloqueada para bíceps
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ] else ...[
                                                Positioned(
                                                  top: 0,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _opacityAnimation,
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity:
                                                            _opacityAnimation
                                                                .value,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_azul.png",
                                                          height: screenHeight *
                                                              0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                              // Capa de Abdominales
                                              if (_isMusculoTrajeBloqueado[
                                                  2]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_abs_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ] else ...[
                                                Positioned(
                                                  top: 0,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _opacityAnimation,
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity:
                                                            _opacityAnimation
                                                                .value,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_azul.png",
                                                          height: screenHeight *
                                                              0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],

                                              // Capa de Abdominales
                                              if (_isMusculoTrajeBloqueado[
                                                  3]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_cua_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ] else ...[
                                                Positioned(
                                                  top: 0,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _opacityAnimation,
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity:
                                                            _opacityAnimation
                                                                .value,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_azul.png",
                                                          height: screenHeight *
                                                              0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],

                                              if (_isMusculoTrajeBloqueado[
                                                  4]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_gemelos_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ] else ...[
                                                Positioned(
                                                  top: 0,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _opacityAnimation,
                                                    builder: (context, child) {
                                                      return Opacity(
                                                        opacity:
                                                            _opacityAnimation
                                                                .value,
                                                        child: Image.asset(
                                                          "assets/images/capa_gem_azul.png",
                                                          height: screenHeight *
                                                              0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ] else if (!isSessionStarted) ...[
                                              if (_isMusculoTrajeBloqueado[
                                                  0]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_pec_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
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
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                              if (_isMusculoTrajeBloqueado[
                                                  1]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_biceps_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
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
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                              if (_isMusculoTrajeBloqueado[
                                                  2]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_abs_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
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
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                              if (_isMusculoTrajeBloqueado[
                                                  3]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_cua_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
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
                                                    height: screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ],
                                              if (_isMusculoTrajeBloqueado[
                                                  4]) ...[
                                                Positioned(
                                                  top: 0,
                                                  child: Image.asset(
                                                    "assets/images/capa_gemelos_naranja.png",
                                                    // Imagen bloqueada para abdominales
                                                    height: screenHeight * 0.4,
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
                                                    height: screenHeight * 0.4,
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
                                                // Círculo de progreso
                                                CustomPaint(
                                                  size: const Size(140, 140),
                                                  painter: CirclePainter(
                                                      progress: progress,
                                                      strokeWidth: 20),
                                                ),
                                                // Imagen que se superpone al CustomPainter
                                                Image.asset(
                                                  'assets/images/RELOJ.png',
                                                  // Reemplaza con la ruta de tu imagen
                                                  height: screenHeight * 0.25,
                                                  // Ajusta el tamaño de la imagen
                                                  fit: BoxFit
                                                      .cover, // Ajuste de la imagen
                                                ),
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
                                                              });
                                                            },
                                                      child: Image.asset(
                                                        'assets/images/flecha-arriba.png',
                                                        height:
                                                            screenHeight * 0.04,
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
                                                        color: const Color(
                                                            0xFF2be4f3), // Color para la sección seleccionada
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: isRunning
                                                          ? null
                                                          : () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  time--; // Disminuye el tiempo si es mayor que 1
                                                                  totalTime = time *
                                                                      60; // Actualiza el tiempo total en segundos
                                                                }
                                                              });
                                                            },
                                                      child: Image.asset(
                                                        'assets/images/flecha-abajo.png',
                                                        height:
                                                            screenHeight * 0.04,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            // Barra de progreso lineal
                                            CustomPaint(
                                              size: const Size(100, 30),
                                              painter: LinePainter(
                                                  progress: progress,
                                                  strokeHeight: 10),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            // Barra de progreso secundaria
                                            CustomPaint(
                                              size: const Size(100, 30),
                                              painter: LinePainter2(
                                                  progress: progress,
                                                  strokeHeight: 10),
                                            ),
                                          ],
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Imagen base del avatar
                                            Image.asset(
                                              "assets/images/avatar_post.png",
                                              height: screenHeight * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                            // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                            if (isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_trap_azul.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Dorsales
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_dorsal_azul.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Lumbares
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_lumbar_azul.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Glúteos
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_gluteo_azul.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Isquiotibiales
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_isquio_azul.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ] else if (!isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_trap_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_dorsal_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_lumbar_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_gluteo_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_isquio_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          onTapDown: () {
                                            print(
                                                "Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print(
                                                "Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: screenHeight * 0.1,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
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

                                              // Alterna el estado de la sesión
                                              isSessionStarted =
                                                  !isSessionStarted;
                                              print(
                                                  'isSessionStarted: $isSessionStarted');
                                            });
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorBack,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  // Cambia la imagen según el estado de isRunning
                                                  'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          onTapDown: () {
                                            print(
                                                "Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print(
                                                "Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: screenHeight * 0.1,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isSessionStarted) ...[
                                      // Fila 1
                                      Container(
                                        color: _isMusculoTrajeBloqueado[5]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  5], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[5] =
                                                      !_isMusculoTrajeBloqueado[
                                                          5]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 0");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[5]
                                                        ? 'assets/images/trap_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/trapazul.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  5], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 2
                                      Container(
                                        color: _isMusculoTrajeBloqueado[6]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  6], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[6] =
                                                      !_isMusculoTrajeBloqueado[
                                                          6]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 1");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[6]
                                                        ? 'assets/images/dorsal_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/dorsalazul.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  6], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 3
                                      Container(
                                        color: _isMusculoTrajeBloqueado[7]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  7], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[7] =
                                                      !_isMusculoTrajeBloqueado[
                                                          7]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 2");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[7]
                                                        ? 'assets/images/lumbar_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/lumbarazul.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  7], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 4
                                      Container(
                                        color: _isMusculoTrajeBloqueado[8]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  8], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[8] =
                                                      !_isMusculoTrajeBloqueado[
                                                          8]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 3");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[8]
                                                        ? 'assets/images/gluteo_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/gluteoazul.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  8], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 5
                                      Container(
                                        color: _isMusculoTrajeBloqueado[9]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  9], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[9] =
                                                      !_isMusculoTrajeBloqueado[
                                                          9]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 4");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[9]
                                                        ? 'assets/images/isquio_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/isquioazul.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  9], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else if (!isSessionStarted) ...[
                                      // Fila 1
                                      Container(
                                        color: _isMusculoTrajeBloqueado[5]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  5], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[5] =
                                                      !_isMusculoTrajeBloqueado[
                                                          5]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 0");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[5]
                                                        ? 'assets/images/trap_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/trap_blanco.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  5], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 2
                                      Container(
                                        color: _isMusculoTrajeBloqueado[6]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  6], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[6] =
                                                      !_isMusculoTrajeBloqueado[
                                                          6]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 1");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[6]
                                                        ? 'assets/images/dorsal_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/dorsal_blanco.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  6], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 3
                                      Container(
                                        color: _isMusculoTrajeBloqueado[7]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  7], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[7] =
                                                      !_isMusculoTrajeBloqueado[
                                                          7]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 2");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[7]
                                                        ? 'assets/images/lumbar_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/lumbar_blanco.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  7], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 4
                                      Container(
                                        color: _isMusculoTrajeBloqueado[8]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  8], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[8] =
                                                      !_isMusculoTrajeBloqueado[
                                                          8]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 3");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[8]
                                                        ? 'assets/images/gluteo_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/gluteo_blanco.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  8], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas

                                      // Fila 5
                                      Container(
                                        color: _isMusculoTrajeBloqueado[9]
                                            ? Color(0xFFFFA500).withOpacity(0.3)
                                            : Colors.transparent,
                                        // Fondo anaranjado transparente si bloqueado
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/mas.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  9], // Deshabilitar si es true
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isMusculoTrajeBloqueado[9] =
                                                      !_isMusculoTrajeBloqueado[
                                                          9]; // Cambiar el estado al tocar
                                                });
                                                print(
                                                    "Imagen tocada en índice 4");
                                              },
                                              onLongPress: () {
                                                print(
                                                    "Imagen presionada prolongadamente");
                                              },
                                              child: SizedBox(
                                                width: 70.0,
                                                height: 70.0,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    _isMusculoTrajeBloqueado[9]
                                                        ? 'assets/images/isquio_naranja.png' // Imagen alternativa si bloqueado
                                                        : 'assets/images/isquio_blanco.png',
                                                    // Imagen original
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: screenWidth * 0.01),
                                            CustomIconButton(
                                              onTap: () {
                                                setState(() {});
                                              },
                                              onTapDown: () {
                                                print(
                                                    "Botón presionado"); // Acción al presionar
                                              },
                                              onTapUp: () {
                                                print(
                                                    "Botón soltado"); // Acción al levantar
                                              },
                                              imagePath:
                                                  'assets/images/menos.png',
                                              size: 40.0,
                                              isDisabled: _isMusculoTrajeBloqueado[
                                                  9], // Deshabilitar si es true
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ] else if (selectedIndexEquip == 1) ...[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/biceps_azul_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/absazul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/cuazul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas
                                      // Fila 5
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/gemelosazul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                    ] else if (!isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/biceps_blanco_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/abs_blanco.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/cua_blanco_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      // Espaciado entre filas
                                      // Fila 5
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/gemelo_blanco_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
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
                                              "assets/images/pantalon_frontal.png",
                                              height: screenHeight * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                            // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                            if (isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_biceps_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Abs Inferiores del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_abs_inf_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Abs Superiores del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_abs_sup_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Glúteos del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_cua_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa de Gemelos del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_gem_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ] else if (!isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_biceps_blanco_pantalon.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_abs_inf_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_abs_sup_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_cua_blanco_pantalon.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_gem_blanco_pantalon.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
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
                                                // Círculo de progreso
                                                CustomPaint(
                                                  size: const Size(140, 140),
                                                  painter: CirclePainter(
                                                      progress: progress,
                                                      strokeWidth: 20),
                                                ),
                                                // Imagen que se superpone al CustomPainter
                                                Image.asset(
                                                  'assets/images/RELOJ.png',
                                                  // Reemplaza con la ruta de tu imagen
                                                  height: screenHeight * 0.25,
                                                  // Ajusta el tamaño de la imagen
                                                  fit: BoxFit
                                                      .cover, // Ajuste de la imagen
                                                ),
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
                                                              });
                                                            },
                                                      child: Image.asset(
                                                        'assets/images/flecha-arriba.png',
                                                        height:
                                                            screenHeight * 0.04,
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
                                                        color: const Color(
                                                            0xFF2be4f3), // Color para la sección seleccionada
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: isRunning
                                                          ? null
                                                          : () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  time--; // Disminuye el tiempo si es mayor que 1
                                                                  totalTime = time *
                                                                      60; // Actualiza el tiempo total en segundos
                                                                }
                                                              });
                                                            },
                                                      child: Image.asset(
                                                        'assets/images/flecha-abajo.png',
                                                        height:
                                                            screenHeight * 0.04,
                                                        fit: BoxFit.scaleDown,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            // Barra de progreso lineal
                                            CustomPaint(
                                              size: const Size(100, 30),
                                              painter: LinePainter(
                                                  progress: progress,
                                                  strokeHeight: 10),
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.01),
                                            // Barra de progreso secundaria
                                            CustomPaint(
                                              size: const Size(100, 30),
                                              painter: LinePainter2(
                                                  progress: progress,
                                                  strokeHeight: 10),
                                            ),
                                          ],
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Imagen base del avatar
                                            Image.asset(
                                              "assets/images/pantalon_posterior.png",
                                              height: screenHeight * 0.4,
                                              fit: BoxFit.cover,
                                            ),
                                            // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                            if (isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_lumbar_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa Glúteo Superior del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_glut_sup_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa Glúteo Inferior del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_glut_inf_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                              // Capa Isquios del pantalón
                                              Positioned(
                                                top: 0,
                                                child: AnimatedBuilder(
                                                  animation: _opacityAnimation,
                                                  builder: (context, child) {
                                                    return Opacity(
                                                      opacity: _opacityAnimation
                                                          .value,
                                                      child: Image.asset(
                                                        "assets/images/capa_isquio_azul_pantalon.png",
                                                        height:
                                                            screenHeight * 0.4,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ] else if (!isSessionStarted) ...[
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_lumbar_blanco_pantalon.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_glut_sup_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_glut_inf_blanco.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                // Ajusta la posición de la superposición
                                                child: Image.asset(
                                                  "assets/images/capa_isquio_blanco_pantalon.png",
                                                  // Reemplaza con la ruta de la imagen del músculo
                                                  height: screenHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          onTapDown: () {
                                            print(
                                                "Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print(
                                                "Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: screenHeight * 0.1,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
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

                                              // Alterna el estado de la sesión
                                              isSessionStarted =
                                                  !isSessionStarted;
                                              print(
                                                  'isSessionStarted: $isSessionStarted');
                                            });
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorBack,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  // Cambia la imagen según el estado de isRunning
                                                  'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {});
                                          },
                                          onTapDown: () {
                                            print(
                                                "Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print(
                                                "Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: screenHeight * 0.1,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/lumbar_pantalon_azul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/gluteoazul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/isquioazul.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                    ] else if (!isSessionStarted) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/lumbar_blanco_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/gluteo_blanco.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath:
                                                'assets/images/menos.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              // Acción al tocar
                                              print("Imagen tocada");
                                            },
                                            onLongPress: () {
                                              // Acción al mantener presionado
                                              print(
                                                  "Imagen presionada prolongadamente");
                                            },
                                            child: SizedBox(
                                              width: 70.0,
                                              height: 70.0,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  'assets/images/isquio_blanco_pantalon.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          CustomIconButton(
                                            onTap: () {
                                              setState(() {});
                                            },
                                            onTapDown: () {
                                              print(
                                                  "Botón presionado"); // Acción al presionar
                                            },
                                            onTapUp: () {
                                              print(
                                                  "Botón soltado"); // Acción al levantar
                                            },
                                            imagePath: 'assets/images/mas.png',
                                            size: 40.0,
                                          ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
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
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            width: _isExpanded2
                                                ? screenWidth * 0.2
                                                : 0,
                                            height: screenHeight * 0.2,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 46, 46, 46),
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
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
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          child: Container(
                                            padding: EdgeInsets.all(10.0),
                                            width: _isExpanded3
                                                ? screenWidth * 0.2
                                                : 0,
                                            height: screenHeight * 0.2,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 46, 46, 46),
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Botón de más
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          valueRampa +=
                                                              1.0; // Aumenta el valor en 1.0
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/mas.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Texto con el valor y una 'S' al final
                                                    Text(
                                                      "${valueRampa.toStringAsFixed(1)} S",
                                                      // Formato con 1 decimal y una 'S'
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Botón de menos
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (valueRampa > 0) {
                                                            valueRampa -=
                                                                1.0; // Disminuye el valor en 1.0 si es mayor a 0
                                                          }
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/menos.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Imagen de rampa
                                                    Image.asset(
                                                      'assets/images/RAMPA.png',
                                                      width: screenWidth * 0.04,
                                                      height:
                                                          screenHeight * 0.04,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height:
                                                        screenHeight * 0.005),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Botón de más
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          valueContraction +=
                                                              1.0; // Aumenta el valor en 1.0
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/mas.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Texto con el valor y una 'S' al final
                                                    Text(
                                                      "${valueContraction.toStringAsFixed(1)} S",
                                                      // Formato con 1 decimal y una 'S'
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Botón de menos
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (valueContraction >
                                                              0) {
                                                            valueContraction -=
                                                                1.0; // Disminuye el valor en 1.0 si es mayor a 0
                                                          }
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/menos.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Imagen de rampa
                                                    Image.asset(
                                                      'assets/images/CONTRACCION.png',
                                                      width: screenWidth * 0.04,
                                                      height:
                                                          screenHeight * 0.04,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height:
                                                        screenHeight * 0.005),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // Botón de más
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          valuePause +=
                                                              1.0; // Aumenta el valor en 1.0
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/mas.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Texto con el valor y una 'S' al final
                                                    Text(
                                                      "${valuePause.toStringAsFixed(1)} S",
                                                      // Formato con 1 decimal y una 'S'
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Botón de menos
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (valuePause > 0) {
                                                            valuePause -=
                                                                1.0; // Disminuye el valor en 1.0 si es mayor a 0
                                                          }
                                                        });
                                                      },
                                                      child: SizedBox(
                                                        width: 40.0,
                                                        height: 40.0,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            'assets/images/menos.png',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.01),
                                                    // Imagen de rampa
                                                    Image.asset(
                                                      'assets/images/CONTRACCION.png',
                                                      width: screenWidth * 0.04,
                                                      height:
                                                          screenHeight * 0.04,
                                                    ),
                                                  ],
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
                                      onTap: () {},
                                      child: AnimatedScale(
                                        scale: scaleFactorBack,
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
        ],
      ),
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
