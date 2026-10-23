import 'dart:async';
import 'dart:math' as math;

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
  BluetoothViewModel? _viewModel;

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
    _viewModel ??= context.read<BluetoothViewModel>();
    _lockLandscape();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    final viewModel = _viewModel;
    if (viewModel?.isConnected ?? false) {
      unawaited(viewModel!.disconnect());
    }
    super.dispose();
  }

  Widget _cross({
    required double horizontalGap,
    required double verticalGap,
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
        SizedBox(height: verticalGap),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            left,
            SizedBox(width: horizontalGap),
            right,
          ],
        ),
        SizedBox(height: verticalGap),
        bottom,
      ],
    );
  }

  Widget _card(Widget content, double buttonSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: buttonSize * 0.22,
        vertical: buttonSize * 0.19,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EAF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D18324D),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _arrowBtn(
    IconData icon,
    String controlId,
    String command,
    BluetoothViewModel vm,
    double size,
  ) {
    return DirectionButton(
      size: size,
      icon: icon,
      onPressed: () => vm.pressControl(controlId, command),
      onReleased: () => vm.releaseControl(controlId),
    );
  }

  Widget _faceBtn(
    String label,
    String command,
    BluetoothViewModel vm,
    double size,
  ) {
    return DirectionButton(
      size: size,
      onPressed: () => vm.pressControl(label, command),
      onReleased: () => vm.releaseControl(label),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.31,
        ),
      ),
    );
  }

  Widget _leftCard(
    BluetoothViewModel vm,
    double buttonSize,
    double horizontalGap,
    double verticalGap,
  ) => _card(
    _cross(
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      top: _arrowBtn(Icons.arrow_upward_rounded, 'up', 'F', vm, buttonSize),
      left: _arrowBtn(Icons.arrow_back_rounded, 'left', 'L', vm, buttonSize),
      right: _arrowBtn(
        Icons.arrow_forward_rounded,
        'right',
        'R',
        vm,
        buttonSize,
      ),
      bottom: _arrowBtn(
        Icons.arrow_downward_rounded,
        'down',
        'B',
        vm,
        buttonSize,
      ),
    ),
    buttonSize,
  );

  Widget _rightCard(
    BluetoothViewModel vm,
    double buttonSize,
    double horizontalGap,
    double verticalGap,
  ) => _card(
    _cross(
      horizontalGap: horizontalGap,
      verticalGap: verticalGap,
      top: _faceBtn('X', 'X', vm, buttonSize),
      left: _faceBtn('Y', 'Y', vm, buttonSize),
      right: _faceBtn('A', 'A', vm, buttonSize),
      bottom: _faceBtn('B', 'C', vm, buttonSize),
    ),
    buttonSize,
  );

  Widget _logo(BluetoothViewModel vm, double size) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
      const SizedBox(height: 8),
      Text(
        vm.connectedDeviceName ?? 'Conectado',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppTheme.secondaryText,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
      appBar: AppBar(
        title: const Text('BRABOTS ctrl'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, color: AppTheme.brandGreen, size: 9),
                const SizedBox(width: 7),
                SizedBox(
                  width: 132,
                  child: Text(
                    vm.connectedDeviceName ?? 'Conectado',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final widthLimit = (constraints.maxWidth - 188) / 7;
            final heightLimit = (constraints.maxHeight - 48) / 3.6;
            final buttonSize = math
                .min(80.0, math.min(widthLimit, heightLimit))
                .clamp(46.0, 80.0)
                .toDouble();
            final horizontalGap = buttonSize * 0.48;
            final verticalGap = buttonSize * 0.11;
            final logoSize = math.min(110.0, buttonSize * 1.7);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _leftCard(vm, buttonSize, horizontalGap, verticalGap),
                  Flexible(child: Center(child: _logo(vm, logoSize))),
                  _rightCard(vm, buttonSize, horizontalGap, verticalGap),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
