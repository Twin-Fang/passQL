package com.passql.web.dto.notification;

import com.passql.member.entity.PushDeliveryFailure;

import java.time.LocalDateTime;
import java.util.UUID;

/** 발송 실패 기기 1건 (관리자 이력의 실패 목록): 회원, 토큰 끝 8자, 토큰 만료 여부, 사유, 시각 */
public record PushDeliveryFailureResponse(UUID memberUuid, String tokenSuffix, boolean isTokenExpired,
                                          String failureReason, LocalDateTime failedAt) {

    public static PushDeliveryFailureResponse from(PushDeliveryFailure failure) {
        return new PushDeliveryFailureResponse(failure.getMemberUuid(), failure.getTokenSuffix(),
                failure.getIsTokenExpired(), failure.getFailureReason(), failure.getCreatedAt());
    }
}
