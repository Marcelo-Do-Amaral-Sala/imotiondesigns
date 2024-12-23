import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/clients/custom_clients/activity_table_custom.dart';

import '../../../utils/translation_utils.dart';

class ClientsActivity extends StatefulWidget {
  final Map<String, dynamic> clientDataActivity;

  const ClientsActivity({
    super.key,
    required this.clientDataActivity,
  });

  @override
  _ClientsActivityState createState() => _ClientsActivityState();
}

class _ClientsActivityState extends State<ClientsActivity> {
  final _indexController = TextEditingController();
  final _nameController = TextEditingController();
  String? selectedOption;

  double scaleFactorTick = 1.0;
  double scaleFactorRemove = 1.0;

  List<Map<String, String>> allSesions = [
    {
      'date': '12/09/2024',
      'hour': '10:00',
      'bonos': '30',
      'points': '450',
      'ekal': '1230'
    },
    {
      'date': '12/02/2024',
      'hour': '11:00',
      'bonos': '40',
      'points': '460',
      'ekal': '1270'
    },
    {
      'date': '02/09/2023',
      'hour': '13:00',
      'bonos': '35',
      'points': '450',
      'ekal': '1200'
    },
    {
      'date': '01/09/2023',
      'hour': '08:00',
      'bonos': '40',
      'points': '550',
      'ekal': '1030'
    },
    {
      'date': '18/12/2023',
      'hour': '06:30',
      'bonos': '50',
      'points': '500',
      'ekal': '1250'
    },
  ];

  @override
  void initState() {
    super.initState();
    _indexController.text = widget.clientDataActivity['id'] ?? '';
    _nameController.text = widget.clientDataActivity['name'] ?? '';
    selectedOption = widget.clientDataActivity['status'];
  }

  @override
  void dispose() {
    _indexController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.03,
          horizontal: screenWidth * 0.03,
        ),
        child: Column(
          children: [
            // Contenedor para los campos de entrada (ID, NOMBRE, ESTADO)
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: _buildTextField(tr(context, 'Nombre').toUpperCase(),
                        _nameController, false),
                  ),
                  SizedBox(width: screenWidth * 0.05), // Espaciado entre campos
                  // Campo ESTADO
                  Flexible(
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
            ),
            SizedBox(height: screenHeight * 0.05),
            // Contenedor para la tabla de actividades
            Flexible(
              flex: 1,
              child: Container(
                width: screenWidth, // Mantener el ancho completo
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 46, 46),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ActivityTableWidget(activityData: allSesions),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Campo de texto
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
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              filled: true,
              fillColor: const Color(0xFF313030),
              isDense: true,
              enabled: enabled, // Habilitar/deshabilitar el campo
            ),
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
            absorbing: !enabled, // Deshabilitar interacción
            child: DropdownButton<String>(
              hint: Text(
                tr(context, 'Seleccione').toUpperCase(),
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
              // Permitir cambio si está habilitado
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
