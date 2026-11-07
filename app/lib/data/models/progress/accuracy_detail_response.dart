import 'package:freezed_annotation/freezed_annotation.dart';

import 'difficulty_stat.dart';
import 'weekly_wrong_count.dart';

part 'accuracy_detail_response.freezed.dart';
part 'accuracy_detail_response.g.dart';

/// GET /progress/accuracy-detail 응답 (#909, 프로): 난이도별 정답률, 틀린 문제·다시 맞힌 문제 수, 최근 8주 남은 오답
@freezed
class AccuracyDetailResponse with _$AccuracyDetailResponse {
  const factory AccuracyDetailResponse({
    @Default([]) List<DifficultyStat> difficultyStats,
    @Default(0) int everWrongQuestionCount,
    @Default(0) int clearedWrongQuestionCount,
    @Default([]) List<WeeklyWrongCount> remainingWrongTrend,
  }) = _AccuracyDetailResponse;

  factory AccuracyDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$AccuracyDetailResponseFromJson(json);
}
