import 'package:flutter/material.dart';
import 'package:imotion_designs/src/info/clients_list_view.dart';
import '../form/create_clients.dart';
import '../info/info_clients.dart';

// ignore: must_be_immutable
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
        widget.contentType = 'listado'; // Regresa a 'listado' si está en 'info'
        widget.clientData = null;
      });
    } else if (widget.contentType == 'form') {
      setState(() {
        widget.contentType = 'crear'; // Regresa a 'crear' si está en 'form'
      });
    } else {
      widget.onClose(); // Cierra el overlay si no está en ninguna subrama
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
        mainAxisSize: MainAxisSize.max,
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
                            : widget.contentType == 'form'
                                ? 'FORMULARIO DE CLIENTE'
                                : 'CREAR NUEVO CLIENTE',
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
                    onPressed: _handleClose,
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
          // Branch for "listado"
          if (widget.contentType == 'listado')
            Column(
              children: [
                ClientListView(onClientTap: (clientData) {
                  setState(() {
                    widget.contentType = 'info'; // Navigate to 'info' when a client is tapped
                    widget.clientData = clientData;
                  });
                }),
              ],
            )
          // Branch for "crear"
          else if (widget.contentType == 'crear')
            Column(
              children: [
                CreateClients(onSave: (onSave) {
                  setState(() {
                    widget.contentType = 'form'; // Navigate to 'form' after saving
                    widget.clientData = onSave;
                  });
                }),
              ],
            )
          // Sub-branch for 'info' under 'listado'
          else if (widget.contentType == 'info' && widget.clientData != null)
            InfoClients(clientData: widget.clientData!)
          // Sub-branch for 'form' under 'crear'
          else if (widget.contentType == 'form')
            CreateClients(onSave: (onSave) {
              setState(() {
                widget.contentType = 'info'; // Navigate to 'info' after form submission
                widget.clientData = onSave;
              });
            }),
        ],
      ),
    );
  }
}
