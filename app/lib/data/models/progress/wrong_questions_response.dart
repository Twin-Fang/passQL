import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _WrongQuestionItem;

  factory WrongQuestionItem.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionItemFromJson(json);
}

/// GET /progress/wrong-questions 응답.
@freezed
class WrongQuestionsResponse with _$WrongQuestionsResponse {
  const factory WrongQuestionsResponse({
    @Default([]) List<WrongQuestionItem> items,
    @Default(0) int totalCount,
  }) = _WrongQuestionsResponse;

  factory WrongQuestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionsResponseFromJson(json);
}
