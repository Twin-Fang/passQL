import 'package:freezed_annotation/freezed_annotation.dart';

part 'submit_request.freezed.dart';
part 'submit_request.g.dart';

@freezed
class SubmitRequest with _$SubmitRequest {
  const factory SubmitRequest({
    required String choiceSetId,
    required String selectedChoiceKey,
    // 연습/챕터 세션 단위 AI 코멘트 집계용. 단건 풀이면 null.
    String? sessionUuid,
  }) = _SubmitRequest;
  factory SubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitRequestFromJson(json);
}
