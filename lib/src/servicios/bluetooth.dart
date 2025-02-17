import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'bluetooth_commands.dart';

class BleConnectionService {
  final flutterReactiveBle = FlutterReactiveBle();
  final BleCommandService bleCommandService = BleCommandService();
  bool isWidgetActive = true;
  List<String> targetDeviceIds = []; // Lista para almacenar las direcciones MAC
  final List<String> connectedDevices = []; // Lista de MACs conectadas
  final Map<String, StreamController<bool>> _deviceConnectionStateControllers =
  {};
  final Map<String, StreamSubscription<ConnectionStateUpdate>> _connectionStreams = {};
  final StreamController<Map<String, dynamic>> _deviceUpdatesController =
  StreamController.broadcast();

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

  BleConnectionService() {
    debugPrint("🚀 Servicio BLE inicializado");
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

  /// Procesa un dispositivo conectado: inicializa la seguridad y obtiene la información
  Future<void> processConnectedDevices(String deviceId) async {
    if (connectedDevices.isEmpty) {
      debugPrint("⚠️ Ningún dispositivo conectado. Abortando operaciones.");
      return;
    }
    try {
      // Inicializar la seguridad mediante el CommandService
      await bleCommandService.initializeSecurity(deviceId);
      debugPrint("🔒--->>> Fase de inicialización de seguridad completada para $deviceId.");
      await _processDeviceInfo(deviceId);
    } catch (e) {
      debugPrint("❌--->>> Error al procesar el dispositivo $deviceId: $e");
    }
  }

  /// Obtiene y procesa la información general del dispositivo
  Future<void> _processDeviceInfo(String macAddress) async {
    try {
      // FUN_INFO
      final deviceInfo = await bleCommandService.getDeviceInfo(macAddress)
          .timeout(const Duration(seconds: 15));
      final parsedInfo = bleCommandService.parseDeviceInfo(deviceInfo);
      debugPrint(parsedInfo);

      // FUN_GET_NAMEBT
      final nameBt = await bleCommandService.getBluetoothName(macAddress)
          .timeout(const Duration(seconds: 15));
      debugPrint("🅱️ Nombre del Bluetooth ($macAddress): $nameBt");
      updateBluetoothName(macAddress, nameBt.isNotEmpty ? nameBt : "No disponible");

      // FUN_GET_PARAMBAT
      final batteryParameters = await bleCommandService.getBatteryParameters(macAddress)
          .timeout(const Duration(seconds: 15));
      final parsedBattery = bleCommandService.parseBatteryParameters(batteryParameters);
      debugPrint(parsedBattery);
      updateBatteryStatus(macAddress, batteryParameters['batteryStatusRaw'] ?? -1);

      // FUN_GET_CONTADOR
      final counters = await bleCommandService.getTariffCounters(macAddress)
          .timeout(const Duration(seconds: 15));
      final parsedCounters = bleCommandService.parseTariffCounters(counters);
      debugPrint(parsedCounters);
    } catch (e) {
      debugPrint("❌ Error al procesar la información general de $macAddress: $e");
    }
  }
  }
