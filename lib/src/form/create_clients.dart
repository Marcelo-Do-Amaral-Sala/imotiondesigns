import 'package:flutter/material.dart';
import 'clients_form.dart'; // Asegúrate de que este archivo esté correctamente importado.

class CreateClients extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  CreateClients({Key? key, required this.onSave}) : super(key: key);

  @override
  _CreateClientsState createState() => _CreateClientsState();
}

class _CreateClientsState extends State<CreateClients>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double scaleFactorTick = 1.0;

  // Mapa para almacenar datos del formulario
  Map<String, dynamic> clientData = {
    'name': '',
    'email': '',
    'gender': '',
    'dateBirth': '',
    'height': 0,
    'weight': 0,
    'phone': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged(Map<String, dynamic> data) {
    setState(() {
      clientData = data; // Almacena todos los datos en un mapa
    });

    // Imprime los datos en la consola
    print('Nombre: ${data['name']}, Email: ${data['email']}, '
        'Género: ${data['gender']}, Fecha de Nacimiento: ${data['dateBirth']}, '
        'Altura: ${data['height']}, Peso: ${data['weight']}, Teléfono: ${data['phone']}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTabBar(),
        _buildTabBarView(),
        //_buildBottomMenu(),
      ],
    );
  }

  Widget _buildTabBar() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenHeight * 0.1,
      width: screenWidth,
      color: Colors.black,
      child: TabBar(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        controller: _tabController,
        tabs: [
          _buildTab('DATOS PERSONALES', 0),
          _buildTab('BONOS', 1),
          _buildTab('GRUPOS ACTIVOS', 2),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        labelColor: const Color(0xFF2be4f3),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: 200,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            decoration: _tabController.index == index
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenHeight * 0.5,
      width: screenWidth,
      child: TabBarView(
        controller: _tabController,
        children: [
          PersonalDataForm(onDataChanged: _onDataChanged), // Integrando PersonalDataForm
          _buildTabContent('Contenido de Opción 2'),
          _buildTabContent('Contenido de Opción 3'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String content) {
    return Center(
      child: Text(content, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildBottomMenu() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.09,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
            onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
            onTapCancel: () => setState(() => scaleFactorTick = 1.0), // Añadido para mejor manejo
            onTap: () {
              // Imprime los datos recogidos al hacer tap en el ícono de tick
              print("Datos recogidos:");
              print(clientData);
            },
            child: AnimatedScale(
              scale: scaleFactorTick,
              duration: const Duration(milliseconds: 100),
              child: SizedBox(
                width: screenWidth * 0.09,
                height: screenHeight * 0.09,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/tick.png',
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}