import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_markdown_body.dart';
import 'concept_pitfall_card.dart';
import 'concept_reading_parser.dart';

/// 자세히 문단 한 구간 (#835): 종류별 머리(아이콘·라벨) + 본문
/// 자주 헷갈리는 점 > 함정 카드들, 시험 포인트 > 강조 상자, 그 외 > 글 (접힘이면 미리보기 + 이어서 읽기)
class ConceptSectionCard extends StatelessWidget {
  const ConceptSectionCard({
    super.key,
    required this.order,
    required this.section,
    required this.isCollapsed,
    required this.onExpandPressed,
  });

  final int order;
  final ConceptDetailSection section;

  /// true: 미리보기 + 이어서 읽기 버튼만 (긴 일반 문단)
  final bool isCollapsed;
  final VoidCallback onExpandPressed;

  @override
  Widget build(BuildContext context) {
    final kind = ConceptReadingParser.kindOf(section.anchor);
    return PassqlSection(
      child: switch (kind) {
        ConceptSectionKind.examPoint => _ExamPointBody(
          order: order,
          section: section,
        ),
        ConceptSectionKind.confusing => _ConfusingBody(
          order: order,
          section: section,
        ),
        _ => _GeneralBody(
          order: order,
          section: section,
          kind: kind,
          isCollapsed: isCollapsed,
          onExpandPressed: onExpandPressed,
        ),
      },
    );
  }
}

/// 문단 머리: (선택) 종류 아이콘·라벨 한 줄 > 보라 번호 + 제목 (번호는 풀이 화면 '다시 읽기' 라벨과 같음)
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.order,
    required this.title,
    this.icon,
    this.label,
    this.labelColor,
  });

  final int order;
  final String title;
  final IconData? icon;
  final String? label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final labelText = label;
    final labelTone = labelColor ?? colors.accentText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null) ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: PassqlIconSize.sm, color: labelTone),
                const SizedBox(width: PassqlSpacing.xxs),
              ],
              Flexible(
                child: Text(
                  labelText,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: labelTone,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xxs),
        ],
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: PassqlTypography.title3.copyWith(color: colors.label),
              children: [
                TextSpan(
                  text: '$order  ',
                  style: TextStyle(color: colors.accentText),
                ),
                TextSpan(text: title),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 일반·왜·정의 문단: 머리 > 본문, 접힘이면 첫 글 문단 미리보기 + 이어서 읽기
class _GeneralBody extends StatelessWidget {
  const _GeneralBody({
    required this.order,
    required this.section,
    required this.kind,
    required this.isCollapsed,
    required this.onExpandPressed,
  });

  final int order;
  final ConceptDetailSection section;
  final ConceptSectionKind kind;
  final bool isCollapsed;
  final VoidCallback onExpandPressed;

  // 접힌 미리보기 최대 줄 수
  static const int _previewMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (icon, label) = switch (kind) {
      ConceptSectionKind.why => (CupertinoIcons.question_circle_fill, '왜 필요한가'),
      ConceptSectionKind.definition => (CupertinoIcons.book_fill, '정의'),
      _ => (null, null),
    };
    final previewText = ConceptReadingParser.previewTextOf(section.bodyMd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          order: order,
          title: section.title,
          icon: icon,
          label: label,
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 펼칠 때 높이가 부드럽게 늘어남 (동작 줄이기면 즉시)
        AnimatedSize(
          duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
          curve: PassqlMotion.curve,
          alignment: Alignment.topCenter,
          child: isCollapsed
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (previewText != null) ...[
                      Text(
                        previewText,
                        maxLines: _previewMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.articleBody.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: PassqlSpacing.sm),
                    ],
                    PassqlButton(
                      label: '이어서 읽기',
                      icon: CupertinoIcons.chevron_down,
                      variant: PassqlButtonVariant.tinted,
                      size: PassqlButtonSize.small,
                      onPressed: onExpandPressed,
                    ),
                  ],
                )
              : ConceptMarkdownBody(section.bodyMd),
        ),
      ],
    );
  }
}

/// 자주 헷갈리는 점: 주의색 머리(개수) > 앞 글 > 함정 카드들 (굵은 첫 문장이 없으면 글 그대로)
class _ConfusingBody extends StatelessWidget {
  const _ConfusingBody({required this.order, required this.section});

  final int order;
  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final split = ConceptReadingParser.splitPitfalls(section.bodyMd);
    final pitfalls = split.pitfalls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          order: order,
          title: section.title,
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          label: pitfalls.isEmpty ? '자주 틀리는 점' : '자주 틀리는 점 ${pitfalls.length}개',
          labelColor: context.passqlColors.warningText,
        ),
        const SizedBox(height: PassqlSpacing.sm),
        if (pitfalls.isEmpty)
          ConceptMarkdownBody(section.bodyMd)
        else ...[
          if (split.introMd.isNotEmpty) ...[
            ConceptMarkdownBody(split.introMd),
            const SizedBox(height: PassqlSpacing.md),
          ],
          for (final (index, pitfall) in pitfalls.indexed) ...[
            if (index > 0) const SizedBox(height: PassqlSpacing.sm),
            ConceptPitfallCard(order: index + 1, pitfall: pitfall),
          ],
        ],
      ],
    );
  }
}

/// 시험 포인트: 강조 상자 하나 (라벨 > 번호 제목 > 본문)
class _ExamPointBody extends StatelessWidget {
  const _ExamPointBody({required this.order, required this.section});

  final int order;
  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCallout(
      kind: PassqlCalloutKind.accent,
      icon: CupertinoIcons.checkmark_seal_fill,
      label: '시험 포인트',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                style: PassqlTypography.headline.copyWith(color: colors.label),
                children: [
                  TextSpan(
                    text: '$order  ',
                    style: TextStyle(color: colors.accentText),
                  ),
                  TextSpan(text: section.title),
                ],
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          ConceptMarkdownBody(section.bodyMd),
        ],
      ),
    );
  }
}
