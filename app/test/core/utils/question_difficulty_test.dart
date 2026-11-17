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

  // 난이도 띠 채운 칸 수: 경계값 2/3/4 > 1/2/3칸 (#1147)
  test('difficultyStepNumber: 경계 2 > 1칸, 3 > 2칸, 4 > 3칸', () {
    expect(toQuestionDifficultyLevel(2)!.difficultyStepNumber, 1);
    expect(toQuestionDifficultyLevel(3)!.difficultyStepNumber, 2);
    expect(toQuestionDifficultyLevel(4)!.difficultyStepNumber, 3);
    expect(QuestionDifficultyLevel.difficultyStepCount, 3);
  });
}
