import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  Widget _buildStatusCard(BluetoothViewModel viewModel) {
    final isBluetoothOn = viewModel.isBluetoothOn;
    final hasError = viewModel.errorMessage.isNotEmpty;

    Color backgroundColor;
    IconData leadingIcon;
    String statusText;

    if (hasError) {
      backgroundColor = Colors.red.shade700;
      leadingIcon = Icons.error_outline;
      statusText = viewModel.errorMessage;
    } else if (isBluetoothOn) {
      backgroundColor = AppTheme.deviceCardGreen;
      leadingIcon = Icons.bluetooth_connected;
      statusText = 'Bluetooth ligado';
    } else {
      backgroundColor = Colors.grey.shade800;
      leadingIcon = Icons.bluetooth_disabled;
      statusText = 'Bluetooth desligado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                _buildStatusCard(viewModel),
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
                      fontSize: 20,
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
                            final isSelected =
                                device.address ==
                                viewModel.selectedDeviceAddress;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color.fromARGB(255, 48, 38, 129)
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: ListTile(
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
                                tileColor: isSelected
                                    ? Colors.yellow.withOpacity(0.2)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
                              ),
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
