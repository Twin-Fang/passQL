import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/date_format.dart';

void main() {
  group('formatSlashMonthDayTime', () {
    test('한 자리 월·일·시·분은 0을 채운다', () {
      expect(
        formatSlashMonthDayTime(DateTime(2026, 3, 7, 8, 5)),
        '03/07 08:05',
      );
    });

    test('오후는 24시간제로', () {
      expect(
        formatSlashMonthDayTime(DateTime(2026, 10, 28, 23, 59)),
        '10/28 23:59',
      );
    });

    test('자정은 00:00', () {
      expect(formatSlashMonthDayTime(DateTime(2026, 12, 31)), '12/31 00:00');
    });
  });

  test('formatRecentDayTitle: 오늘·어제는 낱말, 그 전은 월 일 (달이 바뀌어도 어제)', () {
    final today = DateTime(2026, 11, 1, 23, 30);
    expect(formatRecentDayTitle(DateTime(2026, 11, 1), today: today), '오늘');
    expect(formatRecentDayTitle(DateTime(2026, 10, 31), today: today), '어제');
    expect(
      formatRecentDayTitle(DateTime(2026, 10, 30), today: today),
      '10월 30일',
    );
  });
}
