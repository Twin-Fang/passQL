package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 오늘의 세트 무료 체험 판정 (#992): 무료 회원 기준 오늘의 세트 문제만 체험 기능 열림
 */
class QuestionFeatureAccessPolicyTest {

    private static final UUID FREE_MEMBER_UUID = UUID.randomUUID();
    private static final UUID DAILY_SET_QUESTION_UUID = UUID.randomUUID();
    private static final UUID OTHER_QUESTION_UUID = UUID.randomUUID();

    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    private final DailyQuestionCounter dailyQuestionCounter = mock(DailyQuestionCounter.class);
    private final QuestionFeatureAccessPolicy policy =
        new QuestionFeatureAccessPolicy(featureAccessPolicy, dailyQuestionCounter);

    // 무료 회원(등급으로는 모든 프로 기능 잠김) + 오늘의 세트 문제 1개
    @BeforeEach
    void setUpFreeMember() {
        when(featureAccessPolicy.canUse(any(), any())).thenReturn(false);
        when(featureAccessPolicy.isPro(FREE_MEMBER_UUID)).thenReturn(false);
        when(dailyQuestionCounter.isTodaysDailyChallengeQuestion(DAILY_SET_QUESTION_UUID)).thenReturn(true);
        when(dailyQuestionCounter.isTodaysDailyChallengeQuestion(OTHER_QUESTION_UUID)).thenReturn(false);
    }

    @Test
    void 무료_회원도_오늘의_세트_문제는_실행과_해설을_쓴다() {
        assertThat(policy.canUse(FREE_MEMBER_UUID, ProFeature.SQL_EXECUTION, DAILY_SET_QUESTION_UUID)).isTrue();
        assertThat(policy.canUse(FREE_MEMBER_UUID, ProFeature.FULL_EXPLANATION, DAILY_SET_QUESTION_UUID)).isTrue();
        assertThat(policy.canUse(FREE_MEMBER_UUID, ProFeature.ERROR_EXPLANATION, DAILY_SET_QUESTION_UUID)).isTrue();
        assertThat(policy.isDailySetFreeTrial(FREE_MEMBER_UUID, DAILY_SET_QUESTION_UUID)).isTrue();
    }

    @Test
    void 오늘의_세트가_아닌_문제는_계속_잠긴다() {
        assertThat(policy.canUse(FREE_MEMBER_UUID, ProFeature.SQL_EXECUTION, OTHER_QUESTION_UUID)).isFalse();
        assertThat(policy.isDailySetFreeTrial(FREE_MEMBER_UUID, OTHER_QUESTION_UUID)).isFalse();
        assertThatThrownBy(() -> policy.requireFeature(FREE_MEMBER_UUID, ProFeature.SQL_EXECUTION, OTHER_QUESTION_UUID))
            .isInstanceOf(CustomException.class);
    }

    @Test
    void 체험_기능이_아니면_오늘의_세트_문제여도_잠긴다() {
        assertThat(policy.canUse(FREE_MEMBER_UUID, ProFeature.REAL_MODE, DAILY_SET_QUESTION_UUID)).isFalse();
    }
}
