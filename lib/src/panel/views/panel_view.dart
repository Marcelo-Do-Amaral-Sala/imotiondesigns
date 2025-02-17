import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/translation_utils.dart';
import '../../data_management/licencia_state.dart';
import '../../data_management/provider.dart';
import '../../servicios/bluetooth.dart';
import '../custom/border_neon.dart';
import 'dashboard_controls.dart';

class PanelView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onReset; // Nuevo callback para reiniciar
  final double screenWidth;
  final double screenHeight;

  const PanelView(
      {super.key,
        required this.onBack,
        required this.onReset,
        required this.screenWidth,
        required this.screenHeight});

  @override
  State<PanelView> createState() => PanelViewState();
}

class PanelViewState extends State<PanelView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  BleConnectionService bleConnectionService = BleConnectionService();
  late StreamSubscription _subscription;
  late ClientsProvider? _clientsProvider;
  bool isDisconnected = true;
  bool isConnected = false;
  bool isActive = false;
  bool isFullScreen = false;
  bool isRunning = false;
  bool showBlackScreen = true;
  String? selectedKey;
  String? macAddress;
  String? grupoKey;
  int? selectedIndex = 0;
  int? totalBonosSeleccionados = 0;
  String connectionStatus = "desconectado";
  double scaleFactorBack = 1.0;
  Map<String, int> equipSelectionMap = {};
  ValueNotifier<Map<String, dynamic>> clientSelectionMap = ValueNotifier({});
  Set<String> processedDevices = {};

  ValueNotifier<List<String>> successfullyConnectedDevices = ValueNotifier([]);
  List<String> connectedDevices = [];

  // Listas específicas para grupos
  ValueNotifier<List<String>> groupedAmcis = ValueNotifier([]);
  ValueNotifier<List<String>> groupedBmcis = ValueNotifier([]);
  Map<String, dynamic>? selectedClient;
  final Map<String, String> deviceConnectionStatus = {};
  Map<String, String> clientsNames = {};
  Map<String, String> bluetoothNames = {};
  Map<String, int> batteryStatuses = {};
  Map<String, Key> mciKeys = {};
  Map<String, String?> mciSelectionStatus = {};
  Map<String, String?> temporarySelectionStatus = {};
  Map<String, bool> isSelected = {};
  final Map<String, StreamSubscription<bool>> _connectionSubscriptions = {};

  @override
  void initState() {
    super.initState();
    initializeAndConnectBLE();
    _subscription = bleConnectionService.deviceUpdates.listen((update) {
      final macAddress = update['macAddress'];

      setState(() {
        if (update.containsKey('bluetoothName')) {
          bluetoothNames[macAddress] = update['bluetoothName'];
        }
        if (update.containsKey('batteryStatus')) {
          batteryStatuses[macAddress] = update['batteryStatus'];
        }
      });
    });
    initializeMcis(AppState.instance.mcis);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _clientsProvider = Provider.of<ClientsProvider>(context, listen: false);
      });
    });
    _controller = AnimationController(vsync: this);
  }

  void initializeMcis(List<Map<String, dynamic>> mcisList) {
    for (var mci in mcisList) {
      String macAddress = mci['mac'];
      mciSelectionStatus[macAddress] =
      null; // Ningún grupo seleccionado por defecto
    }
  }

  Future<void> initializeAndConnectBLE() async {
    debugPrint("🛠️ Inicializando BLE y conexiones...");
    bleConnectionService.isWidgetActive = true;
    try {
      await AppState.instance.loadState().timeout(Duration(seconds: 5));
    } catch (e) {
      debugPrint("❌ Error al cargar el estado de la app: $e");
      return;
    }

    List<String> macAddresses =
    AppState.instance.mcis.map((mci) => mci['mac'] as String).toList();
    debugPrint("🔍 Direcciones MAC obtenidas: $macAddresses");


    List<String> newMacAddresses = macAddresses
        .where((mac) => !bleConnectionService.connectedDevices.contains(mac))
        .toList();

    if (newMacAddresses.isNotEmpty) {
      bleConnectionService.updateMacAddresses(newMacAddresses);
    }

    successfullyConnectedDevices.value.clear();
    deviceConnectionStatus.clear();

    for (final macAddress in macAddresses) {
      deviceConnectionStatus[macAddress] = 'desconectado';

      StreamSubscription<bool>? subscription;
      subscription =
          bleConnectionService.connectionStateStream(macAddress).listen(
        (isConnected) {
          if (isConnected) {
            if (!successfullyConnectedDevices.value.contains(macAddress)) {
              successfullyConnectedDevices.value = [
                ...successfullyConnectedDevices.value,
                macAddress,
              ];
            }
          } else {
            successfullyConnectedDevices.value = successfullyConnectedDevices
                .value
                .where((device) => device != macAddress)
                .toList();
          }

          if (mounted) {
                setState(() {
                  deviceConnectionStatus[macAddress] =
                  isConnected ? 'conectado' : 'desconectado';
                });
              }
            },
            onError: (error) {
              debugPrint("❌ Error en la conexión de $macAddress: $error");

              if (mounted) {
                setState(() {
                  deviceConnectionStatus[macAddress] = 'error';
                });
              }
            },
          );

      _connectionSubscriptions[macAddress] = subscription;
    }

    debugPrint("✅ Inicialización BLE completada.");
  }
  void onTapConnectToDevice(String macAddress) async {
    debugPrint("🛠️ Escaneando el dispositivo $macAddress antes de intentar la conexión...");

    // Escanear dispositivos disponibles antes de intentar la conexión
    List<String> availableDevices = await bleConnectionService.scanTargetDevices();

    // Verificar si el dispositivo específico está disponible
    if (!availableDevices.contains(macAddress)) {
      debugPrint("❌ El dispositivo $macAddress no fue encontrado en el escaneo. No se puede conectar.");
      return;
    }

    // Verificar si ya está conectado antes de intentar conectar
    if (bleConnectionService.connectedDevices.contains(macAddress)) {
      debugPrint("✅ El dispositivo $macAddress ya está conectado.");
      return;
    }

    // Agregar un retraso de 500 ms antes de la conexión
    await Future.delayed(Duration(milliseconds: 500));

    // Cambiar el estado a "conectando"
    deviceConnectionStatus[macAddress] = 'conectando';
    setState(() {}); // Actualizar UI si es necesario

    // Intentar conectar
    bool success = await bleConnectionService.connectToDeviceByMac(macAddress);

    if (success) {
      // Suscribirse al stream de conexión para actualizar el estado en tiempo real
      bleConnectionService.connectionStateStream(macAddress).listen(
            (isConnected) {
          if (isConnected) {
            if (!successfullyConnectedDevices.value.contains(macAddress)) {
              successfullyConnectedDevices.value = [
                ...successfullyConnectedDevices.value,
                macAddress,
              ];
            }
          } else {
            successfullyConnectedDevices.value = successfullyConnectedDevices.value
                .where((device) => device != macAddress)
                .toList();
          }

          if (mounted) {
            setState(() {
              deviceConnectionStatus[macAddress] = isConnected ? 'conectado' : 'desconectado';
            });
          }
        },
        onError: (error) {
          debugPrint("❌ Error en la conexión de $macAddress: $error");

          if (mounted) {
            setState(() {
              deviceConnectionStatus[macAddress] = 'error';
            });
          }
        },
      );
    } else {
      debugPrint("⚠️ No se pudo conectar con $macAddress. Intentando reconectar...");
    }

    debugPrint("✅ Proceso de conexión a $macAddress finalizado.");
  }







  void updateDeviceSelection(String mac, String group) {
    setState(() {
      macAddress = mac; // Actualizamos el macAddress
      grupoKey =
          group; // Actualizamos la clave del grupo (vacío para selección individual)
    });

    if (group.isEmpty) {
      print("🔄 Dispositivo individual seleccionado: $mac");
    } else {
      print("🔄 Dispositivo $mac del grupo $group seleccionado.");
    }
  }

  void _handleIndividualSelection(String macAddress) {
    print("📱❌ $macAddress no pertenece a ningún grupo");

    // Deseleccionamos todos los dispositivos
    isSelected.forEach((key, value) {
      if (value == true) {
        isSelected[key] = false;
        print("✖️ El dispositivo $key ha sido deseleccionado.");
      }
    });

    // Seleccionamos el dispositivo individual
    isSelected[macAddress] = true;
    selectedKey = macAddress;
    print("📱 $macAddress ha sido seleccionado.");
    print("🔑 Clave asignada (dispositivo individual): $selectedKey");

    // Actualizamos la selección del dispositivo individual
    updateDeviceSelection(
        macAddress, ''); // El grupo es vacío para selección individual
  }

  void _handleGroupSelection(String group) {
    print("📱 El grupo seleccionado es: $group");

    // Agrupar dispositivos por grupo
    Map<String, List<String>> groupedDevices = {};
    mciSelectionStatus.forEach((deviceMac, deviceGroup) {
      if (deviceGroup != null && deviceGroup.isNotEmpty) {
        groupedDevices.putIfAbsent(deviceGroup, () => []);
        groupedDevices[deviceGroup]!.add(deviceMac);
      }
    });

    // Deseleccionamos todos los dispositivos
    isSelected.forEach((key, _) {
      isSelected[key] = false;
      print("✖️ El dispositivo $key ha sido deseleccionado.");
    });

    // Limpiar las listas observables antes de actualizar
    groupedAmcis.value = [];
    groupedBmcis.value = [];

    // Asignar índices según el grupo
    int indexForGroup = group == "A"
        ? 0
        : group == "B"
        ? 1
        : -1;

    // Seleccionamos los dispositivos del grupo
    groupedDevices[group]?.forEach((deviceMac) {
      isSelected[deviceMac] = true;
      equipSelectionMap[deviceMac] =
          indexForGroup; // Actualiza el índice para el dispositivo

      // Agregar a la lista correspondiente según el grupo
      if (group == "A") {
        groupedAmcis.value = [...groupedAmcis.value, deviceMac];
      } else if (group == "B") {
        groupedBmcis.value = [...groupedBmcis.value, deviceMac];
      }

      // Agregar un print para ver cómo se actualiza equipSelectionMap
      print("🔄 equipSelectionMap actualizado: $deviceMac -> $indexForGroup");

      updateDeviceSelection(deviceMac, group); // Pasa el macAddress y el group
      print("📱 $deviceMac del grupo $group ha sido seleccionado.");
    });

    // Mostrar el índice asignado para el grupo
    print("🔢 Índice asignado para el grupo $group: $indexForGroup");

    // Asignamos la clave para el grupo
    selectedKey = groupedDevices[group]?.join('-') ?? '';
    print("🔑 Clave asignada (grupo): $selectedKey");

    // Asignamos el índice global del grupo
    selectedIndex = indexForGroup; // Establecemos el índice del grupo
    print("📊 Índice global del grupo seleccionado: $selectedIndex");

    // Mostrar las listas separadas por grupo
    print(
        "📋 Lista de dispositivos seleccionados (groupedAmcis): ${groupedAmcis.value}");
    print(
        "📋 Lista de dispositivos seleccionados (groupedBmcis): ${groupedBmcis.value}");
  }

  void updateEquipSelection(String key, int selectedIndex) {
    setState(() {
      equipSelectionMap[key] = selectedIndex;
    });
    print("🔄 Equip seleccionado: $selectedIndex para clave $key");
  }

  void onClientSelected(
      String key, Map<String, dynamic>? client, String? macAddress) {
    setState(() {
      // Crear una copia del mapa actual
      final nuevoMapa = Map<String, dynamic>.from(clientSelectionMap.value);

      if (client != null) {
        // Elimina cualquier entrada con el mismo 'id' para evitar duplicados
        nuevoMapa.removeWhere((k, v) => v != null && v['id'] == client['id']);
        print("Cliente eliminado de asociaciones previas: ${client['name']}");

        // Asigna el cliente al dispositivo actual
        nuevoMapa[key] = client;
        print("Cliente asignado a $macAddress: ${client['name']}");
      } else {
        // Si el cliente es null, elimina la asignación del mapa
        print("Cliente desasignado de $macAddress");
        nuevoMapa.remove(key);
      }

      // Actualiza clientSelectionMap con el nuevo mapa sin duplicados
      clientSelectionMap.value = nuevoMapa;

      // Imprime el estado actual del mapa
      print(
          "********Estado actual de clientSelectionMap: ${nuevoMapa.map((k, v) => MapEntry(k, v?['name'] ?? 'No asignado'))}");
    });
  }


  void handleActiveChange(bool newState) {
    setState(() {
      isFullScreen = newState; // Actualiza el valor del booleano
    });
  }

  Future<void> _exitScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
            side: const BorderSide(color: Color(0xFF28E2F5)),
          ),
          backgroundColor: const Color(0xFF494949),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3, // 🔹 Fija altura máxima
            ),
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.02,
              horizontal: MediaQuery.of(context).size.width * 0.02,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // 🔹 Permite que el contenido se ajuste mejor
                children: [
                  // ✅ Título
                  Text(
                    tr(context, 'Aviso').toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF28E2F5),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                  // ✅ Mensaje de salida
                  Text(
                    tr(context, '¿Quieres salir del panel?').toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 25.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  // ✅ Fila de botones con `Expanded`
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 🔹 Cierra el diálogo sin hacer nada
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
                          widget.onBack();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          tr(context, 'Salir del panel').toUpperCase(),
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
        );
      },
    );
  }
  Future<Map<String, String?>?> _showMCIListDialog(BuildContext context) async {
    return await showDialog<Map<String, String?>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Inicializar temporarySelectionStatus con los valores guardados
              if (temporarySelectionStatus.isEmpty) {
                temporarySelectionStatus = Map.from(mciSelectionStatus);
              }

              return Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.03,
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                decoration: BoxDecoration(
                  color: const Color(0xFF494949),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF28E2F5),
                    width: MediaQuery.of(context).size.width * 0.001,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Grupo A
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    tr(context, "Grupo A").toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.green,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: AppState.instance.mcis.length,
                                      itemBuilder: (context, index) {
                                        var mci = AppState.instance.mcis[index];
                                        String macAddress = mci['mac'];

                                        // Verificar si está seleccionado para el grupo A
                                        bool isSelected =
                                            temporarySelectionStatus[
                                            macAddress] ==
                                                'A';

                                        int selectedEquip =
                                            equipSelectionMap[macAddress] ?? 0;
                                        Map<String, dynamic>? selectedClient =
                                        clientSelectionMap.value[macAddress]
                                        as Map<String, dynamic>?;
                                        String clientName =
                                            selectedClient?['name'] ?? '';

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.02,
                                          ),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.1,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.1,
                                            child: CustomPaint(
                                              painter: NeonBorderPainter(
                                                neonColor: _getBorderColor(
                                                    deviceConnectionStatus[
                                                    macAddress]),
                                                screenWidth: MediaQuery.of(context).size.width,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                        0.005),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                  BorderRadius.circular(7),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    customCheckbox(
                                                        macAddress,
                                                        isSelected,
                                                        setState,
                                                        'A'),
                                                    Expanded(
                                                      child: Center(
                                                        child:
                                                        selectedEquip == 0
                                                            ? Image.asset(
                                                          'assets/images/chalecoblanco.png',
                                                          fit: BoxFit
                                                              .contain,
                                                        )
                                                            : Image.asset(
                                                          'assets/images/pantalonblanco.png',
                                                          fit: BoxFit
                                                              .contain,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          Text(
                                                            clientName.isEmpty
                                                                ? ''
                                                                : clientName,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              color: const Color(
                                                                  0xFF28E2F5),
                                                            ),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                          Text(
                                                            bluetoothNames[
                                                            macAddress] ??
                                                                "",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: const Color(
                                                                  0xFF28E2F5),
                                                            ),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children:
                                                            List.generate(
                                                              5,
                                                                  (batteryIndex) {
                                                                return Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                          0.001),
                                                                  child:
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                        0.015,
                                                                    height: MediaQuery.of(context)
                                                                        .size
                                                                        .height *
                                                                        0.015,
                                                                    color: batteryIndex <=
                                                                        (batteryStatuses[macAddress] ??
                                                                            -1)
                                                                        ? _lineColor(
                                                                        macAddress)
                                                                        : Colors
                                                                        .white
                                                                        .withOpacity(0.5),
                                                                  ),
                                                                );
                                                              },
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                MediaQuery.of(context).size.width * 0.05),
                            // Grupo B
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    tr(context, "Grupo B").toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.red,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: AppState.instance.mcis.length,
                                      itemBuilder: (context, index) {
                                        var mci = AppState.instance.mcis[index];
                                        String macAddress = mci['mac'];

                                        // Verificar si está seleccionado para el grupo A
                                        bool isSelected =
                                            temporarySelectionStatus[
                                            macAddress] ==
                                                'B';

                                        int selectedEquip =
                                            equipSelectionMap[macAddress] ?? 0;
                                        Map<String, dynamic>? selectedClient =
                                        clientSelectionMap.value[macAddress];
                                        String clientName =
                                            selectedClient?['name'] ?? '';

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.02,
                                          ),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.1,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.1,
                                            child: CustomPaint(
                                              painter: NeonBorderPainter(
                                                neonColor: _getBorderColor(
                                                    deviceConnectionStatus[
                                                    macAddress]),
                                                screenWidth: MediaQuery.of(context).size.width,
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                        0.005),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius:
                                                  BorderRadius.circular(7),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  children: [
                                                    customCheckbox(
                                                        macAddress,
                                                        isSelected,
                                                        setState,
                                                        'B'),
                                                    Expanded(
                                                      child: Center(
                                                        child:
                                                        selectedEquip == 0
                                                            ? Image.asset(
                                                          'assets/images/chalecoblanco.png',
                                                          fit: BoxFit
                                                              .contain,
                                                        )
                                                            : Image.asset(
                                                          'assets/images/pantalonblanco.png',
                                                          fit: BoxFit
                                                              .contain,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                        children: [
                                                          Text(
                                                            clientName.isEmpty
                                                                ? ''
                                                                : clientName,
                                                            style: TextStyle(
                                                              fontSize: 10.sp,
                                                              color: const Color(
                                                                  0xFF28E2F5),
                                                            ),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                          Text(
                                                            bluetoothNames[
                                                            macAddress] ??
                                                                "",
                                                            style: TextStyle(
                                                              fontSize: 14.sp,
                                                              color: const Color(
                                                                  0xFF28E2F5),
                                                            ),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children:
                                                            List.generate(
                                                              5,
                                                                  (batteryIndex) {
                                                                return Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal: MediaQuery.of(context)
                                                                          .size
                                                                          .width *
                                                                          0.001),
                                                                  child:
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                        .size
                                                                        .width *
                                                                        0.015,
                                                                    height: MediaQuery.of(context)
                                                                        .size
                                                                        .height *
                                                                        0.015,
                                                                    color: batteryIndex <=
                                                                        (batteryStatuses[macAddress] ??
                                                                            -1)
                                                                        ? _lineColor(
                                                                        macAddress)
                                                                        : Colors
                                                                        .white
                                                                        .withOpacity(0.5),
                                                                  ),
                                                                );
                                                              },
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
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              /* setState(() {
                                temporarySelectionStatus.clear();
                              });*/
                              Navigator.of(context).pop(); // Cierra el diálogo
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              tr(context, 'Cancelar').toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp,
                              ),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Filtrar las MCIs seleccionadas para el Grupo A y B
                              List<String> selectedForGroupA =
                              temporarySelectionStatus.entries
                                  .where((entry) => entry.value == 'A')
                                  .map((entry) => entry.key)
                                  .toList();

                              List<String> selectedForGroupB =
                              temporarySelectionStatus.entries
                                  .where((entry) => entry.value == 'B')
                                  .map((entry) => entry.key)
                                  .toList();

                              // Actualiza mciSelectionStatus con el estado temporal
                              setState(() {
                                mciSelectionStatus =
                                    Map.from(temporarySelectionStatus);
                              });

                              // Cerrar el diálogo y pasar los valores seleccionados
                              Navigator.of(context).pop(mciSelectionStatus);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2be4f3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              backgroundColor: const Color(0xFF2be4f3),
                            ),
                            child: Text(
                              tr(context, 'Definir grupos').toUpperCase(),
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
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    _connectionSubscriptions.clear();
    _subscription.cancel();
    _controller.dispose();
    successfullyConnectedDevices.value.clear();
    bleConnectionService.dispose();
    super.dispose();

  }

  Widget customCheckbox(
      String option, bool isSelected, StateSetter setState, String group) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Filtra el estado temporal para actualizar el grupo correspondiente
          if (group == 'A') {
            // Si no existe, inicializa con 'A' o 'B', o invierte el valor
            temporarySelectionStatus[option] =
            temporarySelectionStatus[option] == 'A' ? '' : 'A';
          } else if (group == 'B') {
            temporarySelectionStatus[option] =
            temporarySelectionStatus[option] == 'B' ? '' : 'B';
          }
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.04,
        height: MediaQuery.of(context).size.height * 0.04,
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.01),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: temporarySelectionStatus[option] == group
              ? const Color(0xFF2be4f3) // Color cuando está seleccionado
              : Colors.transparent,
          border: Border.all(
            color: temporarySelectionStatus[option] == group
                ? const Color(0xFF2be4f3) // Borde azul si está seleccionado
                : Colors.white, // Borde blanco si no está seleccionado
            width: MediaQuery.of(context).size.width * 0.001,
          ),
        ),
      ),
    );
  }
  Color _lineColor(String? macAddress) {
    // Obtener el estado de la batería de la dirección MAC proporcionada
    final int? batteryStatus = batteryStatuses[macAddress];
    // Determinar el color basado en el estado de la batería
    switch (batteryStatus) {
      case 0: // Muy baja
        return Colors.red;
      case 1: // Baja
        return Colors.orange;
      case 2: // Media
        return Colors.yellow;
      case 3: // Alta
        return Colors.lightGreenAccent;
      case 4: // Llena
        return Colors.green;
      default: // Desconocido o no disponible
        return Colors.transparent;
    }
  }
  Color _getBorderColor(String? status) {
    switch (status) {
      case 'conectado':
        return const Color(0xFF2be4f3); // Color para el estado "conectado"
      case 'desconectado':
        return Colors.grey; // Color para el estado "desconectado"
      case 'inactivo':
        return Colors.white; // Color para el estado "inactivo"
      case 'sinTiempo':
        return Colors.orange; // Color para el estado "sin tiempo"
      default:
        return Colors
            .grey; // Color predeterminado (gris si no coincide con ningún estado)
    }
  }
  double _getOpacityForDevice(String macAddress) {
    // Obtenemos el grupo del dispositivo
    String? group = mciSelectionStatus[macAddress];

    // Si el dispositivo pertenece a un grupo, todos los dispositivos del grupo tendrán la misma opacidad
    if (group != null && group.isNotEmpty) {
      // Verificamos si al menos un dispositivo del grupo está seleccionado
      bool groupSelected = isSelected.entries.any((entry) =>
      entry.value == true && mciSelectionStatus[entry.key] == group);
      return groupSelected
          ? 1.0
          : 0.5; // Si está seleccionado, opacidad 1.0, sino 0.3
    } else {
      // Si el dispositivo no pertenece a ningún grupo, solo depende de si está seleccionado
      return isSelected[macAddress] == true
          ? 1.0
          : 0.5; // Si está seleccionado, opacidad 1.0, sino 0.3
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isConnected = bleConnectionService.isConnected;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Fondo de la imagen
          SizedBox.expand(
            child: Image.asset(
              'assets/images/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Contenedor blanco semi-translúcido por encima del fondo
          Container(
            color: Colors.transparent,
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02, horizontal: screenWidth * 0.02),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            if (!isFullScreen) ...[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.015),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ...AppState.instance.mcis
                                          .asMap()
                                          .map((index, mci) {
                                        String macAddress = mci[
                                        'mac']; // Obtener la MAC de cada dispositivo
                                        int selectedEquip =
                                            equipSelectionMap[macAddress] ?? 0;
                                        Map<String, dynamic>? selectedClient =
                                        clientSelectionMap.value[macAddress] as Map<String, dynamic>?;

                                        String clientName =
                                            selectedClient?['name'] ?? '';
                                        return MapEntry(
                                          index,
                                          GestureDetector(
                                            onTap: () async {
                                              if (deviceConnectionStatus[
                                              macAddress] ==
                                                  'conectado') {
                                                setState(() {
                                                  // Asignar índice del dispositivo seleccionado
                                                  selectedIndex = index;
                                                  String? group =
                                                  mciSelectionStatus[
                                                  macAddress];

                                                  if (group == null ||
                                                      group.isEmpty) {
                                                    // Selección individual
                                                    _handleIndividualSelection(
                                                        macAddress);
                                                  } else {
                                                    // Selección por grupo
                                                    _handleGroupSelection(
                                                        group);

                                                    // Asignar el índice global del grupo
                                                    selectedIndex = group == "A"
                                                        ? 0
                                                        : group == "B"
                                                        ? 1
                                                        : index;
                                                    print(
                                                        "📊 Índice global del grupo seleccionado: $selectedIndex");

                                                    // Verificar si la dirección MAC pertenece al grupo
                                                    List<String>
                                                    devicesInGroup =
                                                    group == "A"
                                                        ? groupedAmcis.value
                                                        : group == "B"
                                                        ? groupedBmcis
                                                        .value
                                                        : [];

                                                    // Procesar dispositivos en el grupo
                                                    for (String deviceMac
                                                    in devicesInGroup) {
                                                      if (!processedDevices
                                                          .contains(
                                                          deviceMac)) {
                                                        print(
                                                            "🚀 Procesando dispositivo del grupo: $deviceMac");
                                                        bleConnectionService
                                                            .processConnectedDevices(
                                                            deviceMac);
                                                        processedDevices.add(
                                                            deviceMac); // Marcar como procesado
                                                      } else {
                                                        print(
                                                            "✅ El dispositivo $deviceMac ya fue procesado.");
                                                      }
                                                    }
                                                  }

                                                  // Mostrar índice del dispositivo seleccionado
                                                  print(
                                                      "📊 Índice del dispositivo seleccionado: $selectedIndex");
                                                });

                                                // Verificar si ya se ha procesado el dispositivo individualmente
                                                if (!processedDevices
                                                    .contains(macAddress)) {
                                                  await bleConnectionService
                                                      .processConnectedDevices(
                                                      macAddress);
                                                  processedDevices.add(
                                                      macAddress); // Marcar como procesado
                                                } else {
                                                  print(
                                                      "✅ El dispositivo $macAddress ya fue procesado.");
                                                }
                                              } else {
                                                print(
                                                    "❌ El dispositivo $macAddress no está conectado.");

                                                // Verificar si la macAddress ya está en la lista de dispositivos conectados exitosamente
                                                if (!successfullyConnectedDevices
                                                    .value
                                                    .contains(macAddress)) {
                                                  onTapConnectToDevice(macAddress);
                                                } else {
                                                  print(
                                                      "✅ El dispositivo $macAddress ya está conectado exitosamente.");
                                                }
                                              }
                                            },
                                            onLongPress: () {
                                              if (selectedClient != null) {
                                                print(
                                                    'Cliente deseleccionado: ${selectedClient!['name']}');

                                                setState(() {
                                                  // 🔥 Crear una nueva copia del mapa sin el cliente eliminado
                                                  final nuevoMapa =
                                                  Map<String, dynamic>.from(
                                                      clientSelectionMap
                                                          .value);
                                                  nuevoMapa.remove(macAddress);

                                                  // 🔥 Asignar la nueva copia y notificar cambio
                                                  clientSelectionMap.value =
                                                      nuevoMapa;
                                                  clientSelectionMap
                                                      .notifyListeners(); // 🔥 Esto activará _onClientSelectedMapChanged() en el hijo

                                                  // 🔥 Notificar al hijo enviando `null`
                                                  onClientSelected(selectedKey!,
                                                      null, macAddress);

                                                  // 🔥 También lo eliminamos del Provider si existe
                                                  if (_clientsProvider !=
                                                      null) {
                                                    _clientsProvider!
                                                        .removeClient(
                                                        selectedClient!);
                                                    if (kDebugMode) {
                                                      print(
                                                          "📋 Cliente eliminado del Provider: ${selectedClient!['name']}");
                                                    }
                                                  }

                                                  // 🔥 Borra por completo `selectedClient`
                                                  selectedClient = null;
                                                });

                                                // 🔥 Verificación en consola
                                                debugPrint(
                                                    "✅ selectedClient después de eliminación: $selectedClient");
                                                debugPrint(
                                                    "✅ Estado de clientSelectionMap después de eliminación: ${clientSelectionMap.value}");
                                              } else {
                                                print(
                                                    "❌ No hay cliente asociado a esta dirección MAC para desasignar.");
                                              }
                                            },
                                            child: Stack(
                                              children: [
                                                // Widget principal (contenedor y detalles)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right:
                                                      screenWidth * 0.01),
                                                  child: SizedBox(
                                                    width: screenWidth * 0.1,
                                                    height: screenHeight * 0.1,
                                                    child: CustomPaint(
                                                      painter:
                                                      NeonBorderPainter(
                                                        neonColor: _getBorderColor(
                                                            deviceConnectionStatus[
                                                            macAddress]),
                                                        screenWidth: screenWidth,
                                                        opacity:
                                                        _getOpacityForDevice(
                                                            macAddress),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            vertical:
                                                            screenHeight *
                                                                0.005),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(7),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                _getOpacityForDevice(
                                                                    macAddress) ==
                                                                    1.0
                                                                    ? 0.3
                                                                    : 0.1,
                                                              ),
                                                              blurRadius: 10,
                                                              offset:
                                                              const Offset(
                                                                  0, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                          children: [
                                                            Expanded(
                                                              child: Center(
                                                                child: selectedEquip ==
                                                                    0
                                                                    ? Image
                                                                    .asset(
                                                                  'assets/images/chalecoblanco.png',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                )
                                                                    : Image
                                                                    .asset(
                                                                  'assets/images/pantalonblanco.png',
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  Text(
                                                                    clientName
                                                                        .isEmpty
                                                                        ? ''
                                                                        : clientName,
                                                                    style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                      12.sp,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color: const Color(
                                                                          0xFF28E2F5),
                                                                    ),
                                                                    textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                  ),
                                                                  Text(
                                                                    bluetoothNames[
                                                                    macAddress] ??
                                                                        '',
                                                                    style:
                                                                    TextStyle(
                                                                      fontSize:
                                                                      12.sp,
                                                                      color: const Color(
                                                                          0xFF28E2F5),
                                                                    ),
                                                                    textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                    children: List
                                                                        .generate(
                                                                        5,
                                                                            (index) {
                                                                          return Padding(
                                                                            padding:
                                                                            EdgeInsets.symmetric(horizontal: screenWidth * 0.001),
                                                                            child:
                                                                            Container(
                                                                              width:
                                                                              screenWidth * 0.0085,
                                                                              height:
                                                                              screenHeight * 0.004,
                                                                              color: index <= (batteryStatuses[macAddress] ?? -1)
                                                                                  ? _lineColor(macAddress)
                                                                                  : Colors.white.withOpacity(0.5),
                                                                            ),
                                                                          );
                                                                        }),
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
                                                // Indicador circular en la esquina
                                                Positioned(
                                                  top: screenHeight * 0.003,
                                                  right: screenWidth * 0.012,
                                                  child: Text(
                                                    (mciSelectionStatus[
                                                    macAddress] ??
                                                        '') ==
                                                        'Sin grupo'
                                                        ? '' // Si es 'Sin grupo', mostrar "SG" (o lo que prefieras)
                                                        : (mciSelectionStatus[
                                                    macAddress] ??
                                                        ''),
                                                    style: TextStyle(
                                                      color: (mciSelectionStatus[
                                                      macAddress] ??
                                                          '') ==
                                                          'A'
                                                          ? Colors
                                                          .green // Color verde para Grupo A
                                                          : (mciSelectionStatus[
                                                      macAddress] ??
                                                          '') ==
                                                          'B'
                                                          ? Colors
                                                          .red // Color rojo para Grupo B
                                                          : Colors
                                                          .transparent,
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).values,
                                      const Spacer(),
                                      OutlinedButton(
                                        onPressed: () async {
                                          // Verifica si isRunning es true y bloquea la acción
                                          if (isRunning) {
                                            return; // No hace nada si isRunning es true
                                          }

                                          // Verifica si hay al menos un dispositivo conectado
                                          if (deviceConnectionStatus.values
                                              .contains('conectado')) {
                                            // Limpiar la lista de dispositivos seleccionados (poner todos en false)
                                            setState(() {
                                              isSelected.updateAll((key,
                                                  value) =>
                                              false); // Establece todos los valores a false
                                              selectedKey == null;
                                              print(
                                                  "🔴 Todos los dispositivos han sido deseleccionados.");
                                            });

                                            // Llamar al diálogo y esperar el resultado (mciSelectionStatus)
                                            final updatedSelection =
                                            await _showMCIListDialog(
                                                context);

                                            // Si el resultado no es null, actualizamos el estado
                                            if (updatedSelection != null) {
                                              setState(() {
                                                // Actualizamos mciSelectionStatus con el valor devuelto por el diálogo
                                                mciSelectionStatus =
                                                    updatedSelection;
                                              });
                                            }
                                          } else {
                                            print(
                                                "❌ No hay dispositivos conectados.");
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context).size.height * 0.01,
                                            horizontal: MediaQuery.of(context).size.width * 0.01,
                                          ),
                                          side: BorderSide(
                                            width: screenWidth * 0.001,
                                            color: const Color(0xFF2be4f3),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(7),
                                          ),
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          tr(context, 'Definir grupos')
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: const Color(0xFF2be4f3),
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.05),
                                      GestureDetector(
                                        onTapDown: (_) => setState(
                                                () => scaleFactorBack = 0.90),
                                        onTapUp: (_) => setState(
                                                () => scaleFactorBack = 1.0),
                                        onTap: () {
                                          _exitScreen(context);
                                        },
                                        child: AnimatedScale(
                                          scale: scaleFactorBack,
                                          duration:
                                          const Duration(milliseconds: 100),
                                          child: SizedBox(
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/back.png',
                                                fit: BoxFit.scaleDown,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              '$isFullScreen',
                              style: TextStyle(
                                  fontSize: 1.sp, color: Colors.transparent),
                            ),
                            Expanded(
                              flex: 9,
                              child: IndexedStack(
                                index: selectedIndex,
                                // Muestra el widget según el índice seleccionado
                                children: AppState.instance.mcis.map((mci) {
                                  int index =
                                  AppState.instance.mcis.indexOf(mci);
                                  String macAddress = mci['mac'];

                                  // Crear el widget para cada contenido con su estado independiente
                                  return ExpandedContentWidget(
                                    selectedKey: selectedKey,
                                    index: index,
                                    macAddress: macAddress,
                                    macAddresses: successfullyConnectedDevices,
                                    onSelectEquip: (index) =>
                                        updateEquipSelection(
                                            selectedKey!, index),
                                    onClientSelected: (client) =>
                                        onClientSelected(
                                            selectedKey!, client, macAddress),
                                    isFullChanged: handleActiveChange,
                                    groupedA: groupedAmcis,
                                    groupedB: groupedBmcis,
                                    clientSelectedMap: clientSelectionMap,
                                  );
                                }).toList(),
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
    );
  }
}




