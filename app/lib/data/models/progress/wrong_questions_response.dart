// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../mock_exam/mock_exam_enums.dart';

part 'wrong_questions_response.freezed.dart';
part 'wrong_questions_response.g.dart';

/// 오답 노트 항목. 목록 미리보기용이라 문제 지문은 앞부분만 내려온다.
@freezed
class WrongQuestionItem with _$WrongQuestionItem {
  const factory WrongQuestionItem({
    required String questionUuid,
    required String stemPreview,
    String? topicName,
    DateTime? lastWrongAt,
    // 틀린 횟수 (구버전 서버면 0 > 표시 안 함, #1081)
    @Default(0) int wrongCount,
    // 정리됨: 그 문제 최신 제출이 정답 (#1081)
    @Default(false) bool isResolved,
    // 과목 (토픽 data_modeling 이면 1과목, #1081)
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    @Default(MockExamSubject.unknown)
    MockExamSubject subject,
  }) = _WrongQuestionItem;

  factory WrongQuestionItem.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionItemFromJson(json);
}

/// GET /progress/wrong-questions 응답. totalCount 는 필터 적용 전체 수
@freezed
class WrongQuestionsResponse with _$WrongQuestionsResponse {
  const factory WrongQuestionsResponse({
    @Default([]) List<WrongQuestionItem> items,
    @Default(0) int totalCount,
  }) = _WrongQuestionsResponse;

  factory WrongQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionsResponseFromJson(json);
}

/// GET /progress/wrong-questions/retry-set 응답: 정리 안 된 오답 많이 틀린 순 최대 10개 (#1081)
@freezed
class WrongQuestionRetrySetResponse with _$WrongQuestionRetrySetResponse {
  const factory WrongQuestionRetrySetResponse({
    @Default([]) List<String> questionUuids,
  }) = _WrongQuestionRetrySetResponse;

  factory WrongQuestionRetrySetResponse.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionRetrySetResponseFromJson(json);
}
