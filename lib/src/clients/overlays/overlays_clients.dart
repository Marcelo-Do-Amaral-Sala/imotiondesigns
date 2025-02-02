import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/translation_utils.dart';
import '../forms/clients_form.dart';
import '../forms/clients_form_groups.dart';
import '../forms/clients_forms_bonos.dart';
import '../info/clients_activity.dart';
import '../info/clients_bio.dart';
import '../info/clients_bonos.dart';
import '../info/clients_data.dart';
import '../info/clients_groups.dart';
import '../info/clients_list_view.dart';
import '../subtabs/clients_bio_sessions.dart';
import '../subtabs/evolution_subtab.dart';
import 'main_overlay.dart';

class OverlayInfo extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayInfo({Key? key, required this.onClose}) : super(key: key);

  @override
  _OverlayInfoState createState() => _OverlayInfoState();
}

class _OverlayInfoState extends State<OverlayInfo>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? selectedClientData;
  bool isInfoVisible = false;
  late TabController _tabController;
  bool _showBioSubTab = false;
  bool _showEvolutionSubTab = false;
  Map<String, String>? _subTabData;

  void selectClient(Map<String, dynamic> clientData) {
    setState(() {
      selectedClientData = clientData;
      isInfoVisible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: Text(
        tr(context, 'Listado de clientes').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: isInfoVisible && selectedClientData != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTabBar(),
                Expanded(child: _buildTabBarView()),
              ],
            )
          : ClientListView(
              onClientTap: (clientData) {
                selectClient(clientData);
              },
            ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.1, // Ajusta la altura según lo necesites
      color: Colors.black,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _showBioSubTab = false;
            _showEvolutionSubTab = false;
          });
        },
        tabs: [
          _buildTab(tr(context, 'Datos personales').toUpperCase(), 0),
          _buildTab(tr(context, 'Actividad').toUpperCase(), 1),
          _buildTab(tr(context, 'Bonos').toUpperCase(), 2),
          _buildTab(tr(context, 'Bioimpedancia').toUpperCase(), 3),
          _buildTab(tr(context, 'Grupos activos').toUpperCase(), 4),
        ],
        indicator: const BoxDecoration(
          color: Color(0xFF494949),
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        dividerColor: Colors.black,
        labelColor: const Color(0xFF2be4f3),
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white,
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
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
        ClientsData(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
        ClientsActivity(clientDataActivity: selectedClientData!),
        ClientsBonos(clientDataBonos: selectedClientData!),
        _showBioSubTab
            ? _buildBioSubTabView()
            : _showEvolutionSubTab
                ? _buildEvolutionSubTabView()
                : ClientsBio(
                    onClientTap: (clientData) {
                      setState(() {
                        _showBioSubTab = true;
                        _subTabData = clientData;
                      });
                    },
                    clientDataBio: selectedClientData!,
                    onEvolutionPressed: () {
                      setState(() {
                        _showEvolutionSubTab = true;
                        _showBioSubTab = false;
                      });
                    },
                  ),
        ClientsGroups(
          clientData: selectedClientData!,
          onDataChanged: (data) {
            print(data);
          },
          onClose: widget.onClose,
        ),
      ],
    );
  }

  Widget _buildBioSubTabView() {
    final List<Map<String, String>> bioimpedanceData = [
      {
        'feature': 'HIDRATACIÓN SIN GRASA',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      {
        'feature': 'EQUILIBRIO HÍDRICO',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      {
        'feature': 'IMC',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      {
        'feature': 'MASA GRASA',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      {
        'feature': 'MÚSCULO',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      {
        'feature': 'ESQUELETO',
        'value': '54645',
        'ref': '65456',
        'result': '3432',
      },
      // Agrega más datos según sea necesario
    ];

    return BioSessionSubTab(
      bioimpedanceData: bioimpedanceData,
      onClientTap: (clientData) {
        setState(() {
          _showBioSubTab = false;
          _subTabData = clientData;
        });
      },
      selectedClientData: selectedClientData!,
    );
  }

  Widget _buildEvolutionSubTabView() {
    return EvolutionSubTab(
      onClientTap: (clientData) {
        setState(() {
          _showEvolutionSubTab = false;
          _subTabData = clientData;
        });
      },
      selectedClientData: selectedClientData!,
    );
  }
}

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
      title: Text(
        tr(context, 'Crear clientes').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
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
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Aquí defines el ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.01,
                vertical: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, '¡Alerta!').toUpperCase(),
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  tr(context, 'Debes completar el formulario para continuar')
                      .toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side: BorderSide(
                      width: MediaQuery.of(context).size.width * 0.001,
                      color: const Color(0xFF2be4f3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, '¡Entendido!').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: MediaQuery.of(context).size.height *
          0.1, // Ajusta la altura según lo necesites
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
              _buildTab(tr(context, 'Datos personales').toUpperCase(), 0),
              _buildTab(tr(context, 'Bonos').toUpperCase(), 1),
              _buildTab(tr(context, 'Grupos activos').toUpperCase(), 2),
            ],
            indicator: const BoxDecoration(
              color: Color(0xFF494949),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
            ),
            dividerColor: Colors.black,
            labelColor: const Color(0xFF2be4f3),
            labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            unselectedLabelColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Tab(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
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
}
