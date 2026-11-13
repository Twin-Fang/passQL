import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_reading_parser.dart';

/// 개념 맨 위 구간 (#848): 읽는 시간 줄 > 한 줄 핵심(큰 글씨) > 이번에 배울 것 목차 칩 (누르면 그 문단으로)
/// 꼭 기억할 것(coreMd)은 맨 끝 한 장 요약(ConceptLessonRecap)으로
class ConceptCoreHeader extends StatelessWidget {
  const ConceptCoreHeader({
    super.key,
    required this.summary,
    required this.sections,
    required this.readMinutes,
    required this.onSectionPressed,
  });

  final String? summary;
  final List<ConceptDetailSection> sections;
  final int readMinutes;

  /// 목차 한 줄을 눌렀을 때 (문단 앵커)
  final ValueChanged<String> onSectionPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final summaryText = summary?.trim() ?? '';
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlReveal(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.time,
                  size: PassqlIconSize.sm,
                  color: colors.iconSecondary,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '약 $readMinutes분 | ${sections.length}개 구간',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (summaryText.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlReveal(
              index: 1,
              child: Semantics(
                header: true,
                child: Text(
                  summaryText,
                  style: PassqlTypography.title1.copyWith(color: colors.label),
                ),
              ),
            ),
          ],
          if (sections.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.lg),
            PassqlReveal(
              index: 2,
              child: Text(
                '이번에 배울 것',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            // 목차 칩 (한 화면을 다 차지하지 않게 줄바꿈 칩으로)
            Wrap(
              spacing: PassqlSpacing.xs,
              runSpacing: PassqlSpacing.xs,
              children: [
                for (final (index, section) in sections.indexed)
                  PassqlReveal(
                    index: index + 3,
                    child: _TableOfContentsChip(
                      order: index + 1,
                      title: ConceptReadingParser.splitTitle(
                        section.title,
                      ).title,
                      onPressed: () => onSectionPressed(section.anchor),
                      isMemorizeSection:
                          section.anchor == ConceptReadingParser.memorizeAnchor,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 목차 칩: 두 자리 번호 + 제목 (누르면 그 문단으로 스크롤)
/// 꼭 외울 것 문단은 형광펜 바탕 + 책갈피 (시험 직전 바로 찾게, #876)
class _TableOfContentsChip extends StatelessWidget {
  const _TableOfContentsChip({
    required this.order,
    required this.title,
    required this.onPressed,
    required this.isMemorizeSection,
  });

  final int order;
  final String title;
  final VoidCallback onPressed;
  final bool isMemorizeSection;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: '$order. $title 로 이동',
      hasMinimumTouchTarget: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isMemorizeSection
              ? colors.memorizeHighlight
              : colors.background,
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        child: Text.rich(
          TextSpan(
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
            children: [
              if (isMemorizeSection)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: PassqlSpacing.xxs),
                    child: Icon(
                      CupertinoIcons.bookmark_fill,
                      size: PassqlIconSize.sm,
                      color: colors.label,
                    ),
                  ),
                ),
              TextSpan(
                text: '${order.toString().padLeft(2, '0')}  ',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  // 형광펜 바탕 위는 label (강조색 글자는 노랑 위 대비 부족)
                  color: isMemorizeSection ? colors.label : colors.accentText,
                ),
              ),
              TextSpan(text: title),
            ],
          ),
        ),
      ),
    );
  }
}
