import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_badge.dart';

/// 강조 상자 의미 3종: 강조(핵심·시험 포인트), 주의(자주 틀리는 점), 외울 것(꼭 외울 것 카드, #876)
enum PassqlCalloutKind { accent, warning, memorize }

/// 강조 상자: 옅은 의미색 바탕 + 둥근 모서리 + (선택) 원형 아이콘 > 라벨 > 내용
/// 종류 구분은 아이콘·라벨로 (왼쪽 세로 막대 금지, #1158). 개념 학습·가답안 안내·모의고사 공통 (#835)
class PassqlCallout extends StatelessWidget {
  const PassqlCallout({
    super.key,
    required this.kind,
    required this.child,
    this.icon,
    this.label,
  });

  final PassqlCalloutKind kind;
  final Widget child;
  final IconData? icon;

  /// 내용 위 작은 라벨 (예: '한 줄 핵심', '헷갈리는 점 1')
  final String? label;

  /// 의미 > (원·바탕 색, 라벨 글자색, 원 안 아이콘색)
  static (Color fillTone, Color textTone, Color iconTone) tonesOf(
    PassqlCalloutKind kind,
    PassqlColors colors,
  ) => switch (kind) {
    PassqlCalloutKind.accent => (
      colors.accent,
      colors.accentText,
      colors.onAccent,
    ),
    PassqlCalloutKind.warning => (
      colors.warning,
      colors.warningText,
      colors.onSemantic,
    ),
    PassqlCalloutKind.memorize => (
      colors.memorize,
      colors.memorizeText,
      colors.onSemantic,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (fillTone, textTone, iconTone) = tonesOf(kind, context.passqlColors);
    final iconData = icon;
    final labelText = label;
    // 라벨 > 내용 (아이콘 오른쪽 칸)
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: PassqlTypography.footnoteSemibold.copyWith(color: textTone),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
        ],
        child,
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PassqlSpacing.md),
      decoration: BoxDecoration(
        // 배경 진하기는 배지와 같은 값 (대비 기준 공유)
        color: fillTone.withValues(alpha: PassqlBadge.backgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: iconData == null
          ? body
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 원형 아이콘 (스크린리더는 라벨로 읽어 장식 처리)
                ExcludeSemantics(
                  child: Container(
                    width: PassqlSize.iconTileCompact,
                    height: PassqlSize.iconTileCompact,
                    decoration: BoxDecoration(
                      color: fillTone,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      size: PassqlIconSize.iconTileCompactGlyph,
                      color: iconTone,
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
                Expanded(child: body),
              ],
            ),
    );
  }
}
