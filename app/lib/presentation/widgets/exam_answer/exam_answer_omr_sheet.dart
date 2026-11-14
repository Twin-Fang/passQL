import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/sqld_scoring_rule.dart';
import '../../design/design.dart';

/// OMR 입력지: 과목별 묶음 > 문항 행(번호 + 보기 1~4 큰 동그라미 + 모름)
/// 같은 보기를 다시 누르면 지움, 저장은 누를 때마다 쓰는 쪽이 (자동 저장)
class ExamAnswerOmrSheet extends StatelessWidget {
  const ExamAnswerOmrSheet({
    super.key,
    required this.answers,
    required this.onAnswerSelected,
  });

  /// 답안 50자: '1'~'4' 보기, '0' 모름, 그 밖 미입력
  final String answers;

  /// (문항 번호, 보기 번호 0 = 모름)
  final void Function(int questionNo, int choice) onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final subject in SqldScoringRule.subjects) ...[
          if (subject != SqldScoringRule.subjects.first)
            const SizedBox(height: PassqlSpacing.xl),
          _SubjectHeader(subject: subject, answers: answers),
          const SizedBox(height: PassqlSpacing.xs),
          for (
            var questionNo = subject.firstQuestionNo;
            questionNo <= subject.lastQuestionNo;
            questionNo++
          )
            _OmrRow(
              questionNo: questionNo,
              mark: questionNo <= answers.length ? answers[questionNo - 1] : '',
              onAnswerSelected: onAnswerSelected,
            ),
        ],
      ],
    );
  }
}

/// 과목 머리: `1과목 데이터 모델링의 이해` + 입력 수
class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject, required this.answers});

  final SqldSubjectRule subject;
  final String answers;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    var enteredCount = 0;
    for (
      var questionNo = subject.firstQuestionNo;
      questionNo <= subject.lastQuestionNo && questionNo <= answers.length;
      questionNo++
    ) {
      if (_isEnteredMark(answers[questionNo - 1])) enteredCount++;
    }
    return Semantics(
      header: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${subject.subjectNo}과목 ${subject.name}',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
          Text(
            '$enteredCount / ${subject.questionCount}',
            style: PassqlTypography.footnoteSemibold.copyWith(
              fontFeatures: PassqlTypography.tabular,
              color: enteredCount == subject.questionCount
                  ? colors.correctText
                  : colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

/// 문항 행 1개: 번호 > 보기 4개 > 모름
class _OmrRow extends StatelessWidget {
  const _OmrRow({
    required this.questionNo,
    required this.mark,
    required this.onAnswerSelected,
  });

  final int questionNo;
  final String mark;
  final void Function(int questionNo, int choice) onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          SizedBox(
            width: PassqlSize.examAnswerNumberColumn,
            child: Text(
              '$questionNo',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                fontFeatures: PassqlTypography.tabular,
                color: _isEnteredMark(mark)
                    ? colors.label
                    : colors.secondaryLabel,
              ),
            ),
          ),
          for (var choice = 1; choice <= SqldScoringRule.choiceCount; choice++)
            Expanded(
              child: Center(
                child: _OmrBubble(
                  questionNo: questionNo,
                  choice: choice,
                  isSelected: mark == '$choice',
                  onTap: () => _select(choice),
                ),
              ),
            ),
          _UnknownChip(
            questionNo: questionNo,
            isSelected: mark == '${SqldScoringRule.unknownAnswer}',
            onTap: () => _select(SqldScoringRule.unknownAnswer),
          ),
        ],
      ),
    );
  }

  void _select(int choice) {
    PassqlHaptics.playSelection();
    onAnswerSelected(questionNo, choice);
  }
}

/// 보기 동그라미: 선택 = 강조색 채움 + 흰 숫자, 아니면 테두리 + 회색 숫자
class _OmrBubble extends StatelessWidget {
  const _OmrBubble({
    required this.questionNo,
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  final int questionNo;
  final int choice;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlSemanticButton(
      label: '$questionNo번 보기 $choice',
      isSelected: isSelected,
      onTap: onTap,
      child: PassqlPressable(
        onTap: onTap,
        isTapExposedToScreenReader: false,
        child: AnimatedContainer(
          duration: PassqlMotion.durationOf(context, PassqlMotion.instant),
          curve: PassqlMotion.curve,
          width: PassqlSize.examAnswerOmrBubble,
          height: PassqlSize.examAnswerOmrBubble,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colors.accent : colors.card,
            border: Border.all(
              color: isSelected ? colors.accent : colors.separator,
              width: PassqlSize.examAnswerCutLineWidth,
            ),
          ),
          child: Text(
            '$choice',
            style: PassqlTypography.headline.copyWith(
              fontFeatures: PassqlTypography.tabular,
              color: isSelected ? colors.onAccent : colors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}

/// 모름 알약: 선택 = 회색 채움 + 진한 글자
class _UnknownChip extends StatelessWidget {
  const _UnknownChip({
    required this.questionNo,
    required this.isSelected,
    required this.onTap,
  });

  final int questionNo;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlSemanticButton(
      label: '$questionNo번 모름',
      isSelected: isSelected,
      onTap: onTap,
      child: PassqlPressable(
        onTap: onTap,
        isTapExposedToScreenReader: false,
        child: AnimatedContainer(
          duration: PassqlMotion.durationOf(context, PassqlMotion.instant),
          curve: PassqlMotion.curve,
          height: PassqlSize.examAnswerOmrBubble,
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.fill : colors.card,
            borderRadius: BorderRadius.circular(PassqlRadius.capsule),
            border: Border.all(
              color: isSelected ? colors.secondaryLabel : colors.separator,
              width: PassqlSize.hairline,
            ),
          ),
          child: Text(
            '모름',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: isSelected ? colors.label : colors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}

// 입력된 자리: 보기 1~4 또는 모름 0 ('.' 미입력 제외)
bool _isEnteredMark(String mark) => int.tryParse(mark) != null;
