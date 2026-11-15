// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../mock_exam/mock_exam_enums.dart';

part 'hardest_questions_response.freezed.dart';
part 'hardest_questions_response.g.dart';

/// 오답률 TOP 항목 (#1080): 회원별 첫 제출 기준 오답률
@freezed
class HardestQuestionItem with _$HardestQuestionItem {
  const factory HardestQuestionItem({
    required int rank,
    required String questionUuid,
    required String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    @Default(MockExamSubject.unknown)
    MockExamSubject subject,
    // 첫 제출 오답률 (%, 소수 1자리)
    @Default(0) double wrongRatePercent,
    // 첫 제출 회원 수
    @Default(0) int attemptCount,
  }) = _HardestQuestionItem;

  factory HardestQuestionItem.fromJson(Map<String, dynamic> json) =>
      _$HardestQuestionItemFromJson(json);
}

/// GET /questions/hardest 응답 (서버 1시간 집계)
@freezed
class HardestQuestionsResponse with _$HardestQuestionsResponse {
  const factory HardestQuestionsResponse({
    @Default([]) List<HardestQuestionItem> items,
    DateTime? aggregatedAt,
    // 목록에 넣는 최소 첫 제출 회원 수
    @Default(0) int minimumAttemptCount,
  }) = _HardestQuestionsResponse;

  factory HardestQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$HardestQuestionsResponseFromJson(json);
}
