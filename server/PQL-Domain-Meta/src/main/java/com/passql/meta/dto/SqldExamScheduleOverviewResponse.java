package com.passql.meta.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 앱 시험 일정 화면용 SQLD 한 해 일정 (#991)
 *
 * @param year                 조회 연도 (시험일 기준)
 * @param schedules            그해 회차 (회차 오름차순, 단계는 서버 계산)
 * @param nextSchedule         오늘 이후 가장 가까운 시험 (연도 무관, 없으면 null)
 * @param lastCollectedAt      마지막 자동 수집 성공 시각 (KST, 없으면 null)
 * @param officialScheduleUrl  공식 일정·접수 페이지
 */
public record SqldExamScheduleOverviewResponse(
        int year,
        List<ExamScheduleResponse> schedules,
        ExamScheduleResponse nextSchedule,
        LocalDateTime lastCollectedAt,
        String officialScheduleUrl
) {
}
