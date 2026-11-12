package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * 크레딧 사용 내역 날짜별 계산 (#974): 받은 합·쓴 수·남은 수, 빈 날 제외, 등급·일수 검증
 */
class CreditHistoryServiceTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 12);
    // 보너스 1회분 (크레딧)
    private static final int BONUS = DailyFreeBonusRule.BONUS_QUESTION_COUNT;

    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    private final DailyQuestionCounter dailyQuestionCounter = mock(DailyQuestionCounter.class);
    private final DailyFreeBonusReader dailyFreeBonusReader = mock(DailyFreeBonusReader.class);
    private final CreditHistoryService creditHistoryService = new CreditHistoryService(
        featureAccessPolicy, dailyQuestionCounter, dailyFreeBonusReader,
        Clock.fixed(TODAY.atTime(9, 0).atZone(ServiceTimeZone.ZONE).toInstant(), ServiceTimeZone.ZONE));

    @Test
    void 받은_합에서_쓴_수를_뺀_남은_수를_날짜별로_계산한다() {
        // 어제: 세트 완료 + 광고 2회 = 10 + 5 + 10, 8개 씀 / 그제: 보너스 없이 받은 합보다 많이 제출
        LocalDate yesterday = TODAY.minusDays(1);
        LocalDate twoDaysAgo = TODAY.minusDays(2);
        givenFreeMemberHistory(3,
            Map.of(yesterday, 8, twoDaysAgo, 13),
            Map.of(yesterday, new DailyFreeBonus(true, false, 2, 3, BONUS)));

        CreditHistoryResponse response = creditHistoryService.getCreditHistory(MEMBER_UUID, 3);

        assertThat(response.days()).containsExactly(
            new CreditHistoryDayResponse(TODAY, 10, 0, 0, 0, 0, 0, 10),
            new CreditHistoryDayResponse(yesterday, 10, BONUS, 0, 2, 2 * BONUS, 8, 17),
            new CreditHistoryDayResponse(twoDaysAgo, 10, 0, 0, 0, 0, 13, 0));
    }

    @Test
    void 받은_보너스도_쓴_것도_없는_지난_날짜는_빼고_오늘은_항상_넣는다() {
        // 3일 전에만 정답률 보너스, 나머지 지난 날짜는 활동 없음
        LocalDate threeDaysAgo = TODAY.minusDays(3);
        givenFreeMemberHistory(CreditHistoryService.DEFAULT_DAY_COUNT,
            Map.of(),
            Map.of(threeDaysAgo, new DailyFreeBonus(false, true, 0, 1, BONUS)));

        CreditHistoryResponse response = creditHistoryService.getCreditHistory(MEMBER_UUID, null);

        assertThat(response.days()).extracting(CreditHistoryDayResponse::date).containsExactly(TODAY, threeDaysAgo);
    }

    @Test
    void 결제_꺼짐이나_프로면_조회_없이_빈_목록을_돌려준다() {
        when(featureAccessPolicy.isPro(MEMBER_UUID)).thenReturn(true);

        assertThat(creditHistoryService.getCreditHistory(MEMBER_UUID, null).days()).isEmpty();
        verifyNoInteractions(dailyQuestionCounter, dailyFreeBonusReader);
    }

    @Test
    void 일수가_1에서_30_밖이면_INVALID_INPUT_VALUE() {
        for (int invalidDayCount : new int[] {0, -1, CreditHistoryService.MAX_DAY_COUNT + 1}) {
            assertThatThrownBy(() -> creditHistoryService.getCreditHistory(MEMBER_UUID, invalidDayCount))
                .isInstanceOfSatisfying(CustomException.class,
                    exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.INVALID_INPUT_VALUE));
        }
    }

    /** 무료 회원의 최근 dayCount 일 재료 (보너스 지정 없는 날은 보너스 없음) */
    private void givenFreeMemberHistory(int dayCount, Map<LocalDate, Integer> usedCreditsByDate,
                                        Map<LocalDate, DailyFreeBonus> earnedBonusByDate) {
        LocalDate fromDate = TODAY.minusDays(dayCount - 1L);
        Map<LocalDate, DailyFreeBonus> bonusByDate = new LinkedHashMap<>();
        for (LocalDate date = fromDate; !date.isAfter(TODAY); date = date.plusDays(1)) {
            bonusByDate.put(date, earnedBonusByDate.getOrDefault(date, new DailyFreeBonus(false, false, 0, 1, BONUS)));
        }
        when(featureAccessPolicy.isPro(MEMBER_UUID)).thenReturn(false);
        when(dailyQuestionCounter.countRandomSolvedByDate(MEMBER_UUID, fromDate, TODAY)).thenReturn(usedCreditsByDate);
        when(dailyFreeBonusReader.readByDate(MEMBER_UUID, fromDate, TODAY)).thenReturn(bonusByDate);
    }
}
