import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/clients/custom_clients/bioimpedancia_table_custom.dart';

import '../../../utils/translation_utils.dart';

class ClientsBio extends StatefulWidget {
  final Function(Map<String, String>) onClientTap;
  final Map<String, dynamic> clientDataBio;
  final VoidCallback onEvolutionPressed; // Callback requerido

  const ClientsBio({
    super.key,
    required this.onClientTap,
    required this.clientDataBio,
    required this.onEvolutionPressed,
  });

  @override
  _ClientsBioState createState() => _ClientsBioState();
}

class _ClientsBioState extends State<ClientsBio> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;

  List<Map<String, String>> allBio = [
    {'date': '11/01/2024', 'hour': '10:20'},
    {'date': '15/02/2024', 'hour': '09:20'},
    {'date': '16/05/2024', 'hour': '12:20'},
    {'date': '19/05/2024', 'hour': '15:20'},
    {'date': '31/01/2024', 'hour': '11:20'},
  ];

  Map<String, String>? _subTabData;

  @override
  void initState() {
    super.initState();
    _indexController.text = widget.clientDataBio['id'] ?? '';
    _nameController.text = widget.clientDataBio['name'] ?? '';
    selectedOption = widget.clientDataBio['status'];
  }

  void _showSession(Map<String, String> clientData) {
    setState(() {
      _subTabData = clientData;
    });
    widget.onClientTap(clientData);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03, // Padding dinámico
        ),
        child: Column(
          children: [
            // Contenedor principal con columnas expandibles
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Fila de campos de texto e ID
                  _buildInputRow(screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  // Fila de bio y botón de evolución
                  _buildBioRow(screenHeight, screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(double screenWidth) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTextField(tr(context, 'Nombre').toUpperCase(),
                _nameController, false), // Deshabilitado
          ),
          SizedBox(width: screenWidth * 0.05), // Espaciado entre campos
          // Campo ESTADO (Dropdown)
          Expanded(
            child: _buildDropdownField(
              tr(context, 'Estado').toUpperCase(),
              selectedOption,
              (value) {
                setState(() {
                  selectedOption = value;
                });
              },
              false, // Deshabilitado
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioRow(double screenHeight, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Contenedor de la bio
        _buildBioContainer(screenHeight, screenWidth),
        SizedBox(width: screenWidth * 0.02), // Espaciado entre bio y botón
        // Botón de evolución
        _buildEvolutionButton(),
      ],
    );
  }

  Widget _buildBioContainer(double screenHeight, double screenWidth) {
    return Flexible(
      // Flexible permite que el Container ocupe una fracción del espacio disponible
      flex: 2,
      // Este valor define cuánta parte del espacio disponible debe ocupar el widget
      child: Container(
        height: screenHeight * 0.5,
        width: screenWidth, // Mantiene el ancho completo de la pantalla
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 46, 46, 46),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BioimpedanciaTableWidget(
            dataRegister: allBio,
            onRowTap: _showSession,
          ),
        ),
      ),
    );
  }

  Widget _buildEvolutionButton() {
    return Expanded(
      flex: 1,
      child: _buildOutlinedButton(
        tr(context, 'Evolución').toUpperCase(),
        widget.onEvolutionPressed, // Llama al callback
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(10.0),
        side: const BorderSide(width: 1.0, color: Color(0xFF2be4f3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF2be4f3),
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo de texto
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Contenedor del campo de texto
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF313030),
            borderRadius: BorderRadius.circular(7),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              filled: true,
              fillColor: const Color(0xFF313030),
              isDense: true,
            ),
            enabled: enabled, // Controla si el TextField está habilitado
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label, String? value, Function(String?) onChanged, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del dropdown
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Contenedor del dropdown
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF313030),
            borderRadius: BorderRadius.circular(7),
          ),
          child: AbsorbPointer(
            absorbing: !enabled,
            // Si no está habilitado, se bloquea la interacción
            child: DropdownButton<String>(
              hint: Text(
                tr(context, 'Seleccione'),
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              value: value,
              items: [
                DropdownMenuItem(
                  value: 'Activo',
                  child: Text(
                    tr(context, 'Activo'),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Inactivo',
                  child: Text(
                    tr(context, 'Inactivo'),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ],
              onChanged: enabled ? onChanged : null,
              // Si no está habilitado, no se puede cambiar
              dropdownColor: const Color(0xFF313030),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF2be4f3),
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
