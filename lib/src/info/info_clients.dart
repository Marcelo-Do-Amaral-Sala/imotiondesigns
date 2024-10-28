import 'package:flutter/material.dart';

class InfoClients extends StatefulWidget {
  final Map<String, String> clientData;

  const InfoClients({Key? key, required this.clientData}) : super(key: key);

  @override
  _InfoClientsState createState() => _InfoClientsState();
}

class _InfoClientsState extends State<InfoClients> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      height: screenHeight * 0.45,
      width: screenWidth,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('Contenido de Opción 1'),
          _buildTabContent('Contenido de Opción 2'),
          _buildTabContent('Contenido de Opción 3'),
          _buildTabContent('Contenido de Opción 4'),
          _buildTabContent('Contenido de Opción 5'),
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
      padding: const EdgeInsets.all(2.0),
      height: screenHeight * 0.09,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => scaleFactorRemove = 0.95),
            onTapUp: (_) => setState(() => scaleFactorRemove = 1.0),
            onTap: () {
              print("PAPELARA PULSADA");
            },
            child: AnimatedScale(
              scale: scaleFactorRemove,
              duration: const Duration(milliseconds: 100),
              child: SizedBox(
                width: screenWidth * 0.1,
                height: screenHeight * 0.1,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/papelera.png',
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),
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
                  child:   Image.asset(
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

/*Widget _buildClientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${widget.clientData['id']}', style: TextStyle(color: Colors.white)),
        Text('Nombre: ${widget.clientData['name']}', style: TextStyle(color: Colors.white)),
        Text('Teléfono: ${widget.clientData['phone']}', style: TextStyle(color: Colors.white)),
        Text('Estado: ${widget.clientData['status']}', style: TextStyle(color: Colors.white)),
      ],
    );
  }*/
}
