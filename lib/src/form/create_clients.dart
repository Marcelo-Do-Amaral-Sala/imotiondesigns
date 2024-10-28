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
  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  int height = 0;
  int weight = 0;
  DateTime dateBirth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged(String name, String email, String phone, String gender,
      int height, int weight, DateTime dateBirth) {
    setState(() {
      this.name = name;
      this.email = email;
      this.phone = phone;
      this.gender = gender;
      this.height = height;
      this.weight = weight;
      this.dateBirth = dateBirth;
    });
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
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.1,
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Tab(
      child: SizedBox(
        width: screenWidth,
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
    return SizedBox(
      height: screenHeight * 0.45,
      child: TabBarView(
        controller: _tabController,
        children: [
          PersonalDataForm(
              onDataChanged: _onDataChanged), // Integrando PersonalDataForm
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
      height: screenHeight * 0.09,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => scaleFactorTick = 0.95),
            onTapUp: (_) => setState(() => scaleFactorTick = 1.0),
            onTapCancel: () => setState(
                () => scaleFactorTick = 1.0), // Añadido para mejor manejo
            onTap: () {
              print("TICK PULSADA");
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
