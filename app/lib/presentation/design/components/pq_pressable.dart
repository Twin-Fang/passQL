import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// iOS 처럼 누르는 동안 살짝 흐려지는 피드백. 잉크 물결 대신 이 하나로 통일한다.
class PqPressable extends StatefulWidget {
  const PqPressable({super.key, required this.child, this.onTap, this.semanticLabel, this.button = true});
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool button;

  @override
  State<PqPressable> createState() => _PqPressableState();
}

class _PqPressableState extends State<PqPressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null && _down != v) setState(() => _down = v);
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
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        child: AnimatedOpacity(
          opacity: _down ? 0.55 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}
