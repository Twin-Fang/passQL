import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_wrong_count.freezed.dart';
part 'weekly_wrong_count.g.dart';

/// 한 주(월요일 시작)가 끝난 시점의 남은 오답 수, 이번 주는 지금 기준 (#909)
@freezed
class WeeklyWrongCount with _$WeeklyWrongCount {
  const factory WeeklyWrongCount({
    required String weekStartDate,
    @Default(0) int remainingWrongCount,
  }) = _WeeklyWrongCount;

  factory WeeklyWrongCount.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWrongCountFromJson(json);
}
