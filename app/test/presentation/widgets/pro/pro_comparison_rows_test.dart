import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/widgets/pro/pro_comparison_rows.dart';

/// 비교표 줄 핵심: 값이 다른 줄 먼저, 광고·모의고사 줄, 무료 한도 반영 (#966)
void main() {
  test('값이 둘 다 있는 줄이 먼저, 프로 전용 줄이 나중에 온다', () {
    final rows = proComparisonRows(dailyFreeLimit: 10);
    final firstProOnlyIndex = rows.indexWhere((row) => !row.hasBothValues);
    expect(firstProOnlyIndex, greaterThan(0));
    expect(
      rows.skip(firstProOnlyIndex).every((row) => !row.hasBothValues),
      isTrue,
    );
  });

  test('랜덤 풀기 줄은 무료 크레딧을, 광고·모의고사 줄은 무료·프로 값을 보인다', () {
    final rows = proComparisonRows(dailyFreeLimit: 10);
    final byLabel = {for (final row in rows) row.label: row};
    expect(byLabel['랜덤 풀기']?.free, '크레딧 하루 10개');
    expect(byLabel['광고']?.free, '있음');
    expect(byLabel['광고']?.pro, '없음');
    expect(byLabel['모의고사']?.free, '1회 체험');
    // 무료도 오늘의 세트는 실행·전체 해설 (#992)
    expect(byLabel['SQL 실행']?.free, '오늘의 세트');
    expect(byLabel['해설']?.free, '정답 해설 (세트 전체)');
  });
}
