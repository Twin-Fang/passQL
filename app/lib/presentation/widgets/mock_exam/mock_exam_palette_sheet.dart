import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_session_state.dart';
import 'mock_exam_number_cell.dart';
import 'mock_exam_number_grid.dart';

/// 풀이 문항 목록 시트: 과목별 50칸(답함·표시·현재) + 안 푼·표시 수 + 제출
/// 번호 탭 > 그 문항으로 이동하고 닫힘, 제출 탭 > 시트 닫고 제출 확인
Future<void> showMockExamPaletteSheet(
  BuildContext context, {
  required MockExamSessionState session,
  required void Function(int questionIndex) onQuestionSelected,
  required VoidCallback onSubmitRequested,
}) {
  return showPassqlSheet<void>(
    context,
    title: '문항 목록',
    builder: (sheetContext) => _MockExamPaletteBody(
      session: session,
      onQuestionSelected: (questionIndex) {
        Navigator.of(sheetContext).pop();
        onQuestionSelected(questionIndex);
      },
      onSubmitRequested: () {
        Navigator.of(sheetContext).pop();
        onSubmitRequested();
      },
    ),
  );
}

class _MockExamPaletteBody extends StatelessWidget {
  const _MockExamPaletteBody({
    required this.session,
    required this.onQuestionSelected,
    required this.onSubmitRequested,
  });

  final MockExamSessionState session;
  final void Function(int questionIndex) onQuestionSelected;
  final VoidCallback onSubmitRequested;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final groups = [
      for (final subject in const [
        MockExamSubject.subjectOne,
        MockExamSubject.subjectTwo,
      ])
        if (session.indexesOf(subject).isNotEmpty)
          MockExamNumberGroup(
            title: mockExamSubjectGroupTitle(subject),
            cells: [
              for (final questionIndex in session.indexesOf(subject))
                _cellOf(questionIndex),
            ],
          ),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '안 푼 문항 ${session.unansweredCount}개 · 표시 ${session.flaggedCount}개',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          MockExamNumberGrid(groups: groups),
          const SizedBox(height: PassqlSpacing.lg),
          PassqlButton(label: '제출하기', onPressed: onSubmitRequested),
        ],
      ),
    );
  }

  Widget _cellOf(int questionIndex) {
    final question = session.questions[questionIndex];
    final answer = session.answerOf(question.questionNumber);
    return MockExamNumberCell(
      questionNumber: question.questionNumber,
      kind: answer.isAnswered
          ? MockExamNumberCellKind.answered
          : MockExamNumberCellKind.unanswered,
      isFlagged: answer.isFlagged,
      isCurrent: questionIndex == session.currentIndex,
      onTap: () => onQuestionSelected(questionIndex),
    );
  }
}
