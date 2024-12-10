import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:platform/platform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../servicios/licencia_state.dart';
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
  Map<String, dynamic> licenciaData =
      {}; // Mapa para almacenar la respuesta de la licencia
  List<String> macList = []; // Para almacenar las MACs
  List<String> macBleList = []; // Para almacenar las MACs BLE
  String bloqueada = ''; // Para almacenar si la licencia está bloqueada
  bool _isLicenciaValida = false;

  @override
  void initState() {
    super.initState();
    // Cargar el estado desde AppState
    AppState.instance.loadState().then((_) {
      // Una vez cargado el estado, actualizamos la UI
      setState(() {
        // Los controladores ahora contienen los valores cargados desde SharedPreferences
        _nLicenciaController.text = AppState.instance.nLicencia;
        _nameController.text = AppState.instance.nombre;
        _adressController.text = AppState.instance.direccion;
        _cityController.text = AppState.instance.ciudad;
        _provinciaController.text = AppState.instance.provincia;
        _countryController.text = AppState.instance.pais;
        _phoneController.text = AppState.instance.telefono;
        _emailController.text = AppState.instance.email;
      });
    });
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

  Future<void> _validarLicencia() async {
    // 1. Generar la cadena de licencia
    String cadenaLicencia = generarCadenaLicencia();
    print("Cadena de licencia generada: $cadenaLicencia");

    // 2. Encriptar la cadena de licencia
    String cadenaEncriptada = encrip(cadenaLicencia);
    print("Cadena encriptada: $cadenaEncriptada");

    // 3. Codificar la cadena encriptada para enviarla como parte de la URL
    String cadenaCodificada = Uri.encodeFull(cadenaEncriptada);
    String url = "https://imotionems.es/lic2.php?a=$cadenaCodificada";
    print("URL de validación enviada: $url");

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Aquí procesamos la respuesta del servidor
        String respuesta = response.body;
        print("Respuesta recibida del servidor: $respuesta");

        // Verificar si la respuesta está vacía o tiene datos válidos
        if (respuesta.isEmpty) {
          print("La respuesta del servidor está vacía.");
          return;
        }

        // Dividimos la respuesta en partes
        List<String> parsedData = respuesta.split('|');
        print("Datos divididos (parsedData): $parsedData");

        // Limpiar las listas antes de agregar nuevos datos
        macList.clear();
        macBleList.clear();
        licenciaData.clear();

        // Iteramos sobre los datos para extraer la información relevante
        for (int i = 0; i < parsedData.length; i++) {
          String entry = parsedData[i];
          print("Procesando entrada $i: $entry");

          if (entry.contains('=')) {
            String key = entry.split('=')[0];
            String value = entry.split('=')[1];
            print("Clave: $key, Valor: $value");

            // Añadir a las listas o mapas según el tipo de dato
            if (key.contains("mac")) {
              macList.add(value);
              print("MAC encontrada: $value");
            } else if (key.contains("macble")) {
              macBleList.add(value);
              print("MAC BLE encontrada: $value");
            } else if (key == 'bloqueada') {
              bloqueada = value == '1' ? 'Sí' : 'No';
              print("Estado de bloqueada: $bloqueada");
            } else {
              licenciaData[key] = value;
              print("Otro dato encontrado: $key = $value");
            }
          }
        }

        // Después de procesar los datos, actualizamos el estado
        setState(() {
          _isLicenciaValida = true; // Marca la licencia como válida
        });

        // Guardar el estado utilizando AppState
        AppState.instance.nLicencia = _nLicenciaController.text;
        AppState.instance.nombre = _nameController.text;
        AppState.instance.direccion = _adressController.text;
        AppState.instance.ciudad = _cityController.text;
        AppState.instance.provincia = _provinciaController.text;
        AppState.instance.pais = _countryController.text;
        AppState.instance.telefono = _phoneController.text;
        AppState.instance.email = _emailController.text;
        AppState.instance.isLicenciaValida = _isLicenciaValida;
        AppState.instance.macList = macList;
        AppState.instance.macBleList = macBleList;
        AppState.instance.bloqueada = bloqueada;
        AppState.instance.licenciaData = licenciaData;

        // Guardar los datos en SharedPreferences
        await AppState.instance.saveState();

      } else {
        print("Error al validar la licencia. Código de estado: ${response.statusCode}");
      }
    } catch (e) {
      print('Excepción al validar la licencia: $e');
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                onPressed: _validarLicencia,
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
                              // Si la licencia es válida, mostrar el mensaje
                              if (AppState.instance.isLicenciaValida)
                                const Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    'LICENCIA VALIDADA',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
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
