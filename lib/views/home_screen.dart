import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../widgets/direction_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothViewModel()..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎮 BRABOTS ctrl 🕹️'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            Consumer<BluetoothViewModel>(
              builder: (ctx, vm, _) {
                if (vm.isConnected) {
                  return IconButton(
                    icon: const Icon(Icons.bluetooth_disabled),
                    onPressed: vm.disconnect,
                    tooltip: 'Desconectar',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<BluetoothViewModel>().loadDevices(),
            ),
          ],
        ),
        body: Consumer<BluetoothViewModel>(
          builder: (ctx, vm, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 200),
                  const SizedBox(height: 20),

                  // Status do Bluetooth
                  Text(
                    vm.isBluetoothOn
                        ? '✅ Bluetooth ligado'
                        : '❌ Bluetooth desligado',
                    style: TextStyle(
                      color: vm.isBluetoothOn ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (vm.isConnected)
                    Text(
                      'Conectado a: ${vm.connectedDeviceName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (vm.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        vm.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Botões de direção (só habilitados se conectado)
                  Column(
                    children: [
                      DirectionButton(
                        icon: Icons.arrow_upward,
                        onPressed: vm.isConnected
                            ? () => vm.sendCommand('F')
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DirectionButton(
                            icon: Icons.arrow_back,
                            onPressed: vm.isConnected
                                ? () => vm.sendCommand('L')
                                : null,
                          ),
                          const SizedBox(width: 20),
                          DirectionButton(
                            icon: Icons.arrow_forward,
                            onPressed: vm.isConnected
                                ? () => vm.sendCommand('R')
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DirectionButton(
                        icon: Icons.arrow_downward,
                        onPressed: vm.isConnected
                            ? () => vm.sendCommand('B')
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Dispositivos pareados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: vm.devices.isEmpty
                        ? const Center(
                            child: Text('Nenhum dispositivo pareado'),
                          )
                        : ListView.builder(
                            itemCount: vm.devices.length,
                            itemBuilder: (_, i) {
                              final device = vm.devices[i];
                              return ListTile(
                                leading: const Icon(Icons.bluetooth),
                                title: Text(device.name ?? 'Sem nome'),
                                subtitle: Text(device.address),
                                onTap: vm.isConnected
                                    ? null
                                    : () => vm.connectToDevice(device),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
