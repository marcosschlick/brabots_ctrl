import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DirectionButton extends StatefulWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onReleased;
  final double size;

  const DirectionButton({
    super.key,
    this.icon,
    this.child,
    this.onPressed,
    this.onReleased,
    this.size = 70,
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
      content = Icon(
        widget.icon,
        size: widget.size * 0.42,
        color: Colors.white,
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Listener(
      onPointerDown: (event) => _press(event.pointer),
      onPointerUp: (event) => _release(event.pointer),
      onPointerCancel: (event) => _release(event.pointer),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed ? AppTheme.brandGreen : AppTheme.brandBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: _isPressed ? 0.72 : 0.16),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26123F78),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
