package com.passql.application.billing.management;

/**
 * 실수령 단계별 금액 (통화 단위): 판매 총액, 환불, 순매출, 부가세, 수수료, 예상 실수령 + 건수
 * purchaseCount: 금액이 기록된 구매 수(회수 포함), revokedCount: 그중 회수
 */
public record PayoutAmounts(
    double grossAmount,
    double refundAmount,
    double netSalesAmount,
    double vatAmount,
    double feeAmount,
    double payoutAmount,
    long purchaseCount,
    long revokedCount) {
}
