import 'package:flutter/material.dart';

class OverlayContent extends StatefulWidget {
  final String contentType; // Agregamos contentType para decidir qué mostrar
  final VoidCallback onClose;

  const OverlayContent({Key? key, required this.contentType, required this.onClose}) : super(key: key);

  @override
  _OverlayContentState createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF494949),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: ,
            color: Colors.red,
            child: Text(
              widget.contentType == 'listado' ? 'Listado de Clientes' : 'Crear Clientes',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
          // Contenido dinámico según el tipo
          if (widget.contentType == 'listado')
            Column(
              children: [
                // Ejemplo de lista de clientes
                for (var client in ['Cliente 1', 'Cliente 2', 'Cliente 3', 'Cliente 4'])
                  ListTile(
                    title: Text(client),
                  ),
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
          ElevatedButton(
            onPressed: () {
              // Llama a la función onClose cuando se presione el botón
              widget.onClose();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
