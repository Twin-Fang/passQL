package com.passql.member.constant;

/**
 * 환불 회수 확인 실패 사유 (billing_refund_check_run.failure_reason): 원인 종류만 저장, 토큰·응답 원문 저장 안 함
 */
public enum RefundCheckFailureReason {

    SERVICE_ACCOUNT_NOT_CONFIGURED("Play 서비스 계정 키 없음"),
    VOIDED_PURCHASE_LIST_FAILED("취소 구매 목록 조회 실패"),
    ORDER_LOOKUP_FAILED("주문 상태 조회 실패"),
    APP_STORE_KEY_NOT_CONFIGURED("App Store 인앱 결제 키 미설정"),
    TRANSACTION_LOOKUP_FAILED("App Store 거래 조회 실패"),
    UNEXPECTED_ERROR("예상하지 못한 오류");

    // 화면 표시 이름
    private final String label;

    RefundCheckFailureReason(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
