import 'dart:async';
import 'dart:collection';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class BluetoothViewModel extends ChangeNotifier {
  final BluetoothTransport _service;
  late final StreamSubscription<void> _connectionLostSubscription;

  bool _isBluetoothOn = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectedDeviceName;
  List<BluetoothDevice> _devices = [];
  String _errorMessage = '';
  bool _disposed = false;
  final LinkedHashMap<String, String> _activeControls = LinkedHashMap();

  bool get isBluetoothOn => _isBluetoothOn;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectedDeviceName => _connectedDeviceName;
  List<BluetoothDevice> get devices => _devices;
  String get errorMessage => _errorMessage;

  String? _selectedDeviceAddress;

  String? get selectedDeviceAddress => _selectedDeviceAddress;

  BluetoothViewModel({BluetoothTransport? service})
    : _service = service ?? BluetoothService() {
    _connectionLostSubscription = _service.onConnectionLost.listen((_) {
      _handleConnectionLost('Conexão Bluetooth perdida');
    });
  }

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    _isBluetoothOn = await _service.enableBluetooth();
    if (_isBluetoothOn) {
      await loadDevices();
    } else {
      _devices = [];
      _errorMessage = 'Bluetooth não disponível';
      _safeNotifyListeners();
    }
  }

  Future<void> loadDevices() async {
    if (!_isBluetoothOn) {
      _isBluetoothOn = await _service.enableBluetooth();
      if (!_isBluetoothOn) {
        _devices = [];
        _errorMessage = 'Bluetooth não disponível';
        _safeNotifyListeners();
        return;
      }
    }

    _devices = await _service.loadBondedDevices();
    _errorMessage = '';
    _safeNotifyListeners();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;

    _activeControls.clear();
    _selectedDeviceAddress = device.address;
    _isConnecting = true;
    _errorMessage = '';
    _safeNotifyListeners();

    if (_isConnected) {
      _errorMessage =
          'Já conectado a $_connectedDeviceName. Desconecte primeiro.';
      _isConnecting = false;
      _safeNotifyListeners();
      return false;
    }

    final success = await _service.connectToDevice(device);
    if (success) {
      _isConnected = true;
      _connectedDeviceName = device.name ?? device.address;
      _errorMessage = '';
    } else {
      _isConnected = false;
      _connectedDeviceName = null;
      _errorMessage = 'Falha ao conectar com ${device.name}';
    }

    _isConnecting = false;
    _safeNotifyListeners();
    return success;
  }

  Future<void> disconnect() async {
    _activeControls.clear();
    await _service.disconnect();
    _isConnected = false;
    _connectedDeviceName = null;
    _errorMessage = '';
    _safeNotifyListeners();
  }

  Future<bool> sendCommand(String command) async {
    if (!_isConnected || !_service.isConnected) {
      _activeControls.clear();
      _errorMessage = 'Sem conexão ativa';
      _isConnected = false;
      _connectedDeviceName = null;
      _safeNotifyListeners();
      return false;
    }

    final success = await _service.sendCommand(command);
    if (!success) {
      _handleConnectionLost('Falha ao enviar comando');
    }
    return success;
  }

  void pressControl(String controlId, String command) {
    _activeControls.remove(controlId);
    _activeControls[controlId] = command;
    unawaited(sendCommand(command));
  }

  void releaseControl(String controlId) {
    final previousCommand = _activeControls.isEmpty
        ? null
        : _activeControls.values.last;
    if (_activeControls.remove(controlId) == null) return;

    final activeCommand = _activeControls.isEmpty
        ? 'S'
        : _activeControls.values.last;
    if (activeCommand != previousCommand) {
      unawaited(sendCommand(activeCommand));
    }
  }

  void _handleConnectionLost(String message) {
    _activeControls.clear();
    _isConnected = false;
    _isConnecting = false;
    _connectedDeviceName = null;
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_connectionLostSubscription.cancel());
    _service.dispose();
    super.dispose();
  }
}
