import 'package:flutter/material.dart';

class MainOverlay extends StatefulWidget {
  final Widget title;
  final Widget content;
  final VoidCallback onClose;
  final bool isChangePwdView;

  const MainOverlay({
    Key? key,
    required this.content,
    required this.onClose,
    required this.title,  this.isChangePwdView = false,
  }) : super(key: key);

  @override
  _MainOverlayState createState() => _MainOverlayState();
}

class _MainOverlayState extends State<MainOverlay> {
  bool isVisible = true;

  void closeOverlay() {
    setState(() {
      isVisible = false;
    });
    widget.onClose(); // Llama a la función onClose pasada desde el padre
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return isVisible
        ? Center( // Esto asegura que el overlay se coloque en el centro
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF494949),
          border: Border.all(color: const Color(0xFF2be4f3), width: screenWidth*0.002),
          borderRadius: BorderRadius.circular(7),
        ),
        // Ajusta el tamaño del contenedor con un width y height
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, // 80% del ancho de la pantalla
          maxHeight: MediaQuery.of(context).size.height * 0.9, // 60% de la altura de la pantalla
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()), // Aquí se llama a _buildContent
          ],
        ),
      ),
    )
        : const SizedBox.shrink(); // No muestra nada si no es visible
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2be4f3))),
      ),
      child: Stack(
        children: [
          Center(
            child: widget.title,
          ),
          if (!widget.isChangePwdView) // Mostrar el botón solo si isChangePwdView es false
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                onPressed: closeOverlay,
                icon:  Icon(
                  Icons.close_sharp,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height*0.06,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(child: widget.content); // Muestra el contenido pasado
  }
}
