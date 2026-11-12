package com.passql.meta.constant;

/**
 * 시험 일정 수집 실행 방식 2종 (이름이 exam_schedule_sync_run.trigger_type 저장값, 변경 금지)
 */
public enum ExamScheduleSyncTrigger {
    SCHEDULED("자동"),
    ADMIN("관리자");

    private final String label;

    ExamScheduleSyncTrigger(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
