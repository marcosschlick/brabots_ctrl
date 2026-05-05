import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../widgets/direction_button.dart';
import '../theme/app_theme.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<BluetoothViewModel>().addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    final viewModel = context.read<BluetoothViewModel>();
    if (!viewModel.isConnected && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    context.read<BluetoothViewModel>().removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BluetoothViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 BRABOTS ctrl 🕹️'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: () async {
              await viewModel.disconnect();
              if (context.mounted) Navigator.of(context).pop();
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
              Column(
                children: [
                  DirectionButton(
                    icon: Icons.arrow_upward,
                    onPressed: () => viewModel.sendCommand('F'),
                    onReleased: () => viewModel.sendCommand('S'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DirectionButton(
                        icon: Icons.arrow_back,
                        onPressed: () => viewModel.sendCommand('L'),
                        onReleased: () => viewModel.sendCommand('S'),
                      ),
                      const SizedBox(width: 20),
                      DirectionButton(
                        icon: Icons.arrow_forward,
                        onPressed: () => viewModel.sendCommand('R'),
                        onReleased: () => viewModel.sendCommand('S'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DirectionButton(
                    icon: Icons.arrow_downward,
                    onPressed: () => viewModel.sendCommand('B'),
                    onReleased: () => viewModel.sendCommand('S'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
