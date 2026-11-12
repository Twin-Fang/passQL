package com.passql.application.billing;

import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckFailureReason;
import com.passql.member.constant.RefundCheckTriggerType;
import com.passql.member.entity.BillingRefundCheckRun;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 환불 회수 확인 실행 1건 (관리자 화면): 스토어, 실행 방식, 시각, 단계별 건수, 성공 여부, 실패 사유
 * failureReason·failureReasonLabel: 성공이면 null, App Store 는 checkedOrderCount 조회 거래·refundedOrderCount Apple 회수 표시 거래
 */
public record RefundCheckRunResponse(
    UUID billingRefundCheckRunUuid,
    PurchaseStore store,
    RefundCheckTriggerType triggerType,
    String triggerTypeLabel,
    LocalDateTime startedAt,
    LocalDateTime finishedAt,
    int voidedPurchaseCount,
    int checkedOrderCount,
    int refundedOrderCount,
    int revokedCount,
    Boolean isSucceeded,
    RefundCheckFailureReason failureReason,
    String failureReasonLabel) {

    /** 실행 기록 엔티티 > 응답 */
    static RefundCheckRunResponse from(BillingRefundCheckRun run) {
        RefundCheckFailureReason failureReason = run.getFailureReason();
        return new RefundCheckRunResponse(run.getBillingRefundCheckRunUuid(), run.getStore(), run.getTriggerType(),
            run.getTriggerType().getLabel(), run.getStartedAt(), run.getFinishedAt(), run.getVoidedPurchaseCount(),
            run.getCheckedOrderCount(), run.getRefundedOrderCount(), run.getRevokedCount(), run.isSucceeded(),
            failureReason, failureReason == null ? null : failureReason.getLabel());
    }
}
