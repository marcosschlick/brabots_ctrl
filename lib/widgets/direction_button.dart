import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DirectionButton extends StatefulWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;

  const DirectionButton({
    super.key,
    this.icon,
    this.child,
    this.onPressed,
    this.onReleased,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton> {
  bool _isPressed = false;
  int? _activePointer;

  void _press(int pointer) {
    if (_activePointer != null) return;

    _activePointer = pointer;
    widget.onPressed?.call();
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _release(int pointer) {
    if (_activePointer != pointer) return;

    _activePointer = null;
    widget.onReleased?.call();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else if (widget.icon != null) {
      content = Icon(widget.icon, size: 30, color: Colors.white);
    } else {
      content = const SizedBox.shrink();
    }

    return Listener(
      onPointerDown: (event) => _press(event.pointer),
      onPointerUp: (event) => _release(event.pointer),
      onPointerCancel: (event) => _release(event.pointer),
      child: AnimatedScale(
        scale: _isPressed ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color.fromARGB(255, 48, 38, 129)
                : const Color.fromARGB(255, 56, 64, 172),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  48,
                  38,
                  129,
                ).withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}
