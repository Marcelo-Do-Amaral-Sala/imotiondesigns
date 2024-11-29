import 'package:flutter/material.dart';

class PanelView extends StatefulWidget {
  final VoidCallback onBack;

  const PanelView({super.key, required this.onBack});

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  double scaleFactorBack = 1.0;
  double scaleFactorCliente = 1.0;
  double scaleFactorRepeat = 1.0;
  double scaleFactorTrainer = 1.0;

  double rotationAngle = 0.0; // Controla el ángulo de rotación de la flecha
  bool _isExpanded = false;

  int selectedIndexEquip = 0;

  Color selectedColor =
      const Color(0xFF2be4f3); // Color para la sección seleccionada
  Color unselectedColor = const Color(0xFF494949);

  @override
  void initState() {
    super.initState();
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
            color: Colors.white.withOpacity(0.5),
            // Blanco semi-translúcido
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02, horizontal: screenWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF28E2F5),
                                      width: 1, // Grosor del borde
                                    ),
                                    color: Colors.transparent,
                                    // Fondo transparente
                                    borderRadius: BorderRadius.circular(
                                        7), // Borde redondeado, opcional
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Contenedor 1',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors
                                            .blue, // Color del texto, puedes ajustarlo
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF28E2F5),
                                      width: 1, // Grosor del borde
                                    ),
                                    color: Colors.transparent,
                                    // Fondo transparente
                                    borderRadius: BorderRadius.circular(
                                        7), // Borde redondeado, opcional
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Contenedor 2',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors
                                            .blue, // Color del texto, puedes ajustarlo
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {},
                                  // Mantener vacío para que InkWell funcione
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(10.0),
                                    side: const BorderSide(
                                        width: 1.0, color: Color(0xFF2be4f3)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
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
                            color: Colors.green,
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => scaleFactorBack = 0.90),
                                  onTapUp: (_) =>
                                      setState(() => scaleFactorBack = 1.0),
                                  onTap: () {
                                    setState(() {
                                      _isExpanded =
                                          !_isExpanded; // Cambia el estado de expansión
                                      rotationAngle = _isExpanded
                                          ? 3.14159
                                          : 0.0; // Cambia la dirección de la flecha (180 grados)
                                    });
                                  },
                                  child: AnimatedRotation(
                                    duration: const Duration(milliseconds: 200),
                                    turns: rotationAngle / (2 * 3.14159),
                                    // La rotación en turnos (rango de 0 a 1)
                                    child: SizedBox(
                                      height: screenHeight * 0.1,
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/flderecha.png',
                                          // La imagen de la flecha
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: screenWidth * 0.01),
                                // Este AnimatedContainer se expande/contrae en horizontal
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      width:
                                          _isExpanded ? screenWidth * 0.2 : 0,
                                      // Expande en horizontal
                                      height: screenHeight * 0.1,
                                      // Mantiene la altura
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
                                              onTap: () {
                                                // Aquí puedes agregar la acción que se ejecuta cuando se toca el contenedor
                                              },
                                              child: AnimatedScale(
                                                scale: scaleFactorCliente,
                                                duration: const Duration(
                                                    milliseconds: 100),
                                                child: Container(
                                                  width: screenHeight * 0.05,
                                                  // El ancho del contenedor
                                                  height: screenWidth * 0.05,
                                                  // La altura del contenedor, debe ser igual al ancho para un círculo perfecto
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        const Color(0xFF494949),
                                                    shape: BoxShape
                                                        .circle, // Forma circular
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      width: screenWidth * 0.03,
                                                      height:
                                                          screenHeight * 0.03,
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
                                          SizedBox(width: screenWidth * 0.005),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedIndexEquip =
                                                      0; // Sección 1 seleccionada
                                                });
                                              },
                                              child: Container(
                                                width: screenWidth * 0.05,
                                                height: screenHeight * 0.05,
                                                decoration: BoxDecoration(
                                                  color: selectedIndexEquip == 0
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
                                                width: screenWidth * 0.05,
                                                height: screenHeight * 0.05,
                                                decoration: BoxDecoration(
                                                  color: selectedIndexEquip == 1
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
                                          SizedBox(width: screenWidth * 0.005),
                                          Expanded(
                                            child: GestureDetector(
                                              onTapDown: (_) => setState(() =>
                                                  scaleFactorRepeat = 0.90),
                                              onTapUp: (_) => setState(() =>
                                                  scaleFactorRepeat = 1.0),
                                              onTap: () {
                                                // Aquí puedes agregar la acción que se ejecuta cuando se toca el contenedor
                                              },
                                              child: AnimatedScale(
                                                scale: scaleFactorRepeat,
                                                duration: const Duration(
                                                    milliseconds: 100),
                                                child: Container(
                                                  width: screenHeight * 0.05,
                                                  // El ancho del contenedor
                                                  height: screenWidth * 0.05,
                                                  // La altura del contenedor, debe ser igual al ancho para un círculo perfecto
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
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Container(
                                  padding: const EdgeInsets.all(10.0),
                                  // Expande en horizontal
                                  height: screenHeight * 0.15,
                                  // Mantiene la altura
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 46, 46, 46),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {},
                                        // Mantener vacío para que InkWell funcione
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(10.0),
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
                                      SizedBox(width: screenWidth * 0.02),
                                      Column(children: [
                                        const Text(
                                          "NOMBRE PROGRAMA",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF2be4f3),
                                          ),
                                        ),
                                        Image.asset(
                                          height: screenHeight * 0.1,
                                          'assets/images/cliente.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ]),
                                      const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "frecuencia",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          const Text(
                                            "pulso",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      OutlinedButton(
                                        onPressed: () {},
                                        // Mantener vacío para que InkWell funcione
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
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 13,
                                            )),
                                        GestureDetector(
                                          onTapDown: (_) => setState(
                                              () => scaleFactorTrainer = 0.90),
                                          onTapUp: (_) => setState(
                                              () => scaleFactorTrainer = 1.0),
                                          onTap: () {
                                            // Aquí puedes agregar la acción que se ejecuta cuando se toca el contenedor
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorTrainer,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: Container(
                                              // La altura del contenedor, debe ser igual al ancho para un círculo perfecto
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: Center(
                                                child: SizedBox(
                                                  child: Image.asset(
                                                    height: screenHeight * 0.1,
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
                                    SizedBox(width: screenWidth * 0.02),
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
                        Expanded(
                          flex: 4,
                          child: Container(
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    )),
                VerticalDivider(),
                Expanded(
                    flex: 1,
                    child: Column(
                      children: [Text("EXPANDED2")],
                    )),
              ],
            ),
          ),
          // Contenido adicional de la vista (botón de retroceso y demás)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  widget
                                      .onBack(); // Llama al callback para volver a la vista anterior
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorBack,
                                  duration: const Duration(milliseconds: 100),
                                  child: SizedBox(
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                    child: ClipOval(
                                      child: Image.asset(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
