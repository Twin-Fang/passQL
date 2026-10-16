import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 화면 본문 교체(다음 문제 등): 새 것은 오른쪽에서, 이전 것은 왼쪽으로 페이드 + 미끄러짐
/// child 에 항목마다 다른 key(ValueKey(문제 UUID) 등)를 줘야 교체로 인식한다.
class PassqlPageSlideSwitcher extends StatelessWidget {
  const PassqlPageSlideSwitcher({super.key, required this.child});

  final Widget child;

  // 미끄러지는 거리 (본문 폭 대비 비율)
  static const _slideWidthFraction = 0.12;

  @override
  Widget build(BuildContext context) {
    if (PassqlMotion.isReduced(context)) return child;
    final incomingKey = child.key;
    return AnimatedSwitcher(
      duration: PassqlMotion.standard,
      switchInCurve: PassqlMotion.curve,
      switchOutCurve: PassqlMotion.curve,
      // 두 본문이 겹치는 동안 둘 다 화면 크기를 채움
      layoutBuilder: (currentChild, previousChildren) => Stack(
        fit: StackFit.expand,
        children: [...previousChildren, ?currentChild],
      ),
      // 매 빌드 새 함수라 나가는 쪽도 다시 계산됨 (나가는 쪽 = 왼쪽 방향)
      transitionBuilder: (transitionChild, animation) {
        final isIncoming = transitionChild.key == incomingKey;
        final slideStart = Offset(
          isIncoming ? _slideWidthFraction : -_slideWidthFraction,
          0,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: slideStart,
              end: Offset.zero,
            ).animate(animation),
            child: transitionChild,
          ),
        );
      },
      child: child,
    );
  }
}
