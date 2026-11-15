import 'package:freezed_annotation/freezed_annotation.dart';

part 'ox_quiz_models.freezed.dart';
part 'ox_quiz_models.g.dart';

/// OX 카드 1장 (#1083): 개념 바로 확인 문장 + 정답·이유 (앱이 바로 채점)
@freezed
class OxCardItem with _$OxCardItem {
  const factory OxCardItem({
    required String cardKey,
    @Default('') String conceptUuid,
    @Default('') String conceptTitle,
    @Default('') String topicName,
    required String statement,
    // 정답 (true: O, false: X)
    @Default(false) bool isTrue,
    @Default('') String reason,
    // 현재 Leitner 칸 (1~5), 처음 보는 카드면 null
    int? box,
  }) = _OxCardItem;

  factory OxCardItem.fromJson(Map<String, dynamic> json) =>
      _$OxCardItemFromJson(json);
}

/// GET /ox/cards 응답: 기한 지난 복습 카드 먼저 > 새 카드, 오늘 진행 함께
@freezed
class OxCardSetResponse with _$OxCardSetResponse {
  const factory OxCardSetResponse({
    @Default([]) List<OxCardItem> cards,
    @Default(0) int dueCardCount,
    @Default(0) int newCardCount,
    // 오늘 푼 카드 수 (같은 카드 여러 번은 1장)
    @Default(0) int todayAnsweredCount,
    @Default(0) int dailyGoalCount,
    // 잠긴 단원(무료)에 카드가 더 있음
    @Default(false) bool hasLockedTopics,
  }) = _OxCardSetResponse;

  factory OxCardSetResponse.fromJson(Map<String, dynamic> json) =>
      _$OxCardSetResponseFromJson(json);
}

/// POST /ox/answers 요청: 카드 키 + 맞혔는지
@freezed
class OxAnswerRequest with _$OxAnswerRequest {
  const factory OxAnswerRequest({
    required String cardKey,
    required bool isCorrect,
  }) = _OxAnswerRequest;

  factory OxAnswerRequest.fromJson(Map<String, dynamic> json) =>
      _$OxAnswerRequestFromJson(json);
}

/// POST /ox/answers 응답: 갱신된 칸·다음 출제일·오늘 푼 수
@freezed
class OxAnswerResponse with _$OxAnswerResponse {
  const factory OxAnswerResponse({
    required String cardKey,
    @Default(1) int box,
    DateTime? nextReviewDate,
    @Default(0) int correctStreak,
    @Default(0) int todayAnsweredCount,
  }) = _OxAnswerResponse;

  factory OxAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$OxAnswerResponseFromJson(json);
}
