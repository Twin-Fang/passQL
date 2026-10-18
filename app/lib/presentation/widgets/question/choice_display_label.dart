import '../../../data/models/question/choice_item.dart';

/// 보기 표시 라벨 공통: 화면 순서(0..N) > A, B, C, D (#512)
/// 서버가 고정 보기 순서를 섞어 보내므로 choiceKey 글자 대신 표시 순서로 라벨을 붙인다. 채점은 choiceKey 그대로.
String toChoiceDisplayLabel(int displayIndex) =>
    String.fromCharCode('A'.codeUnitAt(0) + displayIndex);

/// 보기 목록 + choiceKey > 화면 표시 라벨 (목록에 없으면 choiceKey 그대로, 키가 없으면 null)
String? findChoiceDisplayLabel(List<ChoiceItem> choices, String? choiceKey) {
  if (choiceKey == null) return null;
  final displayIndex = choices.indexWhere((choice) => choice.key == choiceKey);
  return displayIndex < 0 ? choiceKey : toChoiceDisplayLabel(displayIndex);
}

/// 보기 목록 > {choiceKey: 표시 라벨} (넣는 순서 = 화면 순서, 해설 보기별 판단 정렬·라벨에 사용)
Map<String, String> choiceDisplayLabelsOf(List<ChoiceItem> choices) => {
  for (var displayIndex = 0; displayIndex < choices.length; displayIndex++)
    choices[displayIndex].key: toChoiceDisplayLabel(displayIndex),
};
