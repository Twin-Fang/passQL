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
    // 로그인 제공자 서버 값 (GOOGLE, APPLE, KAKAO, NAVER, GITHUB): 탈퇴 연결 해제 분기 기준
    String? authProvider,
    // 제공자 회원 식별자 (GOOGLE·APPLE 은 Firebase uid): 탈퇴 재인증 계정 대조 기준
    String? providerUserId,
    // 가입 시각 (KST): 계정 화면 가입일 (#816)
    DateTime? createdAt,
    // 가린 이메일 (예: sq***@kakao.com, 이메일 없는 제공자면 null, #816)
    String? maskedEmail,
    // 회원 번호 표시값 (PQL- + UUID 앞 8자리 대문자): 문의 때 회원 확인 (#816)
    String? memberCode,
  }) = _MemberMeResponse;

  factory MemberMeResponse.fromJson(Map<String, dynamic> json) =>
      _$MemberMeResponseFromJson(json);
}
