package com.passql.member.constant;

/**
 * 환불 회수 확인 실행 방식 (billing_refund_check_run.trigger_type): 자동 스케줄, 관리자 수동
 */
public enum RefundCheckTriggerType {

    SCHEDULED("자동"),
    ADMIN("수동");

    // 화면 표시 이름
    private final String label;

    RefundCheckTriggerType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
