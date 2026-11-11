import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_icon_size.dart';
import '../tokens/passql_spacing.dart';
import '../tokens/passql_typography.dart';

/// PRO 마크: 보라 둥근 사각 + 흰 반짝임 아이콘 (투명 배경, [withLabel]이면 오른쪽에 `PRO` 글자)
/// 마크 에셋은 이 부품만 부름
class PassqlProMark extends StatelessWidget {
  const PassqlProMark({
    super.key,
    this.size = PassqlIconSize.sm,
    this.withLabel = false,
  });

  final double size;
  final bool withLabel;

  /// 마크 에셋 (assets/pro_mark.png)
  static const String _assetPath = 'assets/pro_mark.png';

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      _assetPath,
      width: size,
      height: size,
      // 글자가 옆에 있으면 글자가 읽어 주므로 마크는 읽지 않음
      excludeFromSemantics: withLabel,
      semanticLabel: 'PRO',
    );
    if (!withLabel) return mark;
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
