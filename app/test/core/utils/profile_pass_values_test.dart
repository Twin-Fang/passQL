import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/exam_dday.dart';
import 'package:passql_app/core/utils/profile_pass_values.dart';

void main() {
  test('남은 무료 횟수는 0 아래로 내려가지 않는다', () {
    expect(remainingFreeSolves(used: 7, limit: 10), 3);
    expect(remainingFreeSolves(used: 12, limit: 10), 0);
  });

  test('한도 0(결제 꺼짐 응답)은 다 쓴 날이 아니다', () {
    expect(isFreeLimitReached(used: 0, limit: 0), isFalse);
    expect(isFreeLimitReached(used: 10, limit: 10), isTrue);
  });

  test('더 푼 문제는 한도를 넘었을 때만', () {
    expect(extraSolvedToday(used: 23, limit: 10), 13);
    expect(extraSolvedToday(used: 10, limit: 10), isNull);
    expect(extraSolvedToday(used: 5, limit: 10), isNull);
  });

  test('시험까지 무료 최대치: 일정 없음, 지난 시험은 null', () {
    expect(freeCapUntilExam(daysUntilExam: 17, limit: 10), 170);
    expect(freeCapUntilExam(daysUntilExam: null, limit: 10), isNull);
    expect(freeCapUntilExam(daysUntilExam: 0, limit: 10), isNull);
    expect(freeCapUntilExam(daysUntilExam: -3, limit: 10), isNull);
    expect(freeCapUntilExam(daysUntilExam: 17, limit: 0), isNull);
  });

  test('3개월 권유 금액: 9,900원 vs 4,400원 > 3,300원, 월 1,100원', () {
    final savings = monthlySavingsOf(
      longPrice: 9900,
      longMonths: 3,
      basePrice: 4400,
      baseMonths: 1,
    );
    expect(savings, 3300);
    expect(monthlyShareOf(3300, 3), 1100);
    expect(
      monthlySavingsOf(
        longPrice: null,
        longMonths: 3,
        basePrice: 4400,
        baseMonths: 1,
      ),
      isNull,
    );
    expect(
      monthlySavingsOf(
        longPrice: 13200,
        longMonths: 3,
        basePrice: 4400,
        baseMonths: 1,
      ),
      isNull,
    );
  });

  test('남은 날은 날짜만 비교', () {
    final now = DateTime(2026, 10, 29, 23, 50);
    expect(daysUntilDate(DateTime(2026, 12, 31, 0, 1), now: now), 63);
    expect(daysUntilDate(DateTime(2026, 10, 29, 1), now: now), 0);
  });

  test('AI 분석 시각: 오늘은 오전/오후 시각, 다른 날은 월 일', () {
    final now = DateTime(2026, 10, 29, 15);
    expect(aiAnalyzedLabel('2026-10-29T09:12:00', now: now), '오늘 오전 9:12 분석');
    expect(aiAnalyzedLabel('2026-10-29T13:05:00', now: now), '오늘 오후 1:05 분석');
    expect(aiAnalyzedLabel('2026-10-27T13:05:00', now: now), '10월 27일 분석');
    expect(aiAnalyzedLabel(null, now: now), isNull);
    expect(aiAnalyzedLabel('엉뚱한 값', now: now), isNull);
  });
}
