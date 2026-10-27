import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 넘김 페이지 점: 현재 페이지만 강조색 알약으로 늘어난다 (홈 출제 경향 캐러셀·온보딩 공통)
/// 스크린리더는 넘김 목록·버튼이 위치를 읽으므로 점은 읽지 않는다.
class PassqlPageDots extends StatelessWidget {
  const PassqlPageDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  /// 점 크기 (현재 페이지는 가로로 늘린 알약)
  static const double _dotSize = 6;
  static const double _currentDotWidth = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final dotAnimationDuration = PassqlMotion.durationOf(
      context,
      PassqlMotion.fast,
    );
    return ExcludeSemantics(
      // 내용 폭만 차지: 상단 바 가운데 자리에선 화면 가운데에 오고, 폭을 채워 주는 곳(홈 캐러셀)에선 가운데 정렬
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var pageIndex = 0; pageIndex < count; pageIndex++)
            AnimatedContainer(
              duration: dotAnimationDuration,
              curve: PassqlMotion.curve,
              margin: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.hairlineGap,
              ),
              width: pageIndex == currentIndex ? _currentDotWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: pageIndex == currentIndex
                    ? colors.accentText
                    : colors.tertiaryLabel,
                borderRadius: BorderRadius.circular(PassqlRadius.capsule),
              ),
            ),
        ],
      ),
    );
  }
}
