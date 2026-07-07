import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class BluetoothTransport {
  bool get isConnected;
  List<BluetoothDevice> get bondedDevices;
  Stream<void> get onConnectionLost;

  Future<bool> enableBluetooth();
  Future<List<BluetoothDevice>> loadBondedDevices();
  Future<bool> connectToDevice(BluetoothDevice device);
  Future<bool> sendCommand(String command);
  Future<void> disconnect();
  void dispose();
}

class BluetoothService implements BluetoothTransport {
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  final StreamController<void> _connectionLostController =
      StreamController<void>.broadcast();
  final List<BluetoothDevice> _bondedDevices = [];
  bool _disconnecting = false;
  bool _disposed = false;

  @override
  bool get isConnected => _connection?.isConnected ?? false;

  @override
  List<BluetoothDevice> get bondedDevices => _bondedDevices;

  @override
  Stream<void> get onConnectionLost => _connectionLostController.stream;

  @override
  Future<bool> enableBluetooth() async {
    if (!await _requestPermissions()) return false;

    try {
      final state = await FlutterBluetoothSerial.instance.state;
      if (state == BluetoothState.STATE_OFF) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }
      return await FlutterBluetoothSerial.instance.state ==
          BluetoothState.STATE_ON;
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao ativar Bluetooth',
        name: 'BluetoothService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.locationWhenInUse]?.isGranted == true;
  }

  @override
  Future<List<BluetoothDevice>> loadBondedDevices() async {
    _bondedDevices.clear();
    try {
      _bondedDevices.addAll(
        await FlutterBluetoothSerial.instance.getBondedDevices(),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao carregar dispositivos',
        name: 'BluetoothService',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return _bondedDevices;
  }

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_connection != null) await disconnect();

    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      _connection = connection;

      _inputSubscription = connection.input?.listen(
        (_) {},
        onError: (_, _) => _handleConnectionClosed(),
        onDone: _handleConnectionClosed,
        cancelOnError: true,
      );

      return true;
    } catch (e, stackTrace) {
      _connection = null;
      developer.log(
        'Falha na conexão',
        name: 'BluetoothService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<bool> sendCommand(String command) async {
    if (!isConnected) return false;
    if (command.length != 1 || command.codeUnitAt(0) > 0x7f) return false;

    try {
      final commandBytes = Uint8List.fromList([command.codeUnitAt(0)]);
      _connection!.output.add(commandBytes);
      await _connection!.output.allSent;
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao enviar comando',
        name: 'BluetoothService',
        error: e,
        stackTrace: stackTrace,
      );
      _handleConnectionClosed();
      return false;
    }
  }

  void _handleConnectionClosed() {
    if (_disconnecting || _connection == null) return;

    _connection = null;
    _inputSubscription = null;

    if (!_disposed && !_connectionLostController.isClosed) {
      _connectionLostController.add(null);
    }
  }

  @override
  Future<void> disconnect() async {
    _disconnecting = true;
    final connection = _connection;
    final inputSubscription = _inputSubscription;

    _connection = null;
    _inputSubscription = null;

    try {
      await inputSubscription?.cancel();
      await connection?.close();
    } finally {
      _disconnecting = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(disconnect());
    unawaited(_connectionLostController.close());
  }
}
