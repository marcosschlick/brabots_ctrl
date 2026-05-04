import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../widgets/direction_button.dart';
import '../theme/app_theme.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BluetoothViewModel>();

    // se desconectar, volta para a tela de conexão
    if (!viewModel.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return WillPopScope(
      onWillPop: () async {
        // Ao apertar voltar, desconecta
        await viewModel.disconnect();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎮 Controle do Robô'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bluetooth_disabled),
              onPressed: () async {
                await viewModel.disconnect();
                if (context.mounted) Navigator.pop(context);
              },
              tooltip: 'Desconectar',
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
                  'Conectado a: ${viewModel.connectedDeviceName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                // Botões direcionais (mesmo código de antes)
                Column(
                  children: [
                    DirectionButton(
                      icon: Icons.arrow_upward,
                      onPressed: () => viewModel.sendCommand('F'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DirectionButton(
                          icon: Icons.arrow_back,
                          onPressed: () => viewModel.sendCommand('L'),
                        ),
                        const SizedBox(width: 20),
                        DirectionButton(
                          icon: Icons.arrow_forward,
                          onPressed: () => viewModel.sendCommand('R'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DirectionButton(
                      icon: Icons.arrow_downward,
                      onPressed: () => viewModel.sendCommand('B'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
