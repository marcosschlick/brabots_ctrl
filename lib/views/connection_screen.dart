import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BluetoothViewModel>();

    if (viewModel.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ControlScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('🎮 BRABOTS ctrl 🕹️'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BluetoothViewModel>().loadDevices(),
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            Widget logoSection = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: isLandscape ? 200 : 250,
                ),
                const SizedBox(height: 12),
                Text(
                  viewModel.isBluetoothOn
                      ? 'Bluetooth: ligado ✔'
                      : 'Bluetooth: desligado ✘',
                  style: TextStyle(
                    color: viewModel.isBluetoothOn
                        ? const Color(0xFF1565C0)
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (viewModel.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    viewModel.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            );

            Widget deviceCard = Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 560),
              decoration: AppTheme.deviceCardDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Dispositivos pareados:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  viewModel.devices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum dispositivo pareado',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.devices.length,
                          separatorBuilder: (_, __) => Divider(
                            color: AppTheme.deviceDividerColor,
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (_, i) {
                            final device = viewModel.devices[i];
                            return ListTile(
                              leading: const Icon(
                                Icons.bluetooth,
                                color: Colors.white,
                              ),
                              title: Text(
                                device.name ?? 'Sem nome',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                device.address,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              onTap: viewModel.isConnected
                                  ? null
                                  : () async {
                                      await viewModel.connectToDevice(device);
                                      if (viewModel.isConnected &&
                                          context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ControlScreen(),
                                          ),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                ],
              ),
            );

            if (!isLandscape) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    logoSection,
                    const SizedBox(height: 24),
                    deviceCard,
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: logoSection,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  color: Colors.black12,
                  indent: 24,
                  endIndent: 24,
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: deviceCard,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
