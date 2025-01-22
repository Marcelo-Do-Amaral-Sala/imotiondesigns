import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imotion_designs/src/panel/overlays/overlay_panel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../../../utils/translation_utils.dart';
import '../../db/db_helper.dart';
import '../../servicios/licencia_state.dart';
import '../custom/border_neon.dart';
import '../custom/linear_custom.dart';
import 'package:http/http.dart' as http;

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
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  late BleConnectionService bleConnectionService;
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
  String connectionStatus = "desconectado";
  double scaleFactorBack = 1.0;
  Map<String, int> equipSelectionMap = {};
  Map<String, dynamic> clientSelectionMap = {};
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

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      setState(() {
        showBlackScreen = false;
      });
    });
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

    bleConnectionService = BleConnectionService();
    bleConnectionService.isWidgetActive = true;

    // 2. Cargar los datos desde AppState
    await AppState.instance.loadState();
    List<String> macAddresses =
        AppState.instance.mcis.map((mci) => mci['mac'] as String).toList();

    debugPrint("🔍 Direcciones MAC obtenidas: $macAddresses");

    // 3. Inicializar claves de dispositivos y grupos
    mciKeys.clear();
    for (var mci in AppState.instance.mcis) {
      String macAddress = mci['mac'];
      mciKeys[macAddress] = ValueKey(macAddress);
    }

    for (var grupo in mciSelectionStatus.values) {
      if (grupo != null) {
        List<String> macAddresses = grupo.split(',');
        String grupoKey = macAddresses.join('-');
        mciKeys[grupoKey] = ValueKey(grupoKey);
      }
    }

    // 4. Actualizar las direcciones MAC en el servicio BLE
    bleConnectionService.updateMacAddresses(macAddresses);

    // 5. Limpiar las listas y estados locales
    successfullyConnectedDevices.value.clear();
    deviceConnectionStatus.clear();

    // 6. Configurar estado inicial y escuchar el flujo de conexión
    for (final macAddress in macAddresses) {
      // Inicializar estado de conexión como "desconectado"
      deviceConnectionStatus[macAddress] = 'desconectado';

      // Escuchar el estado de conexión para cada dispositivo
      bleConnectionService.connectionStateStream(macAddress).listen(
          (isConnected) {
        if (isConnected) {
          // Agregar a conexiones exitosas si está conectado
          if (!successfullyConnectedDevices.value.contains(macAddress)) {
            successfullyConnectedDevices.value = [
              ...successfullyConnectedDevices.value,
              macAddress,
            ];
          }
        } else {
          // Remover de conexiones exitosas si está desconectado
          successfullyConnectedDevices.value = successfullyConnectedDevices
              .value
              .where((device) => device != macAddress)
              .toList();
        }

        // Actualizar el estado de conexión en la UI
        if (mounted) {
          setState(() {
            deviceConnectionStatus[macAddress] =
                isConnected ? 'conectado' : 'desconectado';
          });
        }
      }, onError: (error) {
        debugPrint("❌ Error en la conexión de $macAddress: $error");
        if (mounted) {
          setState(() {
            deviceConnectionStatus[macAddress] = 'error';
          });
        }
      });
    }

    debugPrint("✅ Inicialización BLE completada.");
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

  void onClientSelected(String key, Map<String, dynamic>? client) {
    setState(() {
      clientSelectionMap[key] = client;
    });
  }

  void handleActiveChange(bool newState) {
    setState(() {
      isFullScreen = newState; // Actualiza el valor del booleano
    });
  }

  @override
  void dispose() {
    // Llamar al dispose de la clase base
    _subscription.cancel();
    if (kDebugMode) {
      print("📡 Suscripción cancelada.");
    }

    // Liberar otros recursos después de desconectar dispositivos
    successfullyConnectedDevices.value.clear();
    if (kDebugMode) {
      print("Lista despues del dispose $successfullyConnectedDevices}");
    }

    super.dispose();
    if (kDebugMode) {
      print("🚀 dispose() ejecutado correctamente.");
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
                                      vertical: screenHeight * 0.015,
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
                                            clientSelectionMap[macAddress];
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
                                                  // Intentar conectar al dispositivo si no está en la lista
                                                  bool success =
                                                      await bleConnectionService
                                                          ._connectToDeviceByMac(
                                                              macAddress);

                                                  bleConnectionService
                                                      .connectionStateStream(
                                                          macAddress)
                                                      .listen(
                                                          (isConnected) async {
                                                    if (isConnected) {
                                                      // Agregar el MAC address a la lista cuando se conecte con éxito
                                                      successfullyConnectedDevices
                                                          .value = [
                                                        ...successfullyConnectedDevices
                                                            .value,
                                                        macAddress,
                                                      ];
                                                    }
                                                    if (mounted) {
                                                      setState(() {
                                                        // Actualizar el estado de conexión en la UI
                                                        deviceConnectionStatus[
                                                                macAddress] =
                                                            isConnected
                                                                ? 'conectado'
                                                                : 'desconectado';
                                                      });
                                                    }
                                                  });
                                                } else {
                                                  print(
                                                      "✅ El dispositivo $macAddress ya está conectado exitosamente.");
                                                }
                                              }
                                            },
                                            onLongPress: () {
                                              // Imprime el cliente deseleccionado
                                              print(
                                                  'Cliente deseleccionado: $clientName');

                                              setState(() {
                                                // Elimina el cliente de la selección local
                                                clientSelectionMap
                                                    .remove(macAddress);

                                                // Limpia el nombre del cliente
                                                clientName = '';

                                                // Limpia la lista de clientes seleccionados en el Provider
                                                if (_clientsProvider != null) {
                                                  _clientsProvider!
                                                      .clearSelectedClientsSilently(); // Método personalizado para limpiar sin notificar
                                                  if (kDebugMode) {
                                                    print(
                                                        "📋 Lista de clientes seleccionados borrada desde el Provider (sin notificación).");
                                                  }
                                                }
                                              });
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
                                                                          10.sp,
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
                                                                          10.sp,
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
                                                                              screenWidth * 0.01,
                                                                          height:
                                                                              screenHeight * 0.01,
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
                                          padding: const EdgeInsets.all(10.0),
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
                                                // Ajusta el tamaño como sea necesario

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
                                        onClientSelected(selectedKey!, client),
                                    isFullChanged: handleActiveChange,
                                    groupedA: groupedAmcis,
                                    groupedB: groupedBmcis,
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
          if (showBlackScreen)
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  "Cargando...",
                  style: TextStyle(color: Colors.white, fontSize: 24.sp),
                ),
              ),
            ),
        ],
      ),
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
                                            clientSelectionMap[macAddress];
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
                                            clientSelectionMap[macAddress];
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

  Future<void> _exitScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, 'Aviso').toUpperCase(),
                  style: TextStyle(
                    color: const Color(0xFF2be4f3),
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  tr(context, '¿Quieres salir del panel?').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                const Spacer(),
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
                        await bleConnectionService.disposeBle();
                        if (kDebugMode) {
                          print("💡 Recursos BLE liberados.");
                        }
                        widget.onBack();
                        Navigator.of(context)
                            .pop(); // Cierra el diálogo de confirmación
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
        );
      },
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
}

class CustomIconButton extends StatefulWidget {
  final VoidCallback? onTap; // Acción al soltar el botón
  final VoidCallback? onTapDown; // Acción al presionar el botón
  final VoidCallback? onTapUp; // Acción al levantar el botón
  final String imagePath; // Ruta de la imagen del botón
  final double size; // Tamaño del botón
  final bool isDisabled; // Condición para deshabilitar el botón

  const CustomIconButton({
    super.key,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    required this.imagePath,
    this.size = 40.0, // Valor por defecto para el tamaño
    this.isDisabled = false, // Condición por defecto que no está deshabilitado
  });

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double scaleFactor = 1.0; // Factor de escala para la animación

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isDisabled,
      // Deshabilita el botón si isDisabled es true
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            scaleFactor = 0.9; // Escala al presionar
          });
          if (widget.onTapDown != null) {
            widget
                .onTapDown!(); // Llama a la acción de onTapDown si está definida
          }
        },
        onTapUp: (_) {
          setState(() {
            scaleFactor = 1.0; // Regresa a la escala normal al soltar
          });
          if (widget.onTapUp != null) {
            widget.onTapUp!(); // Llama a la acción de onTapUp si está definida
          }
        },
        onTap: widget.onTap, // Llama a la acción de onTap
        child: AnimatedScale(
          scale: scaleFactor,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Image.asset(
              widget.imagePath, // Imagen que se pasa al widget
              height: widget.size,
              width: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandedContentWidget extends StatefulWidget {
  final String? selectedKey;
  final int? index;
  final String? macAddress;
  final ValueNotifier<List<String>> groupedA;
  final ValueNotifier<List<String>> groupedB;
  final ValueNotifier<List<String>> macAddresses;
  final ValueChanged<int> onSelectEquip;
  final ValueChanged<Map<String, dynamic>?> onClientSelected;
  final ValueChanged<bool> isFullChanged;

  const ExpandedContentWidget({
    super.key,
    required this.index,
    required this.macAddress,
    this.selectedKey,
    required this.onSelectEquip,
    required this.onClientSelected,
    required this.isFullChanged,
    required this.macAddresses,
    required this.groupedA,
    required this.groupedB,
  });

  @override
  _ExpandedContentWidgetState createState() => _ExpandedContentWidgetState();
}

class _ExpandedContentWidgetState extends State<ExpandedContentWidget>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final BleConnectionService bleConnectionService;
  late ClientsProvider? _clientsProvider;
  late PanelView panelView = PanelView(
    key: panelViewKey,
    onBack: () {
      // Acción para el callback onBack
    },
    onReset: () {
      // Acción para el callback onReset
    },
    screenWidth: 0,
    screenHeight: 0,
  );
  VideoPlayerController? _videoController;
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  late Timer _timer;
  late DateTime startTime;
  Timer? _phaseTimer;
  Timer? timerSub;
  String currentStatus = '';
  bool isPauseStarted = false;
  bool isTimeless = false;
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;
  bool _isExpanded3 = false;
  bool isFullScreen = false;
  bool isPantalonSelected = false;
  bool isOverlayVisible = false;
  bool isRunning = false;
  bool isRunningSub = false;
  bool isContractionPhase = true;
  bool isSessionStarted = false;
  bool isElectroOn = false;
  bool _isImagesLoaded = false;
  bool showTrainerInfo = false;
  bool _isLoading = true;
  bool _showVideo = false;
  bool _hideControls = true;
  GlobalKey<_PanelViewState> panelViewKey = GlobalKey<_PanelViewState>();
  String modulo =
      "imotion21"; // Cambia "moduloEjemplo" por el valor real del módulo.
  List<String> prvideos = List.filled(
      30, ""); // Inicializamos la lista prvideos con 30 elementos vacíos.
  List<String> invideos = List.filled(30, "");
  String? selectedProgram;
  Map<String, dynamic>? selectedIndivProgram;
  Map<String, dynamic>? selectedRecoProgram;
  Map<String, dynamic>? selectedAutoProgram;
  Map<String, dynamic>? selectedClient;
  int overlayIndex = -1;
  int selectedIndexEquip = 0;
  int totalTime = 25 * 60;
  int previousTotalTime = 0;
  int time = 25;
  int _currentImageIndex = 0;
  int? selectedIndex = 0;
  int remainingTime = 0;
  int? selectedIndivProgramIndex;
  int currentSubprogramIndex = 0;
  int pausedSubprogramIndex = 0;
  double scaleFactorFull = 1.0;
  double scaleFactorCliente = 1.0;
  double scaleFactorRepeat = 1.0;
  double scaleFactorTrainer = 1.0;
  double scaleFactorRayo = 1.0;
  double scaleFactorReset = 1.0;
  double scaleFactorMas = 1.0;
  double scaleFactorMenos = 1.0;
  double rotationAngle1 = 0.0;
  double rotationAngle2 = 0.0;
  double rotationAngle3 = 0.0;
  double progress = 1.0;
  double strokeWidth = 20.0;
  double strokeHeight = 20.0;
  double elapsedTime = 0.0;
  double elapsedTimeSub = 0.0;
  double pausedTime = 0.0;
  double seconds = 0.0;
  double progressContraction = 0.0;
  double progressPause = 0.0;
  double elapsedTimeContraction = 0.0;
  double elapsedTimePause = 0.0;
  double valueContraction = 1.0;
  double valueRampa = 1.0;
  double valuePause = 1.0;
  double contractionDuration = 0.0;

  Map<String, bool> procesosActivos = {};
  Map<int, double> subprogramElapsedTime =
      {}; // Almacena elapsedTimeSub para cada subprograma
  Map<int, int> subprogramRemainingTime = {};
  List<Map<String, dynamic>> selectedClients = [];
  List<Map<String, dynamic>> allIndividualPrograms = [];
  List<Map<String, dynamic>> allRecoveryPrograms = [];
  List<Map<String, dynamic>> allAutomaticPrograms = [];
  List<Map<String, dynamic>> allClients = [];
  List<String> respuestaTroceada = [];
  final List<bool> _isMusculoTrajeInactivo = [
    false, //PECHO
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //TRAPECIOS
    false, //DORSALES
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoPantalonInactivo = [
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoTrajeBloqueado = [
    false, //PECHO
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //TRAPECIOS
    false, //DORSALES
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];

  final List<bool> _isMusculoPantalonBloqueado = [
    false, //BICEPS
    false, //ABS
    false, //CUADRICEPS
    false, //GEMELOS
    false, //LUMBARES
    false, //GLUTEOS
    false //ISQUIOS
  ];
  List<List<int>> porcentajesPorGrupoTraje = [
    [0, 10, 20, 35], // Pecho
    [0, 10, 20, 35], // Brazo
    [0, 25, 45, 70], // Abdomen
    [0, 20, 40, 60], // Cuadriceps
    [0, 10, 20, 35], // Gemelo
    [0, 10, 20, 35], // Trapecio
    [0, 15, 30, 50], // Dorsal
    [0, 15, 30, 50], // Lumbar
    [0, 25, 45, 70], // Glúteo
    [0, 15, 30, 50], // Isquiotibial
  ];
  List<List<int>> porcentajesPorGrupoPantalon = [
    [0, 10, 20, 35], // Brazo
    [0, 25, 45, 70], // Abdomen
    [0, 20, 40, 60], // Cuadriceps
    [0, 10, 20, 35], // Gemelo
    [0, 15, 30, 50], // Lumbar
    [0, 25, 45, 70], // Glúteo
    [0, 15, 30, 50], // Isquiotibial
  ];

  final List<int> porcentajesMusculoTraje = List.filled(10, 0);
  final List<int> porcentajesMusculoPantalon = List.filled(7, 0);

  Map<int, String> imagePaths = {
    1: 'assets/images/31.png',
    2: 'assets/images/30.png',
    3: 'assets/images/29.png',
    4: 'assets/images/28.png',
    5: 'assets/images/27.png',
    6: 'assets/images/26.png',
    7: 'assets/images/25.png',
    8: 'assets/images/24.png',
    9: 'assets/images/23.png',
    10: 'assets/images/22.png',
    11: 'assets/images/21.png',
    12: 'assets/images/20.png',
    13: 'assets/images/19.png',
    14: 'assets/images/18.png',
    15: 'assets/images/17.png',
    16: 'assets/images/16.png',
    17: 'assets/images/15.png',
    18: 'assets/images/14.png',
    19: 'assets/images/13.png',
    20: 'assets/images/12.png',
    21: 'assets/images/11.png',
    22: 'assets/images/10.png',
    23: 'assets/images/9.png',
    24: 'assets/images/8.png',
    25: 'assets/images/7.png',
    26: 'assets/images/6.png',
    27: 'assets/images/5.png',
    28: 'assets/images/4.png',
    29: 'assets/images/3.png',
    30: 'assets/images/2.png',
    31: 'assets/images/1.png',
  };

  Color selectedColor = const Color(0xFF2be4f3);
  Color unselectedColor = const Color(0xFF494949);

  @override
  void initState() {
    super.initState();
    bleConnectionService = BleConnectionService();
    currentStatus = 'Estado inicial para ${widget.macAddress}';
    _currentImageIndex = imagePaths.length - time;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {});
    // Crear el controlador de animación de opacidad
    _opacityController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Hace que la animación repita y reverse

    // Crear la animación de opacidad
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _clientsProvider = Provider.of<ClientsProvider>(context, listen: false);
      });
    });
    loadCachedPrograms();
    widget.groupedA.addListener(() {
      debugPrint(
        "🛠️ Grupos actualizados A: ${widget.groupedA.value}",
      );
    });
    widget.groupedB.addListener(() {
      debugPrint(
        "🛠️ Grupos actualizados B: ${widget.groupedB.value}",
      );
    });
    initializeDataProgram();
    if (selectedIndivProgram != null &&
        selectedIndivProgram!['video'] != null &&
        selectedIndivProgram!['video'].isNotEmpty) {
      _initializeVideoController(
          selectedIndivProgram!['video'], widget.macAddress!);
    }
  }

  Future<void> initializeDataProgram() async {
    await obtenerDatos(); // Esperar a que se obtengan los datos
    _fetchClients();
    await _fetchIndividualPrograms(); // Esperar a que se asigne la información
    _fetchRecoveryPrograms();
    _fetchAutoPrograms();
  }

  @override
  void didUpdateWidget(covariant ExpandedContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detectar cambios en selectedIndivProgram y actualizar el controlador si cambia la URL del video.
    if (selectedIndivProgram != null &&
        selectedIndivProgram!['video'] != selectedIndivProgram?['video']) {
      _initializeVideoController(
          selectedIndivProgram!['video'], widget.macAddress!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  } // Verificar que BLE esté inicializado correctamente

  Future<void> _initializeVideoController(
      String? videoUrl, String macAddress) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      print("No se proporcionó una URL de video válida.");
      setState(() {
        _isLoading = false;
        _videoController = null;
      });
      return;
    }

    print("Intentando reproducir: $videoUrl");
    setState(() {
      _isLoading = true;
    });

    try {
      // Cancela cualquier controlador existente antes de inicializar uno nuevo.
      await _cancelVideoInitialization();

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // Agregar el listener al controlador.
      _videoController!.addListener(_videoControllerListener);

      // Inicializar el controlador.
      await _videoController!.initialize();

      setState(() {
        _isLoading = false;
        _showVideo = true;
      });
    } catch (e) {
      print("Error al inicializar el video: $e");
      setState(() {
        _isLoading = false;
        _videoController = null;
        _showVideo = false;
      });
    }
  }

  void _videoControllerListener() {
    if (_videoController != null && mounted) {
      print("VideoController State: ${_videoController!.value}");
      setState(() {}); // Forzar la actualización del estado.
    }
  }

  void _togglePlayPause(String macAddress) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }

    setState(() {});
  }

  Future<void> _cancelVideoInitialization() async {
    try {
      // Verifica si existe un controlador.
      if (_videoController != null) {
        // Elimina el listener antes de desechar el controlador.
        _videoController!.removeListener(_videoControllerListener);
        await _videoController!.dispose();
        print("VideoController cancelado y liberado correctamente.");
      }
    } catch (e) {
      print("Error al cancelar el VideoController: $e");
    }

    // Actualiza el estado para reflejar la cancelación.
    if (mounted) {
      setState(() {
        _videoController = null;
        _showVideo = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _preloadImages() async {
    // Itera sobre las claves del mapa (1 a 31)
    for (int key in imagePaths.keys) {
      String path = imagePaths[key]!; // Obtiene la ruta de la imagen
      await precacheImage(AssetImage(path), context); // Pre-carga la imagen
    }

    // Cambia el estado una vez que todas las imágenes estén precargadas
    setState(() {
      _isImagesLoaded = true;
    });
  }

  void playBeep() async {
    // Asegúrate de que la ruta del archivo sea correcta
    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
  }

  // Función de encriptación
  String encrip(String wcadena) {
    String xkkk =
        'ABCDE0FGHIJ1KLMNO2PQRST3UVWXY4Zabcd5efghi6jklmn7opqrs8tuvwx9yz(),-.:;@';
    String xkk2 = '[]{}<>?¿!¡*#';
    int wp = 0, wd = 0, we = 0, wr = 0;
    String wa = '', wres = '';
    int wl = xkkk.length;
    var wcont = Random().nextInt(10);

    if (wcadena.isNotEmpty) {
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

  Future<List<String>> getTrainer(String modulo) async {
    // Encripta el módulo
    String datos = encrip("18<#>$modulo");
    // Construye la URL
    Uri url = Uri.parse("https://imotionems.es/lic2.php?a=$datos");

    try {
      // Realiza la solicitud GET
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Trocea la respuesta por "|"
        return response.body.split('|');
      } else {
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Ocurrió un error: $e");
    }
  }

  // Obtener datos y guardarlos localmente
  Future<void> obtenerDatos() async {
    try {
      List<String> datos = await getTrainer("imotion21");

      List<String> datosFiltrados =
          datos.where((element) => element.isNotEmpty).toList();

      setState(() {
        respuestaTroceada = datosFiltrados;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }

  // La función toggleFullScreen se define aquí, pero será ejecutada por el hijo
  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
    widget.isFullChanged(isFullScreen);
  }

  void toggleOverlay(int index) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      overlayIndex = isOverlayVisible ? index : -1; // Actualiza el índice
    });
  }

  void selectEquip(int index) {
    setState(() {
      selectedIndexEquip = index; // Actualizar índice local
    });
    widget.onSelectEquip(index); // Notificar cambio a PanelView
    print("🔄 Cambiado al equipo $index para clave: ${widget.selectedKey}");
  }

  void onClientSelected(Map<String, dynamic>? client) {
    setState(() {
      selectedClient = client; // Actualiza el cliente individual seleccionado
      if (client != null &&
          !selectedClients.any((c) => c['id'] == client['id'])) {
        selectedClients.add(
            client); // Agrega a la lista de clientes seleccionados si no está en la lista
      }
    });

    // Imprime el nombre del cliente seleccionado
    if (selectedClient != null) {
      print("Cliente seleccionado: ${selectedClient!['name']}");
    }

    // Imprime la lista de clientes seleccionados
    print(
        "Lista de clientes seleccionados: ${selectedClients.map((c) => c['name']).toList()}");

    widget.onClientSelected(client); // Pasa el cliente seleccionado
  }

  void _clearGlobals() async {
    if (mounted) {
      await _cancelVideoInitialization();
      setState(() {
        // Verifica si la sesión se ha iniciado antes de detenerla
        isElectroOn = false;
        _isLoading = false;
        _showVideo = false;

        // Restablecer variables globales
        selectedProgram = null;
        selectedAutoProgram = null;
        selectedClient = null;

        isSessionStarted = false;
        _isImagesLoaded = false;
        isRunning = false;
        isContractionPhase = true;
        isPantalonSelected = false;
        selectedIndexEquip = 0;
        // Restablecer los programas
        selectedProgram = null;
        selectedAutoProgram = null;
        selectedIndivProgram = null;
        selectedRecoProgram = null;
        // Restablecer valores de escalado
        scaleFactorFull = 1.0;
        scaleFactorCliente = 1.0;
        scaleFactorRepeat = 1.0;
        scaleFactorTrainer = 1.0;
        scaleFactorRayo = 1.0;
        scaleFactorReset = 1.0;
        scaleFactorMas = 1.0;
        scaleFactorMenos = 1.0;

        // Restablecer los valores de rotación
        rotationAngle1 = 0.0;
        rotationAngle2 = 0.0;
        rotationAngle3 = 0.0;

        // Restablecer los índices y estados de expansión
        _isExpanded1 = false;
        _isExpanded2 = false;
        _isExpanded3 = false;

        // Restablecer el estado de la imagen y su índice
        _currentImageIndex = 31 - 25;
        currentSubprogramIndex = 0;
        remainingTime = 0;

        // Restablecer la lista de músculos inactivos
        _isMusculoTrajeInactivo.fillRange(0, 10, false);
        _isMusculoPantalonInactivo.fillRange(0, 7, false);

        // Restablecer los bloqueos de músculos
        _isMusculoTrajeBloqueado.fillRange(0, 10, false);
        _isMusculoPantalonBloqueado.fillRange(0, 7, false);

        // Limpiar las variables de los temporizadores de los subprogramas
        subprogramElapsedTime = {};
        subprogramRemainingTime = {};

        // Restablecer los porcentajes
        porcentajesMusculoTraje.fillRange(0, 10, 0);
        porcentajesMusculoPantalon.fillRange(0, 7, 0);

        // Restablecer las variables relacionadas con el temporizador
        valueContraction = 1.0;
        valueRampa = 1.0;
        valuePause = 1.0;

        elapsedTime = 0.0;
        elapsedTimeSub = 0.0;
        time = 25;
        seconds = 0.0;
        progress = 1.0;
        elapsedTimeContraction = 0.0;
        elapsedTimePause = 0.0;
        progressContraction = 0.0;
        progressPause = 0.0;
        startTime = DateTime.now();
        pausedTime = 0.0;

        // Cancelar cualquier temporizador activo
        _phaseTimer?.cancel();
        timerSub?.cancel();
        _timer.cancel();

        // Restablecer los temporizadores de subprograma (reiniciar todo)
        remainingTime = 0;
        elapsedTimeSub = 0.0;
        currentSubprogramIndex = 0;
      });
    }
  }

  Future<void> _fetchClients() async {
    final dbHelper = DatabaseHelper();
    try {
      final clientData = await dbHelper.getClients();
      if (mounted) {
        setState(() {
          allClients = clientData; // Asigna a la lista original
        });
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    }
  }

  Future<void> _fetchIndividualPrograms() async {
    var db = await DatabaseHelper().database;
    try {
      final individualProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoIndividual(db);

      if (respuestaTroceada.isEmpty) {
        throw Exception(
            "No se han cargado los datos de videos. Ejecuta 'obtenerDatos()' primero.");
      }

      for (int i = 0; i < individualProgramData.length; i++) {
        var program = Map<String, dynamic>.from(individualProgramData[i]);
        var video =
            (i < respuestaTroceada.length) ? respuestaTroceada[i] : null;
        program['video'] = video;

        individualProgramData[i] = program;
      }

      if (mounted) {
        setState(() {
          allIndividualPrograms = individualProgramData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchRecoveryPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      final recoveryProgramData = await DatabaseHelper()
          .obtenerProgramasPredeterminadosPorTipoRecovery(db);

      for (var recoveryProgram in recoveryProgramData) {
        var cronaxias = await DatabaseHelper()
            .obtenerCronaxiasPorPrograma(db, recoveryProgram['id_programa']);
        var grupos = await DatabaseHelper()
            .obtenerGruposPorPrograma(db, recoveryProgram['id_programa']);
      }

      if (mounted) {
        setState(() {
          allRecoveryPrograms =
              recoveryProgramData; // Asignamos los programas obtenidos a la lista
        });
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  Future<void> _fetchAutoPrograms() async {
    var db = await DatabaseHelper()
        .database; // Obtener la instancia de la base de datos
    try {
      final autoProgramData =
          await DatabaseHelper().obtenerProgramasAutomaticosConSubprogramas(db);

      List<Map<String, dynamic>> groupedPrograms =
          _groupProgramsWithSubprograms(autoProgramData);

      if (mounted) {
        setState(() {
          allAutomaticPrograms =
              groupedPrograms; // Asigna los programas obtenidos a la lista
        });
        _saveProgramsToCache(groupedPrograms);
      }
    } catch (e) {
      debugPrint('Error fetching programs: $e');
    }
  }

  List<Map<String, dynamic>> _groupProgramsWithSubprograms(
      List<Map<String, dynamic>> autoProgramData) {
    List<Map<String, dynamic>> groupedPrograms = [];

    for (var autoProgram in autoProgramData) {
      List<Map<String, dynamic>> subprogramas =
          autoProgram['subprogramas'] ?? [];

      Map<String, dynamic> groupedProgram = {
        'id_programa_automatico': autoProgram['id_programa_automatico'],
        'nombre_programa_automatico': autoProgram['nombre'],
        'imagen': autoProgram['imagen'],
        'descripcion_programa_automatico': autoProgram['descripcion'],
        'duracionTotal': autoProgram['duracionTotal'],
        'tipo_equipamiento': autoProgram['tipo_equipamiento'],
        'subprogramas': subprogramas,
      };

      groupedPrograms.add(groupedProgram);
    }

    return groupedPrograms;
  }

  Future<void> _saveProgramsToCache(List<Map<String, dynamic>> programs) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertir la lista de programas a formato JSON y guardarla
    String jsonPrograms = jsonEncode(programs);
    await prefs.setString('cachedPrograms', jsonPrograms);
  }

  Future<List<Map<String, dynamic>>> _loadProgramsFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener los datos guardados en caché
    String? cachedData = prefs.getString('cachedPrograms');

    if (cachedData != null) {
      // Si hay datos en caché, convertirlos de JSON a lista de Map<String, dynamic>
      List<dynamic> decodedData = jsonDecode(cachedData);
      return List<Map<String, dynamic>>.from(decodedData);
    }
    return [];
  }

  void loadCachedPrograms() async {
    List<Map<String, dynamic>> cachedPrograms = await _loadProgramsFromCache();
    if (cachedPrograms.isNotEmpty) {
      if (mounted) {
        setState(() {
          allAutomaticPrograms = cachedPrograms;
        });
      }
    } else {
      // Si no hay programas en caché, puedes optar por llamar a _fetchAutoPrograms nuevamente.
      await _fetchAutoPrograms();
    }
  }

  void updateContractionAndPauseValues() {
    if (selectedProgram == tr(context, 'Individual').toUpperCase() &&
        selectedIndivProgram != null) {
      valueContraction =
          (selectedIndivProgram!['contraccion'] as double?) ?? valueContraction;
      valuePause = (selectedIndivProgram!['pausa'] as double?) ?? valuePause;
      valueRampa = (selectedIndivProgram!['rampa'] as double?) ?? valueRampa;
    } else if (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
        selectedRecoProgram != null) {
      valueContraction =
          (selectedRecoProgram!['contraccion'] as double?) ?? valueContraction;
      valuePause = (selectedRecoProgram!['pausa'] as double?) ?? valuePause;
      valueRampa = (selectedRecoProgram!['rampa'] as double?) ?? valueRampa;
    } else if (selectedProgram == tr(context, 'Automáticos').toUpperCase() &&
        selectedAutoProgram != null) {
      totalTime = (selectedAutoProgram!['duracion']) ?? totalTime;
      valueContraction = (selectedAutoProgram!['subprogramas']
              [currentSubprogramIndex]['contraccion'] as double?) ??
          valueContraction;
      valuePause = (selectedAutoProgram!['subprogramas'][currentSubprogramIndex]
              ['pausa'] as double?) ??
          valuePause;
      valueRampa = (selectedAutoProgram!['subprogramas'][currentSubprogramIndex]
              ['rampa'] as double?) ??
          valueRampa;
    }
  }

  void _startTimer(String macAddress, List<int> porcentajesMusculoTraje,
      List<int> porcentajesMusculoPantalon) {
    if (isRunning) return; // Evita iniciar si ya está corriendo
    if (mounted) {
      setState(() {
        isRunning = true;
        isSessionStarted = true;
        startTime = DateTime.now();
        _togglePlayPause(widget.macAddress!);
        // Inicia o reanuda el temporizador principal
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              elapsedTime = pausedTime +
                  DateTime.now().difference(startTime).inSeconds.toDouble();
              progress = 1.0 - (elapsedTime / totalTime); // Reducir el progreso

              seconds = (totalTime - elapsedTime).toInt() % 60;
              time = (totalTime - elapsedTime).toInt() ~/ 60;

              if ((totalTime - elapsedTime) % 60 == 0) {
                _currentImageIndex = imagePaths.length - time;
              }

              // Detiene el temporizador al alcanzar el tiempo total
              if (elapsedTime >= totalTime) {
                _stopAllTimersAndReset(widget.macAddress!);
              }
            });
          }
        });

        // Asegura que startSubprogramTimer solo se ejecute si ambos son no nulos
        if (selectedProgram != null && selectedAutoProgram != null) {
          startSubprogramTimer(widget.macAddress!);
        }

        // Reanuda el temporizador de contracción o pausa
        if (isContractionPhase) {
          _startContractionTimer(valueContraction, widget.macAddress!,
              porcentajesMusculoTraje, porcentajesMusculoPantalon);
        } else {
          _startPauseTimer(valuePause, widget.macAddress!,
              porcentajesMusculoTraje, porcentajesMusculoPantalon);
        }
      });
    }
  }

  void _updateTime(int newTime) {
    if (mounted) {
      setState(() {
        if (newTime < 1) newTime = 1; // Tiempo mínimo de 1 minuto
        if (newTime > 30) newTime = 30; // Tiempo máximo de 30 minutos

        // Reinicia el tiempo transcurrido
        //elapsedTime = 0;

        // Actualiza el tiempo en minutos
        time = newTime;

        // Actualiza totalTime a segundos (newTime en minutos * 60)
        totalTime = time * 60;

        // Reinicia el startTime para que el temporizador comience desde cero
        startTime = DateTime.now();

        // Calcula el nuevo índice de la imagen según el tiempo
        _currentImageIndex = 31 - time;
      });
    }
  }

  void _pauseTimer(String macAddress) {
    if (mounted) {
      setState(() {
        stopElectrostimulationProcess(widget.macAddress!);
        _togglePlayPause(widget.macAddress!);
        isRunning = false;
        isSessionStarted = false;
        pausedTime = elapsedTime; // Guarda el tiempo del temporizador principal
        _timer.cancel();
        stopSubprogramTimer(
            widget.macAddress!); // Detiene el temporizador de subprograma
        _phaseTimer?.cancel(); // Detiene el temporizador de fase
      });
    }
  }

  void _stopAllTimersAndReset(String macAddress) {
    if (mounted) {
      // Pausa el temporizador antes de reiniciar las variables globales
      _pauseTimer(widget.macAddress!);
      playBeep();
      toggleOverlay(5);
      // Espera 2 segundos antes de reiniciar las variables globales
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _clearGlobals(); // Reinicia las variables globales
            debugPrint(
                "🔄 Variables globales reiniciadas después de la pausa.");
          });
        }
      });
    }
  }

  void _startContractionTimer(
    double contractionDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer?.cancel(); // Detiene cualquier temporizador previo

    // Verificar y sincronizar con el estado BLE
    if (isElectroOn == false) {
      if (selectedIndexEquip == 0) {
        // Si el índice seleccionado es 0, iniciar la sesión para traje
        startFullElectrostimulationTrajeProcess(
                widget.macAddress!, porcentajesMusculoTraje, selectedProgram)
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                isElectroOn = true; // Actualizar estado local
              });
            }

            // Una vez confirmada la sesión, iniciar el temporizador de contracción
            _startContractionPhase(contractionDuration, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          } else {
            debugPrint(
                "❌ Error al iniciar la electroestimulación para traje durante la fase de contracción.");
          }
        });
      } else if (selectedIndexEquip == 1) {
        // Si el índice seleccionado es 1, iniciar la sesión para pantalón
        startFullElectrostimulationPantalonProcess(
                widget.macAddress!, porcentajesMusculoPantalon, selectedProgram)
            .then((success) {
          if (success) {
            if (mounted) {
              setState(() {
                isElectroOn = true; // Actualizar estado local
              });
            }

            // Una vez confirmada la sesión, iniciar el temporizador de contracción
            _startContractionPhase(contractionDuration, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          } else {
            debugPrint(
                "❌ Error al iniciar la electroestimulación para pantalón durante la fase de contracción.");
          }
        });
      } else {
        debugPrint("❌ Índice seleccionado no válido: $selectedIndex");
      }
    } else {
      // Si ya está activo, inicia directamente el temporizador
      _startContractionPhase(contractionDuration, widget.macAddress!,
          porcentajesMusculoTraje, porcentajesMusculoPantalon);
    }
  }

  void _startContractionPhase(
    double contractionDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          elapsedTimeContraction += 0.1;
          progressContraction = elapsedTimeContraction / contractionDuration;

          if (elapsedTimeContraction >= contractionDuration) {
            elapsedTimeContraction = 0.0;
            isContractionPhase = false;
            _startPauseTimer(valuePause, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          }
        });
      }
    });
  }

  Future<void> _startPauseTimer(
    double pauseDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) async {
    // Detener cualquier temporizador previo
    _phaseTimer?.cancel();

    try {
      // Intentar detener la electroestimulación antes de iniciar la pausa
      bool success = await stopElectrostimulationProcess(widget.macAddress!);

      if (success) {
        debugPrint(
            "✅ Electroestimulación detenida correctamente antes de la pausa.");
        // Iniciar la fase de pausa, independientemente del resultado
        _startPausePhase(
          pauseDuration,
          widget.macAddress!,
          porcentajesMusculoTraje,
          porcentajesMusculoPantalon,
        );
      } else {
        debugPrint("⚠️ No había electroestimulación activa para detener.");
      }
    } catch (e) {
      debugPrint(
          "❌ Error al detener la electroestimulación antes de la pausa: $e");
    }
  }

  void _startPausePhase(
    double pauseDuration,
    String macAddress,
    List<int> porcentajesMusculoTraje,
    List<int> porcentajesMusculoPantalon,
  ) {
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          elapsedTimePause += 0.1;
          progressPause = elapsedTimePause / pauseDuration;

          if (elapsedTimePause >= pauseDuration) {
            elapsedTimePause = 0.0;
            isContractionPhase = true;
            _startContractionTimer(valueContraction, widget.macAddress!,
                porcentajesMusculoTraje, porcentajesMusculoPantalon);
          }
        });
      }
    });
  }

  void startSubprogramTimer(String macAddress) {
    // Verificar si selectedAutoProgram es nulo y usar allAutoPrograms[0] si es el caso
    var programToUse = selectedAutoProgram ?? allAutomaticPrograms[0];

    // Verificar si la lista 'subprogramas' está vacía
    if (programToUse['subprogramas'].isEmpty) {
      print("La lista de subprogramas está vacía.");
      return; // Salir de la función si la lista está vacía
    }

    // Validar que el índice actual está dentro de la lista de subprogramas
    if (currentSubprogramIndex < programToUse['subprogramas'].length) {
      // Obtener la duración en minutos del subprograma actual y convertirla a segundos
      double durationInMinutes = programToUse['subprogramas']
          [currentSubprogramIndex]['duracion'] as double;

      // Si el subprograma es el primero (índice 0), no restar nada
      // Para los subprogramas posteriores, restar 1 segundo
      int durationInSeconds;
      if (currentSubprogramIndex > 0) {
        durationInSeconds = (durationInMinutes * 60).toInt() -
            1; // Restar 1 segundo solo a partir del segundo subprograma
      } else {
        durationInSeconds = (durationInMinutes * 60)
            .toInt(); // No restar nada en el primer subprograma
      }

      // Inicializar o recuperar los tiempos para el subprograma actual
      if (!subprogramElapsedTime.containsKey(currentSubprogramIndex)) {
        subprogramElapsedTime[currentSubprogramIndex] =
            0.0; // Si no tiene valor, inicializar
      }
      if (!subprogramRemainingTime.containsKey(currentSubprogramIndex)) {
        subprogramRemainingTime[currentSubprogramIndex] =
            durationInSeconds; // Duración en segundos
      }

      // Actualizar remainingTime y elapsedTimeSub para el subprograma actual
      remainingTime = subprogramRemainingTime[currentSubprogramIndex]!;
      elapsedTimeSub = subprogramElapsedTime[currentSubprogramIndex]!;

      print(
          "Iniciando subprograma $currentSubprogramIndex con duración: $remainingTime segundos");

      if (isContractionPhase &&
          selectedAutoProgram != null &&
          !isPauseStarted) {
        // Iniciar primero el temporizador de pausa solo si las tres condiciones son verdaderas
        _startPauseTimer(valuePause, widget.macAddress!,
            porcentajesMusculoTraje, porcentajesMusculoPantalon);
        isPauseStarted = true; // Marcar que la pausa ha comenzado
      }

      // Iniciar temporizador para este subprograma
      timerSub = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          if (mounted) {
            setState(() {
              remainingTime--;
              elapsedTimeSub +=
                  1.0; // Aumentar el tiempo transcurrido en segundos
              subprogramRemainingTime[currentSubprogramIndex] =
                  remainingTime; // Actualizar remainingTime en el mapa
              subprogramElapsedTime[currentSubprogramIndex] =
                  elapsedTimeSub; // Actualizar elapsedTime en el mapa
            });
          }
        } else {
          timer.cancel();
          print("Subprograma $currentSubprogramIndex completado.");

          // Pasar al siguiente subprograma
          currentSubprogramIndex++;
          updateContractionAndPauseValues();
          startSubprogramTimer(
              widget.macAddress!); // Iniciar el siguiente subprograma
        }
      });
    } else {
      // Si se terminaron todos los subprogramas
      print("Todos los subprogramas completados.");
      // Aquí puedes agregar una acción al finalizar todos los subprogramas
    }
  }

  void stopSubprogramTimer(String macAddress) {
    timerSub?.cancel();
    if (mounted) {
      setState(() {
        isRunning = false;
      });
    }

    // Guardar el estado actual del subprograma
    var programToUse = selectedAutoProgram ?? allAutomaticPrograms[0];

    // Guardar el tiempo transcurrido en el mapa para el subprograma actual
    subprogramElapsedTime[currentSubprogramIndex] = elapsedTimeSub;
    subprogramRemainingTime[currentSubprogramIndex] = remainingTime;

    print(
        "Temporizador detenido. Tiempo transcurrido: $elapsedTimeSub segundos.");
  }

  Future<bool> startFullElectrostimulationTrajeProcess(
    String macAddress,
    List<int> porcentajesMusculoTraje,
    String? selectedProgram,
  ) async {
    try {
      if (porcentajesMusculoTraje.length != 10) {
        debugPrint(
            "❌ La lista porcentajesMusculoTraje debe tener exactamente 10 elementos.");
        return false;
      }

      // Configurar los valores de los canales del traje
      List<int> valoresCanalesTraje = List.filled(10, 0);
      valoresCanalesTraje[0] = porcentajesMusculoTraje[5];
      valoresCanalesTraje[1] = porcentajesMusculoTraje[6];
      valoresCanalesTraje[2] = porcentajesMusculoTraje[7];
      valoresCanalesTraje[3] = porcentajesMusculoTraje[8];
      valoresCanalesTraje[4] = porcentajesMusculoTraje[9];
      valoresCanalesTraje[5] = porcentajesMusculoTraje[0];
      valoresCanalesTraje[6] = porcentajesMusculoTraje[2];
      valoresCanalesTraje[7] = porcentajesMusculoTraje[3];
      valoresCanalesTraje[8] = porcentajesMusculoTraje[1];
      valoresCanalesTraje[9] = porcentajesMusculoTraje[4];

      debugPrint("📊 Valores de canales configurados: $valoresCanalesTraje");

      // Obtener configuraciones del programa seleccionado
      Map<String, double> settings = getProgramSettings(selectedProgram);
      double frecuencia = settings['frecuencia'] ?? 50;
      double rampa = settings['rampa'] ?? 30;
      double pulso = settings['pulso'] ?? 20;

      // Ajustes de conversión
      rampa *= 10;
      pulso /= 5;

      debugPrint(
          "⚙️ Configuración del programa: Frecuencia: $frecuencia Hz, Rampa: $rampa ms, Pulso: $pulso µs");

      // Iniciar sesión de electroestimulación
      final isElectroOn =
          await bleConnectionService._startElectrostimulationSession(
        widget.macAddress!,
        valoresCanalesTraje,
        frecuencia,
        rampa,
        pulso: pulso,
      );

      if (!isElectroOn) {
        debugPrint("❌ Error al iniciar la electroestimulación en $macAddress.");
        return false;
      }

      // Controlar todos los canales del dispositivo
      final response = await bleConnectionService._controlAllChannels(
        widget.macAddress!,
        1, // Endpoint
        0, // Modo
        valoresCanalesTraje,
      );

      if (response['resultado'] != "OK") {
        debugPrint("❌ Error al configurar los canales: $response");
        return false;
      }

      debugPrint(
          "✅ Proceso completo de electroestimulación iniciado correctamente en $macAddress.");
      return true;
    } catch (e) {
      debugPrint("❌ Error en el proceso completo de electroestimulación: $e");
      return false;
    }
  }

  Future<bool> startFullElectrostimulationPantalonProcess(
    String macAddress,
    List<int> porcentajesMusculoPantalon,
    String? selectedProgram,
  ) async {
    try {
      // Verificar que la lista tiene exactamente 7 elementos
      if (porcentajesMusculoPantalon.length != 7) {
        debugPrint(
            "❌ La lista porcentajesMusculoPantalon debe tener exactamente 7 elementos.");
        return false;
      }

      List<int> valoresCanalesPantalon = List.filled(
          10, 0); // Inicializamos la lista de valoresCanales con ceros.

// Asignar los valores de porcentajesMusculoPantalon a los canales
      valoresCanalesPantalon[0] = 0; // Forzar valor 0 en el índice 0
      valoresCanalesPantalon[1] = 0; // Forzar valor 0 en el índice 1
      valoresCanalesPantalon[2] = porcentajesMusculoPantalon[4];
      valoresCanalesPantalon[3] = porcentajesMusculoPantalon[5];
      valoresCanalesPantalon[4] = porcentajesMusculoPantalon[6];
      valoresCanalesPantalon[5] = 0; // Forzar valor 0 en el índice 5
      valoresCanalesPantalon[6] = porcentajesMusculoPantalon[1];
      valoresCanalesPantalon[7] = porcentajesMusculoPantalon[2];
      valoresCanalesPantalon[8] = porcentajesMusculoPantalon[0];
      valoresCanalesPantalon[9] = porcentajesMusculoPantalon[3];

// Debug: Mostrar los valores asignados
      for (int i = 0; i < valoresCanalesPantalon.length; i++) {
        debugPrint(
            "🔢 Canal ${i + 1}: ${valoresCanalesPantalon[i]} (Porcentaje: ${i < porcentajesMusculoPantalon.length ? porcentajesMusculoPantalon[i] : 0}%)");
      }

      // Paso 2: Obtener configuración del programa seleccionado
      Map<String, double> settings = getProgramSettings(selectedProgram);
      double frecuencia = settings['frecuencia'] ?? 50; // Valor por defecto
      double rampa = settings['rampa'] ?? 30; // Valor por defecto
      double pulso = settings['pulso'] ?? 20; // Valor por defecto

      // Ajustar los valores según las conversiones necesarias
      rampa *= 10;
      pulso /= 5;

      debugPrint(
          "✅ Frecuencia: $frecuencia Hz, Rampa: $rampa ms, Anchura de pulso: $pulso µs");

      // Paso 3: Iniciar la sesión de electroestimulación
      bool isElectroOn =
          await bleConnectionService._startElectrostimulationSession(
        widget.macAddress!,
        valoresCanalesPantalon,
        frecuencia,
        rampa,
        pulso: pulso,
      );

      if (isElectroOn) {
        // Paso 4: Controlar los canales
        Map<String, dynamic> response =
            await bleConnectionService._controlAllChannels(
          widget.macAddress!,
          1,
          0,
          valoresCanalesPantalon,
        );

        debugPrint(
            "📡 Respuesta de controlAllElectrostimulatorChannels: $response");

        if (response['resultado'] != "OK") {
          debugPrint("❌ Error al configurar los canales.");
          return false;
        }
        if (mounted) {
          setState(() {
            isElectroOn = true;
          });
        }
        return true;
      } else {
        debugPrint(
            "❌ Error al iniciar el proceso completo de electroestimulación.");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error en el proceso completo: $e");
      return false;
    }
  }

  Future<bool> stopElectrostimulationProcess(String macAddress) async {
    try {
      // Verificar si la electroestimulación está activa
      if (isElectroOn) {
        debugPrint(
            "🛑 Deteniendo la electroestimulación en el dispositivo ${widget.macAddress!}...");

        // Llamar al servicio para detener la sesión de electroestimulación
        await bleConnectionService
            ._stopElectrostimulationSession(widget.macAddress!);

        if (mounted) {
          // Actualizar el estado de la UI
          setState(() {
            isElectroOn =
                false; // Cambiar la bandera para reflejar que está detenida
          });
        }

        debugPrint(
            "✅ Electroestimulación detenida correctamente en ${widget.macAddress!}.");
        return true; // Operación exitosa
      } else {
        debugPrint(
            "⚠️ No hay ninguna sesión de electroestimulación activa para detener.");
        return false; // No había una sesión activa para detener
      }
    } catch (e) {
      debugPrint(
          "❌ Error al detener la electroestimulación en ${widget.macAddress!}: $e");
      return false; // Error durante la operación
    }
  }

  Future<void> _resetScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            // Aquí defines el ancho del diálogo
            height: MediaQuery.of(context).size.height * 0.3,
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.02,
                horizontal: MediaQuery.of(context).size.width * 0.01),
            decoration: BoxDecoration(
              color: const Color(0xFF494949),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF28E2F5),
                width: MediaQuery.of(context).size.width * 0.001,
              ),
            ),
            child: Column(
              children: [
                Text(
                  tr(context, 'Aviso').toUpperCase(),
                  style: TextStyle(
                      color: const Color(0xFF2be4f3),
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  tr(context, '¿Quieres resetear todo?').toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 25.sp),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
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
                            color: const Color(0xFF2be4f3), fontSize: 17.sp),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        _clearGlobals();
                        await bleConnectionService
                            ._stopElectrostimulationSession(widget.macAddress!);

                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          backgroundColor: Colors.red),
                      child: Text(
                        tr(context, '¡Sí, quiero resetear!').toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 17.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onProgramSelected(String program) {
    setState(() {
      selectedProgram = program; // Aquí actualizas el valor seleccionado
    });
    print("Programa seleccionado: $selectedProgram");
  }

  void onIndivProgramSelected(Map<String, dynamic>? programI) {
    setState(() {
      selectedIndivProgram = programI; // Actualizas el valor seleccionado
    });
    updateContractionAndPauseValues(); // Llamada para actualizar contracción y pausa
    print("Programa seleccionado: $selectedIndivProgram");
  }

  void onRecoProgramSelected(Map<String, dynamic>? programR) {
    setState(() {
      selectedRecoProgram = programR; // Actualizas el valor seleccionado
    });
    updateContractionAndPauseValues(); // Llamada para actualizar contracción y pausa
    print("Programa seleccionado: $selectedRecoProgram");
  }

  void onAutoProgramSelected(Map<String, dynamic>? programA) {
    setState(() {
      selectedAutoProgram = programA; // Actualizas el valor seleccionado
    });
    updateContractionAndPauseValues(); // Llamada para actualizar contracción y pausa
    print("Programa seleccionado: $selectedAutoProgram");
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print("🧹 Limpiando recursos del widget...");
    }
    // Cancelar el temporizador principal
    _timer.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador principal cancelado.");
    }

    // Cancelar el temporizador de fase (contracción/pausa)
    _phaseTimer?.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador de fase cancelado.");
    }

    timerSub?.cancel();
    if (kDebugMode) {
      print("⏲️ Temporizador de subprogramas cancelado.");
    }

    // Liberar el controlador de opacidad
    _opacityController.dispose();
    if (kDebugMode) {
      print("🔧 Controlador de opacidad liberado.");
    }

    // Limpiar la lista de clientes seleccionados del Provider
    if (_clientsProvider != null) {
      _clientsProvider!.clearSelectedClientsSilently(); // Limpia sin notificar
      if (kDebugMode) {
        print(
            "📋 Lista de clientes seleccionados borrada desde el Provider (sin notificación).");
      }
    }
    bleConnectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> selectedClients =
        Provider.of<ClientsProvider>(context).selectedClients;
    return SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            Column(
              children: [
                if (!isFullScreen) ...[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded1 =
                                    !_isExpanded1; // Cambia el estado de expansión
                                rotationAngle1 = _isExpanded1
                                    ? 3.14159
                                    : 0.0; // Cambia la dirección de la flecha (180 grados)
                              });
                            },
                            child: AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: rotationAngle1 / (2 * 3.14159),
                              child: SizedBox(
                                height: screenHeight * 0.15,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/flderecha.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01,
                                  horizontal: screenWidth * 0.01),
                              width: _isExpanded1 ? screenWidth * 0.25 : 0,
                              height: screenHeight * 0.2,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Botón "Cliente"
                                  Expanded(
                                    child: GestureDetector(
                                      onTapDown: widget.selectedKey == null
                                          ? null
                                          : (_) => setState(
                                              () => scaleFactorCliente = 0.90),
                                      onTapUp: widget.selectedKey == null
                                          ? null
                                          : (_) => setState(
                                              () => scaleFactorCliente = 1.0),
                                      onTap: widget.selectedKey == null ||
                                              isRunning
                                          ? null
                                          : () {
                                              setState(() {
                                                toggleOverlay(0);
                                              });
                                            },
                                      child: Opacity(
                                        opacity: widget.selectedKey == null
                                            ? 1.0
                                            : 1.0,
                                        // Indicación visual
                                        child: AnimatedScale(
                                          scale: scaleFactorCliente,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          child: Container(
                                            width: screenHeight * 0.1,
                                            height: screenWidth * 0.1,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF494949),
                                              shape: BoxShape
                                                  .circle, // Forma circular
                                            ),
                                            child: Center(
                                              child: SizedBox(
                                                width: screenWidth * 0.05,
                                                height: screenHeight * 0.05,
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/images/cliente.png',
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  // Botón "Equipo 0"
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: widget.selectedKey == null ||
                                          isRunning,
                                      // Bloquear interacción si no hay selección
                                      child: GestureDetector(
                                        onTap: () {
                                          selectEquip(0);
                                        },
                                        child: Opacity(
                                          opacity: widget.selectedKey == null
                                              ? 1.0
                                              : 1.0,
                                          // Indicación visual
                                          child: Container(
                                            width: screenWidth * 0.1,
                                            height: screenHeight * 0.1,
                                            decoration: BoxDecoration(
                                              color: selectedIndexEquip == 0
                                                  ? selectedColor
                                                  : unselectedColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                bottomLeft:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/chalecoblanco.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: AbsorbPointer(
                                      absorbing: widget.selectedKey == null ||
                                          isRunning,
                                      // Bloquear interacción si no hay selección
                                      child: GestureDetector(
                                        onTap: () {
                                          selectEquip(1);
                                        },
                                        child: Opacity(
                                          opacity: widget.selectedKey == null
                                              ? 1.0
                                              : 1.0,
                                          // Indicación visual
                                          child: Container(
                                            width: screenWidth * 0.1,
                                            height: screenHeight * 0.1,
                                            decoration: BoxDecoration(
                                              color: selectedIndexEquip == 1
                                                  ? selectedColor
                                                  : unselectedColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(10.0),
                                                bottomRight:
                                                    Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/pantalonblanco.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  // Botón "Repetir"
                                  Expanded(
                                    child: GestureDetector(
                                      onTapDown: widget.selectedKey == null
                                          ? null
                                          : (_) => setState(
                                              () => scaleFactorRepeat = 0.90),
                                      onTapUp: widget.selectedKey == null
                                          ? null
                                          : (_) => setState(
                                              () => scaleFactorRepeat = 1.0),
                                      onTap: widget.selectedKey == null ||
                                              isRunning
                                          ? null
                                          : () {
                                              // Acción para botón repetir
                                            },
                                      child: Opacity(
                                        opacity: widget.selectedKey == null
                                            ? 1.0
                                            : 1.0,
                                        // Indicación visual
                                        child: AnimatedScale(
                                          scale: scaleFactorRepeat,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          child: Container(
                                            width: screenHeight * 0.1,
                                            height: screenWidth * 0.1,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: SizedBox(
                                                child: ClipOval(
                                                  child: Image.asset(
                                                    'assets/images/repeat.png',
                                                    width: screenHeight * 0.1,
                                                    height: screenWidth * 0.1,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.02),
                            height: screenHeight * 0.2,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: widget.selectedKey == null ||
                                          isRunning
                                      ? null // Inhabilitar el botón si selectedKey es null
                                      : () {
                                          setState(() {
                                            toggleOverlay(
                                                1); // Suponiendo que toggleOverlay abre el overlay
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.01),
                                    side: BorderSide(
                                      width: screenWidth * 0.001,
                                      color: const Color(0xFF2be4f3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    backgroundColor: const Color(
                                        0xFF2be4f3), // Mantener color de fondo
                                  ),
                                  child: Text(
                                    (tr(context,
                                            selectedProgram ?? 'Programas'))
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      // Mantener color del texto
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Column(
                                  children: [
                                    // Condicional: Si globalSelectedProgram es null, muestra una imagen y texto predeterminados
                                    if (selectedProgram == null)
                                      Column(
                                        children: [
                                          // Texto predeterminado si no se ha seleccionado ningún programa
                                          Text(
                                            tr(context, 'Nombre programa')
                                                .toUpperCase(),
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          // Imagen predeterminada si no se ha seleccionado ningún programa
                                          Image.asset(
                                            'assets/images/programacreado.png',
                                            // Imagen predeterminada
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            fit: BoxFit.contain,
                                          ),
                                        ],
                                      ),

                                    if (selectedProgram ==
                                            tr(context, 'Individual')
                                                .toUpperCase() &&
                                        allIndividualPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                          Text(
                                            selectedIndivProgram?['nombre']
                                                    .toUpperCase() ??
                                                (allIndividualPrograms
                                                        .isNotEmpty
                                                    ? (allIndividualPrograms[0]
                                                                ['nombre']
                                                            ?.toUpperCase() ??
                                                        tr(context,
                                                                'NOMBRE PROGRAMA')
                                                            .toUpperCase())
                                                    : tr(context,
                                                            'No hay programas disponibles')
                                                        .toUpperCase()),
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),

                                          // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                          GestureDetector(
                                            onTap: widget.selectedKey == null ||
                                                    isRunning
                                                ? null // Deshabilitar el pulsado si selectedKey es null
                                                : () {
                                                    setState(() {
                                                      toggleOverlay(2);
                                                    });
                                                  },
                                            child: Image.asset(
                                              selectedIndivProgram != null
                                                  ? selectedIndivProgram![
                                                          'imagen'] ??
                                                      'assets/images/cliente.png'
                                                  : allIndividualPrograms
                                                          .isNotEmpty
                                                      ? allIndividualPrograms[0]
                                                              ['imagen'] ??
                                                          'assets/images/cliente.png'
                                                      : 'assets/images/cliente.png',
                                              // Imagen por defecto
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                            tr(context, 'Recovery')
                                                .toUpperCase() &&
                                        allRecoveryPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          // Mostrar el nombre del programa seleccionado o el primer programa por defecto
                                          Text(
                                            selectedRecoProgram?['nombre']
                                                    ?.toUpperCase() ??
                                                (allRecoveryPrograms.isNotEmpty
                                                    ? (allRecoveryPrograms[0]
                                                                ['nombre']
                                                            ?.toUpperCase() ??
                                                        tr(context,
                                                                'NOMBRE PROGRAMA')
                                                            .toUpperCase())
                                                    : tr(context,
                                                            'No hay programas disponibles')
                                                        .toUpperCase()),
                                            style: TextStyle(
                                              color: const Color(0xFF2be4f3),
                                              fontSize: 15.sp,
                                            ),
                                          ),

                                          // Imagen del programa seleccionado o la imagen del primer programa por defecto
                                          GestureDetector(
                                            onTap: widget.selectedKey == null ||
                                                    isRunning
                                                ? null // Deshabilitar el pulsado si selectedKey es null
                                                : () {
                                                    setState(() {
                                                      toggleOverlay(3);
                                                    });
                                                  },
                                            child: Image.asset(
                                              selectedRecoProgram != null
                                                  ? selectedRecoProgram![
                                                          'imagen'] ??
                                                      'assets/images/cliente.png'
                                                  : allRecoveryPrograms
                                                          .isNotEmpty
                                                      ? allRecoveryPrograms[0]
                                                              ['imagen'] ??
                                                          'assets/images/cliente.png'
                                                      : 'assets/images/cliente.png',
                                              // Imagen por defecto
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                            tr(context, 'Automáticos')
                                                .toUpperCase() &&
                                        allAutomaticPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          // Si isRunning es true, mostrar el primer subprograma
                                          if (selectedAutoProgram != null &&
                                              selectedAutoProgram![
                                                      'subprogramas']
                                                  .isNotEmpty)
                                            Column(
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${selectedAutoProgram!['nombre_programa_automatico']?.toUpperCase() ?? tr(context, 'Programa automático desconocido').toUpperCase()} ',
                                                        style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: widget.selectedKey ==
                                                              null ||
                                                          isRunning
                                                      ? null // Deshabilitar el pulsado si selectedKey es null
                                                      : () {
                                                          setState(() {
                                                            toggleOverlay(4);
                                                          });
                                                        },
                                                  child: Image.asset(
                                                    selectedAutoProgram![
                                                                    'subprogramas']
                                                                [
                                                                currentSubprogramIndex]
                                                            ['imagen'] ??
                                                        'assets/images/programacreado.png',
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            )
                                          // Si isRunning es false, mostrar el programa automático
                                          else
                                            Column(
                                              children: [
                                                Text(
                                                  selectedAutoProgram?[
                                                              'nombre_programa_automatico']
                                                          ?.toUpperCase() ??
                                                      (allAutomaticPrograms
                                                              .isNotEmpty
                                                          ? (allAutomaticPrograms[
                                                                          0][
                                                                      'nombre_programa_automatico']
                                                                  ?.toUpperCase() ??
                                                              tr(context,
                                                                      'NOMBRE PROGRAMA')
                                                                  .toUpperCase())
                                                          : tr(context,
                                                                  'No hay programas disponibles')
                                                              .toUpperCase()),
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF2be4f3),
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: widget.selectedKey ==
                                                              null ||
                                                          isRunning
                                                      ? null // Deshabilitar el pulsado si selectedKey es null
                                                      : () {
                                                          setState(() {
                                                            toggleOverlay(4);
                                                          });
                                                        },
                                                  child: Image.asset(
                                                    selectedAutoProgram != null
                                                        ? selectedAutoProgram![
                                                                'imagen'] ??
                                                            'assets/images/cliente.png'
                                                        : allAutomaticPrograms
                                                                .isNotEmpty
                                                            ? allAutomaticPrograms[
                                                                        0][
                                                                    'imagen'] ??
                                                                'assets/images/cliente.png'
                                                            : 'assets/images/cliente.png',
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.005),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (selectedProgram == null)
                                      Column(
                                        children: [
                                          Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                            tr(context, 'Individual')
                                                .toUpperCase() &&
                                        allIndividualPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          Text(
                                            selectedIndivProgram != null
                                                ? "${selectedIndivProgram!['frecuencia'] != null ? formatNumber(selectedIndivProgram!['frecuencia'] as double) : 'N/A'} Hz"
                                                : allIndividualPrograms
                                                        .isNotEmpty
                                                    ? "${formatNumber(allIndividualPrograms[0]['frecuencia'] as double)} Hz"
                                                    : " N/A",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Text(
                                            selectedIndivProgram != null
                                                ? "${selectedIndivProgram!['pulso'] != null ? formatNumber(selectedIndivProgram!['pulso'] as double) : 'N/A'} ms"
                                                : allIndividualPrograms
                                                        .isNotEmpty
                                                    ? "${formatNumber(allIndividualPrograms[0]['pulso'] as double)} ms"
                                                    : "N/A",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                            tr(context, 'Recovery')
                                                .toUpperCase() &&
                                        allRecoveryPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          Text(
                                            selectedRecoProgram != null
                                                ? "${selectedRecoProgram!['frecuencia'] != null ? formatNumber(selectedRecoProgram!['frecuencia'] as double) : 'N/A'} Hz"
                                                : allRecoveryPrograms.isNotEmpty
                                                    ? "${formatNumber(allRecoveryPrograms[0]['frecuencia'] as double)} Hz"
                                                    : "N/A",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          Text(
                                            selectedRecoProgram != null
                                                ? "${selectedRecoProgram!['pulso'] != null ? formatNumber(selectedRecoProgram!['pulso'] as double) : 'N/A'} ms"
                                                : allRecoveryPrograms.isNotEmpty
                                                    ? "${formatNumber(allRecoveryPrograms[0]['pulso'] as double)} ms"
                                                    : "N/A",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (selectedProgram ==
                                            tr(context, 'Automáticos')
                                                .toUpperCase() &&
                                        allAutomaticPrograms.isNotEmpty)
                                      Column(
                                        children: [
                                          // Si isRunning es true y hay subprogramas, mostrar la frecuencia y pulso del primer subprograma
                                          if (selectedAutoProgram != null &&
                                              selectedAutoProgram![
                                                      'subprogramas']
                                                  .isNotEmpty)
                                            Column(
                                              children: [
                                                // Mostrar frecuencia y pulso del subprograma
                                                Column(
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                ' ${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['orden'] ?? tr(context, 'Subprograma desconocido')}${'. '}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15
                                                                  .sp, // Tamaño más pequeño para el nombre del subprograma
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                '${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['nombre']?.toUpperCase() ?? tr(context, 'Subprograma desconocido').toUpperCase()}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.sp,
                                                              // Tamaño más pequeño para el nombre del subprograma
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              decorationColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Frecuencia
                                                    Text(
                                                      selectedAutoProgram !=
                                                                  null &&
                                                              selectedAutoProgram![
                                                                      'subprogramas']
                                                                  .isNotEmpty
                                                          ? "${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['frecuencia'] != null ? formatNumber(selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['frecuencia'] as double) : 'N/A'} Hz"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                                    // Pulso
                                                    Text(
                                                      selectedAutoProgram !=
                                                                  null &&
                                                              selectedAutoProgram![
                                                                      'subprogramas']
                                                                  .isNotEmpty
                                                          ? "${selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['pulso'] != null ? formatNumber(selectedAutoProgram!['subprogramas'][currentSubprogramIndex]['pulso'] as double) : 'N/A'} ms"
                                                          : "N/A",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                                    // Tiempo restante dinámico
                                                    Text(
                                                      selectedAutoProgram !=
                                                                  null &&
                                                              selectedAutoProgram![
                                                                      'subprogramas']
                                                                  .isNotEmpty
                                                          ? formatTime(
                                                              remainingTime)
                                                          : "N/A",
                                                      style: TextStyle(
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          // Si no hay subprogramas o isRunning es falso, no se muestra nada
                                          else
                                            Column(
                                              children: [
                                                // Mostrar duración total
                                                Text(
                                                  selectedAutoProgram != null
                                                      ? "${selectedAutoProgram!['duracionTotal'] != null ? formatNumber(selectedAutoProgram!['duracionTotal'] as double) : 'N/A'} min"
                                                      : allAutomaticPrograms
                                                              .isNotEmpty
                                                          ? "${formatNumber(allAutomaticPrograms[0]['duracionTotal'] as double)} min"
                                                          : "N/A",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                if (selectedIndexEquip == 0)
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(10.0),
                                      side: BorderSide(
                                          width: screenWidth * 0.001,
                                          color: const Color(0xFF2be4f3)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      tr(context, 'Ciclos').toUpperCase(),
                                      style: TextStyle(
                                        color: const Color(0xFF2be4f3),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("VIRTUAL TRAINER",
                                      style: TextStyle(
                                        color: const Color(0xFF2be4f3),
                                        fontSize: 15.sp,
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      final videoUrl =
                                          selectedIndivProgram?['video'];
                                      if (videoUrl != null &&
                                          videoUrl.isNotEmpty) {
                                        if (_videoController != null &&
                                            _videoController!
                                                .value.isInitialized) {
                                          // Si el controlador ya está inicializado, solo cambia el estado de visibilidad.
                                          setState(() {
                                            _showVideo =
                                                !_showVideo; // Cambiar entre mostrar u ocultar el video.
                                          });
                                          print(
                                              "VideoController ya inicializado. Cambiando visibilidad a: $_showVideo");
                                        } else {
                                          // Si no está inicializado, inicialízalo.
                                          _initializeVideoController(
                                              videoUrl, widget.macAddress!);
                                        }
                                      } else {
                                        print(
                                            "No se proporcionó una URL válida.");
                                      }
                                    },
                                    child: AnimatedScale(
                                      scale: 1.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.transparent),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/virtualtrainer.png',
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              GestureDetector(
                                onTapDown: (_) =>
                                    setState(() => scaleFactorRayo = 0.90),
                                onTapUp: (_) =>
                                    setState(() => scaleFactorRayo = 1.0),
                                onTap: () async {
                                  // Aquí llamamos a la función getPulseMeter al hacer tap
                                  try {
                                    // lamamos a la función que obtiene los datos del pulsómetro
                                    final response = await bleConnectionService
                                        ._getSignalCable(widget.macAddress!, 1);
                                    // Mostrar los datos en consola o en la UI
                                    debugPrint(
                                        "📊 Datos del pulsómetro: $response");
                                  } catch (e) {
                                    debugPrint(
                                        "❌ Error al obtener datos del pulsómetro: $e");
                                  }
                                },
                                child: AnimatedScale(
                                  scale: scaleFactorRayo,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        child: Image.asset(
                                          height: screenHeight * 0.1,
                                          'assets/images/rayoaz.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Expanded(
                  flex: isFullScreen ? 1 : 3,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: isFullScreen
                            ? screenHeight * 0.05
                            : screenHeight * 0.005),
                    child: Row(
                      children: [
                        Expanded(
                          flex: isFullScreen ? 1 : 6,
                          child: GestureDetector(
                            onTap: () {
                              if (_showVideo) {
                                setState(() {
                                  _hideControls = !_hideControls;
                                });
                              }
                            },
                            child: Stack(children: [
                              if (_showVideo)
                                Positioned.fill(
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : (_videoController != null &&
                                              _videoController!
                                                  .value.isInitialized)
                                          ? SizedBox(
                                              width: screenWidth,
                                              height: screenHeight,
                                              child: FittedBox(
                                                fit: BoxFit.cover,
                                                child: SizedBox(
                                                  width: _videoController!
                                                      .value.size.width,
                                                  height: _videoController!
                                                      .value.size.height,
                                                  child: VideoPlayer(
                                                      _videoController!),
                                                ),
                                              ),
                                            )
                                          : const Center(
                                              child: Text(
                                                "",
                                                style: TextStyle(
                                                    fontSize: 1,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                ),
                              if (_hideControls)
                                Row(
                                  children: [
                                    if (selectedIndexEquip == 0) ...[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 0,
                                              imagePathEnabled:
                                                  'assets/images/pec_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/pecazul.png',
                                              imagePathInactive:
                                                  'assets/images/pec_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 1,
                                              imagePathEnabled:
                                                  'assets/images/biceps_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/bicepsazul.png',
                                              imagePathInactive:
                                                  'assets/images/biceps_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 2,
                                              imagePathEnabled:
                                                  'assets/images/abs_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/absazul.png',
                                              imagePathInactive:
                                                  'assets/images/abs_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 3,
                                              imagePathEnabled:
                                                  'assets/images/cua_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/cuazul.png',
                                              imagePathInactive:
                                                  'assets/images/cua_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 4,
                                              imagePathEnabled:
                                                  'assets/images/gemelos_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gemelosazul.png',
                                              imagePathInactive:
                                                  'assets/images/gemelos_gris.png',
                                            ),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 0,
                                              imagePathEnabled:
                                                  'assets/images/pec_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/pec_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/pec_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 1,
                                              imagePathEnabled:
                                                  'assets/images/biceps_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/biceps_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/biceps_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 2,
                                              imagePathEnabled:
                                                  'assets/images/abs_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/abs_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/abs_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 3,
                                              imagePathEnabled:
                                                  'assets/images/cua_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/cua_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/cua_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 4,
                                              imagePathEnabled:
                                                  'assets/images/gemelos_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gemelos_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/gemelos_gris.png',
                                            ),
                                          ]
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/avatar_frontal.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_pecho_azul.png",
                                                                // Imagen para el estado animado
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        1]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja.png",
                                                          // Imagen bloqueada para bíceps
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_biceps_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        2]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        3]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_cua_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        4]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gem_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        0]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_pec_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        1]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        2]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        3]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        4]) ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja.png",
                                                          // Imagen bloqueada para abdominales
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelo_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        imagePaths[
                                                            _currentImageIndex]!,
                                                        // Accede al valor en el mapa usando la clave _currentImageIndex
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Column(
                                                        children: [
                                                          // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time < 30) {
                                                                  // Máximo valor de time es 30
                                                                  time++; // Aumentar el tiempo
                                                                  _updateTime(
                                                                      time);
                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-arriba.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                            style: TextStyle(
                                                              fontSize: 25.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: const Color(
                                                                  0xFF2be4f3), // Color para la sección seleccionada
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  // Mínimo valor de time es 1
                                                                  time--; // Disminuir el tiempo
                                                                  _updateTime(
                                                                      time);

                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-abajo.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.01),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter(
                                                          progress2:
                                                              progressContraction,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02, // Aumentar altura si isFullScreen es verdadero
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            valueContraction ??
                                                                0.0),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .lightGreenAccent
                                                              .shade400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter2(
                                                          progress3:
                                                              progressPause,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            valuePause ?? 0.0),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: isFullScreen
                                                        ? screenHeight * 0.02
                                                        : screenHeight *
                                                            0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "AVERAGE",
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 23.sp
                                                              : 18.sp,
                                                          // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                        ),
                                                      ),
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.15
                                                              : screenWidth *
                                                                  0.15,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.05
                                                              : screenHeight *
                                                                  0.05, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter:
                                                            AverageLineWithTextPainter(
                                                          average: calculateAverage(
                                                                  porcentajesMusculoTraje) /
                                                              100.0,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02,
                                                          // Aumentar altura si isFullScreen es verdadero
                                                          textStyle: TextStyle(
                                                            fontSize:
                                                                isFullScreen
                                                                    ? 23.sp
                                                                    : 18.sp,
                                                            // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/avatar_post.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_trap_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_dorsal_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        7]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris.png",
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        7]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_lumbar_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        8]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        8]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gluteo_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        9]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        9]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_isquio_azul.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoTrajeInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_trap_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_dorsal_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        7]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        7]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        8]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteos_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        8]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_gluteo_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoTrajeInactivo[
                                                        9]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoTrajeBloqueado[
                                                        9]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            children: [
                                              // Botón "Menos"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Disminuir el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoTrajeBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoTrajeBloqueado[
                                                                    i] &&
                                                                !_isMusculoTrajeInactivo[
                                                                    i]) {
                                                              porcentajesMusculoTraje[
                                                                      i] =
                                                                  (porcentajesMusculoTraje[
                                                                              i] -
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/menos.png',
                                                size: screenHeight * 0.1,
                                              ),

                                              SizedBox(
                                                  width: screenWidth * 0.01),
                                              // Botón de control de sesión (Reproducir/Pausar)
                                              GestureDetector(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          if (isRunning) {
                                                            // Pausa el temporizador si está corriendo
                                                            _pauseTimer(widget
                                                                .macAddress!);
                                                          } else {
                                                            _startTimer(
                                                                widget
                                                                    .macAddress!,
                                                                porcentajesMusculoTraje,
                                                                porcentajesMusculoPantalon);
                                                          }

                                                          debugPrint(
                                                              'INCIIANDO SESION ELECTRO PARA: ${widget.macAddress!}');
                                                        });
                                                      },
                                                child: SizedBox(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      height:
                                                          screenHeight * 0.15,
                                                      'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),

                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Aumentar el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoTrajeBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoTrajeBloqueado[
                                                                    i] &&
                                                                !_isMusculoTrajeInactivo[
                                                                    i]) {
                                                              porcentajesMusculoTraje[
                                                                      i] =
                                                                  (porcentajesMusculoTraje[
                                                                              i] +
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/mas.png',
                                                size: screenHeight * 0.1,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 5,
                                              imagePathEnabled:
                                                  'assets/images/trap_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/trapazul.png',
                                              imagePathInactive:
                                                  'assets/images/trap_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 6,
                                              imagePathEnabled:
                                                  'assets/images/dorsal_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/dorsalazul.png',
                                              imagePathInactive:
                                                  'assets/images/dorsal_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 7,
                                              imagePathEnabled:
                                                  'assets/images/lumbar_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/lumbarazul.png',
                                              imagePathInactive:
                                                  'assets/images/lumbar_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 8,
                                              imagePathEnabled:
                                                  'assets/images/gluteo_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gluteoazul.png',
                                              imagePathInactive:
                                                  'assets/images/gluteo_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 9,
                                              imagePathEnabled:
                                                  'assets/images/isquio_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/isquioazul.png',
                                              imagePathInactive:
                                                  'assets/images/isquio_gris.png',
                                            ),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow(
                                              index: 5,
                                              imagePathEnabled:
                                                  'assets/images/trap_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/trap_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/trap_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 6,
                                              imagePathEnabled:
                                                  'assets/images/dorsal_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/dorsal_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/dorsal_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 7,
                                              imagePathEnabled:
                                                  'assets/images/lumbar_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/lumbar_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/lumbar_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 8,
                                              imagePathEnabled:
                                                  'assets/images/gluteo_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/gluteo_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/gluteo_gris.png',
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow(
                                              index: 9,
                                              imagePathEnabled:
                                                  'assets/images/isquio_naranja.png',
                                              imagePathDisabled:
                                                  'assets/images/isquio_blanco.png',
                                              imagePathInactive:
                                                  'assets/images/isquio_gris.png',
                                            ),
                                          ]
                                        ],
                                      ),
                                    ] else if (selectedIndexEquip == 1) ...[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 0,
                                                imagePathEnabled:
                                                    'assets/images/biceps_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/bicepsazul.png',
                                                imagePathInactive:
                                                    'assets/images/biceps_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 1,
                                                imagePathEnabled:
                                                    'assets/images/abs_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/absazul.png',
                                                imagePathInactive:
                                                    'assets/images/abs_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 2,
                                                imagePathEnabled:
                                                    'assets/images/cua_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/cuazul.png',
                                                imagePathInactive:
                                                    'assets/images/cua_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 3,
                                                imagePathEnabled:
                                                    'assets/images/gemelos_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gemelosazul.png',
                                                imagePathInactive:
                                                    'assets/images/gemelos_gris.png'),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 0,
                                                imagePathEnabled:
                                                    'assets/images/biceps_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/biceps_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/biceps_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 1,
                                                imagePathEnabled:
                                                    'assets/images/abs_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/abs_blanco.png',
                                                imagePathInactive:
                                                    'assets/images/abs_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 2,
                                                imagePathEnabled:
                                                    'assets/images/cua_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/cua_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/cua_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 3,
                                                imagePathEnabled:
                                                    'assets/images/gemelos_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gemelo_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/gemelos_gris.png'),
                                          ]
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/pantalon_frontal.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_biceps_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        1]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_inf_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_abs_sup_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        2]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_cua_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        3]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_gem_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        0]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        0]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_biceps_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        1]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        1]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_inf_blanco.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_abs_sup_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        2]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        2]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_cua_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        3]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        3]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gemelos_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_gem_blanco_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        imagePaths[
                                                            _currentImageIndex]!,
                                                        // Accede al valor en el mapa usando la clave _currentImageIndex
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.25,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Column(
                                                        children: [
                                                          // Flecha hacia arriba para aumentar el tiempo (si el cronómetro no está corriendo)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time < 30) {
                                                                  // Máximo valor de time es 30
                                                                  time++; // Aumentar el tiempo
                                                                  _updateTime(
                                                                      time);

                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-arriba.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                          Text(
                                                            "${time.toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}",
                                                            style: TextStyle(
                                                              fontSize: 25.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: const Color(
                                                                  0xFF2be4f3), // Color para la sección seleccionada
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (time > 1) {
                                                                  // Mínimo valor de time es 1
                                                                  time--; // Disminuir el tiempo
                                                                  _updateTime(
                                                                      time);
                                                                  // No se ejecuta _startTimer, solo se actualiza el tiempo y el índice
                                                                  print(
                                                                      'Tiempo actualizado: $time minutos (${totalTime}s)');
                                                                }
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              'assets/images/flecha-abajo.png',
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.01),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter(
                                                          progress2:
                                                              progressContraction,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02, // Aumentar altura si isFullScreen es verdadero
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            valueContraction ??
                                                                0.0),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .lightGreenAccent
                                                              .shade400,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.1
                                                              : screenWidth *
                                                                  0.1,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter: LinePainter2(
                                                          progress3:
                                                              progressPause,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.025
                                                              : screenHeight *
                                                                  0.02,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: isFullScreen
                                                            ? screenWidth * 0.01
                                                            : screenWidth *
                                                                0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                            valuePause ?? 0.0),
                                                        // Si es nulo, pasamos 0.0 como valor por defecto
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 25.sp
                                                              : 20.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: isFullScreen
                                                        ? screenHeight * 0.02
                                                        : screenHeight *
                                                            0.01, // Aumentar el espacio si isFullScreen es verdadero
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "AVERAGE",
                                                        style: TextStyle(
                                                          fontSize: isFullScreen
                                                              ? 23.sp
                                                              : 18.sp,
                                                          // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: const Color(
                                                              0xFF2be4f3),
                                                        ),
                                                      ),
                                                      CustomPaint(
                                                        size: Size(
                                                          isFullScreen
                                                              ? screenWidth *
                                                                  0.15
                                                              : screenWidth *
                                                                  0.15,
                                                          // Aumentar tamaño si isFullScreen es verdadero
                                                          isFullScreen
                                                              ? screenHeight *
                                                                  0.05
                                                              : screenHeight *
                                                                  0.05, // Aumentar tamaño si isFullScreen es verdadero
                                                        ),
                                                        painter:
                                                            AverageLineWithTextPainter(
                                                          average: calculateAverage(
                                                                  porcentajesMusculoPantalon) /
                                                              100.0,
                                                          strokeHeight: isFullScreen
                                                              ? screenHeight *
                                                                  0.03
                                                              : screenHeight *
                                                                  0.02,
                                                          // Aumentar altura si isFullScreen es verdadero
                                                          textStyle: TextStyle(
                                                            fontSize:
                                                                isFullScreen
                                                                    ? 23.sp
                                                                    : 18.sp,
                                                            // Aumentar tamaño de fuente si isFullScreen es verdadero
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Imagen base del avatar
                                                  Image.asset(
                                                    "assets/images/pantalon_posterior.png",
                                                    height: isFullScreen
                                                        ? screenHeight * 0.65
                                                        : screenHeight * 0.4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  // Superposición de imágenes si `musculosTrajeSelected` es verdadero
                                                  if (isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        4]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_lumbar_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_glut_inf_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_glut_sup_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      // Si el músculo no está bloqueado, muestra la capa animada
                                                      Positioned(
                                                        top: 0,
                                                        child: AnimatedBuilder(
                                                          animation:
                                                              _opacityAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Opacity(
                                                              opacity:
                                                                  _opacityAnimation
                                                                      .value,
                                                              child:
                                                                  Image.asset(
                                                                "assets/images/capa_isquio_azul_pantalon.png",
                                                                height: isFullScreen
                                                                    ? screenHeight *
                                                                        0.65
                                                                    : screenHeight *
                                                                        0.4,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ] else if (!isSessionStarted) ...[
                                                    if (_isMusculoPantalonInactivo[
                                                        4]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        4]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_lumbar_blanco_pantalon.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        5]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        5]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_sup_blanco.png",
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_glut_inf_blanco.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                    if (_isMusculoPantalonInactivo[
                                                        6]) ...[
                                                      // Si el músculo está inactivo, muestra otra capa
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_gris_pantalon.png",
                                                          // Imagen para el estado inactivo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else if (_isMusculoPantalonBloqueado[
                                                        6]) ...[
                                                      // Si el músculo está bloqueado, muestra la capa estática bloqueada
                                                      Positioned(
                                                        top: 0,
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_naranja_pantalon.png",
                                                          // Imagen para el estado bloqueado
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      Positioned(
                                                        top: 0,
                                                        // Ajusta la posición de la superposición
                                                        child: Image.asset(
                                                          "assets/images/capa_isquio_blanco_pantalon.png",
                                                          // Reemplaza con la ruta de la imagen del músculo
                                                          height: isFullScreen
                                                              ? screenHeight *
                                                                  0.65
                                                              : screenHeight *
                                                                  0.4,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ]
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          Row(
                                            children: [
                                              // Botón "Menos"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Disminuir el porcentaje de los músculos no bloqueados
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoPantalonBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoPantalonBloqueado[
                                                                    i] &&
                                                                !_isMusculoPantalonInactivo[
                                                                    i]) {
                                                              porcentajesMusculoPantalon[
                                                                      i] =
                                                                  (porcentajesMusculoPantalon[
                                                                              i] -
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/menos.png',
                                                size: screenHeight * 0.1,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),

                                              // Botón de control de sesión (Reproducir/Pausar)
                                              GestureDetector(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          if (isRunning) {
                                                            // Pausa el temporizador si está corriendo
                                                            _pauseTimer(widget
                                                                .macAddress!);
                                                          } else {
                                                            // Inicia o reanuda el temporizador si está pausado
                                                            _startTimer(
                                                                widget
                                                                    .macAddress!,
                                                                porcentajesMusculoTraje,
                                                                porcentajesMusculoPantalon);
                                                          }
                                                          debugPrint(
                                                              'isSessionStarted: $isSessionStarted');
                                                        });
                                                      },
                                                child: SizedBox(
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      height:
                                                          screenHeight * 0.15,
                                                      'assets/images/${isRunning ? 'pause.png' : 'play.png'}',
                                                      fit: BoxFit.scaleDown,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.01),

                                              // Botón "Más"
                                              CustomIconButton(
                                                onTap: widget.selectedKey ==
                                                        null
                                                    ? null // Si selectedKey es null, el botón estará deshabilitado
                                                    : () {
                                                        setState(() {
                                                          // Aumentar el porcentaje de los músculos que no están bloqueados ni inactivos
                                                          for (int i = 0;
                                                              i <
                                                                  _isMusculoPantalonBloqueado
                                                                      .length;
                                                              i++) {
                                                            if (!_isMusculoPantalonBloqueado[
                                                                    i] &&
                                                                !_isMusculoPantalonInactivo[
                                                                    i]) {
                                                              porcentajesMusculoPantalon[
                                                                      i] =
                                                                  (porcentajesMusculoPantalon[
                                                                              i] +
                                                                          1)
                                                                      .clamp(0,
                                                                          100);
                                                            }
                                                          }
                                                        });
                                                      },
                                                imagePath:
                                                    'assets/images/mas.png',
                                                size: screenHeight * 0.1,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 4,
                                                imagePathEnabled:
                                                    'assets/images/lumbar_naranja_pantalon.png',
                                                imagePathDisabled:
                                                    'assets/images/lumbar_pantalon_azul.png',
                                                imagePathInactive:
                                                    'assets/images/lumbar_gris_pantalon.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 5,
                                                imagePathEnabled:
                                                    'assets/images/gluteo_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gluteoazul.png',
                                                imagePathInactive:
                                                    'assets/images/gluteo_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 6,
                                                imagePathEnabled:
                                                    'assets/images/isquio_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/isquioazul.png',
                                                imagePathInactive:
                                                    'assets/images/isquio_gris.png'),
                                          ] else if (!isSessionStarted) ...[
                                            _buildMuscleRow2(
                                                index: 4,
                                                imagePathEnabled:
                                                    'assets/images/lumbar_naranja_pantalon.png',
                                                imagePathDisabled:
                                                    'assets/images/lumbar_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/lumbar_gris_pantalon.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 5,
                                                imagePathEnabled:
                                                    'assets/images/gluteo_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/gluteo_blanco.png',
                                                imagePathInactive:
                                                    'assets/images/gluteo_gris.png'),
                                            SizedBox(
                                                height: screenHeight * 0.005),
                                            _buildMuscleRow2(
                                                index: 6,
                                                imagePathEnabled:
                                                    'assets/images/isquio_naranja.png',
                                                imagePathDisabled:
                                                    'assets/images/isquio_blanco_pantalon.png',
                                                imagePathInactive:
                                                    'assets/images/isquio_gris.png'),
                                          ]
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              if (isFullScreen)
                                Positioned(
                                  bottom: 0,
                                  // Distancia desde el borde superior
                                  right: 0,
                                  // Distancia desde el borde derecho
                                  child: GestureDetector(
                                    onTap: () {
                                      toggleFullScreen(); // Llamamos a la función toggleFullScreen
                                    },
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/fullscreen.png',
                                        width: screenWidth * 0.08,
                                        // Ajusta el tamaño según sea necesario
                                        height: screenHeight * 0.08,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ),
                        if (!isFullScreen)
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Primera sección (con las imágenes y el diseño de la primera parte)
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Contenedor para las imágenes flizquierda alineadas a la derecha
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              // Alineación hacia la derecha
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpanded2 =
                                                        !_isExpanded2; // Cambia el estado de expansión
                                                    rotationAngle2 = _isExpanded2
                                                        ? 3.14159
                                                        : 0.0; // Flecha rota 180 grados
                                                  });
                                                },
                                                child: AnimatedRotation(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  turns: rotationAngle2 /
                                                      (2 * 3.14159),
                                                  child: SizedBox(
                                                    height: screenHeight * 0.15,
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/flizquierda.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          AnimatedSize(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              width: _isExpanded2
                                                  ? screenWidth * 0.2
                                                  : 0,
                                              height: screenHeight * 0.2,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: selectedClients
                                                    .map((client) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                screenWidth *
                                                                    0.008),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          client['name']
                                                                  .toString()
                                                                  .toUpperCase() ??
                                                              'Sin nombre',
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: const Color(
                                                                0xFF2be4f3),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Image.asset(
                                                              width:
                                                                  screenWidth *
                                                                      0.05,
                                                              'assets/images/EKCAL.png',
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.01),
                                                            Text(
                                                              client['counter1']
                                                                      ?.toString() ??
                                                                  '0',
                                                              // Asegúrate de que el contador esté disponible
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Row(
                                        children: [
                                          // Contenedor para las imágenes flizquierda alineadas a la derecha
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              // Alineación hacia la derecha
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpanded3 =
                                                        !_isExpanded3; // Cambia el estado de expansión
                                                    rotationAngle3 = _isExpanded3
                                                        ? 3.14159
                                                        : 0.0; // Flecha rota 180 grados
                                                  });
                                                },
                                                child: AnimatedRotation(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  turns: rotationAngle3 /
                                                      (2 * 3.14159),
                                                  child: SizedBox(
                                                    height: screenHeight * 0.15,
                                                    child: ClipOval(
                                                      child: Image.asset(
                                                        'assets/images/flizquierda.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.01),
                                          AnimatedSize(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      screenHeight * 0.015,
                                                  horizontal:
                                                      screenWidth * 0.015),
                                              width: _isExpanded3
                                                  ? screenWidth * 0.2
                                                  : 0,
                                              height: screenHeight * 0.25,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  buildControlRow(
                                                    value: valueContraction,
                                                    // Valor de la contracción
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/CONTRACCION.png',
                                                    // Imagen que se muestra (Contracción)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valueContraction +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valueContraction >
                                                            0) {
                                                          valueContraction -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight:
                                                        screenHeight, // Altura de pantalla
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                  buildControlRow(
                                                    value: valuePause,
                                                    // Valor de pausa
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/PAUSA.png',
                                                    // Imagen que se muestra (Pausa)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valuePause +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valuePause > 0) {
                                                          valuePause -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight:
                                                        screenHeight, // Altura de pantalla
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.02),
                                                  buildControlRow(
                                                    value: valueRampa,
                                                    // Valor de pausa
                                                    imagePathIncrement:
                                                        'assets/images/mas.png',
                                                    // Imagen del botón de "Más"
                                                    imagePathDecrement:
                                                        'assets/images/menos.png',
                                                    // Imagen del botón de "Menos"
                                                    imagePathDisplay:
                                                        'assets/images/RAMPA.png',
                                                    // Imagen que se muestra (Pausa)
                                                    onIncrement: () {
                                                      setState(() {
                                                        valueRampa +=
                                                            1.0; // Lógica de incremento
                                                      });
                                                    },
                                                    onDecrement: () {
                                                      setState(() {
                                                        if (valueRampa > 0) {
                                                          valueRampa -=
                                                              1.0; // Lógica de decremento
                                                        }
                                                      });
                                                    },
                                                    suffix: " .s",
                                                    // Sufijo para mostrar en el texto
                                                    screenWidth: screenWidth,
                                                    // Ancho de pantalla
                                                    screenHeight:
                                                        screenHeight, // Altura de pantalla
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Usamos Expanded para que ocupe el espacio disponible
                                Expanded(
                                  child: Stack(
                                    children: [
                                      // Aquí puedes poner otros widgets dentro del Stack si lo necesitas
                                      Positioned(
                                        bottom: 0,
                                        left: screenWidth * 0.02,
                                        child: GestureDetector(
                                          onTapDown: (_) => setState(
                                              () => scaleFactorReset = 0.90),
                                          onTapUp: (_) => setState(
                                              () => scaleFactorReset = 1.0),
                                          onTap: () {
                                            _resetScreen(context);
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorReset,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: SizedBox(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  'assets/images/RESET.png',
                                                  width: screenWidth * 0.1,
                                                  height: screenHeight * 0.1,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Aquí está la imagen de fullscreen en la esquina
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTapDown: (_) => setState(
                                              () => scaleFactorFull = 0.90),
                                          onTapUp: (_) => setState(
                                              () => scaleFactorFull = 1.0),
                                          onTap: () {
                                            toggleFullScreen();
                                          },
                                          child: AnimatedScale(
                                            scale: scaleFactorFull,
                                            duration: const Duration(
                                                milliseconds: 100),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/fullscreen.png',
                                                width: screenWidth * 0.08,
                                                height: screenHeight * 0.08,
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
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
            if (isOverlayVisible)
              Positioned(
                top: overlayIndex == 1 ? screenHeight * 0.2 : 0,
                bottom: overlayIndex == 1 ? screenHeight * 0.2 : 0,
                left: overlayIndex == 1 ? screenWidth * 0.2 : 0,
                right: overlayIndex == 1 ? screenWidth * 0.2 : 0,
                child: Align(
                  alignment: Alignment.center,
                  child: _getOverlayWidget(
                      overlayIndex,
                      onProgramSelected,
                      onIndivProgramSelected,
                      onRecoProgramSelected,
                      onAutoProgramSelected,
                      onClientSelected),
                ),
              ),
          ],
        ));
  }

  Widget _getOverlayWidget(
    int overlayIndex,
    Function(String) onProgramSelected,
    Function(Map<String, dynamic>?) onIndivProgramSelected,
    Function(Map<String, dynamic>?) onRecoProgramSelected,
    Function(Map<String, dynamic>?) onAutoProgramSelected,
    Function(Map<String, dynamic>?) onClientSelected,
  ) {
    switch (overlayIndex) {
      case 0:
        return OverlaySeleccionarCliente(
          onClose: () => toggleOverlay(0),
          onClientSelected: onClientSelected,
        );
      case 1:
        return OverlayTipoPrograma(
          onClose: () => toggleOverlay(1),
          onProgramSelected:
              onProgramSelected, // Solo OverlayTipoPrograma recibe este callback
        );
      case 2:
        return OverlaySeleccionarProgramaIndividual(
          onClose: () => toggleOverlay(2),
          onIndivProgramSelected: onIndivProgramSelected,
        );
      case 3:
        return OverlaySeleccionarProgramaRecovery(
          onClose: () => toggleOverlay(3),
          onRecoProgramSelected: onRecoProgramSelected,
        );
      case 4:
        return OverlaySeleccionarProgramaAutomatic(
          onClose: () => toggleOverlay(4),
          onAutoProgramSelected: onAutoProgramSelected,
        );
      case 5:
        return OverlayResumenSesion(
          onClose: () => toggleOverlay(5),
          onClientSelected: onClientSelected,
        );
      default:
        return Container(); // Si no coincide con ninguno de los índices, no muestra nada
    }
  }

  String formatNumber(double number) {
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Función para obtener la frecuencia y la rampa del programa seleccionado
  Map<String, double> getProgramSettings(String? selectedProgram) {
    double frecuencia = 0;
    double rampa = valueRampa;
    double pulso = 0; // Nuevo parámetro

    if (selectedProgram == tr(context, 'Individual').toUpperCase() &&
        allIndividualPrograms.isNotEmpty) {
      if (selectedIndivProgram != null) {
        frecuencia = selectedIndivProgram!['frecuencia'] != null
            ? selectedIndivProgram!['frecuencia'] as double
            : 0;
        rampa = selectedIndivProgram!['rampa'] != null
            ? selectedIndivProgram!['rampa'] as double
            : 0;
        pulso = selectedIndivProgram!['pulso'] != null
            ? selectedIndivProgram!['pulso'] as double
            : 0;
      } else {
        frecuencia = allIndividualPrograms.isNotEmpty
            ? allIndividualPrograms[0]['frecuencia'] as double
            : 0;
        rampa = allIndividualPrograms.isNotEmpty
            ? allIndividualPrograms[0]['rampa'] as double
            : 0;
        pulso = allIndividualPrograms.isNotEmpty
            ? allIndividualPrograms[0]['pulso'] as double
            : 0;
      }
    } else if (selectedProgram == tr(context, 'Recovery').toUpperCase() &&
        allRecoveryPrograms.isNotEmpty) {
      if (selectedRecoProgram != null) {
        frecuencia = selectedRecoProgram!['frecuencia'] != null
            ? selectedRecoProgram!['frecuencia'] as double
            : 0;
        rampa = selectedRecoProgram!['rampa'] != null
            ? selectedRecoProgram!['rampa'] as double
            : 0;
        pulso = selectedRecoProgram!['pulso'] != null
            ? selectedRecoProgram!['pulso'] as double
            : 0;
      } else {
        frecuencia = allRecoveryPrograms.isNotEmpty
            ? allRecoveryPrograms[0]['frecuencia'] as double
            : 0;
        rampa = allRecoveryPrograms.isNotEmpty
            ? allRecoveryPrograms[0]['rampa'] as double
            : 0;
        pulso = allRecoveryPrograms.isNotEmpty
            ? allRecoveryPrograms[0]['pulso'] as double
            : 0;
      }
    } else if (selectedProgram == tr(context, 'Automáticos').toUpperCase() &&
        allAutomaticPrograms.isNotEmpty) {
      if (selectedAutoProgram != null) {
        // Aquí puedes acceder a los valores de cada subprograma
        var subprogram =
            selectedAutoProgram!['subprogramas'][currentSubprogramIndex];

        frecuencia = subprogram['frecuencia'] != null
            ? subprogram['frecuencia'] as double
            : 0;
        rampa = subprogram['rampa'] != null ? subprogram['rampa'] as double : 0;
        pulso = subprogram['pulso'] != null ? subprogram['pulso'] as double : 0;
      } else {
        var subprogram = allAutomaticPrograms.isNotEmpty
            ? allAutomaticPrograms[0]['subprogramas'][0]
            : null;

        if (subprogram != null) {
          frecuencia = subprogram['frecuencia'] != null
              ? subprogram['frecuencia'] as double
              : 0;
          rampa =
              subprogram['rampa'] != null ? subprogram['rampa'] as double : 0;
          pulso =
              subprogram['pulso'] != null ? subprogram['pulso'] as double : 0;
        }
      }
    }

    return {
      'frecuencia': frecuencia,
      'rampa': rampa,
      'pulso': pulso, // Devuelve el nuevo valor
    };
  }

  Widget _buildMuscleRow({
    required int index,
    required String imagePathEnabled,
    required String imagePathDisabled,
    required String imagePathInactive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.height * 0.002),
          decoration: BoxDecoration(
            color: _isMusculoTrajeInactivo[index]
                ? Colors.grey.withOpacity(0.5) // Gris si está inactivo
                : _isMusculoTrajeBloqueado[index]
                    ? const Color(0xFFFFA500)
                        .withOpacity(0.3) // Naranja si está bloqueado
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(7.0),
          ),
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null
                    : () {
                        setState(() {
                          if (!_isMusculoTrajeBloqueado[index] &&
                              !_isMusculoTrajeInactivo[index]) {
                            porcentajesMusculoTraje[index] =
                                (porcentajesMusculoTraje[index] + 1)
                                    .clamp(0, 100);
                            // Llamar a la función con modo 1 (Más)
                          } else if (_isMusculoTrajeInactivo[index]) {
                            // Si está inactivo, poner el porcentaje a 0
                            porcentajesMusculoTraje[index] = 0;
                          }
                        });
                      },
                imagePath: 'assets/images/mas.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Columna que contiene el GestureDetector y el porcentaje
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_isMusculoTrajeInactivo[index]) {
                          _isMusculoTrajeBloqueado[index] =
                              !_isMusculoTrajeBloqueado[index];
                        }
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        if (_isMusculoTrajeBloqueado[index]) {
                          _isMusculoTrajeBloqueado[index] = false;
                        }
                        _isMusculoTrajeInactivo[index] =
                            !_isMusculoTrajeInactivo[index];

                        // Si se pone inactivo, poner el porcentaje a 0
                        if (_isMusculoTrajeInactivo[index]) {
                          porcentajesMusculoTraje[index] = 0;
                        }
                      });
                    },
                    child: SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height * 0.09
                          : MediaQuery.of(context).size.height * 0.08,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Capa de color sobre la imagen, solo si no está inactivo
                            if (!_isMusculoTrajeInactivo[index])
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Forma circular
                                    color: _getColorForPercentage(
                                        porcentajesMusculoTraje[index],
                                        isRunning,
                                        index),
                                  ),
                                ),
                              ),
                            // Imagen sobre la capa de color
                            Image.asset(
                              // Lógica de selección de la imagen
                              _isMusculoTrajeBloqueado[index]
                                  ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                                  : (_isMusculoTrajeInactivo[index]
                                      ? imagePathInactive // Mostrar la imagen inactiva si está inactivo
                                      : imagePathDisabled),
                              // Mostrar la imagen deshabilitada
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${porcentajesMusculoTraje[index]}%',
                    style: TextStyle(
                      fontSize: isFullScreen ? 18.0.sp : 17.0.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),
              // Botón "Menos"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null
                    : () {
                        setState(() {
                          if (!_isMusculoTrajeBloqueado[index] &&
                              !_isMusculoTrajeInactivo[index]) {
                            porcentajesMusculoTraje[index] =
                                (porcentajesMusculoTraje[index] - 1)
                                    .clamp(0, 100);
                            // Llamar a la función con modo 2 (Menos)
                          } else if (_isMusculoTrajeInactivo[index]) {
                            // Si está inactivo, poner el porcentaje a 0
                            porcentajesMusculoTraje[index] = 0;
                          }
                        });
                      },
                imagePath: 'assets/images/menos.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoTrajeBloqueado[index] ||
                    _isMusculoTrajeInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForPercentage(int percentage, bool isRunning, int index) {
    if (!isRunning) {
      return Colors.transparent; // Si no está en ejecución, no se muestra color
    }

    // Obtiene los umbrales de porcentaje del grupo muscular correspondiente
    List<int> umbrales = porcentajesPorGrupoTraje[index];

    // Compara el porcentaje con los umbrales del grupo muscular
    if (percentage >= umbrales[3]) {
      return Colors.red.withOpacity(0.6); // Rojo con opacidad del 60%
    } else if (percentage >= umbrales[2]) {
      return Colors.yellow.withOpacity(0.9); // Amarillo con opacidad del 60%
    } else if (percentage >= umbrales[1]) {
      return Colors.lightGreenAccent.shade400
          .withOpacity(0.8); // Verde claro con opacidad del 60%
    } else {
      return Colors.green.withOpacity(0.6); // Verde con opacidad del 60%
    }
  }

  double calculateAverage(List<int> porcentajesMusculoTraje) {
    double sum =
        porcentajesMusculoTraje.fold(0, (prev, element) => prev + element);
    return sum / porcentajesMusculoTraje.length;
  }

  Widget _buildMuscleRow2({
    required int index,
    required String imagePathEnabled,
    required String imagePathDisabled,
    required String imagePathInactive,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            color: _isMusculoPantalonInactivo[index]
                ? Colors.grey.withOpacity(0.3) // Si está inactivo, color gris
                : _isMusculoPantalonBloqueado[index]
                    ? const Color(0xFFFFA500)
                        .withOpacity(0.3) // Si está bloqueado, color naranja
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(7.0), // Redondea las esquinas
          ),
          child: Row(
            children: [
              // Botón "Más"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          if (!_isMusculoPantalonBloqueado[index] &&
                              !_isMusculoPantalonInactivo[index]) {
                            porcentajesMusculoPantalon[index] =
                                (porcentajesMusculoPantalon[index] + 1)
                                    .clamp(0, 100);
                          } else if (_isMusculoPantalonInactivo[index]) {
                            // Si está inactivo, poner el porcentaje a 0
                            porcentajesMusculoPantalon[index] = 0;
                          }
                        });
                      },
                imagePath: 'assets/images/mas.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Columna que contiene el GestureDetector y el porcentaje
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!_isMusculoPantalonInactivo[index]) {
                          _isMusculoPantalonBloqueado[index] =
                              !_isMusculoPantalonBloqueado[index];
                        }
                      });
                    },
                    onLongPress: () {
                      setState(() {
                        if (_isMusculoPantalonBloqueado[index]) {
                          // Cambiar el estado de bloqueado a desbloqueado
                          _isMusculoPantalonBloqueado[index] = false;
                        }
                        // Cambiar el estado de inactivo
                        _isMusculoPantalonInactivo[index] =
                            !_isMusculoPantalonInactivo[index];
                        // Si se pone inactivo, poner el porcentaje a 0
                        if (_isMusculoPantalonInactivo[index]) {
                          porcentajesMusculoPantalon[index] = 0;
                        }
                      });
                    },
                    child: SizedBox(
                      height: isFullScreen
                          ? MediaQuery.of(context).size.height * 0.09
                          : MediaQuery.of(context).size.height * 0.08,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Capa de color sobre la imagen, solo si no está inactivo
                            if (!_isMusculoPantalonInactivo[index])
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Forma circular
                                    color: _getColorForPercentagePantalon(
                                        porcentajesMusculoPantalon[index],
                                        isRunning,
                                        index), // Si está activo, aplicar el color basado en porcentaje
                                  ),
                                ),
                              ),
                            // Imagen sobre la capa de color
                            Image.asset(
                              // Lógica de selección de la imagen
                              _isMusculoPantalonBloqueado[index]
                                  ? imagePathEnabled // Si está bloqueado, mostrar la imagen de estado activo
                                  : (_isMusculoPantalonInactivo[index]
                                      ? imagePathInactive // Si está inactivo
                                      : imagePathDisabled), // Si está deshabilitado
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Texto que muestra el porcentaje
                  Text(
                    '${porcentajesMusculoPantalon[index]}%',
                    style: TextStyle(
                      fontSize: isFullScreen ? 18.0.sp : 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2be4f3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),

              // Botón "Menos"
              CustomIconButton(
                onTap: widget.selectedKey == null
                    ? null // Si selectedKey es null, el botón estará deshabilitado
                    : () {
                        setState(() {
                          if (!_isMusculoPantalonBloqueado[index] &&
                              !_isMusculoPantalonInactivo[index]) {
                            porcentajesMusculoPantalon[index] =
                                (porcentajesMusculoPantalon[index] - 1)
                                    .clamp(0, 100);
                          } else if (_isMusculoPantalonInactivo[index]) {
                            // Si está inactivo, poner el porcentaje a 0
                            porcentajesMusculoPantalon[index] = 0;
                          }
                        });
                      },
                imagePath: 'assets/images/menos.png',
                size: isFullScreen
                    ? MediaQuery.of(context).size.height * 0.065
                    : MediaQuery.of(context).size.height * 0.055,
                isDisabled: _isMusculoPantalonBloqueado[index] ||
                    _isMusculoPantalonInactivo[index],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForPercentagePantalon(
      int percentage, bool isRunning, int index) {
    if (!isRunning) {
      return Colors.transparent; // Si no está en ejecución, no se muestra color
    }

    // Obtiene los umbrales de porcentaje del grupo muscular correspondiente
    List<int> umbrales = porcentajesPorGrupoPantalon[index];

    // Compara el porcentaje con los umbrales del grupo muscular
    if (percentage >= umbrales[3]) {
      return Colors.red.withOpacity(0.6); // Rojo con opacidad del 60%
    } else if (percentage >= umbrales[2]) {
      return Colors.yellow.withOpacity(0.9); // Amarillo con opacidad del 60%
    } else if (percentage >= umbrales[1]) {
      return Colors.lightGreenAccent.shade400
          .withOpacity(0.8); // Verde claro con opacidad del 60%
    } else {
      return Colors.green.withOpacity(0.6); // Verde con opacidad del 60%
    }
  }

  double calculateAverage2(List<int> porcentajesMusculoPantalon) {
    double sum =
        porcentajesMusculoPantalon.fold(0, (prev, element) => prev + element);
    return sum / porcentajesMusculoPantalon.length;
  }

  Widget buildControlRow({
    required double value, // El valor que se va a mostrar y modificar
    required String imagePathIncrement, // Ruta de la imagen para el botón "Más"
    required String
        imagePathDecrement, // Ruta de la imagen para el botón "Menos"
    required String
        imagePathDisplay, // Ruta de la imagen para mostrar (como la imagen de CONTRACCION)
    required Function onIncrement, // Lógica de incremento
    required Function onDecrement, // Lógica de decremento
    required String
        suffix, // Sufijo para el valor (por ejemplo: "S" para contracción)
    required double screenWidth, // El ancho de la pantalla
    required double screenHeight, // El alto de la pantalla
  }) {
    // Condición para bloquear los botones si selectedProgram no es nulo
    bool isButtonEnabled = selectedProgram ==
        null; // Asegúrate de que selectedProgram esté accesible en el contexto

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de "Más"
        GestureDetector(
          onTap: isButtonEnabled ? () => onIncrement() : null,
          // Solo se ejecuta si el botón está habilitado
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathIncrement, // Imagen para el botón "Más"
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        // Texto con el valor y el sufijo
        Text(
          "${value.toStringAsFixed(0)}$suffix",
          // Aquí formateamos el valor para que no tenga decimales
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        // Botón de "Menos"
        GestureDetector(
          onTap: isButtonEnabled ? () => onDecrement() : null,
          // Solo se ejecuta si el botón está habilitado
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePathDecrement, // Imagen para el botón "Menos"
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.005),
        // Imagen que se muestra en el lado derecho (por ejemplo: "CONTRACCION.png")
        Image.asset(
          imagePathDisplay, // Imagen personalizada
          width: screenWidth * 0.05,
          height: screenHeight * 0.05,
        ),
      ],
    );
  }
}

class BleConnectionService {
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<List<int>>? notificationSubscription;
  final Map<String, StreamSubscription<List<int>>> _subscriptions = {};
  final bool _connected = false;
  bool isWidgetActive = true;
  List<String> targetDeviceIds = []; // Lista para almacenar las direcciones MAC
  final List<String> connectedDevices = []; // Lista de MACs conectadas
  final Map<String, StreamController<bool>> _deviceConnectionStateControllers =
      {};
  final Map<String, StreamSubscription<ConnectionStateUpdate>>
      _connectionStreams = {};
  final Uuid serviceUuid = Uuid.parse("49535343-FE7D-4AE5-8FA9-9FAFD205E455");
  final Uuid rxCharacteristicUuid =
      Uuid.parse("49535343-8841-43F4-A8D4-ECBE34729BB4");
  final Uuid txCharacteristicUuid =
      Uuid.parse("49535343-1E4D-4BD9-BA61-23C647249617");

  final StreamController<Map<String, dynamic>> _deviceUpdatesController =
      StreamController.broadcast();

  /// Constructor con limpieza y reinicialización
  BleConnectionService() {
    debugPrint("🚀 Servicio BLE inicializado");
    flutterReactiveBle.initialize();
  }

  /// Actualizar la lista de dispositivos objetivo
  void updateMacAddresses(List<String> macAddresses) {
    targetDeviceIds.clear();
    targetDeviceIds.addAll(macAddresses);
    debugPrint(
        "🔄 Lista de dispositivos objetivo actualizada: $targetDeviceIds");
    for (String deviceId in targetDeviceIds) {
      _connectToDeviceByMac(deviceId);
    }
  }

  /// Stream de estado de conexión por dispositivo
  Stream<bool> connectionStateStream(String macAddress) {
    if (!_deviceConnectionStateControllers.containsKey(macAddress)) {
      _deviceConnectionStateControllers[macAddress] =
          StreamController<bool>.broadcast();
    }
    return _deviceConnectionStateControllers[macAddress]!.stream;
  }

  /// Actualizar el estado de conexión del dispositivo
  void _updateDeviceConnectionState(String macAddress, bool isConnected) {
    if (!_deviceConnectionStateControllers.containsKey(macAddress)) {
      _deviceConnectionStateControllers[macAddress] =
          StreamController<bool>.broadcast();
    }
    final controller = _deviceConnectionStateControllers[macAddress]!;
    if (!controller.isClosed) {
      controller.add(isConnected);
      debugPrint(
          "🔄 Estado de conexión actualizado para $macAddress: ${isConnected ? 'conectado' : 'desconectado'}");
    }
  }

// Exponer el Stream para que otros lo escuchen
  Stream<Map<String, dynamic>> get deviceUpdates =>
      _deviceUpdatesController.stream;

  // Método para emitir actualizaciones generales
  void _emitDeviceUpdate(String macAddress, String key, dynamic value) {
    _deviceUpdatesController.add({
      'macAddress': macAddress,
      key: value,
    });
  }

// Llamar esto para actualizar el estado del dispositivo
  void updateBluetoothName(String macAddress, String name) {
    _emitDeviceUpdate(macAddress, 'bluetoothName', name);
  }

  void updateBatteryStatus(String macAddress, int status) {
    _emitDeviceUpdate(macAddress, 'batteryStatus', status);
  }

  Future<bool> _connectToDeviceByMac(String deviceId) async {
    if (deviceId.isEmpty) {
      debugPrint("⚠️ Identificador del dispositivo vacío. Conexión cancelada.");
      return false;
    }

    if (connectedDevices.contains(deviceId)) {
      debugPrint("🔗 Dispositivo $deviceId ya conectado.");
      return true;
    }

    debugPrint("🚩 Intentando conectar al dispositivo con ID: $deviceId...");
    bool success = false;

    try {
      _connectionStreams[deviceId] = flutterReactiveBle
          .connectToDevice(id: deviceId)
          .listen((connectionState) {
        switch (connectionState.connectionState) {
          case DeviceConnectionState.connected:
            debugPrint("✅ Dispositivo $deviceId conectado.");
            success = true;

            if (success) connectedDevices.add(deviceId);
            _updateDeviceConnectionState(deviceId, true);
            break;

          case DeviceConnectionState.disconnected:
            debugPrint("⛓️ Dispositivo $deviceId desconectado.");
            _updateDeviceConnectionState(deviceId, false);
            _onDeviceDisconnected(deviceId);
            break;

          default:
            debugPrint("⏳ Estado desconocido para $deviceId.");
            break;
        }
      }, onError: (error) {
        debugPrint("❌ Error al conectar a $deviceId: $error");
      });
    } catch (e) {
      debugPrint("❌ Error inesperado al conectar a $deviceId: $e");
    }

    return success;
  }

  void _onDeviceDisconnected(String macAddress) {
    if (kDebugMode) {
      print("️‍️‍⛓️‍💥--->>>Dispositivo $macAddress desconectado.");
    }
    connectedDevices.remove(macAddress);
    disconnect(macAddress);
    // Cancelar el stream asociado a la MAC
    _connectionStreams[macAddress]?.cancel();
    _connectionStreams.remove(macAddress);

    // Actualizar el estado en los StreamControllers
    final controller = _deviceConnectionStateControllers[macAddress];
    if (controller != null && !controller.isClosed) {
      controller.add(false); // Estado desconectado
    }
  }

  void disconnect(String macAddress) async {
    if (_deviceConnectionStateControllers.containsKey(macAddress)) {
      if (kDebugMode) {
        print("Desconectando del dispositivo: $macAddress");
      }

      // Cancelar la suscripción del stream de conexión
      if (_connectionStreams.containsKey(macAddress)) {
        await _connectionStreams[macAddress]?.cancel();
        if (kDebugMode) {
          print("⚠️ Suscripción cancelada para el dispositivo $macAddress.");
        }
        _connectionStreams.remove(macAddress);
      }

      // Verificar si el StreamController no está cerrado antes de agregar un evento
      final controller = _deviceConnectionStateControllers[macAddress];
      if (controller != null && !controller.isClosed) {
        controller.add(false); // Estado desconectado
        if (kDebugMode) {
          print(
              "🔴 Evento 'desconectado' agregado al controller del dispositivo $macAddress.");
        }
      } else {
        if (kDebugMode) {
          print(
              "⚠️ El StreamController ya está cerrado para la MAC $macAddress.");
        }
      }
    } else {
      if (kDebugMode) {
        print("No hay dispositivo conectado con la MAC $macAddress.");
      }
    }
  }

  Future<void> disposeBle() async {
    debugPrint("🧹 Limpiando recursos y desconectando dispositivos...");

    for (var macAddress in _deviceConnectionStateControllers.keys) {
      disconnect(macAddress);
      disconnect(macAddress); // Esperar a que la desconexión termine
      if (kDebugMode) {
        debugPrint("🛑 Desconectando dispositivo con MAC: $macAddress");
      }
    }
    _deviceConnectionStateControllers.forEach((macAddress, controller) {
      if (!controller.isClosed) {
        controller.close();
        if (kDebugMode) {
          debugPrint(
              "🗑️ Stream controller para el dispositivo $macAddress cerrado.");
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              "⚠️ El Stream controller ya estaba cerrado para el dispositivo $macAddress.");
          debugPrint("🗑️ Stream controller cerrado.");
        }
      }
    });
    if (!_deviceUpdatesController.isClosed) {
      _deviceUpdatesController.close();
      if (kDebugMode) {
        debugPrint(
            "🗑️ Stream controller de actualizaciones generales cerrado.");
      }
    } else {
      if (kDebugMode) {
        debugPrint(
            "⚠️ El Stream controller de actualizaciones generales ya estaba cerrado.");
      }
    }
    flutterReactiveBle.deinitialize();
  }

  Future<void> dispose() async {
    debugPrint("🔒 Liberando recursos de BleConnectionService");
    // Cancelar y limpiar suscripciones
    for (var subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  bool get isConnected => _connected;

  Future<void> processConnectedDevices(String deviceId) async {
    if (connectedDevices.isEmpty) {
      debugPrint("⚠️ Ningún dispositivo conectado. Abortando operaciones.");
      return;
    }

    try {
      // Inicialización de seguridad
      await _initializeSecurity(deviceId);
      debugPrint(
          "🔒--->>>Fase de inicialización de seguridad completada para $deviceId.");

      // Procesar información general del dispositivo
      await _processDeviceInfo(deviceId);
    } catch (e) {
      debugPrint("❌--->>>Error al procesar el dispositivo $deviceId: $e");
    }
  }

  Future<void> _processDeviceInfo(String macAddress) async {
    try {
      // Obtener la información del dispositivo (FUN_INFO)
      final deviceInfo =
          await getDeviceInfo(macAddress).timeout(const Duration(seconds: 15));
      final parsedInfo = parseDeviceInfo(deviceInfo);
      debugPrint(parsedInfo);

      // Obtener el nombre del Bluetooth (FUN_GET_NAMEBT)
      final nameBt = await getBluetoothName(macAddress)
          .timeout(const Duration(seconds: 15));
      debugPrint("🅱️ Nombre del Bluetooth ($macAddress): $nameBt");
      updateBluetoothName(
          macAddress, nameBt.isNotEmpty ? nameBt : "No disponible");

      // Obtener los parámetros de la batería (FUN_GET_PARAMBAT)
      final batteryParameters = await getBatteryParameters(macAddress)
          .timeout(const Duration(seconds: 15));
      final parsedBattery = parseBatteryParameters(batteryParameters);
      debugPrint(parsedBattery);
      updateBatteryStatus(
          macAddress, batteryParameters['batteryStatusRaw'] ?? -1);

      // Obtener contadores de tarifa
      final counters = await getTariffCounters(macAddress)
          .timeout(const Duration(seconds: 15));
      final parsedCounters = parseTariffCounters(counters);
      debugPrint(parsedCounters);
    } catch (e) {
      debugPrint(
          "❌ Error al procesar la información general de $macAddress: $e");
    }
  }

  // Inicialización de la seguridad
  Future<void> _initializeSecurity(String macAddress) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      // Enviar solicitud de inicialización
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: [0x00, 0x00, 0x00, 0x00, 0x00],
      );

      // Suscripción a notificaciones para recibir el reto
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: txCharacteristicUuid,
          deviceId: macAddress,
        ),
      )
          .listen((data) async {
        if (data.isNotEmpty) {
          await _handleSecurityChallenge(macAddress, data);
        }
      });
    } catch (e) {
      print("Error al inicializar seguridad: $e");
    }
  }

  // Manejo del reto de seguridad
  Future<void> _handleSecurityChallenge(
      String macAddress, List<int> data) async {
    // Proceso XOR para resolver el reto
    final h1 = data[1] ^ 0x2A;
    final h2 = data[2] ^ 0x55;
    final h3 = data[3] ^ 0xAA;
    final h4 = data[4] ^ 0xA2;

    // Responder al dispositivo con el contra-reto
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );
    await flutterReactiveBle.writeCharacteristicWithResponse(
      characteristic,
      value: [0x01, h1, h2, h3, h4],
    );
  }

  // Envío de comandos al dispositivo
  Future<void> sendCommand(String macAddress, List<int> command) async {
    // Validar si el dispositivo está conectado
    if (connectedDevices.isNotEmpty) {
      print(
          "⚠️ El dispositivo $macAddress no está conectado. Comando no enviado.");
      return;
    }

    // Validar que el comando tenga exactamente 20 bytes
    if (command.length != 20) {
      print(
          "⚠️ El comando debe tener exactamente 20 bytes. Comando no enviado.");
      return;
    }

    // Crear la característica cualificada
    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      // Enviar el comando al dispositivo
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: command,
      );
      print("✅ Comando enviado correctamente a $macAddress: $command");
    } catch (e) {
      print("❌ Error al enviar comando a $macAddress: $e");
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_INFO
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x02; // FUN_INFO

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x03) {
          final Map<String, dynamic> deviceInfo = {
            'mac': data.sublist(1, 7),
            'tariff': data[7],
            'powerType': data[8],
            'hwVersion': data[9],
            'swCommsVersion': data[10],
            'endpoints': [
              {'type': data[11], 'swVersion': data[12]},
              {'type': data[13], 'swVersion': data[14]},
              {'type': data[15], 'swVersion': data[16]},
              {'type': data[17], 'swVersion': data[18]},
            ],
          };

          completer.complete(deviceInfo);
          debugPrint("📥 FUN_INFO_R recibido desde $macAddress: $deviceInfo");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_INFO
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint("📤 FUN_INFO enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final deviceInfo =
          await completer.future.timeout(const Duration(seconds: 15));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return deviceInfo;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint("❌ Error al obtener FUN_INFO de $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  // Función para parsear información en formato texto
  String parseDeviceInfo(Map<String, dynamic> deviceInfo) {
    final mac = (deviceInfo['mac'] as List<int>)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    final tariff = deviceInfo['tariff'] == 0
        ? "Sin tarifa"
        : deviceInfo['tariff'] == 1
            ? "Con tarifa"
            : "Con tarifa agotada";

    final powerType = deviceInfo['powerType'] == 0
        ? "Fuente de alimentación"
        : "Batería de litio (8.4V)";

    final hwVersion = deviceInfo['hwVersion'];
    final swCommsVersion = deviceInfo['swCommsVersion'];

    final endpoints = (deviceInfo['endpoints'] as List<Map<String, dynamic>>)
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final endpoint = entry.value;

      final type = endpoint['type'] == 0
          ? "Ninguno"
          : endpoint['type'] == 1
              ? "Electroestimulador (10 canales normal)"
              : endpoint['type'] == 2
                  ? "Electroestimulador (10 canales + Ctrl Input)"
                  : "Desconocido";

      final swVersion = endpoint['swVersion'];

      return "  Endpoint ${index + 1}: Tipo: $type, Versión SW: $swVersion";
    }).join('\n');

    return '''
📊 Información del dispositivo:
- Dirección MAC: $mac
- Tarifa: $tariff
- Tipo de alimentación: $powerType
- Versión HW: $hwVersion
- Versión SW de comunicaciones: $swCommsVersion
$endpoints
''';
  }

  Future<String> getBluetoothName(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_NAMEBT
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x04; // FUN_GET_NAMEBT

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<String>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x05) {
          // FUN_GET_NAMEBT_R recibido
          final nameBytes =
              data.sublist(1).takeWhile((byte) => byte != 0).toList();
          final name =
              String.fromCharCodes(nameBytes); // Convertir bytes a string
          completer.complete(name);
          debugPrint("📥 FUN_GET_NAMEBT_R recibido desde $macAddress: $name");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_GET_NAMEBT
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint("📤 FUN_GET_NAMEBT enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final bluetoothName =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return bluetoothName;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error al obtener el nombre del Bluetooth de $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBatteryParameters(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_PARAMBAT
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x08; // FUN_GET_PARAMBAT

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x09 && !completer.isCompleted) {
          // FUN_GET_PARAMBAT_R recibido y Completer no está completado
          final batteryParameters = {
            'batteryStatusRaw': data[3],
            'powerType':
                data[1] == 1 ? "Batería de litio (8.4V)" : "Alimentador AC",
            'batteryModel': data[2] == 0 ? "Por defecto" : "Desconocido",
            'batteryStatus': data[3] == 0
                ? "Muy baja"
                : data[3] == 1
                    ? "Baja"
                    : data[3] == 2
                        ? "Media"
                        : data[3] == 3
                            ? "Alta"
                            : "Llena",
            'temperature': "Sin implementar",
            'compensation': (data[6] << 8) | data[7],
            'voltages': {
              'V1': (data[8] << 8) | data[9],
              'V2': (data[10] << 8) | data[11],
              'V3': (data[12] << 8) | data[13],
              'V4': (data[14] << 8) | data[15],
            },
            'elevatorMax': {
              'endpoint1': data[16],
              'endpoint2': data[17],
              'endpoint3': data[18],
              'endpoint4': data[19],
            },
          };

          completer.complete(batteryParameters);
          debugPrint(
              "📥 FUN_GET_PARAMBAT_R recibido desde $macAddress: $batteryParameters");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_GET_PARAMBAT
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint("📤 FUN_GET_PARAMBAT enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final batteryParameters =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return batteryParameters;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error al obtener los parámetros de la batería de $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  String parseBatteryParameters(Map<String, dynamic> batteryParameters) {
    final powerType = batteryParameters['powerType'];
    final batteryModel = batteryParameters['batteryModel'];
    final batteryStatus = batteryParameters['batteryStatus'];
    final compensation = batteryParameters['compensation'];
    final voltages = batteryParameters['voltages'] as Map<String, int>;
    final elevatorMax = batteryParameters['elevatorMax'] as Map<String, int>;

    return '''
🔋 Parámetros de la batería:
- Tipo de alimentación: $powerType
- Modelo de batería: $batteryModel
- Estado de la batería: $batteryStatus
- Compensación: $compensation
- Voltajes:
  - V1: ${voltages['V1']} mV
  - V2: ${voltages['V2']} mV
  - V3: ${voltages['V3']} mV
  - V4: ${voltages['V4']} mV
- Elevador máximo:
  - Endpoint 1: ${elevatorMax['endpoint1']}
  - Endpoint 2: ${elevatorMax['endpoint2']}
  - Endpoint 3: ${elevatorMax['endpoint3']}
  - Endpoint 4: ${elevatorMax['endpoint4']}
''';
  }

  Future<Map<String, dynamic>> getTariffCounters(String macAddress) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Crear el paquete de solicitud FUN_GET_CONTADOR
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x0C; // FUN_GET_CONTADOR

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x0D) {
          // FUN_GET_CONTADOR_R recibido
          final tariffStatus = data[1] == 0
              ? "Sin tarifa"
              : data[1] == 1
                  ? "Con tarifa"
                  : "Con tarifa agotada";

          final totalSeconds = (data[2] << 24) |
              (data[3] << 16) |
              (data[4] << 8) |
              data[5]; // Contador total (32 bits)

          final remainingSeconds = (data[6] << 24) |
              (data[7] << 16) |
              (data[8] << 8) |
              data[9]; // Contador parcial (32 bits)

          final counters = {
            'tariffStatus': tariffStatus,
            'totalSeconds': totalSeconds,
            'remainingSeconds': remainingSeconds,
          };

          completer.complete(counters);
          debugPrint(
              "📥 FUN_GET_CONTADOR_R recibido desde $macAddress: $counters");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_GET_CONTADOR
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint("📤 FUN_GET_CONTADOR enviado a $macAddress.");

      // Esperar la respuesta con timeout
      final counters =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return counters;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error al obtener los contadores de tarifa de $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  String parseTariffCounters(Map<String, dynamic> counters) {
    final tariffStatus = counters['tariffStatus'];
    final totalSeconds = counters['totalSeconds'];
    final remainingSeconds = counters['remainingSeconds'];

    final totalTime = Duration(seconds: totalSeconds);
    final remainingTime = Duration(seconds: remainingSeconds);

    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      return "${hours}h ${minutes}m ${seconds}s";
    }

    return '''
⏳ Contadores de tarifa:
- Estado de tarifa: $tariffStatus
- Tiempo total utilizado: ${formatDuration(totalTime)} (${totalSeconds}s)
- Tiempo restante de tarifa: ${formatDuration(remainingTime)} (${remainingSeconds}s)
''';
  }

  Future<Map<String, dynamic>> getElectrostimulatorState(
      String macAddress, int endpoint, int mode) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar que el endpoint y el modo sean válidos
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (mode < 0 || mode > 2) {
      throw ArgumentError("El modo debe estar entre 0 y 2.");
    }

    // Crear el paquete de solicitud FUN_GET_ESTADO_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x10; // FUN_GET_ESTADO_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = mode;

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x11) {
          // FUN_GET_ESTADO_EMS_R recibido
          final parsedState = _parseElectrostimulatorState(data, mode);
          completer.complete(parsedState);
          debugPrint(
              "📥 FUN_GET_ESTADO_EMS_R recibido desde $macAddress: $parsedState");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_GET_ESTADO_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint(
          "📤 FUN_GET_ESTADO_EMS enviado a $macAddress. Endpoint: $endpoint, Modo: $mode.");

      // Esperar la respuesta con timeout
      final state = await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return state;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error al obtener el estado del electroestimulador de $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

// Función para parsear los datos de la respuesta
  Map<String, dynamic> _parseElectrostimulatorState(List<int> data, int mode) {
    final endpoint = data[1];
    final state = _mapState(data[2]); // Mapear el estado según lo definido
    final batteryStatus =
        _mapBatteryStatus(data[3]); // Mapear estado de batería
    final frequency = data[4];
    final ramp = data[5]; // Convertir rampa a milisegundos
    final pulseWidth =
        data[6] == 0 ? "Cronaxia" : data[6] * 5; // Ancho de pulso en µs
    final temperature = ((data[7] << 8) | data[8]) / 10.0; // Temperatura en ºC
    final limitador = data[9] == 0 ? "No" : "Sí";

    if (mode == 0) {
      // Modo 0: Estado, niveles de canal y temperatura
      return {
        'endpoint': endpoint,
        'state': state,
        'batteryStatus': batteryStatus,
        'frequency': frequency,
        'ramp': ramp,
        'pulseWidth': pulseWidth,
        'temperature': temperature,
        'limitador': limitador,
        'channelLevels': List.generate(10, (index) => data[index]),
      };
    } else if (mode == 1 || mode == 2) {
      // Modo 1: Tensión batería / Modo 2: Tensión elevador
      final voltageType = mode == 1 ? "Tensión batería" : "Tensión elevador";
      return {
        'endpoint': endpoint,
        'state': state,
        'batteryStatus': batteryStatus,
        'frequency': frequency,
        'ramp': ramp,
        'pulseWidth': pulseWidth,
        'temperature': temperature,
        'limitador': limitador,
        voltageType: ((data[7] << 8) | data[8]) / 10.0, // Tensión en voltios
        'channelLevels': List.generate(10, (index) => data[10 + index]),
      };
    } else {
      throw ArgumentError("Modo inválido.");
    }
  }

  Future<bool> _startElectrostimulationSession(
    String macAddress,
    List<int> valoresCanales,
    double frecuencia,
    double rampa, {
    double pulso = 0, // Nuevo parámetro con valor por defecto
  }) async {
    try {
      debugPrint(
          "⚙️ Iniciando sesión de electroestimulación en $macAddress...");

      final runSuccess = await runElectrostimulationSession(
        macAddress: macAddress,
        endpoint: 1,
        limitador: 0,
        rampa: rampa,
        frecuencia: frecuencia,
        deshabilitaElevador: 0,
        nivelCanales: valoresCanales,
        pulso: pulso.toInt(),
        anchuraPulsosPorCanal: List.generate(10, (index) => pulso.toInt()),
      );

      if (runSuccess) {
        debugPrint(
            "✅ Sesión de electroestimulación iniciada correctamente en $macAddress.");
        return true;
      } else {
        debugPrint(
            "❌ Error al iniciar la sesión de electroestimulación en $macAddress.");
        return false;
      }
    } catch (e) {
      debugPrint(
          "❌ Error al procesar la electroestimulación en $macAddress: $e");
      return false;
    }
  }

// Función para detener la sesión de electroestimulación
  Future<bool> _stopElectrostimulationSession(String macAddress) async {
    try {
      final stopSuccess = await stopElectrostimulationSession(
        macAddress: macAddress,
        endpoint: 1,
      );

      if (stopSuccess) {
        debugPrint(
            "✅ Sesión de electroestimulación detenida correctamente en $macAddress.");
        return true;
      } else {
        debugPrint(
            "❌ Error al detener la sesión de electroestimulación en $macAddress.");
        return false;
      }
    } catch (e) {
      debugPrint(
          "❌ Error al detener la electroestimulación de $macAddress: $e");
      return false;
    }
  }

  Future<bool> runElectrostimulationSession({
    required String macAddress,
    required int endpoint,
    required int limitador,
    required double rampa,
    required double frecuencia,
    required int deshabilitaElevador,
    required List<int> nivelCanales,
    required int pulso,
    required List<int> anchuraPulsosPorCanal,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    if (endpoint < 1 || endpoint > 4) throw ArgumentError("Endpoint inválido.");
    if (anchuraPulsosPorCanal.length != 10) {
      throw ArgumentError(
          "Debe haber exactamente 10 valores de anchura de pulso.");
    }

    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x12;
    requestPacket[1] = endpoint;
    requestPacket[2] = limitador;
    requestPacket[3] = (rampa).toInt();
    requestPacket[4] = (frecuencia).toInt();
    requestPacket[5] = deshabilitaElevador;

    for (int i = 0; i < nivelCanales.length; i++) {
      requestPacket[6 + i] = nivelCanales[i].clamp(0, 100);
    }

    for (int i = 0; i < 10; i++) {
      requestPacket[8 + i] = anchuraPulsosPorCanal[i];
    }

    try {
      // Cancelar suscripción previa si existe
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<bool>();

      // Suscribirse a notificaciones para este dispositivo
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(
        QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: txCharacteristicUuid,
          deviceId: macAddress,
        ),
      )
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x13) {
          final retorno = data[2];
          completer.complete(retorno == 1);
          debugPrint(
              "📥 FUN_RUN_EMS_R recibido desde $macAddress: ${retorno == 1 ? "OK" : "FAIL"}");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Almacenar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar comando
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint("📤 FUN_RUN_EMS enviado a $macAddress.");

      // Esperar respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 20));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return result;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      return false;
    } catch (e) {
      debugPrint(
          "❌ Error en runElectrostimulationSession para $macAddress: $e");
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      return false;
    }
  }

  Future<bool> stopElectrostimulationSession({
    required String macAddress,
    required int endpoint,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar el endpoint
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }

    // Crear el paquete de solicitud FUN_STOP_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x14; // FUN_STOP_EMS
    requestPacket[1] = endpoint;

    try {
      // Cancelar suscripción previa si existe
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      // Completer para manejar la respuesta
      final completer = Completer<bool>();

      // Suscribirse a las notificaciones para este dispositivo
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x15) {
          // FUN_STOP_EMS_R recibido
          final retorno = data[2];
          final result = retorno == 1;
          if (!completer.isCompleted) {
            completer.complete(result);
          }
          debugPrint(
              "📥 FUN_STOP_EMS_R recibido desde $macAddress: ${result ? "OK" : "FAIL"}");
        }
      }, onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Almacenar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_STOP_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint(
          "📤 FUN_STOP_EMS enviado a $macAddress para endpoint $endpoint.");

      // Esperar respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return result;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress al detener sesión: $e");
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      return false;
    } catch (e) {
      debugPrint("❌ Error al detener sesión en $macAddress: $e");
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      return false;
    }
  }

  Future<Map<String, dynamic>> controlElectrostimulatorChannel({
    required String macAddress,
    required int endpoint,
    required int canal,
    required int modo,
    required int valor,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar parámetros
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (canal < 0 || canal > 9) {
      throw ArgumentError("El canal debe estar entre 0 y 9.");
    }
    if (modo < 0 || modo > 3) {
      throw ArgumentError(
          "El modo debe ser 0 (absoluto), 1 (incrementa), 2 (decrementa), o 3 (solo retorna valor).");
    }
    if (valor < 0 || valor > 100) {
      throw ArgumentError("El valor debe estar entre 0 y 100.");
    }

    // Crear el paquete de solicitud FUN_CANAL_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x16; // FUN_CANAL_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = canal;
    requestPacket[3] = modo;
    requestPacket[4] = valor;

    try {
      // Cancelar cualquier suscripción activa previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x17) {
          // FUN_CANAL_EMS_R recibido
          final endpointResp = data[1];
          final canalResp = data[2];
          final resultado = data[3] == 1 ? "OK" : "FAIL";
          final valorResp = data[4];

          final response = {
            'endpoint': endpointResp,
            'canal': canalResp,
            'resultado': resultado,
            'valor': valorResp == 200 ? "Limitador activado" : "$valorResp%",
          };

          completer.complete(response);
          debugPrint(
              "📥 FUN_CANAL_EMS_R recibido desde $macAddress: $response");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_CANAL_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint(
          "📤 FUN_CANAL_EMS enviado a $macAddress. Endpoint: $endpoint, Canal: $canal, Modo: $modo, Valor: $valor.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return response;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error en controlElectrostimulatorChannel para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  String parseChannelControlResponse(Map<String, dynamic> response) {
    final endpoint = response['endpoint'];
    final canal = response['canal'];
    final resultado = response['resultado'];
    final valor = response['valor'];

    return '''
🎛️ Control del canal del electroestimulador:
- Endpoint: $endpoint
- Canal: $canal
- Resultado: $resultado
- Valor: $valor
''';
  }

  Future<Map<String, dynamic>> _controlAllChannels(
    String macAddress,
    int endpoint,
    int modo,
    List<int> valoresCanales,
  ) async {
    try {
      // Invocar la función principal que controla todos los canales
      final response = await controlAllElectrostimulatorChannels(
        macAddress: macAddress,
        endpoint: endpoint,
        modo: modo,
        valoresCanales: valoresCanales,
      );

      // Verificar el resultado y mostrar mensajes adecuados
      if (response['resultado'] == "OK") {
        debugPrint(
            "✅ Control de canales ejecutado correctamente en $macAddress.");
      } else {
        debugPrint(
            "❌ Error al controlar los canales en $macAddress: ${response['resultado']}.");
      }

      return response; // Retornar el mapa con los datos de la respuesta
    } catch (e) {
      debugPrint(
          "❌ Error al procesar el control de canales en $macAddress: $e");
      // Retornar un mapa de error en caso de excepción
      return {
        'endpoint': endpoint,
        'resultado': "ERROR",
        'valoresCanales': [],
      };
    }
  }

  Future<Map<String, dynamic>> controlAllElectrostimulatorChannels({
    required String macAddress,
    required int endpoint,
    required int modo,
    required List<int> valoresCanales,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar parámetros
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }
    if (modo < 0 || modo > 3) {
      throw ArgumentError(
          "El modo debe ser 0 (absoluto), 1 (incrementa), 2 (decrementa), o 3 (solo retorna valores).");
    }
    if (valoresCanales.length != 7 && valoresCanales.length != 10) {
      throw ArgumentError(
          "La lista de valoresCanales debe tener exactamente 7 o 10 elementos.");
    }
    if (valoresCanales.any((valor) => valor < 0 || valor > 100)) {
      throw ArgumentError(
          "Todos los valores de los canales deben estar entre 0 y 100.");
    }

    // Crear el paquete de solicitud FUN_ALL_CANAL_EMS
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x18; // FUN_ALL_CANAL_EMS
    requestPacket[1] = endpoint;
    requestPacket[2] = modo;
    for (int i = 0; i < valoresCanales.length; i++) {
      requestPacket[3 + i] = valoresCanales[i];
    }

    try {
      // Cancelar cualquier suscripción previa para este dispositivo
      _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones
      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x19) {
          // FUN_ALL_CANAL_EMS_R recibido
          final endpointResp = data[1];
          final resultado = data[2] == 1 ? "OK" : "FAIL";
          final valoresResp = data.sublist(3, 13).map((v) {
            return v == 200 ? "Limitador activado" : "$v%";
          }).toList();

          final response = {
            'endpoint': endpointResp,
            'resultado': resultado,
            'valoresCanales': valoresResp,
          };

          completer.complete(response);
          debugPrint(
              "📥 FUN_ALL_CANAL_EMS_R recibido desde $macAddress: $response");
        }
      }, onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
        debugPrint("❌ Error en notificación para $macAddress: $error");
      });

      // Guardar la suscripción
      _subscriptions[macAddress] = subscription;

      // Enviar la solicitud FUN_ALL_CANAL_EMS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );

      debugPrint(
          "📤 FUN_ALL_CANAL_EMS enviado a $macAddress. Endpoint: $endpoint, Modo: $modo, Valores: $valoresCanales.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar y remover la suscripción después de recibir la respuesta
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);

      return response;
    } on TimeoutException catch (e) {
      debugPrint("❌ Timeout para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    } catch (e) {
      debugPrint(
          "❌ Error en controlAllElectrostimulatorChannels para $macAddress: $e");
      await _subscriptions[macAddress]?.cancel();
      _subscriptions.remove(macAddress);
      rethrow;
    }
  }

  String parseAllChannelsResponse(Map<String, dynamic> response) {
    final endpoint = response['endpoint'];
    final resultado = response['resultado'];
    final valoresCanales = response['valoresCanales'] as List<String>;

    final canales = valoresCanales
        .asMap()
        .entries
        .map((entry) => "  Canal ${entry.key + 1}: ${entry.value}")
        .join('\n');

    return '''
🎚️ Control de todos los canales del electroestimulador:
- Endpoint: $endpoint
- Resultado: $resultado
$canales
''';
  }

  Future<bool> performShutdown({
    required String macAddress,
    int temporizado = 0, // Shutdown inmediato por defecto
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    try {
      debugPrint(
          "🔄 Enviando comando de shutdown al dispositivo $macAddress...");

      // Construir el paquete de shutdown
      final List<int> shutdownPacket = List.filled(20, 0);
      shutdownPacket[0] = 0x1A; // FUN_RESET
      shutdownPacket[1] = 0x66; // Shutdown
      shutdownPacket[2] = temporizado; // Temporizado (0 para inmediato)

      // Enviar el paquete
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: shutdownPacket,
      );

      debugPrint("✅ Comando de shutdown enviado correctamente.");
      return true;
    } catch (e) {
      debugPrint("❌ Error al enviar el comando de shutdown: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getFreeMemory({
    required String macAddress,
    required int pagina,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar la página
    if (pagina < 0 || pagina > 31) {
      throw ArgumentError("La página debe estar entre 0 y 31.");
    }

    // Crear el paquete de solicitud FUN_GET_MEM
    final List<int> requestPacket = List.filled(20, 0);
    requestPacket[0] = 0x1C; // FUN_GET_MEM
    requestPacket[1] = pagina;

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_MEM_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x1D) {
          // FUN_GET_MEM_R recibido
          final response = {
            'status': data[1] == 1 ? "OK" : "FAIL",
            'pagina': data[2],
            'datos': data.sublist(3, 19),
          };
          completer.complete(response);
          debugPrint("📥 FUN_GET_MEM_R recibido desde $macAddress: $response");
        }
      });

      // Enviar la solicitud FUN_GET_MEM
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint("📤 FUN_GET_MEM enviado a $macAddress. Página: $pagina.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al obtener memoria libre: $e");
      rethrow;
    }
  }

  Future<bool> setFreeMemory({
    required String macAddress,
    required int pagina,
    required List<int> datos,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar la página y los datos
    if (pagina < 0 || pagina > 31) {
      throw ArgumentError("La página debe estar entre 0 y 31.");
    }
    if (datos.length != 16) {
      throw ArgumentError("Los datos deben tener exactamente 16 bytes.");
    }

    // Crear el paquete de solicitud FUN_SET_MEM
    final List<int> requestPacket = [0x1E, pagina, ...datos];

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<bool>();

      // Suscribirse a las notificaciones para recibir FUN_SET_MEM_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x1F) {
          // FUN_SET_MEM_R recibido
          completer.complete(data[1] == 1); // OK: 1
          debugPrint(
              "📥 FUN_SET_MEM_R recibido desde $macAddress: ${data[1] == 1 ? "OK" : "FAIL"}");
        }
      });

      // Enviar la solicitud FUN_SET_MEM
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_SET_MEM enviado a $macAddress. Página: $pagina, Datos: $datos.");

      // Esperar la respuesta con timeout
      final result =
          await completer.future.timeout(const Duration(seconds: 10));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return result;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al escribir en memoria libre: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPulseMeter({
    required String macAddress,
    required int endpoint,
  }) async {
    final characteristicRx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: rxCharacteristicUuid,
      deviceId: macAddress,
    );

    final characteristicTx = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: txCharacteristicUuid,
      deviceId: macAddress,
    );

    // Validar el endpoint
    if (endpoint < 1 || endpoint > 4) {
      throw ArgumentError("El endpoint debe estar entre 1 y 4.");
    }

    // Crear el paquete de solicitud FUN_GET_PULSOS
    final List<int> requestPacket = [0x20, endpoint];

    try {
      // Cancelar cualquier suscripción activa previa
      notificationSubscription?.cancel();
      notificationSubscription = null;

      // Completer para manejar la respuesta
      final completer = Completer<Map<String, dynamic>>();

      // Suscribirse a las notificaciones para recibir FUN_GET_PULSOS_R
      notificationSubscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x32) {
          // FUN_GET_PULSOS_R recibido
          final response = {
            'endpoint': data[1],
            'status': _mapPulseMeterStatus(data[2]),
            'bps': (data[3] << 8) | data[4], // Pulsaciones por segundo
            'SpO2': (data[5] << 8) | data[6], // Saturación de oxígeno
          };
          completer.complete(response);
          debugPrint(
              "📥 FUN_GET_PULSOS_R recibido desde $macAddress: $response");
        } else {
          debugPrint("❌ Error: Datos inesperados recibidos.");
        }
      });

      // Enviar la solicitud FUN_GET_PULSOS
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristicRx,
        value: requestPacket,
      );
      debugPrint(
          "📤 FUN_GET_PULSOS enviado a $macAddress. Endpoint: $endpoint.");

      // Esperar la respuesta con timeout
      final response =
          await completer.future.timeout(const Duration(seconds: 15));

      // Cancelar la suscripción después de recibir la respuesta
      notificationSubscription?.cancel();
      return response;
    } catch (e) {
      // Cancelar la suscripción en caso de error
      notificationSubscription?.cancel();
      debugPrint("❌ Error al obtener datos del pulsómetro: $e");
      rethrow;
    }
  }

  Future<bool> _getSignalCable(
    String macAddress,
    int endpoint,
  ) async {
    try {
      // Llamar a getPulseMeter para obtener los datos del pulsómetro
      final pulseMeterResponse = await getPulseMeter(
        macAddress: macAddress,
        endpoint: endpoint,
      );
      final status = pulseMeterResponse['status'];
      final bps = pulseMeterResponse['bps'];
      final SpO2 = pulseMeterResponse['SpO2'];

      debugPrint(
          "📡 Datos del pulsómetro recibidos: Status = $status, BPS = $bps, SpO2 = $SpO2");

      // Validar que el sensor esté operando correctamente
      if (status != "OK") {
        debugPrint("❌ Error: El pulsómetro no está operativo. Estado: $status");
        return false;
      }

      // Si el pulsómetro está OK, se retorna true indicando éxito
      return true;
    } catch (e) {
      debugPrint("❌ Error al obtener datos del pulsómetro de $macAddress: $e");
      return false;
    }
  }

  String _mapPulseMeterStatus(int status) {
    switch (status) {
      case 0:
        return "No existe";
      case 1:
        return "Sensor desconectado o con error";
      case 2:
        return "Sensor no capta";
      case 3:
        return "OK";
      default:
        return "Desconocido";
    }
  }

  String _mapState(int state) {
    const states = {
      0: "POWER OFF",
      1: "CHARGE",
      2: "STOP",
      3: "RUN RAMPA",
      4: "RUN",
      10: "CLOSING",
      100: "LIMITE TARIFA",
      101: "ERROR POR FALLO INTERNO",
      102: "ERROR FALLO ELEVADOR",
      103: "ERROR SOBRE-TEMPERATURA",
      104: "ERROR TENSIÓN ALIMENTACIÓN FUERA DEL RANGO",
    };
    return states[state] ?? "Estado desconocido";
  }

// Mapear el estado de la batería
  String _mapBatteryStatus(int status) {
    switch (status) {
      case 0:
        return "Muy baja";
      case 1:
        return "Baja";
      case 2:
        return "Media";
      case 3:
        return "Alta";
      case 4:
        return "Llena";
      default:
        return "Desconocido";
    }
  }
}
