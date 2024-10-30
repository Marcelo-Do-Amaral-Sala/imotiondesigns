import 'package:flutter/material.dart';
import '../forms/clients_form.dart';

class CreateClients extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  const CreateClients({Key? key, required this.onSave}) : super(key: key);

  @override
  _CreateClientsState createState() => _CreateClientsState();
}

class _CreateClientsState extends State<CreateClients>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController(initialPage: 0);
    _tabController.addListener(() {
      _pageController.jumpToPage(_tabController.index);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDataChanged(Map<String, dynamic> data) {
    // Convierte los valores a String
    Map<String, String> stringData = {
      'name': data['name']?.toString() ?? '',
      'email': data['email']?.toString() ?? '',
      'gender': data['gender']?.toString() ?? '',
      'dateBirth': data['dateBirth']?.toString() ?? '',
      'height': data['height']?.toString() ?? '',
      'weight': data['weight']?.toString() ?? '',
      'phone': data['phone']?.toString() ?? '',
    };

    // Llama al callback onSave con el mapa convertido
    widget.onSave(stringData);
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.black,
      child: TabBar(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
          fontSize: 16, // Ajusta el tamaño para mejorar la legibilidad
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          decoration: _tabController.index == index
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Deshabilita el deslizamiento
        children: [
          PersonalDataForm(onDataChanged: _onDataChanged),
          _buildTabContent('Contenido de Opción 2'),
          _buildTabContent('Contenido de Opción 3'),
        ],
      ),
    );
  }

  Widget _buildTabContent(String content) {
    return Center(
      child: Text(content, style: const TextStyle(color: Colors.white)),
    );
  }
}
