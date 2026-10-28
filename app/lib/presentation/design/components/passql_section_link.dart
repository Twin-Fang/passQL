import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_semantic_button.dart';

/// 구간 제목 줄 오른쪽 링크: 글자 + › (전체·순위·더 보기 같은 이동), 누르는 영역 44
class PassqlSectionLink extends StatelessWidget {
  const PassqlSectionLink({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;

  /// 스크린리더 문구 ('전체' 대신 '이번 시험 출제 경향 전체 보기')
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlSemanticButton(
      label: semanticLabel,
      onTap: onTap,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(PassqlSize.minTouchTarget),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.md,
              color: colors.accentText,
            ),
          ],
        ),
      ),
    );
  }
}
