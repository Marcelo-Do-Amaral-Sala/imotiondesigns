import 'package:flutter/material.dart';

import '../clients/overlays/main_overlay.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "BIOIMPEDANCIA",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: isBodyPro
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Primera columna
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 40.0),
                    // Puedes ajustar el valor de padding según sea necesario
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Image.asset(
                            'assets/images/cliente.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        // OutlinedButton
                        OutlinedButton(
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
                            'SELECCIONAR CLIENTE',
                            style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NOMBRE', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  //controller: _nameController,
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: 'Introducir nombre',
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              Text('GÉNERO', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: DropdownButton<String>(
                                  hint: Text('Seleccione',
                                      style: _dropdownHintStyle),
                                  value: selectedGender,
                                  items: [
                                    DropdownMenuItem(
                                        value: 'Hombre',
                                        child: Text('Hombre',
                                            style: _dropdownItemStyle)),
                                    DropdownMenuItem(
                                        value: 'Mujer',
                                        child: Text('Mujer',
                                            style: _dropdownItemStyle)),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  dropdownColor: const Color(0xFF313030),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF2be4f3), size: 30),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              Text('PESO (kg)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  //controller: _nameController,
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: 'Introducir peso',
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              Text('ALTURA (cm)', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  //controller: _nameController,
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: 'Introducir altura',
                                  ),
                                ),
                              ),
                              Text('E-MAIL', style: _labelStyle),
                              Container(
                                alignment: Alignment.center,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  //controller: _nameController,
                                  style: _inputTextStyle,
                                  decoration: _inputDecorationStyle(
                                    hintText: 'Introducir email',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Vertical Divider
                const VerticalDivider(color: Color(0xFF28E2F5)),

                // Segunda columna
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Imagen centrada en la segunda columna
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Image.asset(
                            'assets/images/leerbio.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        // OutlinedButton
                        OutlinedButton(
                          onPressed:
                              () {}, // Mantener vacío para que InkWell funcione
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
                            'LEER MEDIDA',
                            style: TextStyle(
                              color: Color(0xFF2be4f3),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        const Text(
                          "CÓMO OBTENER UNA BIOMEDIDA",
                          style: TextStyle(
                              color: Color(0xFF28E2F5),
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
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
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
              child: Column(
                children: [
                  const Text(
                    "SÓLO PARA CLIENTES CON",
                    style: TextStyle(
                        color: Color(0xFF28E2F5),
                        fontSize: 25,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  const Text(
                    "CONTACTE CON NOSOTROS PARA OBTENER NUESTRO DISPOSITIVO DE ANÁLISIS DE LA COMPOSICIÓN CORPORAL",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
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
                            const Text(
                              "E-MAIL: info@i-motiongroup.com",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05),
                            const Text(
                              "WHATSAPP: (+34) 649 43 95 14",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
      onClose: widget.onClose,
    );
  }
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
