import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/translation_utils.dart';
import '../clients/overlays/main_overlay.dart';
import '../db/db_helper.dart';

class OverlayBioimpedancia extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayBioimpedancia({super.key, required this.onClose});

  @override
  _OverlayBioimpedanciaState createState() => _OverlayBioimpedanciaState();
}

class _OverlayBioimpedanciaState extends State<OverlayBioimpedancia>
    with SingleTickerProviderStateMixin {
  bool isBodyPro = true;
  String? selectedGender;
  bool isOverlayVisible = false; // Controla la visibilidad del overlay
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void updateClientData() {
    if (selectedBioClient != null && selectedBioClient!.isNotEmpty) {
      print("Cliente seleccionado: $selectedBioClient");
      setState(() {
        _nameController.text = selectedBioClient!['name'] ?? 'No Name';
        _genderController.text = selectedBioClient!['gender'] ?? '';
        _weightController.text = selectedBioClient!['weight']?.toString() ?? '';
        _heightController.text = selectedBioClient!['height']?.toString() ?? '';
        _emailController.text = selectedBioClient!['email'] ?? '';
      });
    } else {
      print("No se seleccionó un cliente");
    }
  }

  @override
  void dispose() {
    // Limpiamos los controladores al destruir el widget
    _nameController.dispose();
    _genderController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1;

      if (!isOverlayVisible) {
        updateClientData(); // Actualizar datos al cerrar el overlay
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isOverlayVisible
        ? _getOverlayWidget(overlayIndex) // Muestra el overlay si es visible
        : MainOverlay(
            // Muestra el contenido principal si el overlay no es visible
            title: Text(
              tr(context, 'Bioimpedancia').toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2be4f3),
              ),
            ),
            content: isBodyPro ? _buildBodyProContent() : _buildNonProContent(),
            onClose: widget.onClose,
          );
  }

  Widget _buildBodyProContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Primera columna
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.asset(
                    'assets/images/cliente.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      toggleOverlay(0);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, 'Seleccionar cliente').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                          tr(context, 'Nombre').toUpperCase(), _nameController),
                      _buildInputField(tr(context, 'Género').toUpperCase(),
                          _genderController),
                      _buildInputField(tr(context, 'Peso (kg)').toUpperCase(),
                          _weightController),
                      _buildInputField(tr(context, 'Altura (cm)').toUpperCase(),
                          _heightController),
                      _buildInputField('E-MAIL', _emailController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(color: Color(0xFF28E2F5)),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.asset(
                    'assets/images/leerbio.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(10.0),
                    side:
                        const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    tr(context, 'Leer medida').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Text(
                  tr(context, 'Cómo obtener una biomedida').toUpperCase(),
                  style: TextStyle(
                      color: const Color(0xFF28E2F5),
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Image.asset(
                    'assets/images/obtenerBio.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNonProContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SÓLO PARA CLIENTES CON",
            style: TextStyle(
                color: const Color(0xFF28E2F5),
                fontSize: 30.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Image.asset(
              'assets/images/ibodyPro.png',
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Text(
            "CONTACTE CON NOSOTROS PARA OBTENER NUESTRO DISPOSITIVO DE ANÁLISIS DE LA COMPOSICIÓN CORPORAL",
            style: TextStyle(
                color: Colors.white,
                fontSize: 25.sp,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "E-MAIL: info@i-motiongroup.com",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Text(
                      "WHATSAPP: (+34) 649 43 95 14",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle), // Label tal cual
        Container(
          alignment: Alignment.center,
          decoration: _inputDecoration(),
          child: TextField(
            controller: controller,
            style: _inputTextStyle,
            enabled: false,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 10.0), // Padding agregado
              border: InputBorder.none, // Elimina el borde por defecto
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
      ],
    );
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlaySeleccionarClienteBio(
          onClose: () => toggleOverlay(0),
        );
      default:
        return Container();
    }
  }

  // Ajustes de estilos para simplificar
  TextStyle get _labelStyle => TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      TextStyle(color: Colors.white, fontSize: 14.sp);

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}

Map<String, dynamic>?
    selectedBioClient; // Variable global para el programa seleccionado

class OverlaySeleccionarClienteBio extends StatefulWidget {
  final VoidCallback onClose;

  const OverlaySeleccionarClienteBio({super.key, required this.onClose});

  @override
  _OverlaySeleccionarClienteBioState createState() =>
      _OverlaySeleccionarClienteBioState();
}

class _OverlaySeleccionarClienteBioState
    extends State<OverlaySeleccionarClienteBio>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allClients = [];
  List<Map<String, dynamic>> filteredClients = []; // Lista filtrada
  final TextEditingController _clientNameController = TextEditingController();
  String selectedOption = 'Todos';
  List<Map<String, dynamic>> selectedClients =
      []; // Lista de clientes seleccionados

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _clientNameController.addListener(_filterClients);
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      setState(() {
        allClients = clientData; // Asigna a la lista original
        filteredClients = allClients; // Inicializa la lista filtrada
      });
      _filterClients(); // Filtra para mostrar todos los clientes
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  void _filterClients() {
    setState(() {
      String searchText = _clientNameController.text.toLowerCase();

      filteredClients = allClients.where((client) {
        final matchesName = client['name']!.toLowerCase().contains(searchText);
        // Filtra por estado basado en la selección del dropdown
        final matchesStatus =
            selectedOption == 'Todos' || client['status'] == selectedOption;

        return matchesName && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MainOverlay(
      title: Text(
        tr(context, 'Seleccionar cliente').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTextField(
                  tr(context, 'Nombre').toUpperCase(),
                  _clientNameController,
                  tr(context, 'Introducir nombre'),
                ),
                SizedBox(width: screenWidth * 0.05),
                _buildDropdown(),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildDataTable(screenHeight, screenWidth),
          ],
        ),
      ),
      onClose: widget.onClose,
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                filled: true,
                fillColor: const Color(0xFF313030),
                isDense: true,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(context, 'Estado').toUpperCase(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold)),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF313030),
              borderRadius: BorderRadius.circular(7),
            ),
            child: DropdownButton<String>(
              value: selectedOption,
              items: [
                DropdownMenuItem(
                    value: 'Todos',
                    child: Text(tr(context, 'Todos'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Activo',
                    child: Text(tr(context, 'Activo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
                DropdownMenuItem(
                    value: 'Inactivo',
                    child: Text(tr(context, 'Inactivo'),
                        style:
                            TextStyle(color: Colors.white, fontSize: 14.sp))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  _filterClients(); // Filtrar después de seleccionar
                });
              },
              dropdownColor: const Color(0xFF313030),
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF2be4f3), size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(double screenHeight, double screenWidth) {
    return Flexible(
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Encabezado fijo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderCell('ID'),
                  _buildHeaderCell(
                    tr(context, 'Nombre').toUpperCase(),
                  ),
                  _buildHeaderCell(
                    tr(context, 'Teléfono').toUpperCase(),
                  ),
                  _buildHeaderCell(
                    tr(context, 'Estado').toUpperCase(),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Espaciado entre encabezado y filas
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: filteredClients.map((client) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Guardar el cliente seleccionado en la lista global
                              setState(() {
                                selectedBioClient = client;
                              });
                              print('Cliente seleccionado: ${client['name']}');
                              widget.onClose(); // Cerrar el overlay
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 3, 236, 244),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDataCell(
                                      client['id']?.toString() ?? ''),
                                  _buildDataCell(client['name'] ?? ''),
                                  _buildDataCell(
                                      client['phone']?.toString() ?? ''),
                                  _buildDataCell(client['status'] ?? ''),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // Espaciado entre filas
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 15.sp),
        ),
      ),
    );
  }
}
