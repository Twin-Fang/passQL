package com.passql.application.billing;

/**
 * 서명 검증된 App Store 서버 알림 V2 (Apple 라이브러리 타입과 분리)
 *
 * @param notificationUuid 알림 고유 ID (Apple 재전송 시 같은 값)
 * @param notificationType 알림 유형 원문 (예: REFUND, REVOKE, TEST)
 * @param subtype          알림 하위 유형 원문 (없으면 null)
 * @param transaction      알림에 담긴 거래 (거래 없는 알림은 null)
 */
public record AppStoreNotification(String notificationUuid, String notificationType, String subtype,
                                   AppStoreTransaction transaction) {
}
