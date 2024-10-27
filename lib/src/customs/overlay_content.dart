import 'package:flutter/material.dart';
import 'package:imotion_designs/src/info/clients_list_view.dart';

import '../info/info_clients.dart';

class OverlayContent extends StatefulWidget {
  late String contentType;
  final VoidCallback onClose;
  late Map<String, String>? clientData;

  OverlayContent({
    Key? key,
    required this.contentType,
    required this.onClose,
    this.clientData,
  }) : super(key: key);

  @override
  _OverlayContentState createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  void _handleClose() {
    if (widget.contentType == 'info') {
      setState(() {
        widget.contentType = 'listado'; // Volver a la lista si está en 'info'
        widget.clientData = null; // Limpiar los datos del cliente
      });
    } else if (widget.contentType == 'crear') {
      setState(() {
        widget.contentType = 'listado'; // Volver a la lista si está en 'crear'
      });
    } else {
      widget.onClose(); // Cerrar completamente el overlay si está en 'listado'
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Color(0xFF494949),
        border: Border.all(color: Color(0xFF2be4f3), width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: screenWidth,
            height: screenHeight * 0.1,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF2be4f3))),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    widget.contentType == 'listado'
                        ? 'LISTADO DE CLIENTES'
                        : widget.contentType == 'info'
                        ? 'FICHA CLIENTE'
                        : 'Crear Clientes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2be4f3),
                    ),
                  ),
                ),
                Positioned(
                  right: screenWidth * 0.005,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    onPressed: _handleClose, // Llama a la función de cierre
                    icon: const Icon(
                      Icons.close_sharp,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.contentType == 'listado')
            Column(
              children: [
                ClientListView(onClientTap: (clientData) {
                  setState(() {
                    widget.contentType = 'info';
                    widget.clientData = clientData;
                  });
                }),
              ],
            )
          else if (widget.contentType == 'crear')
            Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Nombre del Cliente'),
                ),
                SizedBox(height: screenHeight * 0.02),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para crear cliente
                  },
                  child: const Text('Crear Cliente'),
                ),
              ],
            )
          else if (widget.contentType == 'info' && widget.clientData != null)
              InfoClients(clientData: widget.clientData!),
        ],
      ),
    );
  }
}
