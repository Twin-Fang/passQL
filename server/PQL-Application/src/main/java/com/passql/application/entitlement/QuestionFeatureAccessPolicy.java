package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.EnumSet;
import java.util.Set;
import java.util.UUID;

/**
 * 문제 단위 기능 잠금: 등급 판정(FeatureAccessPolicy) > 오늘의 세트 무료 체험 (#992)
 * 무료라도 오늘(KST) 오늘의 세트 배정 문제면 체험 기능 3개 열림, 그 외 문제·기능은 등급 판정 그대로
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class QuestionFeatureAccessPolicy {

    // 오늘의 세트 체험 기능 3개: SQL 실행, 전체 해설, 실행 오류·오답 AI 해설
    private static final Set<ProFeature> DAILY_SET_TRIAL_FEATURES = EnumSet.of(
        ProFeature.SQL_EXECUTION, ProFeature.FULL_EXPLANATION, ProFeature.ERROR_EXPLANATION);

    private final FeatureAccessPolicy featureAccessPolicy;
    private final DailyQuestionCounter dailyQuestionCounter;

    /** 문제 기준 기능 사용 가능 여부: 등급으로 가능 > 체험 기능이고 오늘의 세트 문제 */
    public boolean canUse(UUID memberUuid, ProFeature feature, UUID questionUuid) {
        if (featureAccessPolicy.canUse(memberUuid, feature)) {
            return true;
        }
        return isDailySetTrialFeature(feature) && isTodaysDailySetQuestion(questionUuid);
    }

    /** 문제 기준 기능 잠금 검사: 불가 시 PRO_REQUIRED */
    public void requireFeature(UUID memberUuid, ProFeature feature, UUID questionUuid) {
        if (!canUse(memberUuid, feature, questionUuid)) {
            log.info("[pro access] rejected 403 : feature={}, member={}, question={}", feature, memberUuid, questionUuid);
            throw new CustomException(ErrorCode.PRO_REQUIRED);
        }
    }

    /** 무료 체험 중인 문제인가: 무료(회원 기준 결제 켜짐)이고 오늘의 세트 문제 (프로·결제 꺼짐 false) */
    public boolean isDailySetFreeTrial(UUID memberUuid, UUID questionUuid) {
        return !featureAccessPolicy.isPro(memberUuid) && isTodaysDailySetQuestion(questionUuid);
    }

    private static boolean isDailySetTrialFeature(ProFeature feature) {
        return DAILY_SET_TRIAL_FEATURES.contains(feature);
    }

    // 오늘의 세트 = 오늘(KST) daily_challenge 배정 문제 (하루 한도 면제와 같은 기준)
    private boolean isTodaysDailySetQuestion(UUID questionUuid) {
        return questionUuid != null && dailyQuestionCounter.isTodaysDailyChallengeQuestion(questionUuid);
    }
}
