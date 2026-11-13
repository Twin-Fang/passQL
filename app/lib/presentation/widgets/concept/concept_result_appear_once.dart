import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 처음 한 번 아래에서 올라오며 나타남 (결과 제목·줄·버튼, 점수판 제목·버튼)
class ConceptResultAppearOnce extends StatelessWidget {
  const ConceptResultAppearOnce({
    super.key,
    required this.isVisible,
    required this.child,
    this.riseFraction = defaultRiseFraction,
  });

  // 올라오는 거리 기본값 (자기 높이 비율)
  static const double defaultRiseFraction = 0.3;

  final bool isVisible;
  final Widget child;

  /// 올라오는 거리 (자기 높이 비율)
  final double riseFraction;

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
