package com.passql.application.entitlement;

import org.junit.jupiter.api.Test;

import java.util.OptionalInt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 무료 하루 한도 보너스 판정 (#808): 세트 완료 +5, 정답률 80% 이상 +5, 광고 +5 × 2
 */
class DailyFreeBonusRuleTest {

    @Test
    void 완료_기록_없으면_보너스_없음() {
        DailyFreeBonus bonus = DailyFreeBonusRule.calculate(new DailyFreeBonusInput(false, 0, 5, 5, 0));

        assertFalse(bonus.isDailySetCompletionEarned());
        assertFalse(bonus.isDailySetAccuracyEarned());
        assertEquals(0, bonus.totalBonusQuestionCount());
    }

    @Test
    void 전부_제출하고_완료하면_완료_보너스() {
        DailyFreeBonus bonus = DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 3, 5, 5, 0));

        assertTrue(bonus.isDailySetCompletionEarned());
        assertFalse(bonus.isDailySetAccuracyEarned());
        assertEquals(5, bonus.totalBonusQuestionCount());
    }

    @Test
    void 일부만_제출하면_완료_보너스_없음() {
        // 완료 기록은 제출 1건만 있어도 생기므로 배정 문제 전부 제출을 따로 확인
        DailyFreeBonus bonus = DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 4, 5, 3, 0));

        assertFalse(bonus.isDailySetCompletionEarned());
        assertTrue(bonus.isDailySetAccuracyEarned());
        assertEquals(5, bonus.totalBonusQuestionCount());
    }

    @Test
    void 정답률_80퍼센트_경계() {
        assertEquals(10, DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 4, 5, 5, 0)).totalBonusQuestionCount());
        // 3/4 = 75% 미달
        assertFalse(DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 3, 4, 4, 0)).isDailySetAccuracyEarned());
    }

    @Test
    void 배정_0개면_정답률_보너스_없음() {
        DailyFreeBonus bonus = DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 0, 0, 0, 0));

        assertFalse(bonus.isDailySetCompletionEarned());
        assertFalse(bonus.isDailySetAccuracyEarned());
    }

    @Test
    void 광고_보너스는_2회까지() {
        assertEquals(10, DailyFreeBonusRule.calculate(new DailyFreeBonusInput(false, 0, 5, 0, 2)).totalBonusQuestionCount());
        // 저장 이상으로 3회가 읽혀도 2회분만
        assertEquals(10, DailyFreeBonusRule.calculate(new DailyFreeBonusInput(false, 0, 5, 0, 3)).totalBonusQuestionCount());
        assertEquals(OptionalInt.of(1), DailyFreeBonusRule.nextAdBonusSlot(0));
        assertEquals(OptionalInt.of(2), DailyFreeBonusRule.nextAdBonusSlot(1));
        assertEquals(OptionalInt.empty(), DailyFreeBonusRule.nextAdBonusSlot(2));
    }

    @Test
    void 최대_합계_20() {
        DailyFreeBonus bonus = DailyFreeBonusRule.calculate(new DailyFreeBonusInput(true, 5, 5, 5, 2));

        assertEquals(20, bonus.totalBonusQuestionCount());
        assertEquals(2, bonus.adBonusMaxCount());
        assertEquals(5, bonus.bonusQuestionCount());
    }
}
