import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:imotion_designs/src/ajustes/overlays/overlays.dart';
import 'package:platform/platform.dart';

import '../../../utils/translation_utils.dart';
import '../../servicios/licencia_state.dart';

class LicenciaFormView extends StatefulWidget {
  final Function(Map<String, dynamic>) onMciTap;
  final Function() onBack; // Callback para navegar de vuelta
  final double screenWidth;
  final double screenHeight;

  const LicenciaFormView(
      {super.key,
      required this.onBack,
      required this.onMciTap,
      required this.screenWidth,
      required this.screenHeight});

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
  final FocusNode _nLicenciaFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _adressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _provinciaFocus = FocusNode();
  final FocusNode _countryFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  List<Map<String, dynamic>> allMcis = []; // Lista original de clientes
  Map<String, dynamic> licenciaData =
      {}; // Mapa para almacenar la respuesta de la licencia
  List<String> macList = []; // Para almacenar las MACs
  List<String> macBleList = []; // Para almacenar las MACs BLE
  String bloqueada = ''; // Para almacenar si la licencia está bloqueada
  bool _isLicenciaValida = false;
  String cadenaLicencia = '';
  String cadenaEncriptada = '';
  String cadenaCodificada = '';
  String url = '';
  String respuestaServidor = '';
  String estadoBloqueada = '';
  List<String> parsedData = [];
  String licenciaMac = '';
  List<Map<String, dynamic>> mcis = [];
  bool isOverlayVisible = false;
  int overlayIndex = -1;
  String? overlayMac;
  bool? overlayMacBle;
  String? overlayEstado;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus(); // 🔹 Asegurar que no haya focus al abrir la vista
    });
  }

  @override
  void dispose() {
    super.dispose();
    // 🔹 Liberar los FocusNodes
    _nLicenciaFocus.dispose();
    _nameFocus.dispose();
    _adressFocus.dispose();
    _cityFocus.dispose();
    _provinciaFocus.dispose();
    _countryFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();

  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });

    // Imprime el estado de isOverlayVisible después de actualizarlo
    debugPrint('isOverlayVisible después de toggleOverlay: $isOverlayVisible');
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
    // Validar que los campos no estén vacíos
    if (_nLicenciaController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _adressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _provinciaController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "DEBES RELLENAR TODOS LOS CAMPOS",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return; // Salir de la función si hay campos vacíos
    }

    // Si todos los campos están llenos, procedemos con la validación de la licencia
    // Generar la cadena de licencia
    String generatedCadenaLicencia = generarCadenaLicencia();
    setState(() {
      cadenaLicencia = generatedCadenaLicencia;
    });
    print("Cadena de licencia generada: $cadenaLicencia");

    // Encriptar la cadena de licencia
    String encryptedCadena = encrip(generatedCadenaLicencia);
    setState(() {
      cadenaEncriptada = encryptedCadena;
    });
    print("Cadena encriptada: $cadenaEncriptada");

    // Codificar la cadena encriptada para enviarla como parte de la URL
    String encodedCadena = Uri.encodeFull(encryptedCadena);
    setState(() {
      cadenaCodificada = encodedCadena;
      url = "https://imotionems.es/lic2.php?a=$cadenaCodificada";
    });
    print("URL de validación enviada: $url");

    try {
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        // Aquí procesamos la respuesta del servidor
        String respuesta = response.body;
        setState(() {
          respuestaServidor = respuesta;
        });
        print("Respuesta recibida del servidor: $respuesta");

        // Procesar la respuesta del servidor
        Map<String, dynamic> licenciaData = procesarRespuesta(respuesta);

        // Extraer las MCIs del mapa de datos procesados
        List<Map<String, dynamic>> mcis = licenciaData["mcis"];

        // Filtrar las MCIs para eliminar las que tienen la MAC vacía
        mcis = mcis.where((mci) => mci['mac'].isNotEmpty).toList();

        // Verificar que mcis no esté vacío y procesarlo
        if (mcis.isNotEmpty) {
          allMcis = mcis;
          // Actualizar el estado con las MCIs procesadas
          setState(() {
            macList = mcis.map((mci) => mci['mac'] as String).toList();
            macBleList = mcis
                .where((mci) =>
                    mci['macBle'] as bool) // Asegurarse de que sea un bool
                .map((mci) => mci['mac'] as String)
                .toList();
            estadoBloqueada = licenciaData['bloqueada']
                ? "1"
                : "0"; // Convertir bool a String
          });

          print("Información procesada:");
          print(
              "Estado de la licencia: ${estadoBloqueada == '1' ? 'Bloqueada' : 'Activa'}");
          print("Limite semanal: ${licenciaData['limiteSemana']}");
          print("Estado del biomac: ${licenciaData['biomac']}");
          print("Nivel en la nube: ${licenciaData['nivelNube']}");
          print("Sesiones en la nube: ${licenciaData['nubeSesiones']}");
          print("EMS activo: ${licenciaData['emsActivo']}");
          print("MCIs procesadas:");
          mcis.forEach((mci) {
            print(
                "MCI - MAC: ${mci['mac']}, MAC BLOQUEADA: ${mci['macBloqueo'] ? 'Bloqueada' : 'Activa'}, BLE: ${mci['macBle'] ? 'BLE' : 'BT'}, Nombre: ${mci['nombre']}");
          });

          // Marcar la licencia como válida
          setState(() {
            _isLicenciaValida = true;
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
          AppState.instance.bloqueada = estadoBloqueada;
          AppState.instance.licenciaData = licenciaData;

          // Guardar la lista de MCIs en AppState
          AppState.instance.mcis = mcis;

          // Guardar los datos en SharedPreferences
          await AppState.instance.saveState();
        } else {
          print("Las MCIs están vacías o son inválidas.");
        }
      } else {
        print(
            "Error al validar la licencia. Código de estado: ${response.statusCode}");
      }
    } catch (e) {
      print('Excepción al validar la licencia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "LICENCIA NO VÁLIDA",
            style: TextStyle(color: Colors.white, fontSize: 17.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Map<String, dynamic> procesarRespuesta(String respuesta) {
    // Dividimos la respuesta en partes
    List<String> datos = respuesta.split('|');

    // Validación para evitar errores si la respuesta no tiene suficientes elementos
    if (datos.length < 33) {
      print("La respuesta no contiene datos suficientes.");
      return {};
    }

    // Extraer propiedades generales de la licencia
    Map<String, dynamic> licenciaInfo = {
      "limiteSemana": int.tryParse(datos[15]) ?? 0, // Límite semanal
      "bloqueada": datos[16] == "1", // Si la licencia está bloqueada
      "biomac": datos[17], // MAC del lector de bioimpedancia
      "nivelNube": int.tryParse(datos[18]) ?? 0, // Nivel de nube
      "nubeSesiones": int.tryParse(datos[19]) ?? 0, // Sesiones en la nube
      "emsActivo": datos[32] == "1", // Si el EMS está activo
    };

    // Crear una lista para almacenar las MCIs con sus características
    List<Map<String, dynamic>> mcis = [];

    // Iteramos sobre las MCIs (índices 1 al 7 para las MACs)
    for (int i = 0; i < 7; i++) {
      Map<String, dynamic> mci = {
        "mac": datos[1 + i], // MAC del MCI
        "macBloqueo": datos[8 + i] == "1", // Estado de bloqueo (true/false)
        "macBle": datos[20 + i] == "1", // Si es BLE (true/false)
        "nombre": datos[27 + i], // Nombre del MCI
      };
      mcis.add(mci);
    }

    // Añadir las MCIs al mapa de información de la licencia
    licenciaInfo["mcis"] = mcis;

    // Retornamos la información de la licencia procesada
    return licenciaInfo;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.008,
                                        vertical: screenHeight * 0.008,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tr(context, 'Licencia')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: const Color(0xFF28E2F5),
                                                fontSize: 34.sp,
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
          Stack(children: [
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
                          Text(
                            tr(context, 'Datos licencia').toUpperCase(),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2be4f3),
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
                                    Text(
                                        tr(context, 'Nº de licencia')
                                            .toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _nLicenciaController,
                                        focusNode: _nLicenciaFocus, // 🔹 FocusNode asignado
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next, // 🔹 Muestra "Siguiente"
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir nº licencia')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_nameFocus), // 🔹 Mover foco al siguiente campo
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(tr(context, 'Nombre').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _nameController,
                                        focusNode: _nameFocus, // 🔹 FocusNode asignado
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: 'Introducir nombre'),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_adressFocus),
                                      ),

                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(tr(context, 'Dirección').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _adressController,
                                        focusNode: _adressFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir dirección')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_cityFocus),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(tr(context, 'Ciudad').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _cityController,
                                        focusNode: _cityFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir ciudad')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_provinciaFocus),
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
                                    Text(tr(context, 'Provincia').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _provinciaController,
                                        focusNode: _provinciaFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir provincia')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_countryFocus),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(tr(context, 'País').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _countryController,
                                        focusNode: _countryFocus,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir país')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                                      ),

                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(tr(context, 'Teléfono').toUpperCase(),
                                        style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _phoneController,
                                        focusNode: _phoneFocus,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10), // Limita la longitud del teléfono
                                        ],
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir teléfono')),
                                        onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text('E-MAIL', style: _labelStyle),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: _inputDecoration(),
                                      child: TextField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.done, // 🔹 Último campo, muestra "Hecho"
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.deny(RegExp(r'\s')), // 🔹 Evita espacios en blanco
                                        ],
                                        style: _inputTextStyle,
                                        decoration: _inputDecorationStyle(hintText: tr(context, 'Introducir e-mail')),
                                        onSubmitted: (_) => FocusScope.of(context).unfocus(), // 🔹 Cierra el teclado
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.01,
                                      vertical: screenHeight * 0.01,
                                    ),
                                    side: BorderSide(
                                        width: screenWidth * 0.001,
                                        color: const Color(0xFF2be4f3)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    tr(context, 'Validar licencia')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: const Color(0xFF2be4f3),
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (AppState.instance.isLicenciaValida)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screenWidth * 0.01),
                                    child: Text(
                                      tr(context, 'Licencia validada')
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 22.sp,
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
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        // Ajusta el tamaño del Column a su contenido
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // Alinea el texto y el contenedor al inicio
                        children: [
                          Text(
                            tr(context, 'Nº de licencia').toUpperCase(),
                            // Texto fijo
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2be4f3),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.001,
                                  vertical: screenHeight * 0.001,
                                ),
                                child: Column(
                                  children: [
                                    // Encabezado de la tabla
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildCell('MAC'),
                                        buildCell(
                                          tr(context, 'Tipo').toUpperCase(),
                                        ),
                                        buildCell(
                                          tr(context, 'Estado').toUpperCase(),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children:
                                              AppState.instance.mcis.map((row) {
                                            String mac =
                                                row['mac'] ?? ''; // MAC
                                            bool macBle = row['macBle'] ??
                                                false; // macBle
                                            String estado = AppState
                                                        .instance.bloqueada ==
                                                    '1'
                                                ? 'Bloqueada'
                                                : 'Activa'; // Estado basado en la propiedad bloqueada

                                            return Column(
                                              children: [
                                                DataRowWidget(
                                                  mac: mac,
                                                  macBle: macBle,
                                                  estado: estado,
                                                  onTap: () {
                                                    setState(() {
                                                      // Actualizar los valores del overlay
                                                      // Establece las variables del overlay aquí
                                                      overlayMac = mac;
                                                      overlayMacBle = macBle;
                                                      overlayEstado = estado;
                                                      toggleOverlay(
                                                          0); // Llamar a toggleOverlay con el nuevo estado
                                                    });
                                                  },
                                                ),
                                                SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.01),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    )
                                  ],
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
            ),
            if (isOverlayVisible)
              Positioned(
                top: screenHeight * 0.2,
                bottom: screenHeight * 0.2,
                right: screenWidth * 0.1,
                left: screenWidth * 0.1,
                child: Align(
                    alignment: Alignment.center,
                    child: _getOverlayWidget(overlayIndex, overlayMac,
                        overlayMacBle, overlayEstado)),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _getOverlayWidget(
      int overlayIndex, String? mac, bool? macBle, String? estado) {
    switch (overlayIndex) {
      case 0:
        // Verificamos si los valores son nulos y asignamos valores predeterminados
        return OverlayMciInfo(
          mac: mac ?? 'Desconocido',
          // Si mac es nulo, usamos 'Desconocido'
          macBle: macBle ?? false,
          // Si macBle es nulo, usamos false
          estado: estado ?? 'Desconocido',
          // Si estado es nulo, usamos 'Desconocido'
          onClose: () => toggleOverlay(0),
        );
      default:
        return Container(); // Si el índice no es 0, no se muestra nada
    }
  }

  // Función para crear las celdas de la tabla
  Widget buildCell(String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
          vertical: screenHeight * 0.01,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }
}

class DataRowWidget extends StatefulWidget {
  final String mac;
  final bool macBle;
  final String estado;
  final VoidCallback onTap;

  const DataRowWidget({
    super.key,
    required this.mac,
    required this.macBle,
    required this.estado,
    required this.onTap,
  });

  @override
  _DataRowWidgetState createState() => _DataRowWidgetState();
}

class _DataRowWidgetState extends State<DataRowWidget> {
  bool isPressed = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          isPressed = true;
        });

        _timer = Timer(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              isPressed = false;
            });
          }
        });
      },
      child: Stack(
        children: [
          // El contenido principal del DataRowWidget
          Container(
            decoration: BoxDecoration(
              color:
                  isPressed ? Colors.blue.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(255, 3, 236, 244),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCell(widget.mac),
                // Mostrar la MAC
                buildCell(widget.macBle ? 'BLE' : 'BT'),
                // Mostrar el tipo de conexión
                buildCell(widget.estado),
                // Mostrar el estado
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCell(String text) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01, vertical: screenHeight * 0.01),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
      ),
    );
  }
}

// Ajustes de estilos para simplificar
TextStyle get _labelStyle => TextStyle(
    color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold);

TextStyle get _inputTextStyle =>
    TextStyle(color: Colors.white, fontSize: 14.sp);


InputDecoration _inputDecorationStyle(
    {String hintText = '', bool enabled = true}) {
  return InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
    filled: true,
    fillColor: const Color(0xFF313030),
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
    enabled: enabled,
  );
}

BoxDecoration _inputDecoration() {
  return BoxDecoration(
      color: const Color(0xFF313030), borderRadius: BorderRadius.circular(7));
}
