import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothViewModel extends ChangeNotifier {
  final BluetoothService _service = BluetoothService();

  bool _isBluetoothOn = false;
  bool _isConnected = false;
  String? _connectedDeviceName;
  List<BluetoothDevice> _devices = [];
  String _errorMessage = '';

  bool get isBluetoothOn => _isBluetoothOn;
  bool get isConnected => _isConnected;
  String? get connectedDeviceName => _connectedDeviceName;
  List<BluetoothDevice> get devices => _devices;
  String get errorMessage => _errorMessage;

  Future<void> init() async {
    _isBluetoothOn = await _service.enableBluetooth();
    if (_isBluetoothOn) {
      await loadDevices();
    } else {
      _errorMessage = 'Bluetooth não disponível';
    }
    notifyListeners();
  }

  Future<void> loadDevices() async {
    if (!_isBluetoothOn) return;
    _devices = await _service.loadBondedDevices();
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_isConnected) {
      _errorMessage =
          'Já conectado a $_connectedDeviceName. Desconecte primeiro.';
      notifyListeners();
      return;
    }

    final success = await _service.connectToDevice(device);
    if (success) {
      _isConnected = true;
      _connectedDeviceName = device.name ?? device.address;
      _errorMessage = '';
    } else {
      _errorMessage = 'Falha ao conectar com ${device.name}';
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _service.disconnect();
    } catch (e) {
      print('Erro ao desconectar: $e');
    }
    _isConnected = false;
    _connectedDeviceName = null;
    notifyListeners();
  }

  Future<bool> sendCommand(String command) async {
    if (!_isConnected) {
      _errorMessage = 'Sem conexão ativa';
      notifyListeners();
      return false;
    }
    final success = await _service.sendCommand(command);
    if (!success) {
      _errorMessage = 'Falha ao enviar comando';
      notifyListeners();
    }
    return success;
  }
}
