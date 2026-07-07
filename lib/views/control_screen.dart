import 'dart:async';

import 'package:ctrl/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/bluetooth_viewmodel.dart';
import '../widgets/direction_button.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  static const double _buttonSize = 70.0;
  static const double _gapV = 1.0;
  static const double _gapH = _gapV * 50.0;

  static void _lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void initState() {
    super.initState();

    _lockLandscape();
    WidgetsBinding.instance.addPostFrameCallback((_) => _lockLandscape());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lockLandscape();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    final vm = context.read<BluetoothViewModel>();
    if (vm.isConnected) {
      unawaited(vm.disconnect());
    }
    super.dispose();
  }

  Widget _cross({
    required Widget top,
    required Widget left,
    required Widget right,
    required Widget bottom,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        top,
        SizedBox(height: _gapV),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            left,
            SizedBox(width: _gapH),
            right,
          ],
        ),
        SizedBox(height: _gapV),
        bottom,
      ],
    );
  }

  Widget _card(Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.deviceCardGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deviceCardGreen.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _arrowBtn(IconData icon, String cmd, BluetoothViewModel vm) {
    return SizedBox(
      width: _buttonSize,
      height: _buttonSize,
      child: DirectionButton(
        icon: icon,
        onPressed: () => vm.sendCommand(cmd),
        onReleased: () => vm.sendCommand('S'),
      ),
    );
  }

  Widget _faceBtn(String label, String cmd, BluetoothViewModel vm) {
    return DirectionButton(
      onPressed: () => vm.sendCommand(cmd),
      onReleased: () => vm.sendCommand('S'),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _leftCard(BluetoothViewModel vm) => _card(
    _cross(
      top: _arrowBtn(Icons.arrow_upward, 'F', vm),
      left: _arrowBtn(Icons.arrow_back, 'L', vm),
      right: _arrowBtn(Icons.arrow_forward, 'R', vm),
      bottom: _arrowBtn(Icons.arrow_downward, 'B', vm),
    ),
  );

  Widget _rightCard(BluetoothViewModel vm) => _card(
    _cross(
      top: _faceBtn('X', 'X', vm),
      left: _faceBtn('Y', 'Y', vm),
      right: _faceBtn('A', 'A', vm),
      bottom: _faceBtn('B', 'C', vm),
    ),
  );

  Widget _logo(BluetoothViewModel vm) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('assets/images/logo.png', height: 250),
      const SizedBox(height: 10),
      Text(
        'Conectado a:\n${vm.connectedDeviceName}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BluetoothViewModel>();

    if (!vm.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: const Text('🎮 BRABOTS ctrl 🕹️')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _leftCard(vm),
                Flexible(child: Center(child: _logo(vm))),
                _rightCard(vm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
