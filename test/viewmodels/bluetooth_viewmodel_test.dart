import 'dart:async';

import 'package:ctrl/services/bluetooth_service.dart';
import 'package:ctrl/viewmodels/bluetooth_viewmodel.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBluetoothTransport implements BluetoothTransport {
  bool enableResult = true;
  bool connectResult = true;
  bool connected = false;
  bool sendResult = true;
  List<BluetoothDevice> devicesResult = const [];
  final List<String> sentCommands = [];
  final StreamController<void> _connectionLostController =
      StreamController<void>.broadcast();

  @override
  bool get isConnected => connected;

  @override
  List<BluetoothDevice> get bondedDevices => devicesResult;

  @override
  Stream<void> get onConnectionLost => _connectionLostController.stream;

  @override
  Future<bool> enableBluetooth() async => enableResult;

  @override
  Future<List<BluetoothDevice>> loadBondedDevices() async => devicesResult;

  @override
  Future<bool> connectToDevice(BluetoothDevice device) async {
    connected = connectResult;
    return connectResult;
  }

  @override
  Future<bool> sendCommand(String command) async {
    sentCommands.add(command);
    return connected && sendResult;
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }

  void loseConnection() {
    connected = false;
    _connectionLostController.add(null);
  }

  @override
  void dispose() {
    _connectionLostController.close();
  }
}

void main() {
  const device = BluetoothDevice(name: 'HC-05', address: '00:11:22:33:44:55');

  test('loads bonded devices when Bluetooth is available', () async {
    final transport = FakeBluetoothTransport()..devicesResult = [device];
    final viewModel = BluetoothViewModel(service: transport);

    await viewModel.init();

    expect(viewModel.isBluetoothOn, isTrue);
    expect(viewModel.devices, [device]);
    expect(viewModel.errorMessage, isEmpty);

    viewModel.dispose();
  });

  test(
    'refresh retries permissions and clears previous Bluetooth error',
    () async {
      final transport = FakeBluetoothTransport()
        ..enableResult = false
        ..devicesResult = [device];
      final viewModel = BluetoothViewModel(service: transport);

      await viewModel.init();

      expect(viewModel.isBluetoothOn, isFalse);
      expect(viewModel.devices, isEmpty);
      expect(viewModel.errorMessage, 'Bluetooth não disponível');

      transport.enableResult = true;
      await viewModel.refresh();

      expect(viewModel.isBluetoothOn, isTrue);
      expect(viewModel.devices, [device]);
      expect(viewModel.errorMessage, isEmpty);

      viewModel.dispose();
    },
  );

  test('connects to a selected device', () async {
    final transport = FakeBluetoothTransport();
    final viewModel = BluetoothViewModel(service: transport);

    final connected = await viewModel.connectToDevice(device);

    expect(connected, isTrue);
    expect(viewModel.isConnected, isTrue);
    expect(viewModel.connectedDeviceName, 'HC-05');
    expect(viewModel.selectedDeviceAddress, device.address);
    expect(viewModel.errorMessage, isEmpty);

    viewModel.dispose();
  });

  test('keeps recoverable error when connection fails', () async {
    final transport = FakeBluetoothTransport()..connectResult = false;
    final viewModel = BluetoothViewModel(service: transport);

    final connected = await viewModel.connectToDevice(device);

    expect(connected, isFalse);
    expect(viewModel.isConnected, isFalse);
    expect(viewModel.connectedDeviceName, isNull);
    expect(viewModel.errorMessage, 'Falha ao conectar com HC-05');

    viewModel.dispose();
  });

  test('clears connected state on remote connection loss', () async {
    final transport = FakeBluetoothTransport();
    final viewModel = BluetoothViewModel(service: transport);

    await viewModel.connectToDevice(device);
    transport.loseConnection();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.isConnected, isFalse);
    expect(viewModel.connectedDeviceName, isNull);
    expect(viewModel.errorMessage, 'Conexão Bluetooth perdida');

    viewModel.dispose();
  });

  test(
    'sendCommand sends command and fails closed after a lost connection',
    () async {
      final transport = FakeBluetoothTransport();
      final viewModel = BluetoothViewModel(service: transport);

      await viewModel.connectToDevice(device);

      expect(await viewModel.sendCommand('F'), isTrue);
      expect(transport.sentCommands, ['F']);

      transport.connected = false;

      expect(await viewModel.sendCommand('R'), isFalse);
      expect(viewModel.isConnected, isFalse);
      expect(viewModel.connectedDeviceName, isNull);
      expect(viewModel.errorMessage, 'Sem conexão ativa');

      viewModel.dispose();
    },
  );

  test('sendCommand clears state when the transport write fails', () async {
    final transport = FakeBluetoothTransport()..sendResult = false;
    final viewModel = BluetoothViewModel(service: transport);

    await viewModel.connectToDevice(device);

    expect(await viewModel.sendCommand('F'), isFalse);
    expect(viewModel.isConnected, isFalse);
    expect(viewModel.connectedDeviceName, isNull);
    expect(viewModel.errorMessage, 'Falha ao enviar comando');

    viewModel.dispose();
  });

  test(
    'resumes the remaining control when the latest control is released',
    () async {
      final transport = FakeBluetoothTransport();
      final viewModel = BluetoothViewModel(service: transport);

      await viewModel.connectToDevice(device);

      viewModel.pressControl('up', 'F');
      viewModel.pressControl('right', 'R');
      viewModel.releaseControl('right');
      viewModel.releaseControl('up');

      expect(transport.sentCommands, ['F', 'R', 'F', 'S']);

      viewModel.dispose();
    },
  );

  test('does not stop while another control remains active', () async {
    final transport = FakeBluetoothTransport();
    final viewModel = BluetoothViewModel(service: transport);

    await viewModel.connectToDevice(device);

    viewModel.pressControl('up', 'F');
    viewModel.pressControl('right', 'R');
    viewModel.releaseControl('up');

    expect(transport.sentCommands, ['F', 'R']);

    viewModel.releaseControl('right');

    expect(transport.sentCommands, ['F', 'R', 'S']);

    viewModel.dispose();
  });

  test('retains the most recent command among three active controls', () async {
    final transport = FakeBluetoothTransport();
    final viewModel = BluetoothViewModel(service: transport);

    await viewModel.connectToDevice(device);

    viewModel.pressControl('up', 'F');
    viewModel.pressControl('right', 'R');
    viewModel.pressControl('action', 'A');
    viewModel.releaseControl('right');
    viewModel.releaseControl('action');
    viewModel.releaseControl('up');

    expect(transport.sentCommands, ['F', 'R', 'A', 'F', 'S']);

    viewModel.dispose();
  });
}
