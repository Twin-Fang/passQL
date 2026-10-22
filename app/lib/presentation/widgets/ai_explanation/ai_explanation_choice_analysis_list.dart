import 'package:flutter/cupertino.dart';

import '../../../data/models/ai/choice_explanation.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import 'ai_explanation_inline_text.dart';

/// 보기별 판단: 화면 순서·표시 라벨(#512), 정답·내 선택 강조
class AiExplanationChoiceAnalysisList extends StatelessWidget {
  const AiExplanationChoiceAnalysisList({
    super.key,
    required this.explanation,
    required this.entry,
  });

  final ChoiceExplanation explanation;
  final AiExplanationEntry entry;

  @override
  Widget build(BuildContext context) {
    final analyses = [...explanation.choiceAnalyses]
      ..sort(
        (left, right) => entry
            .displayOrderOf(left.choiceKey)
            .compareTo(entry.displayOrderOf(right.choiceKey)),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < analyses.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.xs),
          _ChoiceAnalysisRow(
            analysis: analyses[index],
            displayLabel: entry.displayLabelOf(analyses[index].choiceKey),
            isSelected:
                analyses[index].choiceKey == explanation.selectedChoiceKey,
          ),
        ],
      ],
    );
  }
}

class _ChoiceAnalysisRow extends StatelessWidget {
  const _ChoiceAnalysisRow({
    required this.analysis,
    required this.displayLabel,
    required this.isSelected,
  });

  final ChoiceAnalysis analysis;
  final String displayLabel;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isCorrect = analysis.isCorrect;
    final isWrongSelection = isSelected && !isCorrect;
    final rowBackground = isCorrect
        ? colors.correctTint
        : isWrongSelection
        ? colors.wrongTint
        : colors.fill;
    final keyColor = isCorrect
        ? colors.correct
        : isWrongSelection
        ? colors.wrong
        : colors.secondaryLabel;
    // 키 글자: 초록·빨강 위 onSemantic, 회색 위는 화면 배경색(반전) > 라이트·다크 모두 4.5 이상
    final keyTextColor = isCorrect || isWrongSelection
        ? colors.onSemantic
        : colors.background;
    return Semantics(
      label:
          '$displayLabel 보기${isCorrect ? ', 정답' : ''}${isSelected ? ', 내 선택' : ''}',
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: rowBackground,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: PassqlSize.choiceKeyBadge,
              height: PassqlSize.choiceKeyBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: keyColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                displayLabel,
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: keyTextColor,
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCorrect || isSelected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
                      child: Wrap(
                        spacing: PassqlSpacing.xxs,
                        runSpacing: PassqlSpacing.xxs,
                        children: [
                          if (isCorrect)
                            const PassqlBadge(
                              text: '정답',
                              kind: PassqlBadgeKind.success,
                            ),
                          if (isSelected)
                            PassqlBadge(
                              text: '내 선택',
                              kind: isCorrect
                                  ? PassqlBadgeKind.neutral
                                  : PassqlBadgeKind.important,
                              icon: CupertinoIcons.hand_point_right_fill,
                            ),
                        ],
                      ),
                    ),
                  AiExplanationInlineText(analysis.reason),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
