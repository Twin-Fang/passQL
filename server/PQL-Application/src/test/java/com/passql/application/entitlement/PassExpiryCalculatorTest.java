package com.passql.application.entitlement;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 이용권 만료일 계산: 신규 구매 시각 + 일수, 보유 중이면 현재 만료일 + 일수, 만료 후면 구매 시각 + 일수
 */
class PassExpiryCalculatorTest {

    // 구매 시각: 2026-10-23 12:00 KST
    private static final LocalDateTime PURCHASED_AT = LocalDateTime.of(2026, 10, 23, 12, 0);
    // 3개월 이용권 일수
    private static final int DURATION_DAYS = 90;

    private final PassExpiryCalculator calculator = new PassExpiryCalculator();

    @Test
    void newPurchase_extendsFromPurchasedAt() {
        assertThat(calculator.calculateExpiresAt(PURCHASED_AT, null, DURATION_DAYS))
            .isEqualTo(PURCHASED_AT.plusDays(DURATION_DAYS));
    }

    @Test
    void activePass_extendsFromCurrentExpiresAt() {
        LocalDateTime currentExpiresAt = PURCHASED_AT.plusDays(10);

        assertThat(calculator.calculateExpiresAt(PURCHASED_AT, currentExpiresAt, 30))
            .isEqualTo(currentExpiresAt.plusDays(30));
    }

    @Test
    void expiredPass_extendsFromPurchasedAt() {
        LocalDateTime expiredAt = PURCHASED_AT.minusDays(1);

        assertThat(calculator.calculateExpiresAt(PURCHASED_AT, expiredAt, DURATION_DAYS))
            .isEqualTo(PURCHASED_AT.plusDays(DURATION_DAYS));
    }
}
