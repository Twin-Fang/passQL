package com.passql.member.constant;

/**
 * App Store 서버 알림 처리 결과 (app_store_notification_log.handling_result, #1032)
 * 환불 요청 3종: CONSUMPTION_REQUEST 수신 > 접수만, 소비 정보 응답 성공, 응답 실패
 */
public enum AppStoreNotificationResult {

    REVOKED("회수"),
    NO_VERIFIED_PURCHASE("기록 없음·이미 회수"),
    IGNORED("무시"),
    VERIFICATION_FAILED("서명 검증 실패"),
    REFUND_REQUESTED("환불 요청 접수"),
    CONSUMPTION_SENT("환불 요청 접수 · 소비 정보 보냄"),
    CONSUMPTION_FAILED("환불 요청 접수 · 소비 정보 실패");

    // 화면 표시 이름
    private final String label;

    AppStoreNotificationResult(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 환불 요청(CONSUMPTION_REQUEST) 결과 3종 여부 */
    public boolean isRefundRequest() {
        return this == REFUND_REQUESTED || this == CONSUMPTION_SENT || this == CONSUMPTION_FAILED;
    }
}
