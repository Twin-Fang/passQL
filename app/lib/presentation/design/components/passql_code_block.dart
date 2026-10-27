import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_horizontal_scroll_view.dart';

/// SQL 표시 공통 블록. 기본은 줄바꿈해 전체가 보이게 하고, 정렬이 중요한 곳만
/// `shouldWrap: false`로 가로 스크롤한다(넘치면 오른쪽 끝 흐림). 길게 눌러 복사할 수 있다.
class PassqlCodeBlock extends StatelessWidget {
  const PassqlCodeBlock({
    super.key,
    required this.code,
    this.isSelectable = true,
    this.shouldWrap = true,
    this.hasBackground = true,
  });
  final String code;
  final bool isSelectable;

  /// true면 줄바꿈, false면 가로 스크롤.
  final bool shouldWrap;

  /// false면 배경 상자 없이 코드만 (카드 안에 넣어 상자가 겹치지 않게)
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final style = PassqlTypography.code.copyWith(color: colors.label);
    final codeText = isSelectable
        ? SelectableText(code, style: style)
        : Text(code, style: style);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasBackground ? colors.fill : null,
        borderRadius: BorderRadius.circular(PassqlRadius.sm),
      ),
      child: shouldWrap
          ? Padding(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              child: codeText,
            )
          : PassqlHorizontalScrollView(
              padding: const EdgeInsets.all(PassqlSpacing.sm),
              child: codeText,
            ),
    );
  }
}
