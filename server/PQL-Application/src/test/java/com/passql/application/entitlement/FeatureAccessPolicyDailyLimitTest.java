package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.member.repository.MemberEntitlementRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 하루 문제 수 제출 판정 (#860): 열기와 같은 규칙을 제출 시점 수로 다시 확인
 */
class FeatureAccessPolicyDailyLimitTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final UUID QUESTION_UUID = UUID.randomUUID();

    private final AppSettingService appSettingService = mock(AppSettingService.class);
    private final MemberEntitlementRepository memberEntitlementRepository = mock(MemberEntitlementRepository.class);
    private final SubmissionRepository submissionRepository = mock(SubmissionRepository.class);
    private final DailyQuestionCounter dailyQuestionCounter = mock(DailyQuestionCounter.class);
    private final DailyFreeBonusReader dailyFreeBonusReader = mock(DailyFreeBonusReader.class);
    private FeatureAccessPolicy featureAccessPolicy;

    @BeforeEach
    void setUp() {
        featureAccessPolicy = new FeatureAccessPolicy(memberEntitlementRepository, appSettingService,
            mock(PassExpiryCalculator.class), submissionRepository, dailyQuestionCounter,
            mock(EntitlementPurchaseRepository.class), dailyFreeBonusReader, Clock.systemDefaultZone());
        // 무료 회원 (등급 행 없음), 보너스 없음 > 한도 10
        when(memberEntitlementRepository.findById(MEMBER_UUID)).thenReturn(Optional.empty());
        when(dailyFreeBonusReader.readToday(MEMBER_UUID)).thenReturn(DailyFreeBonus.none());
    }

    @Test
    void 결제_켜짐_무료가_한도에_닿으면_처음_푸는_문제_제출을_막는다() {
        givenBillingEnabled(true);
        when(dailyQuestionCounter.countTodayRandomSolved(MEMBER_UUID)).thenReturn(FeatureAccessPolicy.DAILY_FREE_LIMIT);

        assertThatThrownBy(() -> featureAccessPolicy.assertCanSubmitQuestion(MEMBER_UUID, QUESTION_UUID))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FREE_DAILY_LIMIT_REACHED));
    }

    @Test
    void 한도에_닿아도_예전에_제출한_문제는_다시_낼_수_있다() {
        givenBillingEnabled(true);
        when(dailyQuestionCounter.countTodayRandomSolved(MEMBER_UUID)).thenReturn(FeatureAccessPolicy.DAILY_FREE_LIMIT);
        when(submissionRepository.existsOutsideMockExam(MEMBER_UUID, QUESTION_UUID)).thenReturn(true);

        assertThatCode(() -> featureAccessPolicy.assertCanSubmitQuestion(MEMBER_UUID, QUESTION_UUID))
            .doesNotThrowAnyException();
    }

    @Test
    void 결제_꺼짐이면_수와_관계없이_통과한다() {
        givenBillingEnabled(false);
        when(dailyQuestionCounter.countTodayRandomSolved(MEMBER_UUID)).thenReturn(FeatureAccessPolicy.DAILY_PRO_FAIR_USE_LIMIT);

        assertThatCode(() -> featureAccessPolicy.assertCanSubmitQuestion(MEMBER_UUID, QUESTION_UUID))
            .doesNotThrowAnyException();
    }

    /** 전체 결제 스위치 (미리보기 회원 목록은 비움) */
    private void givenBillingEnabled(boolean isBillingEnabled) {
        when(appSettingService.getBooleanOrDefault(eq(AppSettingKeys.BILLING_ANDROID_ENABLED), anyBoolean()))
            .thenReturn(isBillingEnabled);
        when(appSettingService.getString(AppSettingKeys.BILLING_PREVIEW_MEMBER_UUIDS)).thenReturn("");
    }
}
