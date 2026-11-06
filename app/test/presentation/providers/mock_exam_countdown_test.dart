import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/mock_exam_countdown.dart';
import 'package:passql_app/presentation/providers/mock_exam_session_state.dart';

/// 모의고사 남은 시간·답 병합 판정 (#866): 서버 남은 초 - 단조 경과, 저장 실패 답은 기기 값 우선
void main() {
  test('남은 시간은 서버 값에서 받은 뒤 흐른 시간만 뺀다 (0 아래로 내려가지 않음)', () {
    var elapsed = const Duration(seconds: 30);
    final countdown = MockExamCountdown(remainingSecondsAtSync: 100, elapsedSinceSync: () => elapsed);

    expect(countdown.remainingSeconds, 70);
    elapsed = const Duration(seconds: 103);
    expect(countdown.remainingSeconds, 0);
    expect(countdown.isTimeUp, isTrue);
    expect(countdown.secondsPastDeadline, 3);
  });

  test('경고 단계는 10분 이하 주의, 5분 이하 임박', () {
    expect(mockExamTimeLevelOf(601), MockExamTimeLevel.relaxed);
    expect(mockExamTimeLevelOf(600), MockExamTimeLevel.caution);
    expect(mockExamTimeLevelOf(300), MockExamTimeLevel.urgent);
    expect(formatMockExamRemaining(5400), '1:30:00');
    expect(formatMockExamRemaining(59), '00:59');
  });

  test('다시 받은 시험지에 저장 실패한 기기 답을 덮어 쓴다', () {
    final merged = mergeUnsyncedAnswers(
      {1: const MockExamLocalAnswer(selectedChoiceKey: 'A'), 2: const MockExamLocalAnswer()},
      {
        1: const MockExamLocalAnswer(selectedChoiceKey: 'A'),
        2: const MockExamLocalAnswer(selectedChoiceKey: 'C', isSynced: false),
      },
    );

    expect(merged[1]!.selectedChoiceKey, 'A');
    expect(merged[2]!.selectedChoiceKey, 'C');
    expect(merged[2]!.isSynced, isFalse);
  });
}
