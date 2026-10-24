package com.passql.application.statistics.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * 구독·매출 현황: 지금 프로 회원·만료 임박, 구간 구매·회수, 상품별 판매, 금액, 전환율, 일별 구매
 * expiringSoonDayCount: 만료 임박 기준 일수, previous*: 직전 기간 값 (비교용)
 * purchasedMemberRatePercent: 현재 전체 회원 중 구매 이력 있는 비율, signupConversionRatePercent: 구간 가입자 중 구매 이력 있는 비율
 */
public record SubscriptionSummaryResponse(
        LocalDate fromDate,
        LocalDate toDate,
        long activeProMemberCount,
        long expiringSoonMemberCount,
        int expiringSoonDayCount,
        long purchaseCount,
        long previousPurchaseCount,
        long revokedPurchaseCount,
        long previousRevokedPurchaseCount,
        List<ProductSales> productSales,
        List<CurrencyAmount> amounts,
        long verifiedPurchaseWithoutAmountCount,
        long signupCount,
        long convertedSignupCount,
        double signupConversionRatePercent,
        long totalMemberCount,
        long purchasedMemberCount,
        double purchasedMemberRatePercent,
        List<String> dailyLabels,
        List<Long> dailyPurchaseCounts
) {

    /** 상품·스토어별 판매 (soldCount 회수 포함) */
    public record ProductSales(String productId, String store, long soldCount, long revokedCount) {}

    /** 통화별 금액 (amount = micros / 1,000,000) */
    public record CurrencyAmount(String currencyCode, double amount, long purchaseCount) {}
}
