import 'package:flutter/material.dart';
import '../customs/overlay_custom.dart';

class ClientsView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  const ClientsView({super.key, required this.onBack});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  double scaleFactorBack = 1.0;
  double scaleFactorListado = 1.0;
  double scaleFactorCrear = 1.0;

  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '-CLIENTES',
                                        style: TextStyle(
                                          color: Color(0xFF28E2F5),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              buildButton(
                                context,
                                'Listado de clientes',
                                scaleFactorListado,
                                () {
                                  setState(() {
                                    scaleFactorListado = 1.0;
                                    isOverlayVisible = true;
                                    overlayContentType = 'listado';
                                  });
                                },
                                () {
                                  setState(() => scaleFactorListado = 0.95);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              buildButton(
                                context,
                                'Crear clientes',
                                scaleFactorCrear,
                                () {
                                  setState(() {
                                    scaleFactorCrear = 1.0;
                                    isOverlayVisible = true;
                                    overlayContentType = 'crear';
                                  });
                                },
                                () {
                                  setState(() => scaleFactorCrear = 0.95);
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
                                aspectRatio: 1, // Mantiene la proporción
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
                                    setState(() => scaleFactorBack = 0.95),
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
                            if (isOverlayVisible)
                              Positioned.fill(
                                top: screenHeight * 0.12,
                                child: OverlayContent(
                                  contentType: overlayContentType,
                                  onClose: () {
                                    setState(() {
                                      isOverlayVisible = false;
                                      clientData = null;
                                    });
                                  },
                                  clientData: clientData,
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
