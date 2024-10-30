import 'package:flutter/material.dart';
import 'package:imotion_designs/src/info/clients_bonos.dart';
import '../info/clients_activity.dart';
import '../info/clients_bio.dart';
import '../info/clients_data.dart';

class InfoClients extends StatefulWidget {
  final Map<String, String> clientData;

  const InfoClients({Key? key, required this.clientData}) : super(key: key);

  @override
  _InfoClientsState createState() => _InfoClientsState();
}

class _InfoClientsState extends State<InfoClients>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  bool _showSubTab = false;
  Map<String, String>? _subTabData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController(initialPage: 0);
    _tabController.addListener(() {
      _pageController.jumpToPage(_tabController.index);
      setState(() {
        _showSubTab = false; // Reiniciar la subpestaña al cambiar de tab
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void onTapClient(Map<String, String> clientData) {
    setState(() {
      _showSubTab = true; // Mostrar subpestaña
      _subTabData = clientData; // Asignar datos a mostrar
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(),
        SizedBox(height: screenHeight * 0.01), // Espaciado adicional
        Expanded(
          child: _buildTabBarView(),
        ),
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
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        controller: _tabController,
        tabs: [
          _buildTab('DATOS PERSONALES', 0),
          _buildTab('ACTIVIDAD', 1),
          _buildTab('BONOS', 2),
          _buildTab('BIOIMPEDANCIA', 3),
          _buildTab('GRUPOS ACTIVOS', 4),
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
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ClientsData(
          clientData: widget.clientData,
          onDataChanged: (data) {
            print(data);
          },
        ),
        ClientsActivity(clientDataActivity: widget.clientData),
        ClientsBonos(clientDataBonos: widget.clientData),
        _showSubTab
            ? _buildSubTabView()
            : ClientsBio(
                onClientTap: onTapClient,
                clientDataBio: widget.clientData,
              ),
        _buildTabContent('Contenido de Opción 5'),
      ],
    );
  }

  Widget _buildTabContent(String content) {
    return Center(
      child: Text(content, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSubTabView() {
    return Center(
      child: Text(
        'Subpestaña: ${_subTabData?['nombre'] ?? 'No disponible'}', // Ejemplo de datos
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
