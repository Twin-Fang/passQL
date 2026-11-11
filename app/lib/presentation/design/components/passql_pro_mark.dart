import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_icon_size.dart';
import '../tokens/passql_spacing.dart';
import '../tokens/passql_typography.dart';

/// PRO 마크: 보라 둥근 사각 + 흰 반짝임 아이콘 (투명 배경, [shouldShowLabel]이면 오른쪽에 `PRO` 글자)
/// 마크 에셋은 이 부품만 부름
class PassqlProMark extends StatelessWidget {
  const PassqlProMark({
    super.key,
    this.size = PassqlIconSize.sm,
    this.shouldShowLabel = false,
    this.isDecorative = false,
  });

  final double size;
  final bool shouldShowLabel;

  /// 옆에 이미 `PRO` 글자가 있어 스크린리더가 읽을 필요 없을 때
  final bool isDecorative;

  /// 마크 에셋 (assets/pro_mark.png)
  static const String _assetPath = 'assets/pro_mark.png';

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      _assetPath,
      width: size,
      height: size,
      // 글자가 옆에 있으면 글자가 읽어 줌
      excludeFromSemantics: shouldShowLabel || isDecorative,
      semanticLabel: 'PRO',
    );
    if (!shouldShowLabel) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: PassqlSpacing.xxs),
        Text(
          'PRO',
          style: PassqlTypography.captionSemibold.copyWith(
            color: context.passqlColors.accentText,
          ),
        ),
      ],
    );
  }
}
