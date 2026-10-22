import 'package:flutter/cupertino.dart';

import '../../../data/models/ai/choice_explanation.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import 'ai_explanation_choice_analysis_list.dart';
import 'ai_explanation_inline_text.dart';
import 'ai_explanation_verdict.dart';

/// 구조화 해설 본문: 판정 배지 > 정답 근거 > 시험 팁 > 핵심 개념 > 헷갈리는 지점 > 보기별 판단
/// 시험 팁은 풀이 직후 가장 먼저 기억할 한 줄이라 긴 섹션보다 앞
/// 비어 있는 섹션은 그리지 않음
/// [isFullExplanationLocked] (무료, 결제 켜짐): 판정 아래 블러 (서버가 판정 외 섹션을 비워 보냄)
class AiExplanationSections extends StatelessWidget {
  const AiExplanationSections({
    super.key,
    required this.explanation,
    required this.entry,
    this.isFullExplanationLocked = false,
  });

  final ChoiceExplanation explanation;
  final AiExplanationEntry entry;
  final bool isFullExplanationLocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final correctLabel = entry.displayLabelOf(explanation.correctChoiceKey);
    final keyConcepts = explanation.keyConcepts
        .where((concept) => concept.name.trim().isNotEmpty)
        .toList();
    final confusingPoints = explanation.confusingPoints
        .where((point) => point.trim().isNotEmpty)
        .toList();
    final sections = <Widget>[
      _VerdictBanner(
        isCorrect: explanation.isSelectedCorrect,
        verdict: composeAiExplanationVerdict(explanation, entry),
      ),
      if (isFullExplanationLocked)
        const ProLockedSection(
          preview: ExplanationLockedSample(),
          caption: LockedPreviewCaptions.explanation,
        ),
      if (explanation.correctReason.trim().isNotEmpty)
        _ExplanationSection(
          icon: CupertinoIcons.checkmark_seal_fill,
          title: '정답 $correctLabel 근거',
          toneColor: colors.correctText,
          child: AiExplanationInlineText(explanation.correctReason),
        ),
      if (explanation.examTip.trim().isNotEmpty)
        _ExamTip(examTip: explanation.examTip),
      if (keyConcepts.isNotEmpty)
        _ExplanationSection(
          icon: CupertinoIcons.book_fill,
          title: '핵심 개념',
          toneColor: colors.accent,
          child: _KeyConceptList(keyConcepts: keyConcepts),
        ),
      if (confusingPoints.isNotEmpty)
        _ExplanationSection(
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          title: '헷갈리는 지점',
          toneColor: colors.warning,
          child: _ConfusingPointList(confusingPoints: confusingPoints),
        ),
      if (explanation.choiceAnalyses.isNotEmpty)
        _ExplanationSection(
          icon: CupertinoIcons.list_bullet,
          title: '보기별 판단',
          toneColor: colors.secondaryLabel,
          child: AiExplanationChoiceAnalysisList(
            explanation: explanation,
            entry: entry,
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.lg),
          PassqlReveal(index: index, child: sections[index]),
        ],
      ],
    );
  }
}

/// 판정 배지: 정답/오답 색 옅은 바탕 + 아이콘 + 판정 한 줄
class _VerdictBanner extends StatelessWidget {
  const _VerdictBanner({required this.isCorrect, required this.verdict});

  final bool isCorrect;
  final String verdict;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final textColor = isCorrect ? colors.correctText : colors.wrongText;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: isCorrect ? colors.correctTint : colors.wrongTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.xmark_circle_fill,
            size: PassqlIconSize.lg,
            color: isCorrect ? colors.correct : colors.wrong,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: AiExplanationInlineText(
              verdict,
              style: PassqlTypography.explanationEmphasis.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 머리(아이콘 + 제목) + 본문
class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection({
    required this.icon,
    required this.title,
    required this.toneColor,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color toneColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              Icon(icon, size: PassqlIconSize.xs, color: toneColor),
              const SizedBox(width: PassqlSpacing.xxs),
              Flexible(
                child: Text(
                  title,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        child,
      ],
    );
  }
}

/// 핵심 개념: 이름 칩(코드 글꼴) + 정의
class _KeyConceptList extends StatelessWidget {
  const _KeyConceptList({required this.keyConcepts});

  final List<KeyConcept> keyConcepts;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final nameStyle = PassqlTypography.inlineCodeOf(
      PassqlTypography.subheadlineSemibold,
    ).copyWith(color: colors.accent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < keyConcepts.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.xs,
              vertical: PassqlSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: colors.accentTint,
              borderRadius: BorderRadius.circular(PassqlRadius.sm),
            ),
            child: Text(keyConcepts[index].name, style: nameStyle),
          ),
          if (keyConcepts[index].description.trim().isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            AiExplanationInlineText(keyConcepts[index].description),
          ],
        ],
      ],
    );
  }
}

/// 헷갈리는 지점: 경고 톤 바탕 + 항목마다 경고 점
class _ConfusingPointList extends StatelessWidget {
  const _ConfusingPointList({required this.confusingPoints});

  final List<String> confusingPoints;

  /// 경고 바탕 진하기 (PassqlBadge 배경과 같은 단계)
  static const double _warningBackgroundAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: _warningBackgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < confusingPoints.length; index++) ...[
            if (index > 0) const SizedBox(height: PassqlSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
                  child: Icon(
                    CupertinoIcons.circle_fill,
                    size: PassqlSpacing.xs,
                    color: colors.warning,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: AiExplanationInlineText(confusingPoints[index]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 시험 팁: 강조색 옅은 바탕 + 전구
class _ExamTip extends StatelessWidget {
  const _ExamTip({required this.examTip});

  final String examTip;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb_fill,
            size: PassqlIconSize.lg,
            color: colors.accent,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시험 팁',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accent,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                AiExplanationInlineText(examTip),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
