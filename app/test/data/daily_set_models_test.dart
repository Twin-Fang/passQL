import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';

void main() {
  test('오늘의 세트 응답: 완료했으면 문제별 결과(results)를 읽는다', () {
    final res = DailySetTodayResponse.fromJson({
      'questions': [],
      'alreadyCompleted': true,
      'correctCount': 1,
      'results': [true, false, null],
    });
    expect(res.results, [true, false, null]);
  });

  test('오늘의 세트 응답: results 가 없으면 null (구버전 서버 호환)', () {
    final res = DailySetTodayResponse.fromJson({
      'questions': [],
      'alreadyCompleted': false,
    });
    expect(res.results, isNull);
  });
}
