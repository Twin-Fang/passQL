import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// SQL 실행 결과 한 줄: 아이콘 + 글자 (성공 ✓ 정답색, 경고 ! 주황, #999)
/// 첫 문제 완료 `1행 수정됨`, 크레딧 소진 `0 rows · 0시에 N개 충전`
class PassqlQueryStatusLine extends StatelessWidget {
  const PassqlQueryStatusLine({
    super.key,
    required this.text,
    this.isWarning = false,
  });

  final String text;

  /// true면 경고(주황 아이콘·글자), false면 성공(정답색)
  final bool isWarning;

  /// 아이콘 <-> 글자 간격 (PassqlResultMark 작은 표시와 같은 값)
  static const double _iconLabelGap = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isWarning
              ? CupertinoIcons.exclamationmark_circle_fill
              : CupertinoIcons.checkmark_circle_fill,
          size: PassqlIconSize.md,
          color: isWarning ? colors.warning : colors.correct,
        ),
        const SizedBox(width: _iconLabelGap),
        Flexible(
          child: Text(
            text,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: isWarning ? colors.warningText : colors.correctText,
            ),
          ),
        ),
      ],
    );
  }
}
