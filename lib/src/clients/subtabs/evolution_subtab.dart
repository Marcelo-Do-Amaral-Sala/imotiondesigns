import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EvolutionSubTab extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic>? selectedClientData;

  const EvolutionSubTab({
    super.key,
    required this.onClientTap,
    this.selectedClientData,
  });

  @override
  _EvolutionSubTabState createState() => _EvolutionSubTabState();
}

class _EvolutionSubTabState extends State<EvolutionSubTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showBioSubTab = false;
  bool _showEvolutionSubTab = false;

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.selectedClientData != null) {
                  // Convertir Map<String, dynamic> a Map<String, String>
                  Map<String, String> clientData = widget.selectedClientData!
                      .map((key, value) => MapEntry(key, value.toString()));
                  widget.onClientTap(clientData);
                  setState(() {
                    _showBioSubTab = true;
                    _showEvolutionSubTab = false;
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                height: screenHeight * 0.08,
                width: screenWidth * 0.08,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/back.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                flex: 2, // Esto asigna un 20% del ancho disponible al TabBar
                child: _buildTabBar(),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.03,
              ),
              Flexible(
                flex: 8, // El contenido ocupa el 80% del ancho
                child: _buildTabBarView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          bottom: 10.0,
        ),
        child: Container(
          color: Colors.black, // Fondo negro para la barra
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // Distribuir uniformemente las pestañas
            children: [
              _buildTab('HIDRATACIÓN SIN GRASA', 0),
              _buildTab('EQUILIBRIO HÍDRICO', 1),
              _buildTab('IMC', 2),
              _buildTab('MASA GRASA', 3),
              _buildTab('MÚSCULO', 4),
              _buildTab('SALUD ÓSEA', 5),
            ],
          ),
        ));
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
        padding: const EdgeInsets.only(left: 20.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF494949) : Colors.transparent,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(7.0)),
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
        _buildTabContent('Contenido de HIDRATACIÓN SIN GRASA',
            _generateSampleDataHidratacion()),
        _buildTabContent(
            'Contenido de EQUILIBRIO HÍDRICO', _generateSampleDataEquilibrio()),
        _buildTabContent('Contenido de IMC', _generateSampleDataIMC()),
        _buildTabContent(
            'Contenido de MASA GRASA', _generateSampleDataMasaGrasa()),
        _buildTabContent('Contenido de MÚSCULO', _generateSampleDataMusculo()),
        _buildTabContent(
            'Contenido de SALUD ÓSEA', _generateSampleDataSaludOsea()),
      ],
    );
  }

  Widget _buildTabContent(String content, List<FlSpot> spots) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Ene');
                      case 1:
                        return const Text('Feb');
                      case 2:
                        return const Text('Mar');
                      case 3:
                        return const Text('Abr');
                      case 4:
                        return const Text('May');
                      case 5:
                        return const Text('Jun');
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Excelente',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                      case 20:
                        return const Text('Muy bien',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                      case 40:
                        return const Text('Normal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                      case 60:
                        return const Text('Cerca de la norma',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                      case 80:
                        return const Text('A vigilar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                      case 100:
                        return const Text('A tratar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ));
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white, width: 1),
            ),
            minX: 0,
            maxX: 5,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF2be4f3),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2be4f3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                aboveBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, 50),
                  FlSpot(5, 50), // Dibuja una línea horizontal a 50
                ],
                isCurved: false,
                color: Colors.white,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                aboveBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSampleDataHidratacion() {
    return [
      FlSpot(0, 10),
      FlSpot(1, 30),
      FlSpot(2, 60),
      FlSpot(3, 90),
      FlSpot(4, 40),
      FlSpot(5, 80),
    ];
  }

  List<FlSpot> _generateSampleDataEquilibrio() {
    return [
      FlSpot(0, 20),
      FlSpot(1, 40),
      FlSpot(2, 80),
      FlSpot(3, 60),
      FlSpot(4, 30),
      FlSpot(5, 70),
    ];
  }

  List<FlSpot> _generateSampleDataIMC() {
    return [
      FlSpot(0, 30),
      FlSpot(1, 50),
      FlSpot(2, 90),
      FlSpot(3, 30),
      FlSpot(4, 20),
      FlSpot(5, 40),
    ];
  }

  List<FlSpot> _generateSampleDataMasaGrasa() {
    return [
      FlSpot(0, 40),
      FlSpot(1, 60),
      FlSpot(2, 20),
      FlSpot(3, 80),
      FlSpot(4, 50),
      FlSpot(5, 10),
    ];
  }

  List<FlSpot> _generateSampleDataMusculo() {
    return [
      FlSpot(0, 50),
      FlSpot(1, 20),
      FlSpot(2, 40),
      FlSpot(3, 70),
      FlSpot(4, 90),
      FlSpot(5, 60),
    ];
  }

  List<FlSpot> _generateSampleDataSaludOsea() {
    return [
      FlSpot(0, 60),
      FlSpot(1, 30),
      FlSpot(2, 70),
      FlSpot(3, 20),
      FlSpot(4, 10),
      FlSpot(5, 50),
    ];
  }
}
