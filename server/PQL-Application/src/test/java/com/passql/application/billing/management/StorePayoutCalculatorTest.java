package com.passql.application.billing.management;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;

/**
 * 예상 실수령 계산 (#1032): 환불 차감 > 원화 부가세 제외 > 스토어 수수료
 */
class StorePayoutCalculatorTest {

    // 4,400원 (micros)
    private static final long ONE_MONTH_PASS_MICROS = 4_400_000_000L;

    @Test
    void 원화_판매는_환불을_빼고_부가세_제외_후_수수료를_뗀다() {
        // 2건 판매 중 1건 환불 > 순매출 4,400 > 부가세 400 > 수수료 15% 600 > 실수령 3,400
        PayoutAmounts amounts = StorePayoutCalculator.calculate(ONE_MONTH_PASS_MICROS * 2, ONE_MONTH_PASS_MICROS,
            2, 1, 15, 10);

        assertThat(amounts.grossAmount()).isEqualTo(8_800d);
        assertThat(amounts.refundAmount()).isEqualTo(4_400d);
        assertThat(amounts.vatAmount()).isCloseTo(400d, within(0.001));
        assertThat(amounts.feeAmount()).isCloseTo(600d, within(0.001));
        assertThat(amounts.payoutAmount()).isCloseTo(3_400d, within(0.001));
    }

    @Test
    void 부가세율_0이면_수수료만_뗀다() {
        // USD 1.99 > 수수료 30% > 1.393
        PayoutAmounts amounts = StorePayoutCalculator.calculate(1_990_000L, 0, 1, 0, 30, 0);

        assertThat(amounts.vatAmount()).isZero();
        assertThat(amounts.payoutAmount()).isCloseTo(1.393d, within(0.0001));
    }
}
