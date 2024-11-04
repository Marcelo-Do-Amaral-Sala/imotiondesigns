import 'package:flutter/material.dart';

class MainOverlay extends StatefulWidget {
  final Widget title;
  final Widget content;
  final VoidCallback onClose;

  const MainOverlay({
    Key? key,
    required this.content,
    required this.onClose,
    required this.title,
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
    return isVisible
        ? SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF494949),
          border: Border.all(color: const Color(0xFF2be4f3), width: 2),
          borderRadius: BorderRadius.circular(7),
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
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: closeOverlay,
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.white,
                size: 50,
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
