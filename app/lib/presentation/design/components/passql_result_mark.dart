import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 정답/오답 표시 한 벌. 아이콘 모양과 색을 화면마다 다르게 고르지 않게 한다.
class PassqlResultMark extends StatelessWidget {
  const PassqlResultMark({
    super.key,
    required this.isCorrect,
    this.label,
    this.isLarge = false,
  });
  final bool isCorrect;
  final String? label;
  final bool isLarge;

  /// 작은 표시의 아이콘 <-> 글자 간격
  static const double _iconLabelGap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final icon = isCorrect
        ? CupertinoIcons.checkmark_circle_fill
        : CupertinoIcons.xmark_circle_fill;
    final iconColor = isCorrect ? colors.correct : colors.wrong;
    final textColor = isCorrect ? colors.correctText : colors.wrongText;
    final text = label ?? (isCorrect ? '정답' : '오답');
    if (isLarge) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: PassqlIconSize.resultMarkLarge, color: iconColor),
          const SizedBox(height: PassqlSpacing.sm),
          Text(
            text,
            style: PassqlTypography.title2.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: PassqlIconSize.md, color: iconColor),
        const SizedBox(width: _iconLabelGap),
        Flexible(
          child: Text(
            text,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
