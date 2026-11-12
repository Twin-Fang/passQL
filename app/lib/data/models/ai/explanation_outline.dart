// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'explanation_outline.freezed.dart';
part 'explanation_outline.g.dart';

/// 잠긴 상세 해설 섹션 종류 5개 (서버 선언 순서 = 화면 배치 순서), 모르는 값은 unknown (그리지 않음)
enum ExplanationOutlineSectionKind {
  @JsonValue('CORRECT_REASON')
  correctReason,
  @JsonValue('EXAM_TIP')
  examTip,
  @JsonValue('KEY_CONCEPTS')
  keyConcepts,
  @JsonValue('CONFUSING_POINTS')
  confusingPoints,
  @JsonValue('CHOICE_ANALYSES')
  choiceAnalyses,
  unknown,
}

/// 무료 응답의 잠긴 상세 해설 구성 (#999): 섹션 종류·항목별 대략 글자 수만 (진짜 글 없음)
@freezed
class ExplanationOutline with _$ExplanationOutline {
  const factory ExplanationOutline({
    @Default(0) int choiceCount,
    @Default([]) List<ExplanationOutlineSection> sections,
  }) = _ExplanationOutline;

  factory ExplanationOutline.fromJson(Map<String, dynamic> json) =>
      _$ExplanationOutlineFromJson(json);
}

/// 섹션 1개: 종류 + 항목별 대략 글자 수 (항목 수 = 목록 길이)
@freezed
class ExplanationOutlineSection with _$ExplanationOutlineSection {
  const factory ExplanationOutlineSection({
    @JsonKey(unknownEnumValue: ExplanationOutlineSectionKind.unknown)
    @Default(ExplanationOutlineSectionKind.unknown)
    ExplanationOutlineSectionKind kind,
    @Default([]) List<int> itemCharacterCounts,
  }) = _ExplanationOutlineSection;

  factory ExplanationOutlineSection.fromJson(Map<String, dynamic> json) =>
      _$ExplanationOutlineSectionFromJson(json);
}
