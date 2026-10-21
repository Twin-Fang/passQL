import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

class PassqlProgressBar extends StatelessWidget {
  const PassqlProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      // 폭 고정: 가운데 정렬 Column 안에서도 트랙이 전체 폭, 채움은 왼쪽부터 (#552)
      child: SizedBox(
        width: double.infinity,
        height: PassqlSize.progressBarHeight,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: colors.fill)),
            AnimatedFractionallySizedBox(
              duration: PassqlMotion.fast,
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
  }
}
