package com.passql.member.push;

/**
 * 토큰 1건 발송 결과
 * isTokenExpired: 앱 삭제·토큰 폐기로 다시 보낼 수 없는 토큰 (자동 삭제 대상)
 */
public record PushDeliveryResult(String token, boolean isDelivered, boolean isTokenExpired) {

    public static PushDeliveryResult delivered(String token) {
        return new PushDeliveryResult(token, true, false);
    }

    public static PushDeliveryResult failed(String token, boolean isTokenExpired) {
        return new PushDeliveryResult(token, false, isTokenExpired);
    }
}
