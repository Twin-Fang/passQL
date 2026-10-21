import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 진행 막대 (0~1). 옆에 숫자가 없는 자리만 [semanticValue] 로 값을 읽게 함
class PassqlProgressBar extends StatelessWidget {
  const PassqlProgressBar({super.key, required this.value, this.semanticValue});
  final double value;

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
        height: PassqlSize.progressBarHeight,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.fill)),
            AnimatedFractionallySizedBox(
              duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
              curve: PassqlMotion.curve,
              widthFactor: value.clamp(0, 1),
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: colors.accent),
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
