import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/question_difficulty.dart';

void main() {
  // 경계값 2/3/4 (1~2 쉬움, 3 보통, 4~5 어려움) + 범위 밖은 표시 없음 (#1145)
  test('toDifficultyLabel: 경계 2 쉬움, 3 보통, 4 어려움, 범위 밖·없음은 null', () {
    expect(toDifficultyLabel(2), '쉬움');
    expect(toDifficultyLabel(3), '보통');
    expect(toDifficultyLabel(4), '어려움');
    expect(toDifficultyLabel(0), isNull);
    expect(toDifficultyLabel(6), isNull);
    expect(toDifficultyLabel(null), isNull);
  });
}
