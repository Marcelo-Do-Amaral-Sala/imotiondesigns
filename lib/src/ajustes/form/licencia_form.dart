import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:platform/platform.dart';

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
  List<String> licenciaData = [];
  String mac = '';       // Para almacenar el valor de MAC
  String macBle = '';    // Para almacenar el valor de MAC BLE
  String bloqueada = ''; // Para almacenar si la licencia está bloqueada

  @override
  void initState() {
    super.initState();
  }

  // Método para detectar el sistema operativo
  String detectarSO() {
    final Platform platform = LocalPlatform(); // Obtenemos la plataforma actual

    if (platform.isWindows) {
      print("Sistema Operativo: Windows");
      return 'WIN';
    } else if (platform.isIOS) {
      print("Sistema Operativo: iOS");
      return 'IOS';
    } else if (platform.isAndroid) {
      print("Sistema Operativo: Android");
      return 'AND';
    } else {
      print("Sistema Operativo: Otro");
      return 'OTRO'; // Para otros SO si es necesario
    }
  }

// Método para generar la cadena de licencia
  String generarCadenaLicencia() {
    String licencia = _nLicenciaController.text;
    String nombre = _nameController.text;
    String direccion = _adressController.text;
    String ciudad = _cityController.text;
    String provincia = _provinciaController.text;
    String pais = _countryController.text;
    String telefono = _phoneController.text;
    String email = _emailController.text;

    String modulo = "imotion21"; // Valor fijo
    String so = detectarSO(); // Detectamos el sistema operativo

    // Imprimimos todos los valores para comprobar que están correctos
    print("Generando cadena de licencia con los siguientes datos:");
    print("Licencia: $licencia");
    print("Nombre: $nombre");
    print("Dirección: $direccion");
    print("Ciudad: $ciudad");
    print("Provincia: $provincia");
    print("País: $pais");
    print("Teléfono: $telefono");
    print("Email: $email");
    print("Módulo: $modulo");
    print("Sistema Operativo: $so");

    // Generamos la cadena de licencia
    String cadenaLicencia =
        "13<#>$licencia<#>$nombre<#>$direccion<#>$ciudad<#>$provincia<#>$pais<#>$telefono<#>$email<#>$modulo<#>$so";

    print("CADENA LICENCIA: $cadenaLicencia");

    return cadenaLicencia; // Aquí se devuelve la cadena codificada
  }

// Método de encriptación (sin cambios)
  String encrip(String wcadena) {
    String xkkk =
        'ABCDE0FGHIJ1KLMNO2PQRST3UVWXY4Zabcd5efghi6jklmn7opqrs8tuvwx9yz(),-.:;@';
    String xkk2 = '[]{}<>?¿!¡*#';
    int wp = 0, wd = 0, we = 0, wr = 0;
    String wa = '', wres = '';
    int wl = xkkk.length;
    var wcont = Random().nextInt(10);

    if (wcadena != '') {
      wres = xkkk.substring(wcont, wcont + 1);
      for (int wx = 0; wx < wcadena.length; wx++) {
        wa = wcadena.substring(wx, wx + 1);
        wp = xkkk.indexOf(wa);
        if (wp == -1) {
          wd = wa.codeUnitAt(0);
          we = wd ~/ wl;
          wr = wd % wl;
          wcont += wr;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkk2.substring(we, we + 1) + xkkk.substring(wcont, wcont + 1);
        } else {
          wcont += wp;
          if (wcont >= wl) {
            wcont -= wl;
          }
          wres += xkkk.substring(wcont, wcont + 1);
        }
      }
    }

    print("Cadena encriptada: $wres"); // Imprime la cadena encriptada
    return wres;
  }

  // Método para validar la licencia usando POST
  Future<void> _validarLicencia() async {
    // 1. Generamos la cadena de licencia
    String cadenaLicencia = generarCadenaLicencia();

    // 2. Encriptamos la cadena de licencia
    String cadenaEncriptada = encrip(cadenaLicencia);

    // 3. Codificamos la cadena encriptada para enviarla como parte de la URL
    String cadenaCodificada = Uri.encodeFull(cadenaEncriptada);

    // URL para la validación (con el parámetro 'a' directamente en la URL)
    String url = "https://imotionems.es/lic2.php?a=$cadenaCodificada";

    print("Enviando solicitud POST a la URL: $url");

    try {
      final response = await http.post(
        Uri.parse(url), // La URL con el parámetro 'a'
      );

      if (response.statusCode == 200) {
        // Aquí procesamos la respuesta del servidor
        String respuesta = response.body;
        print('Respuesta del servidor: $respuesta');
        List<String> parsedData = respuesta.split('|');

        // Actualizamos el estado con solo los datos relevantes
        setState(() {
          mac = parsedData[1];             // MAC
          macBle = parsedData[27];         // MAC BLE
          bloqueada = parsedData[15] == '1' ? 'Sí' : 'No';  // Bloqueada (1 es sí, 0 es no)
        });
      } else {
        print(
            'Error al validar licencia. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción: $e');
    }
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
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
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
                                      keyboardType: TextInputType.text,
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
                            onPressed: _validarLicencia,
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
                        mac.isEmpty
                            ? CircularProgressIndicator()  // Muestra un indicador de carga si no hay datos
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MAC: $mac', style: TextStyle(color:Colors.white),),
                            Text('MAC BLE: $macBle',style: TextStyle(color:Colors.white)),
                            Text('Licencia Bloqueada: $bloqueada',style: TextStyle(color:Colors.white)),
                          ],
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
