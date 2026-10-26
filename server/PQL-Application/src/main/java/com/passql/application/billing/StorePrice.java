package com.passql.application.billing;

import org.springframework.util.StringUtils;

/**
 * 스토어가 알려 준 결제 금액 1건: 통화 단위 x 1,000,000 (entitlement_purchase.price_amount_micros) + ISO 4217 통화
 * 스토어 원본 단위(App Store 밀리 단위, Play Money 단위·나노) > 마이크로 단위 변환, 값이 없거나 형식이 틀리면 null
 */
public record StorePrice(long amountMicros, String currencyCode) {

    // App Store price 단위: 통화 단위 x 1,000 (밀리 단위) > 마이크로 단위 배수
    private static final long MICROS_PER_APP_STORE_MILLIUNIT = 1_000L;
    // Play Money: units(정수 통화 단위) + nanos(10억분의 1) > 마이크로 단위
    private static final long MICROS_PER_CURRENCY_UNIT = 1_000_000L;
    private static final long NANOS_PER_MICRO = 1_000L;
    // ISO 4217 통화 코드 길이 (DB currency_code VARCHAR(3))
    private static final int CURRENCY_CODE_LENGTH = 3;

    /** App Store 거래 price(밀리 단위)·currency > 금액, 하나라도 없으면 null */
    public static StorePrice fromAppStoreMilliunits(Long priceMilliunits, String currencyCode) {
        if (priceMilliunits == null || !isValidCurrencyCode(currencyCode)) {
            return null;
        }
        return new StorePrice(priceMilliunits * MICROS_PER_APP_STORE_MILLIUNIT, currencyCode);
    }

    /** Play Money(units, nanos, currencyCode) > 금액, 금액·통화 없으면 null (nanos 없으면 0) */
    public static StorePrice fromPlayMoney(Long units, Integer nanos, String currencyCode) {
        if (units == null || !isValidCurrencyCode(currencyCode)) {
            return null;
        }
        long nanosPart = nanos != null ? nanos : 0;
        return new StorePrice(units * MICROS_PER_CURRENCY_UNIT + nanosPart / NANOS_PER_MICRO, currencyCode);
    }

    private static boolean isValidCurrencyCode(String currencyCode) {
        return StringUtils.hasText(currencyCode) && currencyCode.length() == CURRENCY_CODE_LENGTH;
    }
}
