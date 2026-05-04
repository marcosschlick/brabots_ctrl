import 'package:ctrl/theme/app_theme.dart';
import 'package:ctrl/views/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control Brabots',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
