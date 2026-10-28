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
}
