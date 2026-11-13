package com.passql.meta.constant;

/**
 * 시험 일정 수집 실패 사유 9종 (이름이 exam_schedule_sync_run.failure_reason 저장값, 변경 금지)
 * 실패하면 일정은 덮어쓰지 않고 사유·원문 일부만 기록
 */
public enum ExamScheduleSyncFailureReason {
    FETCH_FAILED("공식 페이지를 가져오지 못함"),
    TABLE_NOT_FOUND("일정 표(table_schdule_all)가 없음"),
    COLUMN_COUNT_MISMATCH("열 개수가 예상(9열)과 다름"),
    SQLD_ROWS_NOT_FOUND("SQL 개발자 행이 없음"),
    DATE_PARSE_FAILED("날짜를 해석하지 못함"),
    DATE_ORDER_INVALID("회차 안 날짜 순서가 이상함"),
    ROUND_ORDER_INVALID("회차·시험일 순서가 이상함"),
    ROUND_DECREASED("회차가 지난 성공 수집보다 줄어듦"),
    UNEXPECTED_ERROR("예상하지 못한 오류");

    private final String label;

    ExamScheduleSyncFailureReason(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
