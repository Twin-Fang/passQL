package com.passql.application.billing.management;

import java.time.LocalDate;
import java.util.List;

/**
 * 실수령액 대시보드 (#1032): 기간(구매 시각 기준, 테스트 계정 제외), 설정, 통화별 합계, 스토어별·상품별 분해, 금액 미확인 건수, 월별 추이
 * fromDate null = 전체 기간, 금액이 없는 구매는 합계에서 빠지고 amountUnknownCount 로만 셈
 */
public record BillingPayoutResponse(
    LocalDate fromDate,
    LocalDate toDate,
    PayoutSettings settings,
    List<CurrencyPayout> currencyTotals,
    List<StorePayout> storePayouts,
    List<ProductPayout> productPayouts,
    long amountUnknownCount,
    List<MonthlyPayout> monthlyPayouts) {

    /** 통화별 전체 합계 */
    public record CurrencyPayout(String currencyCode, PayoutAmounts amounts) {}

    /** 스토어·통화별 (feeRatePercent·vatRatePercent: 적용한 값) */
    public record StorePayout(String store, String currencyCode, double feeRatePercent, double vatRatePercent,
                              PayoutAmounts amounts) {}

    /** 스토어·상품·통화별 */
    public record ProductPayout(String store, String productId, String currencyCode, PayoutAmounts amounts) {}

    /** 원화 월별 추이 (month: yyyy-MM, 최근 12개월, 빈 달 0) */
    public record MonthlyPayout(String month, double grossAmount, double refundAmount, double payoutAmount) {}
}
