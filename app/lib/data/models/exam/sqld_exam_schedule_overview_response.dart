import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam_schedule_response.dart';

part 'sqld_exam_schedule_overview_response.freezed.dart';
part 'sqld_exam_schedule_overview_response.g.dart';

/// GET /exam-schedules/sqld 응답 (#991): 그해 회차·다음 시험·마지막 수집 시각·공식 페이지
@freezed
class SqldExamScheduleOverviewResponse with _$SqldExamScheduleOverviewResponse {
  const factory SqldExamScheduleOverviewResponse({
    required int year,
    // 그해 회차 (회차 오름차순)
    @Default(<ExamScheduleResponse>[]) List<ExamScheduleResponse> schedules,
    // 오늘 이후 가장 가까운 시험 (연도 무관, 없으면 null)
    ExamScheduleResponse? nextSchedule,
    // 마지막 자동 수집 성공 시각 (KST, 없으면 null)
    DateTime? lastCollectedAt,
    // 공식 일정·접수 페이지 (데이터자격검정)
    String? officialScheduleUrl,
  }) = _SqldExamScheduleOverviewResponse;

  factory SqldExamScheduleOverviewResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$SqldExamScheduleOverviewResponseFromJson(json);
}
