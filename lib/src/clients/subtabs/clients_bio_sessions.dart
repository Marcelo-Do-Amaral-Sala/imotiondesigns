import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:imotion_designs/src/clients/custom_clients/bio_session_table.dart';

class BioSessionSubTab extends StatefulWidget {
  final List<Map<String, String>> bioimpedanceData;
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic>? selectedClientData;

  const BioSessionSubTab({
    Key? key,
    required this.bioimpedanceData,
    required this.onClientTap,
    required this.selectedClientData,
  }) : super(key: key);

  @override
  _BioSessionSubTabState createState() => _BioSessionSubTabState();
}

class _BioSessionSubTabState extends State<BioSessionSubTab> {
  bool useSides = false;
  double numberOfFeatures = 6;
  bool _showBioSubTab = false;
  bool _showEvolutionSubTab = false;

  @override
  Widget build(BuildContext context) {
    const ticks = [7, 14, 21, 28, 35];
    var features = ["HSG", "EH", "IMC", "MG", "M", "E"];
    var data = [
      [12, 10, 22, 15, 19, 20]
    ];

    features = features.sublist(0, numberOfFeatures.floor());
    data = data
        .map((graph) => graph.sublist(0, numberOfFeatures.floor()))
        .toList();

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    var legend = [
      "HSG: Hidratación Sin Grasa",
      "EH: Equilibrio Hidráulico",
      "IMC: Índice de Masa Corporal",
      "MG: Masa Grasa",
      "M: Masa Muscular",
      "E: Esqueleto"
    ];

    return Column(
      children: [
        // Fila con el botón de retroceso
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
        SizedBox(height: screenHeight * 0.02),

        // Expansión de la interfaz
        Expanded(
          child: Container(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              children: [
                // BioSessionTableWidget ocupará un 50% del espacio disponible
                Expanded(
                  flex: 5,
                  child: BioSessionTableWidget(
                    bioimpedanceData: widget.bioimpedanceData,
                  ),
                ),
                // RadarChart ocupará el 50% del espacio disponible
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1, // Este contenedor se expande verticalmente
                        child: RadarChart.dark(
                          ticks: ticks,
                          features: features,
                          data: data,
                          reverseAxis: true,
                          useSides: true,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: const Color.fromARGB(255, 46, 46, 46),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: legend
                              .map(
                                (text) => Text(
                                  text,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
