import 'package:freezed_annotation/freezed_annotation.dart';

import 'heatmap_response.dart';

part 'study_pattern_response.freezed.dart';
part 'study_pattern_response.g.dart';

/// GET /progress/study-pattern 응답 (#909, 무료). 풀이 수는 제출 횟수 기준, 날짜·시각은 KST.
/// dailyRecords: 오늘 포함 최근 [dailyWindowDays]일(오래된 날 먼저, 0 채움) + 서버 요약(앞 2주 대비 정답률 변화, 비교 불가면 null)
/// weekdayAttemptCounts: 월(0)~일(6), hourAttemptCounts: 0~23시 (최근 [patternWindowDays]일),
/// 가장 많은 요일·시각은 풀이가 [minimumPatternAttemptCount] 미만이면 null
@freezed
class StudyPatternResponse with _$StudyPatternResponse {
  const factory StudyPatternResponse({
    @Default(28) int dailyWindowDays,
    @Default([]) List<HeatmapEntry> dailyRecords,
    @Default(0) int recentAttemptCount,
    @Default(0) int recentCorrectCount,
    @Default(0) int recentStudyDayCount,
    int? accuracyChangePoints,
    @Default(84) int patternWindowDays,
    @Default([]) List<int> weekdayAttemptCounts,
    @Default([]) List<int> hourAttemptCounts,
    @Default(0) int patternAttemptCount,
    @Default(10) int minimumPatternAttemptCount,
    int? busiestWeekdayIndex,
    int? busiestHour,
    @Default(0) int totalStudyDayCount,
    @Default(0) int longestStreakDays,
  }) = _StudyPatternResponse;

  factory StudyPatternResponse.fromJson(Map<String, dynamic> json) =>
      _$StudyPatternResponseFromJson(json);
}
