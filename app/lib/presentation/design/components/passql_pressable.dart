import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/passql_tokens.dart';

/// 누르는 동안 살짝 흐려지고 작아지는 피드백. 잉크 물결 대신 이 하나로 통일한다.
class PassqlPressable extends StatefulWidget {
  const PassqlPressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.isButton = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool isButton;

  @override
  State<PassqlPressable> createState() => _PassqlPressableState();
}

class _PassqlPressableState extends State<PassqlPressable> {
  /// 누르는 동안 불투명도
  static const double _pressedOpacity = 0.7;

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
      button: widget.isButton,
      enabled: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? PassqlMotion.pressedScale : 1,
          duration: PassqlMotion.instant,
          curve: PassqlMotion.curve,
          child: AnimatedOpacity(
            opacity: _isPressed ? _pressedOpacity : 1,
            duration: PassqlMotion.instant,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
