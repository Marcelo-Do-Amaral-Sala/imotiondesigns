import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConnectionService {
  final flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<List<int>>? notificationSubscription;
  final Map<String, StreamSubscription<List<int>>> _subscriptions = {};
  bool isWidgetActive = true;
  List<String> targetDeviceIds = []; // Lista para almacenar las direcciones MAC
  final List<String> connectedDevices = []; // Lista de MACs conectadas
  final Map<String, StreamController<bool>> _deviceConnectionStateControllers =
  {};
  final Map<String, StreamSubscription<ConnectionStateUpdate>> _connectionStreams = {};
  final Uuid serviceUuid = Uuid.parse("49535343-FE7D-4AE5-8FA9-9FAFD205E455");
  final Uuid rxCharacteristicUuid =
  Uuid.parse("49535343-8841-43F4-A8D4-ECBE34729BB4");
  final Uuid txCharacteristicUuid =
  Uuid.parse("49535343-1E4D-4BD9-BA61-23C647249617");

  final StreamController<Map<String, dynamic>> _deviceUpdatesController =
  StreamController.broadcast();


  BleConnectionService() {
    debugPrint("🚀 Servicio BLE inicializado");
  }


  /// 🎯 **Obtener stream del estado de conexión de un dispositivo**
  Stream<bool> connectionStateStream(String macAddress) {
    _deviceConnectionStateControllers.putIfAbsent(
        macAddress, () => StreamController<bool>.broadcast());
    return _deviceConnectionStateControllers[macAddress]!.stream;
  }


  void updateDeviceConnectionState(String macAddress, bool isConnected) {
    _deviceConnectionStateControllers.putIfAbsent(
        macAddress, () => StreamController<bool>.broadcast());

    final controller = _deviceConnectionStateControllers[macAddress]!;

    if (!controller.isClosed) {
      controller.add(isConnected);
      debugPrint("🔄 Estado de conexión actualizado para $macAddress: ${isConnected ? 'conectado' : 'desconectado'}");
    }

    // Si el dispositivo se desconecta, cerramos el StreamController
    if (!isConnected) {
      _deviceConnectionStateControllers[macAddress]?.close();
      _deviceConnectionStateControllers.remove(macAddress);
    }
  }

  // Llamar esto para actualizar el estado del dispositivo
  void updateBluetoothName(String macAddress, String name) {
    emitDeviceUpdate(macAddress, 'bluetoothName', name);
  }

  void updateBatteryStatus(String macAddress, int status) {
    emitDeviceUpdate(macAddress, 'batteryStatus', status);
  }

  Stream<Map<String, dynamic>> get deviceUpdates =>
      _deviceUpdatesController.stream;

  /// 📡 **Emitir actualizaciones del dispositivo**
  void emitDeviceUpdate(String macAddress, String key, dynamic value) {
    _deviceUpdatesController.add({'macAddress': macAddress, key: value});
  }


  void updateMacAddresses(List<String> macAddresses) async {
    targetDeviceIds.clear();
    connectedDevices.clear();

    targetDeviceIds.addAll(macAddresses);
    debugPrint("🔄 Lista de dispositivos objetivo actualizada: $targetDeviceIds");

    List<String> availableDevices = await scanTargetDevices();

    for (String deviceId in availableDevices) {
      if (!connectedDevices.contains(deviceId)) {
        connectToDeviceByMac(deviceId);
      }
    }
  }

  Future<List<String>> scanTargetDevices() async {
    List<String> availableDevices = [];

    debugPrint("🔎 Iniciando escaneo de dispositivos en la lista objetivo...");

    final scanSubscription = flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      if (targetDeviceIds.contains(device.id) && !availableDevices.contains(device.id)) {
        availableDevices.add(device.id);
        debugPrint("✅ Dispositivo encontrado: ${device.id} - ${device.name}");
      }
    }, onError: (error) {
      debugPrint("❌ Error durante el escaneo: $error");
    });

    await Future.delayed(Duration(seconds: 2)); // Escanear durante 5 segundos
    await scanSubscription.cancel();

    debugPrint("🔍 Escaneo finalizado. Dispositivos disponibles: $availableDevices");
    return availableDevices;
  }


  /// 📶 **Conectar con un dispositivo BLE por MAC**
  Future<bool> connectToDeviceByMac(String deviceId) async {
    if (deviceId.isEmpty) {
      debugPrint("⚠️ Identificador del dispositivo vacío. Conexión cancelada.");
      return false;
    }

    if (connectedDevices.contains(deviceId)) {
      debugPrint("🔗 Dispositivo $deviceId ya conectado.");
      return true;
    }

    debugPrint("🚩 Intentando conectar al dispositivo con ID: $deviceId...");

    try {
      // Cancelar cualquier conexión previa para evitar conflictos
      _connectionStreams[deviceId]?.cancel();

      _connectionStreams[deviceId] = flutterReactiveBle
          .connectToDevice(id: deviceId)
          .listen((connectionState) {
        switch (connectionState.connectionState) {
          case DeviceConnectionState.connected:
            debugPrint("✅ Dispositivo $deviceId conectado.");
            connectedDevices.add(deviceId);
            updateDeviceConnectionState(deviceId, true);
            break;

          case DeviceConnectionState.disconnected:
            debugPrint("⛓️ Dispositivo $deviceId desconectado.");
            updateDeviceConnectionState(deviceId, false);
            _connectionStreams[deviceId]?.cancel();
            _connectionStreams.remove(deviceId);
            connectedDevices.remove(deviceId);
            break;


          default:
            debugPrint("⏳ Estado desconocido para $deviceId.");
            break;
        }
      }, onError: (error) {
        debugPrint("❌ Error al conectar a $deviceId: $error");
        _connectionStreams[deviceId]?.cancel();
        _connectionStreams.remove(deviceId);
      });
    } catch (e) {
      debugPrint("❌ Error inesperado al conectar a $deviceId: $e");
    }

    return true;
  }
  void dispose() {
    debugPrint("🛑 Cerrando servicio BLE y desconectando dispositivos...");
    for (var deviceId in connectedDevices) {
      _connectionStreams[deviceId]?.cancel();
    }
    connectedDevices.clear();
    for (var controller in _deviceConnectionStateControllers.values) {
      controller.close();
    }
    _deviceConnectionStateControllers.clear();
    _deviceUpdatesController.close();
  }


  /// 📡 **Obtener el estado de conexión global**
  bool get isConnected => connectedDevices.isNotEmpty;



///METODOS DE COMUNICACION CON MCIS

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
          await handleSecurityChallenge(macAddress, data);
        }
      });
    } catch (e) {
      print("Error al inicializar seguridad: $e");
    }
  }

  // Manejo del reto de seguridad
  Future<void> handleSecurityChallenge(
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
    final state = mapState(data[2]); // Mapear el estado según lo definido
    final batteryStatus = mapBatteryStatus(data[3]); // Mapear estado de batería
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

  Future<bool> startElectrostimulationSession(
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
  Future<bool> stopElectrostimulationSession(String macAddress) async {
    try {
      final stopSuccess = await stopElectrostimulationSession1(
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
          if (!completer.isCompleted) { // ✅ Evita completar más de una vez
            completer.complete(retorno == 1);
            debugPrint("📥 FUN_RUN_EMS_R recibido desde $macAddress: ${retorno == 1 ? "OK" : "FAIL"}");
          } else {
            debugPrint("⚠️ Se ignoró respuesta duplicada de $macAddress.");
          }
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

  Future<bool> stopElectrostimulationSession1({
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

  Future<Map<String, dynamic>> controlAllChannels(
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

      final subscription = flutterReactiveBle
          .subscribeToCharacteristic(characteristicTx)
          .listen((data) {
        if (data.isNotEmpty && data[0] == 0x19) {
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

          if (!completer.isCompleted) { // ✅ Evita completar más de una vez
            completer.complete(response);
            debugPrint("📥 FUN_ALL_CANAL_EMS_R recibido desde $macAddress: $response");
          } else {
            debugPrint("⚠️ Se ignoró respuesta duplicada de $macAddress.");
          }
        }
      }, onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
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
            'status': mapPulseMeterStatus(data[2]),
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

  Future<bool> getSignalCable(
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

  String mapPulseMeterStatus(int status) {
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

  String mapState(int state) {
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
  String mapBatteryStatus(int status) {
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
