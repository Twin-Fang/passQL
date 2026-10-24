package com.passql.application.statistics;

import com.passql.application.statistics.AdminSubscriptionQueryRepository.ConversionRow;
import com.passql.application.statistics.AdminSubscriptionQueryRepository.DailyCountRow;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse.CurrencyAmount;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse.ProductSales;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 관리자 구독·매출 현황: 프로 회원·만료 임박 > 구간 구매·회수(직전 기간 비교) > 상품별 판매 > 금액 > 전환율 > 일별 구매
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminSubscriptionService {

    // 만료 임박 기준 (일)
    static final int EXPIRING_SOON_DAY_COUNT = 7;
    // 금액 micros > 통화 단위 (x 1,000,000)
    private static final double MICROS_PER_CURRENCY_UNIT = 1_000_000d;
    private static final DateTimeFormatter DAILY_LABEL_FORMATTER = DateTimeFormatter.ofPattern("MM/dd");

    private final AdminSubscriptionQueryRepository subscriptionQueryRepository;

    public SubscriptionSummaryResponse getSummary(StatisticsPeriod period) {
        LocalDateTime now = LocalDateTime.now();
        StatisticsPeriod previousPeriod = period.getPreviousPeriod();
        LocalDateTime start = period.getStartInclusive();
        LocalDateTime end = period.getEndExclusive();

        // 구간 가입자 전환, 현재 전체 회원 전환
        ConversionRow signupConversion = subscriptionQueryRepository.countSignupConversion(start, end);
        ConversionRow allMemberConversion = subscriptionQueryRepository.countAllMemberConversion();

        // 일별 구매 (빈 날 0 채움)
        Map<LocalDate, Long> purchaseCountByDate = subscriptionQueryRepository.countPurchasesByDay(start, end).stream()
                .collect(Collectors.toMap(DailyCountRow::date, DailyCountRow::count));
        List<LocalDate> dates = period.fromDate().datesUntil(period.toDate().plusDays(1)).toList();

        return new SubscriptionSummaryResponse(
                period.fromDate(),
                period.toDate(),
                subscriptionQueryRepository.countActiveProMembers(now),
                subscriptionQueryRepository.countProMembersExpiringBetween(now, now.plusDays(EXPIRING_SOON_DAY_COUNT)),
                EXPIRING_SOON_DAY_COUNT,
                subscriptionQueryRepository.countPurchases(start, end),
                subscriptionQueryRepository.countPurchases(previousPeriod.getStartInclusive(), previousPeriod.getEndExclusive()),
                subscriptionQueryRepository.countRevokedPurchases(start, end),
                subscriptionQueryRepository.countRevokedPurchases(previousPeriod.getStartInclusive(), previousPeriod.getEndExclusive()),
                subscriptionQueryRepository.countSalesByProduct(start, end).stream()
                        .map(row -> new ProductSales(row.productId(), row.store(), row.soldCount(), row.revokedCount()))
                        .toList(),
                subscriptionQueryRepository.sumVerifiedAmountByCurrency(start, end).stream()
                        .map(row -> new CurrencyAmount(row.currencyCode(), row.amountMicros() / MICROS_PER_CURRENCY_UNIT, row.purchaseCount()))
                        .toList(),
                subscriptionQueryRepository.countVerifiedPurchasesWithoutAmount(start, end),
                signupConversion.memberCount(),
                signupConversion.purchasedMemberCount(),
                StatisticsNumbers.toPercent(signupConversion.purchasedMemberCount(), signupConversion.memberCount()),
                allMemberConversion.memberCount(),
                allMemberConversion.purchasedMemberCount(),
                StatisticsNumbers.toPercent(allMemberConversion.purchasedMemberCount(), allMemberConversion.memberCount()),
                dates.stream().map(DAILY_LABEL_FORMATTER::format).toList(),
                dates.stream().map(date -> purchaseCountByDate.getOrDefault(date, 0L)).toList());
    }
}
