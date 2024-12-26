import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/overlays/overlays.dart';

import '../../../utils/translation_utils.dart';

class AjustesMenuView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  final Function() onNavigatetoLicencia; // Callback para navegar de vuelta
  final Function() onNavigatetoGestion; // Callback para navegar de vuelta
  final double screenWidth;
  final double screenHeight;

  const AjustesMenuView(
      {super.key,
      required this.onBack,
      required this.onNavigatetoLicencia,
      required this.onNavigatetoGestion,
      required this.screenWidth,
      required this.screenHeight});

  @override
  State<AjustesMenuView> createState() => _AjustesMenuViewState();
}

class _AjustesMenuViewState extends State<AjustesMenuView>
    with SingleTickerProviderStateMixin {
  double scaleFactorBack = 1.0;
  double scaleFactorLicencia = 1.0;
  double scaleFactorCentros = 1.0;
  double scaleFactorBackup = 1.0;
  double scaleFactorIdioma = 1.0;
  double scaleFactorServicio = 1.0;
  double scaleFactorVITA = 1.0;

  bool isOverlayVisible = false;
  int overlayIndex = -1; // -1 indica que no hay overlay visible

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Crear el controlador de animación
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Duración de 0.5 segundos
      vsync: this,
    );

    // Animación de opacidad para simular latencia
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Iniciar la animación de latido, pero solo hacerla una vez (sin repetir)
    _controller.repeat(
        reverse: true,
        period: const Duration(
            milliseconds: 500)); // Reproducir la animación una sola vez

    // Después de 10 segundos, detener la animación y dejar la escala fija
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        // Verifica si el widget sigue montado
        setState(() {
          // Asegurarse de que la animación quede fija en el valor final
          _controller.stop();
          _opacityAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
        });
      }
    });
  }

  void toggleOverlay(int index) {
    if (mounted) {
      // Verifica si el widget sigue montado
      setState(() {
        isOverlayVisible = !isOverlayVisible;
        overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10.0),
                                            width: screenWidth * 0.05,
                                            height: screenHeight * 0.1,
                                            child: Image.asset(
                                              'assets/images/ajustes.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Ajustes')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: const Color(0xFF28E2F5),
                                                fontSize: 32.sp,
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
                                tr(context, 'Licencia').toUpperCase(),
                                scaleFactorLicencia,
                                () {
                                  setState(() {
                                    scaleFactorLicencia = 1;
                                    widget.onNavigatetoLicencia();
                                  });
                                },
                                () {
                                  setState(() => scaleFactorLicencia = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Gestión de centros').toUpperCase(),
                                scaleFactorCentros,
                                () {
                                  setState(() {
                                    scaleFactorCentros = 1;
                                    widget.onNavigatetoGestion();
                                  });
                                },
                                () {
                                  setState(() => scaleFactorCentros = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Copia de seguridad').toUpperCase(),
                                scaleFactorBackup,
                                () {
                                  setState(() {
                                    scaleFactorBackup = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorBackup = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Idioma').toUpperCase(),
                                scaleFactorIdioma,
                                () {
                                  setState(() {
                                    scaleFactorIdioma = 1;
                                    toggleOverlay(1);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorIdioma = 0.90);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                tr(context, 'Servicio técnico').toUpperCase(),
                                scaleFactorServicio,
                                () {
                                  setState(() {
                                    scaleFactorServicio = 1;
                                    toggleOverlay(2);
                                  });
                                },
                                () {
                                  setState(() => scaleFactorServicio = 0.90);
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
                            if (overlayIndex == 2)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _opacityAnimation,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _opacityAnimation.value,
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: const Text(
                                          "¡Nuevo!",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTapDown: (_) => setState(
                                          () => scaleFactorVITA = 0.90),
                                      onTapUp: (_) =>
                                          setState(() => scaleFactorVITA = 1.0),
                                      onTap: () {
                                        setState(() {
                                          isOverlayVisible = false;
                                          toggleOverlay(3);
                                        });
                                      },
                                      child: AnimatedScale(
                                        scale: scaleFactorVITA,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        child: SizedBox(
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.1,
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/mujer.png',
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlay: Esto se coloca fuera del contenido principal y en el centro de la pantalla
          if (isOverlayVisible)
            Positioned(
              // Aplica medidas personalizadas solo para el overlay 3
              top: overlayIndex == 3 ? screenHeight * 0.1 : screenHeight * 0.25,
              // Puedes ajustar estos valores como quieras
              bottom:
                  overlayIndex == 3 ? screenHeight * 0.1 : screenHeight * 0.2,
              left: overlayIndex == 3 ? screenWidth * 0.4 : screenWidth * 0.4,
              right: overlayIndex == 3 ? screenWidth * 0.1 : screenWidth * 0.1,
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
        return OverlayBackup(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlayIdioma(
          onClose: () => toggleOverlay(1),
        );
      case 2:
        return OverlayServicio(
          onClose: () => toggleOverlay(2),
        );
      case 3:
        return OverlayVita(
          onClose: () => toggleOverlay(3),
        );
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
                    style: TextStyle(
                      color: const Color(0xFF28E2F5),
                      fontSize: 22.sp,
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
