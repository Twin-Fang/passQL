import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/exam_answer/exam_answer_display_rule.dart';

// 지난 회차 판정 (#1151): 정답 반영 완료 + 시험일 7일 초과일 때만
void main() {
  final now = DateTime(2026, 11, 17);

  test('시험일 7일 이내이거나 정답 미반영이면 지난 회차가 아니다', () {
    expect(
      ExamAnswerDisplayRule.isPastSettledRound(
        isOfficial: true,
        examDate: '2026-11-14',
        now: now,
      ),
      isFalse,
    );
    expect(
      ExamAnswerDisplayRule.isPastSettledRound(
        isOfficial: false,
        examDate: '2026-08-22',
        now: now,
      ),
      isFalse,
    );
  });

  test('시험일이 7일을 넘고 정답이 반영됐으면 지난 회차다', () {
    expect(
      ExamAnswerDisplayRule.isPastSettledRound(
        isOfficial: true,
        examDate: '2026-08-22',
        now: now,
      ),
      isTrue,
    );
  });

  test('시험일을 모르면 지난 회차로 보지 않는다', () {
    expect(
      ExamAnswerDisplayRule.isPastSettledRound(
        isOfficial: true,
        examDate: null,
        now: now,
      ),
      isFalse,
    );
  });
}
