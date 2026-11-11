package com.passql.application.entitlement;

import com.passql.application.ads.AdMobRewardCallback;
import com.passql.application.ads.AdMobRewardCallbackVerifier;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.repository.MemberDailyAdBonusRepository;
import com.passql.meta.service.AppSettingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * 광고 보너스 공정 사용 상한 (#963): 오늘 200문제면 앱 신고 429, 서버 콜백은 기록 없이 끝남
 */
class AdBonusGrantServiceFairUseTest {

    private static final UUID MEMBER_UUID = UUID.randomUUID();
    private static final String REWARD_NONCE = UUID.randomUUID().toString();
    private static final String CALLBACK_QUERY = "signed-callback-query";

    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    private final DailyAdBonusRecorder dailyAdBonusRecorder = mock(DailyAdBonusRecorder.class);
    private final DailyQuestionCounter dailyQuestionCounter = mock(DailyQuestionCounter.class);
    private final MemberDailyAdBonusRepository memberDailyAdBonusRepository = mock(MemberDailyAdBonusRepository.class);
    private final AdMobRewardCallbackVerifier adMobRewardCallbackVerifier = mock(AdMobRewardCallbackVerifier.class);
    private AdBonusGrantService adBonusGrantService;

    @BeforeEach
    void setUp() {
        adBonusGrantService = new AdBonusGrantService(featureAccessPolicy, dailyAdBonusRecorder, dailyQuestionCounter,
            memberDailyAdBonusRepository, mock(AppSettingService.class), adMobRewardCallbackVerifier);
        // 무료 회원, 처음 보는 광고, 오늘 랜덤 제출 = 공정 사용 상한
        when(featureAccessPolicy.isPro(MEMBER_UUID)).thenReturn(false);
        when(dailyQuestionCounter.countTodayRandomSolved(MEMBER_UUID)).thenReturn(FeatureAccessPolicy.DAILY_FAIR_USE_LIMIT);
    }

    @Test
    void 앱_신고는_공정_사용_상한이면_429로_거부하고_기록하지_않는다() {
        assertThatThrownBy(() -> adBonusGrantService.grantByAppReport(MEMBER_UUID, REWARD_NONCE))
            .isInstanceOfSatisfying(CustomException.class,
                exception -> assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.FAIR_USE_DAILY_LIMIT_REACHED));
        verify(dailyAdBonusRecorder, never()).saveNextAdBonus(any(), any(), any());
    }

    @Test
    void 서버_콜백은_공정_사용_상한이면_기록_없이_끝난다() {
        when(adMobRewardCallbackVerifier.verify(CALLBACK_QUERY)).thenReturn(
            new AdMobRewardCallback("ca-app-pub-test/rewarded", MEMBER_UUID.toString(), REWARD_NONCE, "transaction-1"));
        when(memberDailyAdBonusRepository.existsBySsvTransactionId(anyString())).thenReturn(false);

        adBonusGrantService.grantByServerVerification(CALLBACK_QUERY);

        verify(dailyAdBonusRecorder, never()).saveNextAdBonus(any(), any(), any());
    }
}
