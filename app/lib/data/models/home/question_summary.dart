import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_summary.freezed.dart';
part 'question_summary.g.dart';

/// 오늘의 문제 / 추천 문제 / 문제 목록 리스트에서 사용하는 축약 문제 모델.
/// difficulty: 1(쉬움), 2(보통), 3(어려움)
@freezed
class QuestionSummary with _$QuestionSummary {
  const factory QuestionSummary({
    required String questionUuid,
    String? topicCode,
    String? topicName,
    String? stemPreview,
    int? difficulty,
    String? executionMode,
    String? createdAt,
    // 최신 출제 경향 반영 문제 ('최신 경향' 배지, 구버전 서버면 false, #523)
    @Default(false) bool isLatestTrend,
  }) = _QuestionSummary;

  factory QuestionSummary.fromJson(Map<String, dynamic> json) =>
      _$QuestionSummaryFromJson(json);
}
