import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_trend_report_response.freezed.dart';
part 'exam_trend_report_response.g.dart';

/// 출제 경향 화면 응답 (GET /exam-trends/latest, #523).
/// 항목마다 topicCode·latestTrendQuestionCount 로 해당 토픽 최신 경향 문제 풀기.
@freezed
class ExamTrendReportResponse with _$ExamTrendReportResponse {
  const factory ExamTrendReportResponse({
    required String title,
    required String basisDescription,
    required String updatedDate,
    required String summary,
    @Default(0) int latestTrendQuestionCount,
    @Default([]) List<ExamTrendSubjectShare> subjectShares,
    @Default([]) List<ExamTrendPattern> risingPatterns,
    @Default([]) List<ExamTrendConcept> frequentConcepts,
    @Default([]) List<String> studyTips,
    @Default([]) List<LatestTrendTopicCount> latestTrendTopics,
  }) = _ExamTrendReportResponse;

  factory ExamTrendReportResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamTrendReportResponseFromJson(json);
}

/// 과목별 비중 (문항 수, 백분율)
@freezed
class ExamTrendSubjectShare with _$ExamTrendSubjectShare {
  const factory ExamTrendSubjectShare({
    required String subjectName,
    required int questionCount,
    required int percent,
    required String description,
  }) = _ExamTrendSubjectShare;

  factory ExamTrendSubjectShare.fromJson(Map<String, dynamic> json) =>
      _$ExamTrendSubjectShareFromJson(json);
}

/// 최근 회차에서 늘어난 유형 1건
@freezed
class ExamTrendPattern with _$ExamTrendPattern {
  const factory ExamTrendPattern({
    required String title,
    required String description,
    required String examRoundsText,
    required String topicCode,
    // 최신 경향 문제 없는 토픽이면 null
    String? topicName,
    @Default(0) int latestTrendQuestionCount,
  }) = _ExamTrendPattern;

  factory ExamTrendPattern.fromJson(Map<String, dynamic> json) =>
      _$ExamTrendPatternFromJson(json);
}

/// 자주 나오는 개념 순위 1건
@freezed
class ExamTrendConcept with _$ExamTrendConcept {
  const factory ExamTrendConcept({
    required int rank,
    required String name,
    required String description,
    required String frequencyText,
    required String topicCode,
    // 최신 경향 문제 없는 토픽이면 null
    String? topicName,
    @Default(0) int latestTrendQuestionCount,
  }) = _ExamTrendConcept;

  factory ExamTrendConcept.fromJson(Map<String, dynamic> json) =>
      _$ExamTrendConceptFromJson(json);
}

/// 토픽별 최신 경향 문제 수 (GET /exam-trends/latest/topics)
@freezed
class LatestTrendTopicCount with _$LatestTrendTopicCount {
  const factory LatestTrendTopicCount({
    required String topicCode,
    required String topicName,
    @Default(0) int latestTrendQuestionCount,
  }) = _LatestTrendTopicCount;

  factory LatestTrendTopicCount.fromJson(Map<String, dynamic> json) =>
      _$LatestTrendTopicCountFromJson(json);
}
