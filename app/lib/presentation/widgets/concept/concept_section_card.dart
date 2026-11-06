import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_lesson_body.dart';
import 'concept_pitfall_card.dart';
import 'concept_reading_parser.dart';

/// 개념 문단 한 구간 (#848): 교과서식 머리(큰 번호·종류 라벨 > 제목 > 부제) + 레슨 블록 본문
/// 자주 헷갈리는 점 > 주의색 머리, 꼭 외울 것 > 노랑 머리, 시험 포인트 > 강조 상자, 옛 글의 굵은 문장 함정 > 함정 카드
class ConceptSectionCard extends StatelessWidget {
  const ConceptSectionCard({
    super.key,
    required this.order,
    required this.section,
  });

  final int order;
  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final kind = ConceptReadingParser.kindOf(section.anchor);
    final header = PassqlScrollReveal(
      child: _SectionHeader(order: order, section: section, kind: kind),
    );
    if (kind == ConceptSectionKind.examPoint) {
      return PassqlSection(
        child: PassqlScrollReveal(
          child: PassqlCallout(
            kind: PassqlCalloutKind.accent,
            icon: CupertinoIcons.checkmark_seal_fill,
            label: '시험 포인트',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitleText(section: section, isCompact: true),
                const SizedBox(height: PassqlSpacing.sm),
                ConceptLessonBody(section.bodyMd),
              ],
            ),
          ),
        ),
      );
    }
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: PassqlSpacing.md),
          if (kind == ConceptSectionKind.confusing)
            _ConfusingBody(section: section)
          else
            ConceptLessonBody(section.bodyMd),
        ],
      ),
    );
  }
}

/// 문단 머리: 큰 번호(01)·종류 라벨 한 줄 > 제목 > 부제
/// 번호는 풀이 화면 '다시 읽기' 라벨과 같은 순서
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.order,
    required this.section,
    required this.kind,
  });

  final int order;
  final ConceptDetailSection section;
  final ConceptSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (icon, label, tone) = switch (kind) {
      ConceptSectionKind.why => (
        CupertinoIcons.question_circle_fill,
        '왜 배우나요',
        colors.accentText,
      ),
      ConceptSectionKind.definition => (
        CupertinoIcons.book_fill,
        '정의',
        colors.accentText,
      ),
      ConceptSectionKind.confusing => (
        CupertinoIcons.exclamationmark_triangle_fill,
        '자주 틀리는 점',
        colors.warningText,
      ),
      ConceptSectionKind.memorize => (
        CupertinoIcons.bookmark_fill,
        // 제목이 늘 '꼭 외울 것'이라 라벨은 블록 성격으로
        '암기 카드',
        colors.memorizeText,
      ),
      _ => (null, null, colors.accentText),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 두 자리 번호 (교과서 단원 번호처럼 크게)
            Text(
              order.toString().padLeft(2, '0'),
              style: PassqlTypography.title2.copyWith(color: tone),
            ),
            if (label != null) ...[
              const SizedBox(width: PassqlSpacing.sm),
              PassqlBadge(
                text: label,
                icon: icon,
                kind: switch (kind) {
                  ConceptSectionKind.confusing => PassqlBadgeKind.warning,
                  ConceptSectionKind.memorize => PassqlBadgeKind.memorize,
                  _ => PassqlBadgeKind.topic,
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        _SectionTitleText(section: section),
      ],
    );
  }
}

/// 제목(큰 글씨) + 부제(보조색), 제목만 화면 읽기 머리로 표시
class _SectionTitleText extends StatelessWidget {
  const _SectionTitleText({required this.section, this.isCompact = false});

  final ConceptDetailSection section;

  /// 강조 상자 안 (시험 포인트): 한 단계 작은 제목
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final title = ConceptReadingParser.splitTitle(section.title);
    final subtitle = title.subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title.title,
            style:
                (isCompact
                        ? PassqlTypography.headline
                        : PassqlTypography.title2)
                    .copyWith(color: colors.label),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            subtitle,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}

/// 자주 헷갈리는 점 본문: 옛 글(굵은 문장으로 시작하는 문단) > 함정 카드, 새 글(헷갈리는 말 표 등) > 레슨 블록
class _ConfusingBody extends StatelessWidget {
  const _ConfusingBody({required this.section});

  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final split = ConceptReadingParser.splitPitfalls(section.bodyMd);
    final pitfalls = split.pitfalls;
    if (pitfalls.isEmpty) return ConceptLessonBody(section.bodyMd);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (split.introMd.isNotEmpty) ...[
          ConceptLessonBody(split.introMd),
          const SizedBox(height: PassqlSpacing.md),
        ],
        for (final (index, pitfall) in pitfalls.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.sm),
          PassqlScrollReveal(
            index: index,
            child: ConceptPitfallCard(order: index + 1, pitfall: pitfall),
          ),
        ],
      ],
    );
  }
}
