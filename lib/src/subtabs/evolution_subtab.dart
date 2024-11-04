import 'package:flutter/material.dart';

class EvolutionSubTab extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic>?
      selectedClientData; // Mantén como Map<String, dynamic>
  const EvolutionSubTab({
    super.key,
    required this.onClientTap,
    this.selectedClientData,
  });

  @override
  _EvolutionSubTabState createState() => _EvolutionSubTabState();
}

class _EvolutionSubTabState extends State<EvolutionSubTab> {
  double scaleFactorBack = 1.0;
  List<Map<String, dynamic>> clients = [];
  bool _showBioSubTab = false;
  bool _showEvolutionSubTab = false;

  @override
  void initState() {
    super.initState();
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
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                height: screenHeight * 0.05,
                width: screenWidth * 0.05,
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
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
        )
      ],
    );
  }
}
