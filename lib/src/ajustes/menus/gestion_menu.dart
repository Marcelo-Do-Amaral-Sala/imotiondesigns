import 'package:flutter/material.dart';
import 'package:imotion_designs/src/ajustes/overlays/overlays.dart';
import 'package:imotion_designs/src/programs/overlays/overlays_programs.dart';

class GestionMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  const GestionMenuView({super.key, required this.onBack});

  @override
  State<GestionMenuView> createState() => _GestionMenuViewState();
}

class _GestionMenuViewState extends State<GestionMenuView> {
  double scaleFactorBack = 1.0;
  double scaleFactorAdmins= 1.0;
  double scaleFactorLista= 1.0;
  double scaleFactorCrear = 1.0;
  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  @override
  void initState() {
    super.initState();
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido principal
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
                      // Contenedor de los botones
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.15,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/recuadro.png',
                                      fit: BoxFit.fill,
                                    ),
                                    const Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "GESTIÓN DE CENTROS",
                                              style: TextStyle(
                                                color: Color(0xFF28E2F5),
                                                fontSize: 26,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              buildButton(
                                context,
                                'Administradores',
                                scaleFactorAdmins,
                                    () {
                                  setState(() {
                                    scaleFactorAdmins = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorAdmins = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Lista de entrenadores',
                                scaleFactorLista,
                                    () {
                                  setState(() {
                                    scaleFactorLista = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorLista = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Crear nuevo',
                                scaleFactorCrear,
                                    () {
                                  setState(() {
                                    scaleFactorCrear = 1;
                                  });
                                },
                                    () {
                                  setState(() => scaleFactorCrear = 0.90);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
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

          // Overlay: Esto se coloca fuera del contenido principal y en el centro de la pantalla
          if (isOverlayVisible)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: _getOverlayWidget(overlayIndex),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlayAdmins(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlayTrainers(
          onClose: () => toggleOverlay(1),
        );
      /*case 2:
        return OverlayServicio(
          onClose: () => toggleOverlay(2),
        );*/
      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
  }

  Widget buildButton(BuildContext context, String text, double scale,
      VoidCallback onTapUp, VoidCallback onTapDown) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTapDown: isOverlayVisible ? null : (_) => onTapDown(),
        onTapUp: isOverlayVisible ? null : (_) => onTapUp(),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/recuadro.png',
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF28E2F5),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
