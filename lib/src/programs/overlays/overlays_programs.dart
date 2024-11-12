import 'package:flutter/material.dart';
import 'package:imotion_designs/src/programs/info_programs/programs_list_view.dart';

import '../../clients/overlays/main_overlay.dart';

class OverlayIndividuales extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayIndividuales({Key? key, required this.onClose})
      : super(key: key);

  @override
  _OverlayIndividualesState createState() => _OverlayIndividualesState();
}

class _OverlayIndividualesState extends State<OverlayIndividuales>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedProgram;
  bool isInfoVisible = false;

  void selectProgram(Map<String, dynamic> programData) {
    setState(() {
      selectedProgram = programData;
      isInfoVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "INDIVIDUALES",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedProgram != null
          ? Column()
          : ProgramsListView(
              onProgramTap: (programData) {
                selectProgram(programData);
              },
            ),
      onClose: widget.onClose,
    );
  }
}
/*
class OverlayCrear extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayCrear({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayCrearState createState() => _OverlayCrearState();
}

class _OverlayCrearState extends State<OverlayCrear>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isClientSaved = false; // Variable to check if the client has been saved
  Map<String, dynamic>?
      selectedClientData; // Nullable Map, no late initialization required

  final GlobalKey<PersonalDataFormState> _personalDataFormKey =
      GlobalKey<PersonalDataFormState>();

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: const Text(
        "CREAR CLIENTE",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
      onClose: widget.onClose,
    );
  }

  Future<void> _showAlert(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF494949),
          title: const Text(
            '¡ALERTA!',
            style: TextStyle(
                color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Debes completar el formulario para continuar',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2be4f3)),
                  ),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(color: Color(0xFF2be4f3)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 60,
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          if (!isClientSaved) {
            _showAlert(context);
          }
        },
        child: AbsorbPointer(
          absorbing: !isClientSaved,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index != 0 && !isClientSaved) {
                return; // Don't switch tabs if not saved
              } else {
                setState(() {
                  _tabController.index = index;
                });
              }
            },
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
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white,
          ),
        ),
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
    return IndexedStack(
      index: _tabController.index,
      children: [
        PersonalDataForm(
          key: _personalDataFormKey,
          onDataChanged: (data) {
            print(data); // Verify that the data is arriving correctly
            setState(() {
              isClientSaved = true; // Client has been saved
              selectedClientData = data; // Save the client data
            });
          },
        ),
        // Check if selectedClientData is not null before passing it to ClientsFormBonos
        selectedClientData != null
            ? ClientsFormBonos(clientDataBonos: selectedClientData!)
            : Center(child: Text("No client data available.")),
        selectedClientData != null
            ? ClientsFormGroups(
                onDataChanged: (data) {
                  print(data); // Handle changed data
                },
                onClose: widget.onClose,
                clientDataGroups: selectedClientData!,
              )
            : Center(child: Text("No client data available.")),
      ],
    );
  }
}*/
