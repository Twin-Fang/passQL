// freezed 생성자 파라미터에 붙이는 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'choice_generation_mode.dart';

part 'member_me_response.freezed.dart';
part 'member_me_response.g.dart';

/// GET /members/me 응답.
@freezed
class MemberMeResponse with _$MemberMeResponse {
  const factory MemberMeResponse({
    required String memberUuid,
    required String nickname,
    // 서버에 새 값이 생겨도 앱이 깨지지 않도록 모르는 값은 practice 로 받는다.
    @JsonKey(unknownEnumValue: ChoiceGenerationMode.practice)
    ChoiceGenerationMode? choiceGenerationMode,
    DateTime? nicknameChangedAt,
  }) = _MemberMeResponse;

  factory MemberMeResponse.fromJson(Map<String, dynamic> json) =>
      _$MemberMeResponseFromJson(json);
}
