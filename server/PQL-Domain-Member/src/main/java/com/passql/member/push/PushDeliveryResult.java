package com.passql.member.push;

/**
 * 토큰 1건 발송 결과
 * isTokenExpired: 앱 삭제·토큰 폐기로 다시 보낼 수 없는 토큰 (자동 삭제 대상)
 * failureReason: 실패 사유 (FCM 오류 코드 이름, 성공이면 null)
 */
public record PushDeliveryResult(String token, boolean isDelivered, boolean isTokenExpired, String failureReason) {

    // FCM 오류 코드를 알 수 없는 실패의 사유
    public static final String UNKNOWN_FAILURE_REASON = "UNKNOWN";

    public static PushDeliveryResult delivered(String token) {
        return new PushDeliveryResult(token, true, false, null);
    }

    public static PushDeliveryResult failed(String token, boolean isTokenExpired) {
        return failed(token, isTokenExpired, UNKNOWN_FAILURE_REASON);
    }

    public static PushDeliveryResult failed(String token, boolean isTokenExpired, String failureReason) {
        return new PushDeliveryResult(token, false, isTokenExpired, failureReason);
    }
}
