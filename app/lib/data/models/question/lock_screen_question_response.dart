import 'package:freezed_annotation/freezed_annotation.dart';

part 'lock_screen_question_response.freezed.dart';
part 'lock_screen_question_response.g.dart';

/// 잠금화면 문제 응답 (GET /questions/lockscreen 200): READY 선택지 세트가 보장된 문제
@freezed
class LockScreenQuestionResponse with _$LockScreenQuestionResponse {
  const factory LockScreenQuestionResponse({required String questionUuid}) =
      _LockScreenQuestionResponse;

  factory LockScreenQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$LockScreenQuestionResponseFromJson(json);
}

/// 잠금화면 문제 응답 본문 > questionUuid (204·빈 본문이면 null)
String? lockScreenQuestionUuidOf(Object? responseBody) {
  if (responseBody is! Map<String, dynamic>) return null;
  return LockScreenQuestionResponse.fromJson(responseBody).questionUuid;
}
