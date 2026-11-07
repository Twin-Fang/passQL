import 'package:freezed_annotation/freezed_annotation.dart';

part 'difficulty_stat.freezed.dart';
part 'difficulty_stat.g.dart';

/// 난이도(1~5) 한 단계 정답률: 전체 기록, 문제별 마지막 시도 (#909)
@freezed
class DifficultyStat with _$DifficultyStat {
  const factory DifficultyStat({
    required int difficulty,
    @Default(0) int solvedCount,
    @Default(0.0) double correctRate,
  }) = _DifficultyStat;

  factory DifficultyStat.fromJson(Map<String, dynamic> json) =>
      _$DifficultyStatFromJson(json);
}
