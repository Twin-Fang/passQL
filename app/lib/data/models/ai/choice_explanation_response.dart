// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'choice_explanation.dart';

part 'choice_explanation_response.freezed.dart';
part 'choice_explanation_response.g.dart';

/// 해설 상태 3개: 준비됨, 생성 중(재조회), 실패(재시도 상한 도달)
enum ChoiceExplanationStatus {
  @JsonValue('READY')
  ready,
  @JsonValue('GENERATING')
  generating,
  @JsonValue('FAILED')
  failed,
}

/// GET /ai/choice-explanation 응답 (기다리지 않음, #521)
@freezed
class ChoiceExplanationResponse with _$ChoiceExplanationResponse {
  const factory ChoiceExplanationResponse({
    @Default('') String choiceSetUuid,
    @Default('') String selectedChoiceKey,
    // 서버에 상태가 추가돼도 깨지지 않게 모르는 값은 실패로 봄
    @JsonKey(unknownEnumValue: ChoiceExplanationStatus.failed)
    @Default(ChoiceExplanationStatus.failed)
    ChoiceExplanationStatus status,
    // READY 의 구조화 해설 (고정 세트·옛 해설이면 null)
    ChoiceExplanation? explanation,
    // 마크다운 해설: READY 는 항상, GENERATING·FAILED 는 옛 해설 있으면 임시 표시용
    String? text,
    // GENERATING 일 때 다시 조회할 간격
    int? retryAfterMilliseconds,
    int? promptVersion,
    // 무료 응답에서 뺀 묶음 이름 (FULL_EXPLANATION), 없으면 빈 목록
    @Default([]) List<String> lockedSections,
  }) = _ChoiceExplanationResponse;

  factory ChoiceExplanationResponse.fromJson(Map<String, dynamic> json) =>
      _$ChoiceExplanationResponseFromJson(json);
}
