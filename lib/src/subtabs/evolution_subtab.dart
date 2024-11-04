import 'package:flutter/material.dart';

class EvolutionSubTab extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic>? selectedClientData;

  const EvolutionSubTab({
    Key? key,
    required this.onClientTap,
    this.selectedClientData,
  }) : super(key: key);

  @override
  _EvolutionSubTabState createState() => _EvolutionSubTabState();
}

class _EvolutionSubTabState extends State<EvolutionSubTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: 250, // Ajustar según lo necesario
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildTab('HIDRATACIÓN SIN GRASA', 0),
                _buildTab('EQUILIBRIO HÍDRICO', 1),
                _buildTab('IMC', 2),
                _buildTab('MASA GRASA', 3),
                _buildTab('MÚSCULO', 4),
                _buildTab('SALUD ÓSEA', 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
        child: Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          // Padding vertical para uniformidad
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF494949) : Colors.transparent,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(7.0)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2be4f3) : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              decoration:
                  isSelected ? TextDecoration.underline : TextDecoration.none,
              decorationColor: const Color(0xFF2be4f3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return IndexedStack(
      index: _tabController.index,
      children: [
        _buildTabContent('Contenido de HIDRATACIÓN SIN GRASA'),
        _buildTabContent('Contenido de EQUILIBRIO HÍDRICO'),
        _buildTabContent('Contenido de ÍNDICE DE MASA CORPORAL (IMC)'),
        _buildTabContent('Contenido de MASA GRASA'),
        _buildTabContent('Contenido de MÚSCULO'),
        _buildTabContent('Contenido de SALUD ÓSEA'),
      ],
    );
  }

  Widget _buildTabContent(String content) {
    return Center(
      child: Container(color: Colors.yellow, padding: const EdgeInsets.all(20.0)),
    );
  }
}
