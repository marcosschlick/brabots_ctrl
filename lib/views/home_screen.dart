import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BluetoothViewModel>();

    // se já está conectado, pula para a tela de controle
    if (viewModel.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ControlScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Controle do Robô'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BluetoothViewModel>().loadDevices(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 150),
              const SizedBox(height: 20),
              Text(
                viewModel.isBluetoothOn
                    ? '✅ Bluetooth ligado'
                    : '❌ Bluetooth desligado',
                style: TextStyle(
                  color: viewModel.isBluetoothOn ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              if (viewModel.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    viewModel.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Dispositivos pareados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: viewModel.devices.isEmpty
                    ? const Center(child: Text('Nenhum dispositivo pareado'))
                    : ListView.builder(
                        itemCount: viewModel.devices.length,
                        itemBuilder: (_, i) {
                          final device = viewModel.devices[i];
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            title: Text(device.name ?? 'Sem nome'),
                            subtitle: Text(device.address),
                            onTap: viewModel.isConnected
                                ? null
                                : () async {
                                    await viewModel.connectToDevice(device);
                                    if (viewModel.isConnected) {
                                      if (context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ControlScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
