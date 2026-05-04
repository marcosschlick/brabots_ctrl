import 'package:flutter/material.dart';

class DirectionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const DirectionButton({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Icon(icon, size: 30),
    );
  }
}
