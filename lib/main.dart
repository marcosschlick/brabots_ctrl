import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/connection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/bluetooth_viewmodel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BluetoothViewModel()..init(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BRABOTS ctrl',
        theme: AppTheme.theme,
        home: const ConnectionScreen(),
      ),
    );
  }
}
