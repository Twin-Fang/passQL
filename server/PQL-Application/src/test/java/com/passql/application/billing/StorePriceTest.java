package com.passql.application.billing;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 스토어 금액 변환: App Store 밀리 단위·Play Money > 마이크로 단위, 값 없음·통화 형식 오류 > null
 */
class StorePriceTest {

    @Test
    void fromAppStoreMilliunits_convertsToMicros() {
        // 1,100.5 단위 = 1,100,500 밀리 단위
        assertThat(StorePrice.fromAppStoreMilliunits(1_100_500L, "KRW"))
            .isEqualTo(new StorePrice(1_100_500_000L, "KRW"));
    }

    @Test
    void fromAppStoreMilliunits_missingValue_returnsNull() {
        assertThat(StorePrice.fromAppStoreMilliunits(null, "KRW")).isNull();
        assertThat(StorePrice.fromAppStoreMilliunits(1_000L, null)).isNull();
        assertThat(StorePrice.fromAppStoreMilliunits(1_000L, "KRWX")).isNull();
    }

    @Test
    void fromPlayMoney_combinesUnitsAndNanos() {
        // 1.99 USD = units 1 + nanos 990,000,000
        assertThat(StorePrice.fromPlayMoney(1L, 990_000_000, "USD")).isEqualTo(new StorePrice(1_990_000L, "USD"));
        assertThat(StorePrice.fromPlayMoney(1_100L, null, "KRW")).isEqualTo(new StorePrice(1_100_000_000L, "KRW"));
    }

    @Test
    void fromPlayMoney_missingValue_returnsNull() {
        assertThat(StorePrice.fromPlayMoney(null, 0, "KRW")).isNull();
        assertThat(StorePrice.fromPlayMoney(1L, 0, "")).isNull();
    }
}
