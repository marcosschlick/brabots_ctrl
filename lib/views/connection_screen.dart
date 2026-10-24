import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/control_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  Widget _buildStatusCard(BuildContext context, BluetoothViewModel viewModel) {
    final isConnecting = viewModel.isConnecting;
    final hasError = viewModel.errorMessage.isNotEmpty;
    final isBluetoothOn = viewModel.isBluetoothOn;
    final color = hasError
        ? const Color(0xFFB42318)
        : isBluetoothOn || isConnecting
        ? AppTheme.brandGreen
        : AppTheme.secondaryText;
    final icon = isConnecting
        ? Icons.bluetooth_searching
        : hasError
        ? Icons.error_outline
        : isBluetoothOn
        ? Icons.bluetooth_connected
        : Icons.bluetooth_disabled;
    final text = isConnecting
        ? 'Conectando…'
        : hasError
        ? viewModel.errorMessage
        : isBluetoothOn
        ? 'Bluetooth ligado'
        : 'Bluetooth desligado';

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      reverseDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.deviceDividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection(
    BuildContext context,
    BluetoothViewModel viewModel, {
    required bool isWide,
  }) {
    final logoSize = isWide ? 92.0 : 104.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Controle Arduino',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _buildStatusCard(context, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, BluetoothViewModel viewModel) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: AppTheme.deviceCardDecoration,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dispositivos pareados',
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Selecione o módulo Bluetooth do robô',
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 14),
          if (viewModel.devices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              decoration: BoxDecoration(
                color: AppTheme.surfaceTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    color: AppTheme.brandBlue,
                    size: 28,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nenhum dispositivo pareado',
                    style: TextStyle(
                      color: AppTheme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pareie o HC-05 ou HC-06 nas configurações Bluetooth do Android.',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.devices.length,
              separatorBuilder: (_, _) => const Divider(
                color: AppTheme.deviceDividerColor,
                height: 1,
                indent: 12,
                endIndent: 12,
              ),
              itemBuilder: (context, index) {
                final device = viewModel.devices[index];
                final isSelected =
                    device.address == viewModel.selectedDeviceAddress;
                final isConnecting = viewModel.isConnecting && isSelected;

                return AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE9F2FC)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.brandBlue.withValues(alpha: 0.28)
                          : Colors.transparent,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.brandBlue
                              : AppTheme.surfaceTint,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.bluetooth,
                          color: isSelected ? Colors.white : AppTheme.brandBlue,
                          size: 21,
                        ),
                      ),
                      title: Text(
                        device.name ?? 'Sem nome',
                        style: const TextStyle(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        device.address,
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isConnecting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              color: AppTheme.secondaryText,
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: viewModel.isConnected || viewModel.isConnecting
                          ? null
                          : () async {
                              final connected = await viewModel.connectToDevice(
                                device,
                              );
                              if (connected && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ControlScreen(),
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BluetoothViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('BRABOTS ctrl'),
        actions: [
          IconButton(
            tooltip: 'Atualizar dispositivos',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BluetoothViewModel>().refresh(),
          ),
          PopupMenuButton<String>(
            tooltip: 'Mais opções',
            onSelected: (value) {
              if (value == 'demo') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ControlScreen(isDemo: true),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'demo',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Visualizar controles'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final brandSection = _buildBrandSection(
              context,
              viewModel,
              isWide: isWide,
            );
            final deviceCard = _buildDeviceCard(context, viewModel);

            if (!isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    brandSection,
                    const SizedBox(height: 22),
                    deviceCard,
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
                      padding: const EdgeInsets.all(18),
                      child: brandSection,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  color: AppTheme.deviceDividerColor,
                  indent: 24,
                  endIndent: 24,
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
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
