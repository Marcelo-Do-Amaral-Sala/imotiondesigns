import 'package:flutter/material.dart';
import '../info/clients_list_view.dart';
import '../overlayviews/create_clients.dart';
import '../overlayviews/info_clients.dart';

class OverlayContent extends StatefulWidget {
  late String contentType;
  late VoidCallback onClose;
  late Map<String, String>? clientData;

   OverlayContent({
    Key? key,
    required this.contentType,
    required this.onClose,
    required this.clientData,
  }) : super(key: key);

  @override
  _OverlayContentState createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  void _handleClose() {
    setState(() {
      if (widget.contentType == 'info') {
        widget.clientData = null;
        widget.contentType = 'listado';
      } else if (widget.contentType == 'form') {
        widget.contentType = 'crear';
      } else {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF494949),
        border: Border.all(color: const Color(0xFF2be4f3), width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(screenWidth),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Container(
      width: screenWidth,
      height: MediaQuery.of(context).size.height * 0.1,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2be4f3))),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              _getTitle(),
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
    );
  }

  String _getTitle() {
    switch (widget.contentType) {
      case 'listado':
        return 'LISTADO DE CLIENTES';
      case 'info':
        return 'FICHA CLIENTE';
      case 'form':
        return 'FORMULARIO DE CLIENTE';
      case 'crear':
        return 'CREAR NUEVO CLIENTE';
      default:
        return '';
    }
  }

  Widget _buildContent() {
    switch (widget.contentType) {
      case 'listado':
        return ClientListView(onClientTap: (clientData) {
          setState(() {
            widget.clientData = clientData;
            widget.contentType = 'info';
          });
        });
      case 'crear':
        return CreateClients(onSave: (onSave) {
          setState(() {
            widget.clientData = onSave;
            widget.contentType = 'form';
          });
        });
      case 'info':
        return widget.clientData != null ? InfoClients(clientData: widget.clientData!) : SizedBox.shrink();
      case 'form':
        return CreateClients(onSave: (onSave) {
          setState(() {
            widget.clientData = onSave;
            widget.contentType = 'info';
          });
        });
      default:
        return SizedBox.shrink();
    }
  }
}
