package com.passql.member.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.constant.RefundCheckFailureReason;
import com.passql.member.constant.RefundCheckTriggerType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 스토어 환불 회수 확인 1회 실행 기록 (Play #984, App Store #1032): 스토어, 실행 방식, 시작·종료 시각, 단계별 건수, 실패 사유
 * 실패 사유 null = 끝까지 성공, 실패해도 그때까지의 건수는 남김
 * App Store: checkedOrderCount 조회한 거래 수, refundedOrderCount Apple 이 회수 표시한 거래 수 (voidedPurchaseCount 미사용 0)
 */
@Entity
@Table(name = "billing_refund_check_run",
    indexes = @Index(name = "idx_billing_refund_check_run_started_at", columnList = "started_at"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class BillingRefundCheckRun extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID billingRefundCheckRunUuid;

    // 확인한 스토어 (PLAY, APP_STORE)
    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private PurchaseStore store;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private RefundCheckTriggerType triggerType;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    private LocalDateTime finishedAt;

    // 취소 구매 목록(voidedpurchases)에서 받은 토큰 수
    @Column(nullable = false)
    private Integer voidedPurchaseCount = 0;

    // 주문 상태(orders.batchget)를 확인한 주문 수
    @Column(nullable = false)
    private Integer checkedOrderCount = 0;

    // 전액 환불(REFUNDED) 주문 수
    @Column(nullable = false)
    private Integer refundedOrderCount = 0;

    // 이번 실행에서 REVOKED 로 바꾼 구매 수 (두 단계 합)
    @Column(nullable = false)
    private Integer revokedCount = 0;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private RefundCheckFailureReason failureReason;

    /** 실행 시작 기록 (건수 0, 실패 사유 없음) */
    public static BillingRefundCheckRun start(PurchaseStore store, RefundCheckTriggerType triggerType,
                                              LocalDateTime startedAt) {
        BillingRefundCheckRun run = new BillingRefundCheckRun();
        run.store = store;
        run.triggerType = triggerType;
        run.startedAt = startedAt;
        return run;
    }

    /** 취소 구매 목록 단계 결과 */
    public void recordVoidedPurchaseStep(int voidedPurchaseCount, int revokedCount) {
        this.voidedPurchaseCount = voidedPurchaseCount;
        this.revokedCount += revokedCount;
    }

    /** 주문 상태 단계 결과 (확인 주문 수는 조회 전에 먼저 기록) */
    public void recordCheckedOrderCount(int checkedOrderCount) {
        this.checkedOrderCount = checkedOrderCount;
    }

    public void recordRefundedOrderStep(int refundedOrderCount, int revokedCount) {
        this.refundedOrderCount = refundedOrderCount;
        this.revokedCount += revokedCount;
    }

    /** 실패 사유 기록 (첫 실패만 유지) */
    public void recordFailure(RefundCheckFailureReason failureReason) {
        if (this.failureReason == null) {
            this.failureReason = failureReason;
        }
    }

    public void finish(LocalDateTime finishedAt) {
        this.finishedAt = finishedAt;
    }

    public boolean isSucceeded() {
        return failureReason == null;
    }
}
