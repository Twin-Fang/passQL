import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS 처럼 누르는 동안 살짝 흐려지는 피드백. 잉크 물결 대신 이 하나로 통일한다.
class PassqlPressable extends StatefulWidget {
  const PassqlPressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.button = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool button;

  @override
  State<PassqlPressable> createState() => _PassqlPressableState();
}

class _PassqlPressableState extends State<PassqlPressable> {
  bool _isPressed = false;

  void _setPressed(bool isPressed) {
    // 해제(false)는 onTap 이 사라져도 항상 허용해 흐림이 남지 않게 한다.
    if ((!isPressed || widget.onTap != null) && _isPressed != isPressed) {
      setState(() => _isPressed = isPressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.button,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.55 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}
