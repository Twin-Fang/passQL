import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_markdown_body.dart';
import 'concept_reading_parser.dart';

/// 개념 맨 위 구간 (#835): 읽는 시간 줄 > 한 줄 핵심(요약) > 꼭 기억할 것 번호 카드
/// 핵심 글머리 한 줄 = 카드 하나, 글머리가 아닌 핵심 글은 원문 그대로
class ConceptCoreHeader extends StatelessWidget {
  const ConceptCoreHeader({
    super.key,
    required this.summary,
    required this.coreMd,
    required this.sectionCount,
    required this.readMinutes,
  });

  final String? summary;
  final String coreMd;
  final int sectionCount;
  final int readMinutes;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final summaryText = summary?.trim() ?? '';
    final keyPoints = ConceptReadingParser.parseCoreKeyPoints(coreMd);
    final hasCoreText = coreMd.trim().isNotEmpty;
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '약 $readMinutes분 · 설명 $sectionCount개',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (summaryText.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlCallout(
              kind: PassqlCalloutKind.accent,
              icon: CupertinoIcons.lightbulb_fill,
              label: '한 줄 핵심',
              child: Text(
                summaryText,
                style: PassqlTypography.title3.copyWith(color: colors.label),
              ),
            ),
          ],
          if (hasCoreText) ...[
            const SizedBox(height: PassqlSpacing.xl),
            Semantics(
              header: true,
              child: Text(
                keyPoints.length > 1
                    ? '꼭 기억할 것 ${keyPoints.length}가지'
                    : '꼭 기억할 것',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            if (keyPoints.isEmpty)
              ConceptMarkdownBody(coreMd)
            else
              for (final (index, keyPoint) in keyPoints.indexed) ...[
                if (index > 0) const SizedBox(height: PassqlSpacing.xs),
                _KeyPointCard(order: index + 1, text: keyPoint),
              ],
          ],
        ],
      ),
    );
  }
}

/// 기억할 것 한 장: 보라 번호 원 + 한 문장 (번호와 글을 한 번에 읽힘)
class _KeyPointCard extends StatelessWidget {
  const _KeyPointCard({required this.order, required this.text});

  final int order;
  final String text;

  // 번호 원 최소 지름 (큰 글자에서는 글자에 맞춰 커짐)
  static const double _orderCircleMinDiameter = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.sm,
          PassqlSpacing.sm,
          PassqlSpacing.md,
          PassqlSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 본문 첫 줄 위 여백(xxs)과 맞춤
            Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: _orderCircleMinDiameter,
                  minHeight: _orderCircleMinDiameter,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accentTint,
                  borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                ),
                child: Text(
                  '$order',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: MarkdownLiteText(text, style: MarkdownLiteStyle.article),
            ),
          ],
        ),
      ),
    );
  }
}
