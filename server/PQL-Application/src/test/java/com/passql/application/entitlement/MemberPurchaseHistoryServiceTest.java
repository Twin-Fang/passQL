package com.passql.application.entitlement;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class MemberPurchaseHistoryServiceTest {

    private static final LocalDateTime GRANTED_AT = LocalDateTime.of(2026, 11, 2, 10, 0);

    @Test
    void 운영_지급_일수는_남은_만료일_뒤로_이어_붙여_센다() {
        // 남은 만료일 없음 > 지급일부터
        assertThat(MemberPurchaseHistoryService.toGrantedDays(GRANTED_AT, null,
            LocalDateTime.of(2026, 11, 9, 23, 59, 59))).isEqualTo(7);
        // 남은 만료일이 지급 뒤 > 그 만료일부터
        assertThat(MemberPurchaseHistoryService.toGrantedDays(GRANTED_AT, LocalDateTime.of(2026, 11, 30, 23, 59),
            LocalDateTime.of(2026, 12, 7, 23, 59, 59))).isEqualTo(7);
    }

    @Test
    void 만료일을_줄였거나_모르면_일수는_null() {
        assertThat(MemberPurchaseHistoryService.toGrantedDays(GRANTED_AT, LocalDateTime.of(2026, 12, 30, 0, 0),
            LocalDateTime.of(2026, 12, 7, 0, 0))).isNull();
        assertThat(MemberPurchaseHistoryService.toGrantedDays(GRANTED_AT, null, null)).isNull();
    }
}
