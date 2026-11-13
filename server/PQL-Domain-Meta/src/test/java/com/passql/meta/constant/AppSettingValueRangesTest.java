package com.passql.meta.constant;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 설정 범위 판정 고정 (#624): 경계 포함, 범위 밖 사유, 범위 없는 키 통과
 */
class AppSettingValueRangesTest {

    @Test
    void 경계값은_허용하고_범위_밖은_사유를_돌려준다() {
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, "1")).isEmpty();
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, "100")).isEmpty();
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, "0"))
                .hasValue("sandbox.pool.concurrency 값은 1~100 범위여야 합니다.");
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.BILLING_KRW_VAT_RATE_PERCENT, "100.5")).isPresent();
    }

    @Test
    void 범위_없는_키와_숫자_아닌_값은_검사하지_않는다() {
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.STORE_IOS_URL, "-1")).isEmpty();
        assertThat(AppSettingValueRanges.findRejectionReason(AppSettingKeys.SANDBOX_POOL_CONCURRENCY, "abc")).isEmpty();
    }
}
