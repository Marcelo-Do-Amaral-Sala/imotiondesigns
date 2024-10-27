import 'package:flutter/material.dart';

class ClientForm extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  ClientForm({Key? key, required this.onSave}) : super(key: key);

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

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
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveClient() {
    // Creamos un mapa con los datos del cliente
    final clientData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
    };
    widget.onSave(clientData); // Pasamos los datos al padre
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildTabBar(),
        _buildTabBarView(),
        _buildBottomMenu(),
      ],
    );
  }

  Widget _buildTabBar() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            decoration: _tabController.index == index ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.34,
      width: screenWidth,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('Contenido de Opción 1'),
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
    return Container(
      padding: EdgeInsets.all(10.0),
      height: screenHeight * 0.1,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
            onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
            onTap: () {
              print("TICK PULSADA");
            },
            child: AnimatedScale(
              scale: scaleFactorTick,
              duration: const Duration(milliseconds: 100),
              child: SizedBox(
                width: screenWidth * 0.1,
                height: screenHeight * 0.1,
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
