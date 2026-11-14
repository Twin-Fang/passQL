import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 진행 막대 (0~1). 옆에 숫자가 없는 자리만 [semanticValue] 로 값을 읽게 함
class PassqlProgressBar extends StatelessWidget {
  const PassqlProgressBar({
    super.key,
    required this.value,
    this.semanticValue,
    this.fillColor,
    this.height = PassqlSize.progressBarHeight,
    this.isFillAnimated = true,
  });
  final double value;

  /// 막대 두께 (홈 준비도 지표처럼 크게 보일 자리만 키움)
  final double height;

  /// false: 값 변화를 그대로 그림 (쓰는 쪽이 차오름을 직접 맞출 때, 홈 준비도 링과 함께 #972)
  final bool isFillAnimated;

  /// 채움 색 (null 이면 강조색). 의미가 다른 막대(과락 위험 등)만 의미 색을 넘김
  final Color? fillColor;

  /// 스크린리더가 읽을 값 (예: '3/10'). null 이면 막대는 읽지 않음(옆 숫자가 대신 전달)
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      // 폭 고정: 가운데 정렬 Column 안에서도 트랙이 전체 폭, 채움은 왼쪽부터 (#552)
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.fill)),
            AnimatedFractionallySizedBox(
              duration: isFillAnimated
                  ? PassqlMotion.durationOf(context, PassqlMotion.fast)
                  : Duration.zero,
              curve: PassqlMotion.curve,
              widthFactor: value.clamp(0, 1),
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: fillColor ?? colors.accent),
            ),
          ],
        ),
      ),
    );
    final semanticValueText = semanticValue;
    if (semanticValueText == null) return ExcludeSemantics(child: bar);
    return Semantics(
      value: semanticValueText,
      child: ExcludeSemantics(child: bar),
    );
  }
}
