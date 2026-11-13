package com.passql.application.billing.management;

/**
 * 예상 실수령액 계산 (#1032): 판매 총액 − 환불 = 순매출 > 부가세(판매가 포함분) 제외 > 스토어 수수료 제외 = 예상 실수령
 * 부가세 = 순매출 x 세율 / (100 + 세율), 수수료 = (순매출 − 부가세) x 수수료율 / 100 (스토어 정산 방식 가정)
 */
public final class StorePayoutCalculator {

    // 금액 micros > 통화 단위 (x 1,000,000)
    static final double MICROS_PER_CURRENCY_UNIT = 1_000_000d;
    private static final double PERCENT_BASE = 100d;

    private StorePayoutCalculator() {
    }

    /**
     * 판매·환불 합계(micros) > 단계별 금액
     * vatRatePercent: 원화 외 통화는 0 (나라별 세금을 모름), feeRatePercent: 스토어 수수료율
     */
    public static PayoutAmounts calculate(long grossAmountMicros, long refundAmountMicros, long purchaseCount,
                                          long revokedCount, double feeRatePercent, double vatRatePercent) {
        double grossAmount = grossAmountMicros / MICROS_PER_CURRENCY_UNIT;
        double refundAmount = refundAmountMicros / MICROS_PER_CURRENCY_UNIT;
        double netSalesAmount = grossAmount - refundAmount;
        double vatAmount = netSalesAmount * vatRatePercent / (PERCENT_BASE + vatRatePercent);
        double feeAmount = (netSalesAmount - vatAmount) * feeRatePercent / PERCENT_BASE;
        double payoutAmount = netSalesAmount - vatAmount - feeAmount;
        return new PayoutAmounts(grossAmount, refundAmount, netSalesAmount, vatAmount, feeAmount, payoutAmount,
            purchaseCount, revokedCount);
    }

    /** 두 계산 결과 합 (스토어별 > 통화 합계) */
    public static PayoutAmounts sum(PayoutAmounts first, PayoutAmounts second) {
        return new PayoutAmounts(first.grossAmount() + second.grossAmount(), first.refundAmount() + second.refundAmount(),
            first.netSalesAmount() + second.netSalesAmount(), first.vatAmount() + second.vatAmount(),
            first.feeAmount() + second.feeAmount(), first.payoutAmount() + second.payoutAmount(),
            first.purchaseCount() + second.purchaseCount(), first.revokedCount() + second.revokedCount());
    }

    /** 빈 합계 (합산 시작값) */
    public static PayoutAmounts empty() {
        return new PayoutAmounts(0, 0, 0, 0, 0, 0, 0, 0);
    }
}
