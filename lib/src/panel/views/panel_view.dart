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

  bool musculosTrajeSelected = true;
  bool musculosPantalonSelected = true;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                                                        selectedIndexEquip == 0
                                                            ? selectedColor
                                                            : unselectedColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10.0)),
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
                                            Expanded(
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
                                                        selectedIndexEquip == 1
                                                            ? selectedColor
                                                            : unselectedColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0)),
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
                                    // Fila 1
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {
                                             
                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/pecazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 2
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/bicepsazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 3
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 4
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            "assets/images/avatar_frontal.png",
                                            height: screenHeight * 0.4,
                                            fit: BoxFit.cover),
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
                                        Image.asset(
                                            "assets/images/avatar_post.png",
                                            height: screenHeight * 0.4,
                                            fit: BoxFit.cover),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: screenHeight*0.1,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        GestureDetector(
                                          onTap: () {
                                            if (isRunning) {
                                              // Si el temporizador está corriendo, lo pausamos
                                              _pauseTimer();
                                            } else {
                                              // Si el temporizador está pausado, lo iniciamos o reanudamos
                                              _startTimer();
                                            }
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorBack,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  // Cambiar la imagen según el estado de isRunning
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: screenHeight*0.1,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fila 1
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/trapazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 2
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/dorsalazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 3
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/lumbarazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 4
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else if (selectedIndexEquip == 1) ...[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fila 1
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
                                          width: 70.0,
                                          height: 70.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                              'assets/images/bicepsazul.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 3
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 4
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                            "assets/images/avatar_frontal.png",
                                            height: screenHeight * 0.4,
                                            fit: BoxFit.cover),
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
                                        Image.asset(
                                            "assets/images/avatar_post.png",
                                            height: screenHeight * 0.4,
                                            fit: BoxFit.cover),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: screenHeight*0.1,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        GestureDetector(
                                          onTap: () {
                                            if (isRunning) {
                                              // Si el temporizador está corriendo, lo pausamos
                                              _pauseTimer();
                                            } else {
                                              // Si el temporizador está pausado, lo iniciamos o reanudamos
                                              _startTimer();
                                            }
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorBack,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  height: screenHeight * 0.15,
                                                  // Cambiar la imagen según el estado de isRunning
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: screenHeight*0.1,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Fila 1
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Espaciado entre filas
                                    // Fila 4
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
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
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/mas.png',
                                          size: 40.0,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        SizedBox(
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
                                        SizedBox(width: screenWidth * 0.01),
                                        CustomIconButton(
                                          onTap: () {
                                            setState(() {

                                            });
                                          },
                                          onTapDown: () {
                                            print("Botón presionado"); // Acción al presionar
                                          },
                                          onTapUp: () {
                                            print("Botón soltado"); // Acción al levantar
                                          },
                                          imagePath: 'assets/images/menos.png',
                                          size: 40.0,
                                        ),
                                      ],
                                    ),
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

  const CustomIconButton({
    Key? key,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    required this.imagePath,
    this.size = 40.0, // Valor por defecto para el tamaño
  }) : super(key: key);

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double scaleFactor = 1.0; // Factor de escala para la animación

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          scaleFactor = 0.9; // Escala al presionar
        });
        if (widget.onTapDown != null) {
          widget.onTapDown!(); // Llama a la acción de onTapDown si está definida
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
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
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

