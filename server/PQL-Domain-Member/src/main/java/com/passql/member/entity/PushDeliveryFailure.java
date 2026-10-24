package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

/**
 * 발송 실패 기기 1건: 어느 발송에서, 어느 회원 기기가, 왜 실패했는지
 * 토큰은 끝 8자만 저장 (식별용, 전체 토큰은 보관하지 않음)
 */
@Entity
@Table(
    name = "push_delivery_failure",
    indexes = @Index(name = "idx_push_delivery_failure_history", columnList = "push_send_history_uuid")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PushDeliveryFailure extends BaseEntity {

    // 토큰 식별용 끝 글자 수
    public static final int TOKEN_SUFFIX_LENGTH = 8;
    // 실패 사유 최대 길이 (문자 수)
    public static final int MAX_FAILURE_REASON_LENGTH = 100;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID pushDeliveryFailureUuid;

    @Column(nullable = false)
    private UUID pushSendHistoryUuid;

    @Column(nullable = false)
    private UUID memberUuid;

    @Column(length = 16, nullable = false)
    private String tokenSuffix;

    // 앱 삭제·토큰 폐기로 토큰을 지운 실패
    @Column(nullable = false)
    private Boolean isTokenExpired;

    @Column(length = MAX_FAILURE_REASON_LENGTH, nullable = false)
    private String failureReason;

    public static PushDeliveryFailure of(UUID pushSendHistoryUuid, UUID memberUuid, String token,
                                         boolean isTokenExpired, String failureReason) {
        PushDeliveryFailure failure = new PushDeliveryFailure();
        failure.pushSendHistoryUuid = pushSendHistoryUuid;
        failure.memberUuid = memberUuid;
        failure.tokenSuffix = token.length() <= TOKEN_SUFFIX_LENGTH ? token : token.substring(token.length() - TOKEN_SUFFIX_LENGTH);
        failure.isTokenExpired = isTokenExpired;
        failure.failureReason = failureReason.length() <= MAX_FAILURE_REASON_LENGTH
                ? failureReason : failureReason.substring(0, MAX_FAILURE_REASON_LENGTH);
        return failure;
    }
}
