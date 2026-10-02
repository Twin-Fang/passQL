import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/date_format.dart';

void main() {
  test('월 일 시:분 형태로 표기하고 분은 두 자리로 맞춘다', () {
    expect(formatMonthDayTime(DateTime(2026, 10, 2, 15, 5)), '10월 2일 15:05');
    expect(formatMonthDayTime(DateTime(2026, 1, 9, 0, 0)), '1월 9일 00:00');
  });
}
