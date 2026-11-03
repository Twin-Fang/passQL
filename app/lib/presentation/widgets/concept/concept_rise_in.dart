import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 처음 한 번 아래에서 올라오며 나타남 (결과 화면의 제목·줄·버튼, 점수판의 제목·버튼)
class ConceptRiseIn extends StatelessWidget {
  const ConceptRiseIn({
    super.key,
    required this.isVisible,
    this.riseFraction = defaultRiseFraction,
    required this.child,
  });

  // 올라오는 거리 (자기 높이 비율): 결과 화면 기본, 점수판은 살짝
  static const double defaultRiseFraction = 0.3;
  static const double subtleRiseFraction = 0.2;

  final bool isVisible;
  final double riseFraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return AnimatedSlide(
      offset: Offset(0, isVisible ? 0 : riseFraction),
      duration: duration,
      curve: PassqlMotion.curve,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: duration,
        child: child,
      ),
    );
  }
}
