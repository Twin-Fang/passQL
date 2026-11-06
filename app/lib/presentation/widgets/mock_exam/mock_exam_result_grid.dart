import 'package:flutter/widgets.dart';

import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import 'mock_exam_number_cell.dart';
import 'mock_exam_number_grid.dart';

/// 결과 정오 번호판: 과목별 정답(초록)·오답(빨강)·안 푼 문항, 표시한 문항 점 / 탭 > 문항 해설
class MockExamResultGrid extends StatelessWidget {
  const MockExamResultGrid({
    super.key,
    required this.questionMarks,
    required this.onQuestionTap,
  });

  final List<MockExamQuestionMark> questionMarks;
  final void Function(int questionNumber) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return MockExamNumberGrid(
      groups: [
        for (final subject in const [
          MockExamSubject.subjectOne,
          MockExamSubject.subjectTwo,
        ])
          if (questionMarks.any((mark) => mark.subject == subject))
            MockExamNumberGroup(
              title: mockExamSubjectGroupTitle(subject),
              cells: [
                for (final mark in questionMarks.where(
                  (mark) => mark.subject == subject,
                ))
                  MockExamNumberCell(
                    questionNumber: mark.questionNumber,
                    kind: mark.isCorrect
                        ? MockExamNumberCellKind.correct
                        : mark.isAnswered
                        ? MockExamNumberCellKind.wrong
                        : MockExamNumberCellKind.skipped,
                    isFlagged: mark.isFlagged,
                    onTap: () => onQuestionTap(mark.questionNumber),
                  ),
              ],
            ),
      ],
    );
  }
}
