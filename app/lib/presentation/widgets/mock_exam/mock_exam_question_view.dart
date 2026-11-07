import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_sheet.dart';
import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import '../question/choice_display_label.dart';
import '../question/choice_item_card.dart';
import '../question/question_sections.dart';
import 'mock_exam_number_grid.dart';

/// 모의고사 문항 본문 (풀이·해설 공용): 머리 줄(번호·과목·토픽·표시) > 지문 > 테이블 > 보기
/// 보기 모양은 [choiceStateOf] 가 정함 (풀이: 선택, 해설: 정답·오답)
class MockExamQuestionView extends StatelessWidget {
  const MockExamQuestionView({
    super.key,
    required this.questionNumber,
    required this.subject,
    required this.topicName,
    required this.stem,
    required this.schemaTables,
    required this.choices,
    required this.choiceStateOf,
    this.onChoiceTap,
    this.isFlagged = false,
    this.footer,
  });

  final int questionNumber;
  final MockExamSubject subject;
  final String? topicName;
  final String stem;
  final List<QuestionSchemaTable> schemaTables;
  final List<MockExamChoice> choices;
  final PassqlChoiceState Function(MockExamChoice choice) choiceStateOf;

  /// 보기 탭 (없으면 눌리지 않음: 해설)
  final void Function(MockExamChoice choice)? onChoiceTap;
  final bool isFlagged;

  /// 보기 아래 (해설: 보기 근거·요약)
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final headerParts = [
      mockExamSubjectShortName(subject),
      if (topicName != null && topicName!.isNotEmpty) topicName!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.sm,
            PassqlSpacing.md,
            0,
          ),
          child: Row(
            children: [
              Text(
                '$questionNumber번',
                style: PassqlTypography.headline.copyWith(color: colors.label),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: Text(
                  headerParts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
              if (isFlagged)
                const PassqlBadge(
                  text: '표시함',
                  kind: PassqlBadgeKind.warning,
                  icon: CupertinoIcons.flag_fill,
                ),
            ],
          ),
        ),
        QuestionStem(stem: stem, schemaTables: schemaTables),
        const SizedBox(height: PassqlSpacing.xs),
        for (
          var displayIndex = 0;
          displayIndex < choices.length;
          displayIndex++
        )
          ChoiceItemCard(
            item: choices[displayIndex].toChoiceItem(),
            displayLabel: toChoiceDisplayLabel(displayIndex),
            state: choiceStateOf(choices[displayIndex]),
            onTap: onChoiceTap == null
                ? () {}
                : () => onChoiceTap!(choices[displayIndex]),
          ),
        ?footer,
      ],
    );
  }
}
