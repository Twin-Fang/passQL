package com.passql.application.billing.management;

import com.passql.application.billing.management.BillingPayoutQueryRepository.MonthlyAmountRow;
import com.passql.application.billing.management.BillingPayoutQueryRepository.ProductAmountRow;
import com.passql.application.billing.management.BillingPayoutResponse.CurrencyPayout;
import com.passql.application.billing.management.BillingPayoutResponse.MonthlyPayout;
import com.passql.application.billing.management.BillingPayoutResponse.ProductPayout;
import com.passql.application.billing.management.BillingPayoutResponse.StorePayout;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.PurchaseStore;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 관리자 실수령액 (#1032): 기간 해석 > 스토어·상품·통화별 합계 > 스토어 수수료·원화 부가세 적용 > 통화 합계 > 원화 월별 추이
 * 설정(수수료율·부가세율)은 app_setting, 저장은 AppSettingService.save 경유 (감사 로그·캐시 공통)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BillingPayoutService {

    // 부가세를 적용하는 통화 (원화 판매가는 부가세 포함, 그 외 통화는 나라별 세금을 몰라 0)
    static final String VAT_CURRENCY_CODE = "KRW";
    // 설정 기본값 (%): Play·App Store 수수료 15, 원화 부가세 10
    static final double DEFAULT_FEE_RATE_PERCENT = 15d;
    static final double DEFAULT_KRW_VAT_RATE_PERCENT = 10d;
    // 월별 추이 개월 수 (이번 달 포함)
    static final int MONTHLY_TREND_MONTH_COUNT = 12;
    // 전체 기간 시작 (서비스 출시 전 날짜, 구매 기록은 이후에만 있음)
    static final LocalDate ALL_TIME_FROM_DATE = LocalDate.of(2026, 1, 1);

    private final BillingPayoutQueryRepository billingPayoutQueryRepository;
    private final AppSettingService appSettingService;

    /** 실수령액 대시보드: fromDate null = 전체, toDate null·미래 = 오늘 */
    public BillingPayoutResponse getPayout(LocalDate requestedFromDate, LocalDate requestedToDate) {
        LocalDate today = LocalDate.now(ServiceTimeZone.ZONE);
        LocalDate toDate = requestedToDate == null || requestedToDate.isAfter(today) ? today : requestedToDate;
        LocalDate fromDate = requestedFromDate == null ? ALL_TIME_FROM_DATE : requestedFromDate;
        if (fromDate.isAfter(toDate)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "from must be on or before to");
        }
        LocalDateTime start = fromDate.atStartOfDay();
        LocalDateTime end = toDate.plusDays(1).atStartOfDay();
        PayoutSettings settings = getSettings();

        // 상품별 > 스토어별 > 통화별 합산 (입력 정렬: 통화 > 스토어 > 상품)
        List<ProductPayout> productPayouts = new ArrayList<>();
        Map<String, StorePayout> storePayoutByKey = new LinkedHashMap<>();
        Map<String, PayoutAmounts> totalByCurrency = new LinkedHashMap<>();
        for (ProductAmountRow row : billingPayoutQueryRepository.sumAmountByStoreProductCurrency(start, end)) {
            double feeRatePercent = toFeeRatePercent(settings, row.store());
            double vatRatePercent = toVatRatePercent(settings, row.currencyCode());
            PayoutAmounts amounts = StorePayoutCalculator.calculate(row.grossAmountMicros(), row.refundAmountMicros(),
                row.purchaseCount(), row.revokedCount(), feeRatePercent, vatRatePercent);
            productPayouts.add(new ProductPayout(row.store(), row.productId(), row.currencyCode(), amounts));
            storePayoutByKey.merge(row.store() + "|" + row.currencyCode(),
                new StorePayout(row.store(), row.currencyCode(), feeRatePercent, vatRatePercent, amounts),
                (existing, added) -> new StorePayout(existing.store(), existing.currencyCode(), feeRatePercent,
                    vatRatePercent, StorePayoutCalculator.sum(existing.amounts(), added.amounts())));
            totalByCurrency.merge(row.currencyCode(), amounts, StorePayoutCalculator::sum);
        }

        return new BillingPayoutResponse(requestedFromDate == null ? null : fromDate, toDate, settings,
            totalByCurrency.entrySet().stream().map(entry -> new CurrencyPayout(entry.getKey(), entry.getValue())).toList(),
            List.copyOf(storePayoutByKey.values()),
            productPayouts,
            billingPayoutQueryRepository.countPurchasesWithoutAmount(start, end),
            buildMonthlyPayouts(settings, today));
    }

    /** 현재 설정값 (행 없음·형식 오류는 기본값) */
    public PayoutSettings getSettings() {
        return new PayoutSettings(
            appSettingService.getDoubleOrDefault(AppSettingKeys.BILLING_FEE_RATE_PERCENT_PLAY, DEFAULT_FEE_RATE_PERCENT),
            appSettingService.getDoubleOrDefault(AppSettingKeys.BILLING_FEE_RATE_PERCENT_APP_STORE, DEFAULT_FEE_RATE_PERCENT),
            appSettingService.getDoubleOrDefault(AppSettingKeys.BILLING_KRW_VAT_RATE_PERCENT, DEFAULT_KRW_VAT_RATE_PERCENT));
    }

    /** 설정 저장 3개 (값 범위는 요청 검증, 저장은 공통 설정 저장 경로) */
    @Transactional
    public PayoutSettings saveSettings(PayoutSettings settings) {
        appSettingService.save(AppSettingKeys.BILLING_FEE_RATE_PERCENT_PLAY, toSettingText(settings.playFeeRatePercent()));
        appSettingService.save(AppSettingKeys.BILLING_FEE_RATE_PERCENT_APP_STORE, toSettingText(settings.appStoreFeeRatePercent()));
        appSettingService.save(AppSettingKeys.BILLING_KRW_VAT_RATE_PERCENT, toSettingText(settings.krwVatRatePercent()));
        return settings;
    }

    /** 원화 최근 12개월: 월·스토어별 합계 > 스토어 수수료 적용 > 월 합산 (빈 달 0) */
    private List<MonthlyPayout> buildMonthlyPayouts(PayoutSettings settings, LocalDate today) {
        YearMonth firstMonth = YearMonth.from(today).minusMonths(MONTHLY_TREND_MONTH_COUNT - 1L);
        Map<String, PayoutAmounts> amountsByMonth = new LinkedHashMap<>();
        for (int monthIndex = 0; monthIndex < MONTHLY_TREND_MONTH_COUNT; monthIndex++) {
            amountsByMonth.put(firstMonth.plusMonths(monthIndex).toString(), StorePayoutCalculator.empty());
        }
        List<MonthlyAmountRow> rows = billingPayoutQueryRepository.sumMonthlyAmountByStore(VAT_CURRENCY_CODE,
            firstMonth.atDay(1).atStartOfDay(), today.plusDays(1).atStartOfDay());
        for (MonthlyAmountRow row : rows) {
            PayoutAmounts amounts = StorePayoutCalculator.calculate(row.grossAmountMicros(), row.refundAmountMicros(),
                row.purchaseCount(), row.revokedCount(), toFeeRatePercent(settings, row.store()), settings.krwVatRatePercent());
            amountsByMonth.computeIfPresent(row.month(), (month, existing) -> StorePayoutCalculator.sum(existing, amounts));
        }
        return amountsByMonth.entrySet().stream()
            .map(entry -> new MonthlyPayout(entry.getKey(), entry.getValue().grossAmount(),
                entry.getValue().refundAmount(), entry.getValue().payoutAmount()))
            .toList();
    }

    /** 스토어 코드 > 수수료율 (모르는 스토어는 Play 값) */
    private static double toFeeRatePercent(PayoutSettings settings, String store) {
        return PurchaseStore.APP_STORE.name().equals(store) ? settings.appStoreFeeRatePercent() : settings.playFeeRatePercent();
    }

    private static double toVatRatePercent(PayoutSettings settings, String currencyCode) {
        return VAT_CURRENCY_CODE.equals(currencyCode) ? settings.krwVatRatePercent() : 0d;
    }

    /** 설정 저장 문자열 (정수면 소수점 없이: 15.0 > "15") */
    private static String toSettingText(double value) {
        return value == Math.rint(value) ? String.valueOf((long) value) : String.valueOf(value);
    }
}
