import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_badge.dart';

/// 강조 상자 의미 3종: 강조(핵심·시험 포인트), 주의(자주 틀리는 점), 외울 것(꼭 외울 것 카드, #876)
enum PassqlCalloutKind { accent, warning, memorize }

/// 강조 상자: 옅은 의미색 바탕 + 왼쪽 의미색 막대 + (선택) 아이콘·라벨 한 줄 + 내용
/// 개념 학습 한 줄 핵심·자주 틀리는 점·시험 포인트 공통 (#835)
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

  // 왼쪽 막대 두께 (색만으로 구분하지 않게 아이콘·라벨과 함께 씀)
  static const double _accentBarWidth = 4;

  /// 의미 > (채움·막대 색, 라벨 글자·아이콘 색)
  static (Color fillTone, Color textTone) tonesOf(
    PassqlCalloutKind kind,
    PassqlColors colors,
  ) => switch (kind) {
    PassqlCalloutKind.accent => (colors.accent, colors.accentText),
    PassqlCalloutKind.warning => (colors.warning, colors.warningText),
    PassqlCalloutKind.memorize => (colors.memorize, colors.memorizeText),
  };

  @override
  Widget build(BuildContext context) {
    final (fillTone, textTone) = tonesOf(kind, context.passqlColors);
    final labelText = label;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PassqlRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.sm,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        decoration: BoxDecoration(
          // 배경 진하기는 배지와 같은 값 (대비 기준 공유)
          color: fillTone.withValues(alpha: PassqlBadge.backgroundAlpha),
          border: Border(
            left: BorderSide(color: fillTone, width: _accentBarWidth),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (labelText != null || icon != null) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: PassqlIconSize.sm, color: textTone),
                    const SizedBox(width: PassqlSpacing.xxs),
                  ],
                  if (labelText != null)
                    Flexible(
                      child: Text(
                        labelText,
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: textTone,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: PassqlSpacing.xs),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
