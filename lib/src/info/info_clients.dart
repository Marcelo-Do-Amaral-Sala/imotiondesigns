import 'package:flutter/material.dart';

class InfoClients extends StatefulWidget {
  final Map<String, String> clientData;

  const InfoClients({Key? key, required this.clientData}) : super(key: key);

  @override
  _InfoClientsState createState() => _InfoClientsState();
}

class _InfoClientsState extends State<InfoClients> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Número de pestañas
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
        children: [
          _buildTabBar(), // Construir el TabBar
          _buildTabBarView(), // Construir el TabBarView
          _buildClientInfo(), // Información del cliente
        ],
      ),
    );
  }

  // Método para construir el TabBar
  // Método para construir el TabBar
  Widget _buildTabBar() {
    return Container(
      color: Colors.black, // Color de fondo negro
      child: TabBar(
        tabs: [
          Tab(text: 'Opción 1'),
          Tab(text: 'Opción 2'),
          Tab(text: 'Opción 3'),
          Tab(text: 'Opción 4'),
        ],
        labelStyle: TextStyle(color: Colors.white), // Color del texto de las pestañas
        indicatorColor: Colors.white, // Color del indicador
      ),
    );
  }


  // Método para construir el TabBarView
  Widget _buildTabBarView() {
    return Container(
      height: 200, // Ajusta la altura según sea necesario
      child: TabBarView(
        children: [
          _buildTabContent('Contenido de Opción 1'),
          _buildTabContent('Contenido de Opción 2'),
          _buildTabContent('Contenido de Opción 3'),
          _buildTabContent('Contenido de Opción 4'),
        ],
      ),
    );
  }

  // Método para construir el contenido de las pestañas
  Widget _buildTabContent(String content) {
    return Center(
      child: Text(content, style: TextStyle(color: Colors.white)),
    );
  }

  // Método para construir la información del cliente
  Widget _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alineación a la izquierda
      children: [
        Text('ID: ${widget.clientData['id']}', style: TextStyle(color: Colors.white)),
        Text('Nombre: ${widget.clientData['name']}', style: TextStyle(color: Colors.white)),
        Text('Teléfono: ${widget.clientData['phone']}', style: TextStyle(color: Colors.white)),
        Text('Estado: ${widget.clientData['status']}', style: TextStyle(color: Colors.white)),
        // Agrega más campos según sea necesario
      ],
    );
  }
}
