import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/passql_tokens.dart';
import 'passql_semantic_button.dart';

/// 누르는 동안 살짝 흐려지고 작아지는 피드백. 잉크 물결 대신 이 하나로 통일한다.
/// 시맨틱: semanticLabel 있으면 그 문구만 읽음(자식 글자 덮음), 없으면 자식 글자를 합쳐 읽음
class PassqlPressable extends StatefulWidget {
  const PassqlPressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.hasMinimumTouchTarget = false,
    this.isTapExposedToScreenReader = true,
  });
  final Widget child;
  final VoidCallback? onTap;

  /// 자식 글자를 대신할 문구. 자식에 읽어야 할 정보(본문·시각)가 더 있으면 문구에 함께 넣음
  final String? semanticLabel;

  /// true 면 보이는 크기가 작아도 누르는 영역은 최소 44x44 (작은 버튼·칩)
  final bool hasMinimumTouchTarget;

  /// false: 시각 사용자용 탭만 두고 시맨틱 노드를 만들지 않음 (안쪽에 같은 동작 버튼이 있는 카드)
  final bool isTapExposedToScreenReader;

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
    Widget pressFeedback = AnimatedScale(
      scale: _isPressed ? PassqlMotion.pressedScale : 1,
      duration: PassqlMotion.durationOf(context, PassqlMotion.instant),
      curve: PassqlMotion.curve,
      child: AnimatedOpacity(
        opacity: _isPressed ? _pressedOpacity : 1,
        duration: PassqlMotion.durationOf(context, PassqlMotion.instant),
        child: widget.child,
      ),
    );
    // 누르는 영역만 44 로 넓히고 보이는 모양은 가운데 그대로
    if (widget.hasMinimumTouchTarget) {
      pressFeedback = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: PassqlSize.minTouchTarget,
          minHeight: PassqlSize.minTouchTarget,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: pressFeedback),
      );
    }
    final gestureDetector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: !widget.isTapExposedToScreenReader,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: pressFeedback,
    );
    if (!widget.isTapExposedToScreenReader) return gestureDetector;
    final semanticLabel = widget.semanticLabel;
    if (semanticLabel != null) {
      return PassqlSemanticButton(
        label: semanticLabel,
        onTap: widget.onTap,
        child: gestureDetector,
      );
    }
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      child: gestureDetector,
    );
  }
}
