import 'package:flutter/material.dart';
import 'package:imotion_designs/src/info/clients_list_view.dart';

class OverlayContent extends StatefulWidget {
  final String contentType; // Agregamos contentType para decidir qué mostrar
  final VoidCallback onClose;


  const OverlayContent({Key? key, required this.contentType, required this.onClose,}) : super(key: key);

  @override
  _OverlayContentState createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF494949),
        border: Border(bottom: BorderSide(color: Color(0xFF2be4f3), width: 2)),
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
              border: Border(bottom: BorderSide(color:Color(0xFF2be4f3))),
            ),
            child: Stack(
              children: [
                // Texto centrado
                Center(
                  child: Text(
                    widget.contentType == 'listado' ? 'Listado de Clientes' : 'Crear Clientes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, color: Color(0xFF2be4f3)),
                  ),
                ),
                // Imagen a la derecha
                Positioned(
                  right: screenWidth * 0.005, // Espacio desde el borde derecho
                  top: 0, // Alinear verticalmente con el contenedor
                  bottom: 0, // Alinear verticalmente con el contenedor
                  child: IconButton(
                    onPressed: () {
                      // Llama a la función onClose cuando se presione el botón
                      widget.onClose();
                    },
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
           SizedBox(height: screenHeight * 0.02),
          // Contenido dinámico según el tipo
          if (widget.contentType == 'listado')
            Column(
              children: [
                ClientListView(),
                // Fila con dos TextFields y un DropdownButton
                SizedBox(height: screenHeight * 0.02), // Espacio entre el Row y la lista de clientes
              ],
            )
          else if (widget.contentType == 'crear')
            Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para crear cliente
                  },
                  child: const Text('Crear Cliente'),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
