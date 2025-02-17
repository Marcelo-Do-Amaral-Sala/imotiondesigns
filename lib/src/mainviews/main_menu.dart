import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/ajustes/overlays/overlays.dart';
import 'package:imotion_designs/src/servicios/bluetooth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/translation_utils.dart';
import '../bio/overlay_bio.dart';
import '../db/db_helper.dart';
import '../panel/views/panel_view.dart';
import '../data_management/licencia_state.dart';

class MainMenuView extends StatefulWidget {
  final Function() onNavigateToLogin;
  final Function() onNavigateToPanel;
  final Function() onNavigateToClients;
  final Function() onNavigateToPrograms;
  final Function() onNavigateToAjustes;
  final Function() onNavigateToTutoriales;
  final double screenWidth;
  final double screenHeight;

  const MainMenuView({
    Key? key,
    required this.onNavigateToPanel,
    required this.onNavigateToClients,
    required this.onNavigateToPrograms,
    required this.onNavigateToAjustes,
    required this.onNavigateToTutoriales,
    required this.screenWidth,
    required this.screenHeight,
    required this.onNavigateToLogin,
  }) : super(key: key);

  @override
  State<MainMenuView> createState() => MainMenuViewState();
}

class MainMenuViewState extends State<MainMenuView>
    with SingleTickerProviderStateMixin {
  double scaleFactorBack = 1.0;
  double scaleFactorPanel = 1.0;
  double scaleFactorClient = 1.0;
  double scaleFactorProgram = 1.0;
  double scaleFactorBio = 1.0;
  double scaleFactorTuto = 1.0;
  double scaleFactorAjustes = 1.0;
  bool _isImagesLoaded = false;
  bool isOverlayVisible = false;
  String overlayContentType = '';
  Map<String, String>? clientData;
  int overlayIndex = -1; // -1 indica que no hay overlay visible
  int? userId;
  String? userTipoPerfil;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusScope.of(context).unfocus();
    });
    checkAppState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkUserProfile();
  }

  Future<void> checkAppState() async {
    await AppState.instance.loadState();
    print("Valor de bloqueada: ${AppState.instance.bloqueada}");

    if (_isAppBlocked() && mounted) {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            isBlocked = true;
            isOverlayVisible = true;
            overlayIndex = 2; // Mostrar el overlay de licencia bloqueada
          });
        }
      });
    }
  }

  bool _isAppBlocked() {
    return AppState.instance.bloqueada == "1";
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _validateLicenseAndNavigate() async {
    await AppState.instance.loadState(); // Cargar el estado de la aplicación

    if (AppState.instance.nLicencia.isEmpty) {
      _showLicenseDialog(
          context); // Mostrar el diálogo si la licencia está vacía
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PanelView(
            onBack: () => Navigator.pop(context),
            onReset: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PanelView(
                  onBack: () => Navigator.pop(context),
                  onReset: () {},
                  screenWidth: widget.screenWidth,
                  screenHeight: widget.screenHeight,
                ),
              ),
            ),
            screenWidth: widget.screenWidth,
            screenHeight: widget.screenHeight,
          ),
        ),
      );
    }
  }

  Future<void> _showLicenseDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            // Alto del diálogo
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01,
                vertical: MediaQuery.of(context).size.height * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr(context, 'Aviso').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF28E2F5),
                        fontSize: 30.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF28E2F5),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      tr(context, 'Para usar el panel de control debe validar su licencia'),
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo
                        FocusScope.of(context).unfocus();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLicenseDialog2(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            // Alto del diálogo
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01,
                vertical: MediaQuery.of(context).size.height * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.01,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr(context, 'Aviso').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF28E2F5),
                        fontSize: 30.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF28E2F5),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      tr(context,
                          'Para usar el asistente virtual debe validar su licencia'),
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo
                        FocusScope.of(context).unfocus();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
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
            ),
          ),
        );
      },
    );
  }

  Future<void> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_tipo_perfil');
    print('Datos de inicio de sesión eliminados de SharedPreferences');
  }

  Future<void> checkUserProfile() async {
    // Obtener el userId desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId =
        prefs.getInt('user_id'); // Guardamos el userId en la variable de clase

    if (userId != null) {
      // Obtener el tipo de perfil del usuario usando el userId
      DatabaseHelper dbHelper = DatabaseHelper();
      String? tipoPerfil = await dbHelper.getTipoPerfilByUserId(userId!);
      setState(() {
        userTipoPerfil = tipoPerfil; // Guardamos el tipo de perfil en el estado
      });
    } else {
      // Si no se encuentra el userId en SharedPreferences
      print('No se encontró el userId en SharedPreferences.');

      // Aquí puedes agregar un flujo para navegar al login si no hay usuario
      // widget.onNavigateToLogin();
    }
  }

  void toggleOverlay(int index) {
    setState(() {
      if (isOverlayVisible && overlayIndex == index) {
        // Si el mismo overlay está visible, se cierra
        isOverlayVisible = false;
        overlayIndex = -1;
      } else {
        // Si no, se muestra el nuevo overlay
        isOverlayVisible = true;
        overlayIndex = index;
      }
    });
  }



  Future<void> _logOut(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4, // Ancho máximo
              maxHeight:
                  MediaQuery.of(context).size.height * 0.2, // Alto máximo
            ),
            child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF494949),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF28E2F5),
                    width: MediaQuery.of(context).size.width * 0.001,
                  ),
                ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ('¿${tr(context, 'Cerrar sesión')}?').toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2be4f3),
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:  MediaQuery.of(context).size.width * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Cierra el diálogo sin hacer nada
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2be4f3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: Text(
                            tr(context, 'Cancelar').toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF2be4f3),
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await clearLoginData();
                            setState(() {
                              userId = null;
                              userTipoPerfil = null;
                            });

                            widget.onNavigateToLogin();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            tr(context, 'Cerrar sesión').toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ),
        );
      },
    );
  }


  Future<void> _showMessage(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4, // Ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.4, // Alto del diálogo
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01,
                vertical: MediaQuery.of(context).size.height * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye uniformemente
              crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
              children: [
                Text(
                  tr(context, 'Función en desarrollo').toUpperCase(),
                  style: TextStyle(
                      color: const Color(0xFF28E2F5),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  tr(context, 'Estamos trabajando para ofrecerte esta funcionalidad muy pronto.\nGracias por tu paciencia y apoyo'),
                  style: TextStyle(color: Colors.white, fontSize: 20.sp),
                  textAlign: TextAlign.center,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
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
                              SizedBox(height: screenHeight * 0.05),
                              buildButton(
                                context,
                                'assets/images/panel.png',
                                tr(context, 'Panel de control').toUpperCase(),
                                scaleFactorPanel,
                                    () async {
                                  setState(() => scaleFactorPanel = 1);
                                  _validateLicenseAndNavigate();
                                },
                                () => setState(() => scaleFactorPanel = 0.95),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/cliente.png',
                                tr(context, 'Clientes').toUpperCase(),
                                scaleFactorClient,
                                () {
                                  scaleFactorClient = 1;
                                  widget.onNavigateToClients();
                                },
                                () => setState(() => scaleFactorClient = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/programas.png',
                                tr(context, 'Programas').toUpperCase(),
                                scaleFactorProgram,
                                () {
                                  setState(() {
                                    scaleFactorProgram = 1;
                                    widget.onNavigateToPrograms();
                                  });
                                },
                                () => setState(() => scaleFactorProgram = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/bio.png',
                                tr(context, 'Bioimpedancia').toUpperCase(),
                                scaleFactorBio,
                                () {
                                  setState(() {
                                    scaleFactorBio = 1;
                                    toggleOverlay(0);
                                  });
                                },
                                () => setState(() => scaleFactorBio = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/tutoriales.png',
                                tr(context, 'Tutoriales').toUpperCase(),
                                scaleFactorTuto,
                                () {
                                  setState(() {
                                    scaleFactorTuto = 1;
                                    _showMessage(context);
                                  });
                                },
                                () => setState(() => scaleFactorTuto = 0.90),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              buildButton(
                                context,
                                'assets/images/ajustes.png',
                                tr(context, 'Ajustes').toUpperCase(),
                                scaleFactorAjustes,
                                () {
                                  setState(() {
                                    scaleFactorAjustes = 1;
                                    widget.onNavigateToAjustes();
                                  });
                                },
                                () => setState(() => scaleFactorAjustes = 0.90),
                                isDisabled: userTipoPerfil ==
                                    "Entrenador", // Deshabilitar si el perfil no es "Ambos" ni "Administrador"
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
                            Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorBack = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorBack = 1.0),
                                onTap: () {
                                  _logOut(context);
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
                            if (AppState.instance.nLicencia.isNotEmpty)
                              Positioned(
                              bottom: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTapDown: (_) => setState(() => scaleFactorBack = 0.90),
                                    onTapUp: (_) => setState(() => scaleFactorBack = 1.0),
                                    onTap: () {
                                      toggleOverlay(1);
                                    },
                                    child: AnimatedScale(
                                      scale: scaleFactorBack,
                                      duration: const Duration(milliseconds: 100),
                                      child: SizedBox(
                                        width: widget.screenWidth * 0.1,
                                        height: widget.screenHeight * 0.1,
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/icono-vita.png',
                                            fit: BoxFit.scaleDown,
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
              ],
            ),
          ),
          if (isOverlayVisible)
            Stack(
              children: [
                if (overlayIndex == 2)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {}, // Captura los toques pero no hace nada (bloquea eventos debajo)
                      behavior: HitTestBehavior.opaque, // 🔹 Captura todos los eventos táctiles
                      child: Container(
                        color: Colors.black.withOpacity(0.7), // 🔥 Fondo oscurecido
                      ),
                    ),
                  ),

                // 🔹 Posicionamiento del overlay
                Positioned.fill(
                  top: overlayIndex == 2 ? screenHeight * 0.2 : 0,
                  bottom: overlayIndex == 2 ? screenHeight * 0.2 : 0,
                  left: overlayIndex == 2 ? screenWidth * 0.2 : 0,
                  right: overlayIndex == 2 ? screenWidth * 0.2 : 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: _getOverlayWidget(overlayIndex),
                  ),
                ),
              ],
            ),


        ],
      ),
    );
  }

  Widget _getOverlayWidget(int overlayIndex) {
    switch (overlayIndex) {
      case 0:
        return OverlayBioimpedancia(
          onClose: () => toggleOverlay(0),
        );
      case 1:
        return OverlayVita(
          onClose: () => toggleOverlay(1),
        );
      case 2:
        return OverlayLicenciaBloc(
          onClose: () {
            if (isBlocked) {
              clearLoginData();
              widget.onNavigateToLogin();
            }
            setState(() {
              isOverlayVisible = false;
              overlayIndex = -1;
            });
          },
        );
      default:
        return Container();
    }
  }


  Widget buildButton(BuildContext context, String imagePath, String text,
      double scale, VoidCallback onTapUp, VoidCallback onTapDown,
      {bool isDisabled = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => onTapDown(),
        // Deshabilitar acción si está deshabilitado
        onTapUp: isDisabled ? null : (_) => onTapUp(),
        // Deshabilitar acción si está deshabilitado
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 100), // 🔥 ¡Animación más rápida!
          curve: Curves.easeInToLinear,
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            // Aplica opacidad solo si está deshabilitado
            child: SizedBox(
              width: screenWidth * 0.25,
              height: screenHeight * 0.12,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/recuadro.png',
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: screenWidth * 0.005,
                      vertical: screenHeight * 0.001),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding:  EdgeInsets.only(left: screenWidth*0.01),
                          width: screenWidth * 0.05,
                          height: screenHeight * 0.1,
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              color: const Color(0xFF28E2F5),
                              fontSize: 22.sp,
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
          ),
        ),
      ),
    );
  }
}
