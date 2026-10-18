import 'package:freezed_annotation/freezed_annotation.dart';

part 'choice_explanation.freezed.dart';
part 'choice_explanation.g.dart';

/// 구조화 AI 해설 (고른 보기 기준, #521)
/// 화면 순서: 판정 > 정답 근거 > 핵심 개념 > 헷갈리는 지점 > 보기별 판단 > 시험 팁
/// 문장 속 `코드` 는 인라인 SQL 조각
@freezed
class ChoiceExplanation with _$ChoiceExplanation {
  const factory ChoiceExplanation({
    @Default('') String selectedChoiceKey,
    @Default('') String correctChoiceKey,
    @Default(false) bool isSelectedCorrect,
    // 서버가 choiceKey 로 조립한 판정. 화면은 표시 라벨(#512)로 다시 조립해서 씀
    @Default('') String verdict,
    @Default('') String correctReason,
    @Default([]) List<KeyConcept> keyConcepts,
    @Default([]) List<String> confusingPoints,
    @Default([]) List<ChoiceAnalysis> choiceAnalyses,
    @Default('') String examTip,
  }) = _ChoiceExplanation;

  factory ChoiceExplanation.fromJson(Map<String, dynamic> json) =>
      _$ChoiceExplanationFromJson(json);
}

/// 핵심 개념 1건: 이름(예: DENSE_RANK) + 설명 한두 줄
@freezed
class KeyConcept with _$KeyConcept {
  const factory KeyConcept({
    @Default('') String name,
    @Default('') String description,
  }) = _KeyConcept;

  factory KeyConcept.fromJson(Map<String, dynamic> json) =>
      _$KeyConceptFromJson(json);
}

/// 보기별 판정 1건: 보기 키 + 정답 여부 + 이유 한 줄
@freezed
class ChoiceAnalysis with _$ChoiceAnalysis {
  const factory ChoiceAnalysis({
    @Default('') String choiceKey,
    @Default(false) bool isCorrect,
    @Default('') String reason,
  }) = _ChoiceAnalysis;

  factory ChoiceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ChoiceAnalysisFromJson(json);
}
