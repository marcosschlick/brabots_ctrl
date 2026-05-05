import 'package:flutter/material.dart';

class DirectionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;

  const DirectionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.onReleased,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        widget.onPressed?.call();
        setState(() => _isPressed = true);
      },
      onPointerUp: (_) {
        widget.onReleased?.call();
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(widget.icon, size: 30),
        ),
      ),
    );
  }
}
