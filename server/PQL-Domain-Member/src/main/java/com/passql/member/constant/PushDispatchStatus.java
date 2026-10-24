package com.passql.member.constant;

/** 관리자 발송 진행 상태 3종: 예약 대기, 발송 시작, 예약 취소 */
public enum PushDispatchStatus {
    SCHEDULED("예약"),
    DISPATCHED("발송"),
    CANCELED("예약 취소");

    private final String label;

    PushDispatchStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
