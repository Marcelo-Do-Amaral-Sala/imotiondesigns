import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../custom/licencia_table_widget.dart';

class LicenciaFormView extends StatefulWidget {
  final Function() onBack; // Callback para navegar de vuelta
  const LicenciaFormView({super.key, required this.onBack});

  @override
  State<LicenciaFormView> createState() => _LicenciaFormViewState();
}

class _LicenciaFormViewState extends State<LicenciaFormView> {
  double scaleFactorBack = 1.0;
  final _nLicenciaController = TextEditingController();
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _adressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> allLicencias = []; // Lista original de clientes

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.07,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.15,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/recuadro.png',
                                      fit: BoxFit.fill,
                                    ),
                                    const Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              "LICENCIA",
                                              style: TextStyle(
                                                color: Color(0xFF28E2F5),
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  widget
                                      .onBack(); // Llama al callback para volver a la vista anterior
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorBack,
                                  duration: const Duration(milliseconds: 100),
                                  child: SizedBox(
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/back.png',
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Aquí agregamos un nuevo Expanded que ocupe el espacio restante debajo
          Positioned(
            top: screenHeight * 0.25,
            // Ajusta este valor según lo que necesites
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.05,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna que contiene los dos primeros Expanded y el botón
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'DATOS LICENCIA', // Texto fijo
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2be4f3),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            // Primer Expanded: Formulario izquierdo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nº DE LICENCIA', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _nLicenciaController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir nº licencia'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('NOMBRE', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _nameController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir nombre'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('DIRECCIÓN', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _adressController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir dirección'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('CIUDAD', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _cityController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir ciudad'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            // Segundo Expanded: Formulario derecho
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PROVINCIA', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _provinciaController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir provincia'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('PAÍS', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _countryController,
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir país'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('TELÉFONO', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir teléfono'),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text('E-MAIL', style: _labelStyle),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: _inputDecoration(),
                                    child: TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s')),
                                      ],
                                      style: _inputTextStyle,
                                      decoration: _inputDecorationStyle(
                                          hintText: 'Introducir e-mail'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // OutlinedButton debajo de los dos Expanded
                        Center(
                          child: OutlinedButton(
                            onPressed: () {},
                            // Mantener vacío para que InkWell funcione
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(10.0),
                              side: const BorderSide(
                                  width: 1.0, color: Color(0xFF2be4f3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text(
                              'VALIDAR LICENCIA',
                              style: TextStyle(
                                color: Color(0xFF2be4f3),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // Ajusta el tamaño del Column a su contenido
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // Alinea el texto y el contenedor al inicio
                      children: [
                        const Text(
                          'Nº DE LICENCIA', // Texto fijo
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2be4f3),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(
                          // Asegura que el Container ocupe el espacio restante
                          child: SizedBox(
                            width: double.infinity, // Ancho completo
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: LicenciaTableWidget(
                                data: allLicencias,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ajustes de estilos para simplificar
  TextStyle get _labelStyle => const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold);

  TextStyle get _inputTextStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownHintStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  TextStyle get _dropdownItemStyle =>
      const TextStyle(color: Colors.white, fontSize: 14);

  InputDecoration _inputDecorationStyle(
      {String hintText = '', bool enabled = true}) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      filled: true,
      fillColor: const Color(0xFF313030),
      isDense: true,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      enabled: enabled,
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
        color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
  }
}
