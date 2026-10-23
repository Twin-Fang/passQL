package com.passql.application.billing;

import jakarta.validation.constraints.NotBlank;

/**
 * App Store Server Notifications V2 요청 본문 (Apple 이 보내는 형태 그대로)
 *
 * @param signedPayload 알림 JWS (Apple 서명, 로그 금지)
 */
public record AppStoreNotificationRequest(
    @NotBlank String signedPayload
) {
}
