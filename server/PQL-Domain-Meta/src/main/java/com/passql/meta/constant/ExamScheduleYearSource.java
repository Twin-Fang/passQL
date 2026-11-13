package com.passql.meta.constant;

/**
 * 공식 일정 표의 연도 결정 근거 4종 (우선순위 순, 이름이 exam_schedule_sync_run.year_source 저장값)
 * HEADING "2026년도 일정" 제목 > CAPTION 표 caption "2026년" > KNOWN_ROUND 이미 저장된 같은 회차의 연도 > REFERENCE_DATE 수집 날짜 기준 보정
 */
public enum ExamScheduleYearSource {
    HEADING,
    CAPTION,
    KNOWN_ROUND,
    REFERENCE_DATE
}
