package com.passql.meta.constant;

/**
 * 시험 일정 값 출처 2종 (이름이 exam_schedule.source 저장값, 변경 금지)
 */
public enum ExamScheduleSource {
    AUTO("자동"),
    MANUAL("수동");

    private final String label;

    ExamScheduleSource(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
