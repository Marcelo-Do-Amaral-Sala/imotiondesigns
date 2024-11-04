import 'package:flutter/material.dart';
import '../info/clients_list_view.dart';
import '../overlayviews/create_clients.dart';
import '../overlayviews/info_clients.dart';

// ignore: must_be_immutable
class OverlayContent extends StatefulWidget {
  String contentType;
  final VoidCallback onClose;
  Map<String, String>?
      clientData; // Cambié 'final' a 'var' o 'Map<String, String>?'

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
    return SizedBox.expand(
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
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
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
            child: Text(
              _getTitle(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2be4f3),
              ),
            ),
          ),
          Positioned(
            right: 0,
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
            //widget.clientData = clientData;
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
        return widget.clientData != null
            ? InfoClients(clientData: widget.clientData!)
            : const SizedBox.shrink();
      case 'form':
        return CreateClients(onSave: (onSave) {
          setState(() {
            widget.clientData = onSave;
            widget.contentType = 'info';
          });
        });
      default:
        return const SizedBox.shrink();
    }
  }
}
