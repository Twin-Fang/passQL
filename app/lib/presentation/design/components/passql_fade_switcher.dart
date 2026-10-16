import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 로딩 > 내용 같은 상태 교체를 부드럽게: 이전 것은 사라지고 새 것은 페이드 + 살짝 위로
/// 상태마다 child 에 다른 key(ValueKey('loading') 등)를 줘야 교체로 인식한다.
class PassqlFadeSwitcher extends StatelessWidget {
  const PassqlFadeSwitcher({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (PassqlMotion.isReduced(context)) return child;
    return AnimatedSwitcher(
      duration: PassqlMotion.standard,
      switchInCurve: PassqlMotion.curve,
      switchOutCurve: PassqlMotion.curve,
      // 높이가 다른 두 상태가 겹칠 때 위쪽 기준으로 맞춘다
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
