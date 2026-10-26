import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/presentation/widgets/question/choice_display_label.dart';

/// 보기 표시 라벨 (#512): 섞인 순서에서도 화면 순서대로 A..D, 정답 라벨도 화면 순서 기준
void main() {
  ChoiceItem choice(String key) => ChoiceItem(key: key, kind: 'TEXT', body: '보기 $key', sortOrder: 0);
  final shuffledChoices = [choice('C'), choice('A'), choice('D'), choice('B')];

  test('화면 순서 0..3 > A..D', () {
    expect([0, 1, 2, 3].map(toChoiceDisplayLabel), ['A', 'B', 'C', 'D']);
  });

  test('정답 choiceKey B 가 화면 4번째면 D 로 표시', () {
    expect(findChoiceDisplayLabel(shuffledChoices, 'B'), 'D');
  });

  test('목록에 없는 키는 그대로, null 은 null', () {
    expect(findChoiceDisplayLabel(shuffledChoices, 'Z'), 'Z');
    expect(findChoiceDisplayLabel(shuffledChoices, null), isNull);
  });
}
