import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  final List<BluetoothDevice> _bondedDevices = [];

  // Getters para acesso externo (quando necessário)
  bool get isConnected => _connection?.isConnected ?? false;
  List<BluetoothDevice> get bondedDevices => _bondedDevices;

  // Solicitar permissões e ativar Bluetooth
  Future<bool> enableBluetooth() async {
    // Permissões
    if (!await _requestPermissions()) return false;

    final state = await FlutterBluetoothSerial.instance.state;
    if (state == BluetoothState.STATE_OFF) {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
      } catch (e) {
        return false;
      }
    }
    return await FlutterBluetoothSerial.instance.state ==
        BluetoothState.STATE_ON;
  }

  Future<bool> _requestPermissions() async {
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    return scanStatus.isGranted && connectStatus.isGranted;
  }

  // Carregar dispositivos pareados
  Future<List<BluetoothDevice>> loadBondedDevices() async {
    _bondedDevices.clear();
    try {
      _bondedDevices.addAll(
        await FlutterBluetoothSerial.instance.getBondedDevices(),
      );
    } catch (e) {
      print('Erro ao carregar dispositivos: $e');
    }
    return _bondedDevices;
  }

  // Conectar a um dispositivo
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_connection?.isConnected == true) await disconnect();

    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      _connection = connection;

      // Listener opcional para dados recebidos (apenas debug)
      connection.input
          ?.listen((Uint8List data) {
            print('Recebido: ${String.fromCharCodes(data)}');
          })
          .onDone(() {
            disconnect(); // limpa estado quando perde conexão
          });

      return true;
    } catch (e) {
      print('Falha na conexão: $e');
      return false;
    }
  }

  // Enviar comando (string) + newline
  Future<bool> sendCommand(String command) async {
    if (!isConnected) return false;
    try {
      // Converte a string para Uint8List
      final List<int> commandBytes = command.codeUnits;
      final Uint8List commandUint8 = Uint8List.fromList(commandBytes);
      _connection!.output.add(commandUint8);

      // Adiciona newline (\n) também como Uint8List
      final Uint8List newline = Uint8List.fromList([10]);
      _connection!.output.add(newline);

      // Aguarda o envio de todos os dados
      await _connection!.output.allSent;
      return true;
    } catch (e) {
      print('Erro ao enviar: $e');
      return false;
    }
  }

  // Desconectar manualmente
  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
  }
}
