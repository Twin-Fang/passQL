import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/relative_time.dart';

void main() {
  final now = DateTime(2026, 10, 2, 15, 30);

  test('날짜 기준으로 오늘/어제/N일 전을 구한다', () {
    expect(formatRelativeDay(DateTime(2026, 10, 2, 0, 5), now: now), '오늘');
    expect(formatRelativeDay(DateTime(2026, 10, 1, 23, 59), now: now), '어제');
    expect(formatRelativeDay(DateTime(2026, 9, 29, 12), now: now), '3일 전');
  });

  test('시각이 24시간 미만이어도 날짜가 다르면 어제로 본다', () {
    // 새벽 1시 기준, 전날 밤 11시는 2시간 전이지만 날짜상 어제다.
    final early = DateTime(2026, 10, 2, 1);
    expect(formatRelativeDay(DateTime(2026, 10, 1, 23), now: early), '어제');
  });

  test('시각이 없으면 빈 문자열이다', () {
    expect(formatRelativeDay(null, now: now), '');
  });
}
