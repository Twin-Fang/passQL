package com.passql.application.entitlement;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 크레딧 사용 내역 (#974): 최근 N일 날짜별 받은 수(기본·세트 완료·세트 정답률·광고)·쓴 수·남은 수, 오늘 먼저
 * 전용 기록 테이블 없음 > 제출·세트 완료·광고 보너스 기록을 오늘 판정과 같은 메서드로 날짜별 계산, 지금 무료(결제 켜짐) 회원에게만
 */
@Service
@Transactional(readOnly = true)
public class CreditHistoryService {

    // 조회 일수 기본값 (일, 오늘 포함)
    public static final int DEFAULT_DAY_COUNT = 14;
    // 조회 일수 허용 범위 (일, 오늘 포함)
    public static final int MIN_DAY_COUNT = 1;
    public static final int MAX_DAY_COUNT = 30;

    private final FeatureAccessPolicy featureAccessPolicy;
    private final DailyQuestionCounter dailyQuestionCounter;
    private final DailyFreeBonusReader dailyFreeBonusReader;
    private final Clock clock;

    @Autowired
    public CreditHistoryService(FeatureAccessPolicy featureAccessPolicy,
                                DailyQuestionCounter dailyQuestionCounter,
                                DailyFreeBonusReader dailyFreeBonusReader) {
        this(featureAccessPolicy, dailyQuestionCounter, dailyFreeBonusReader, Clock.system(ServiceTimeZone.ZONE));
    }

    CreditHistoryService(FeatureAccessPolicy featureAccessPolicy,
                         DailyQuestionCounter dailyQuestionCounter,
                         DailyFreeBonusReader dailyFreeBonusReader, Clock clock) {
        this.featureAccessPolicy = featureAccessPolicy;
        this.dailyQuestionCounter = dailyQuestionCounter;
        this.dailyFreeBonusReader = dailyFreeBonusReader;
        this.clock = clock;
    }

    /**
     * 최근 N일 내역: 일수 검증 > 등급 확인 > 기간 묶음 조회 > 날짜별 계산 (오늘 먼저)
     * 일수 없음 > 14, 1~30 밖 > INVALID_INPUT_VALUE, 결제 꺼짐·프로 > 빈 목록
     */
    public CreditHistoryResponse getCreditHistory(UUID memberUuid, Integer requestedDayCount) {
        int dayCount = resolveDayCount(requestedDayCount);
        // 크레딧은 무료(결제 켜짐) 회원에게만 적용 (과거 등급 이력은 따지지 않음)
        if (featureAccessPolicy.isPro(memberUuid)) {
            return new CreditHistoryResponse(List.of());
        }

        // 기간 [오늘 - (N-1)일, 오늘] 묶음 조회 (날짜 수와 무관한 쿼리 수)
        LocalDate today = LocalDate.now(clock);
        LocalDate fromDate = today.minusDays(dayCount - 1L);
        Map<LocalDate, Integer> usedCreditsByDate = dailyQuestionCounter.countRandomSolvedByDate(memberUuid, fromDate, today);
        Map<LocalDate, DailyFreeBonus> bonusByDate = dailyFreeBonusReader.readByDate(memberUuid, fromDate, today);

        // 날짜별 계산 (오늘 먼저, 받은 보너스도 쓴 것도 없는 지난 날짜는 뺌)
        List<CreditHistoryDayResponse> days = new ArrayList<>();
        for (LocalDate date = today; !date.isBefore(fromDate); date = date.minusDays(1)) {
            int usedCredits = usedCreditsByDate.getOrDefault(date, 0);
            DailyFreeBonus bonus = bonusByDate.getOrDefault(date, DailyFreeBonus.none());
            if (date.equals(today) || hasCreditActivity(bonus, usedCredits)) {
                days.add(toDayResponse(date, bonus, usedCredits));
            }
        }
        return new CreditHistoryResponse(days);
    }

    /** 요청 일수 > 조회 일수 (없으면 기본 14, 1~30 밖이면 INVALID_INPUT_VALUE) */
    private static int resolveDayCount(Integer requestedDayCount) {
        if (requestedDayCount == null) {
            return DEFAULT_DAY_COUNT;
        }
        if (requestedDayCount < MIN_DAY_COUNT || requestedDayCount > MAX_DAY_COUNT) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE,
                "days must be " + MIN_DAY_COUNT + " to " + MAX_DAY_COUNT);
        }
        return requestedDayCount;
    }

    /** 그날 받은 보너스나 쓴 크레딧이 있는가 (기본 크레딧만 있고 안 쓴 날 false) */
    private static boolean hasCreditActivity(DailyFreeBonus bonus, int usedCredits) {
        return usedCredits > 0 || bonus.totalBonusQuestionCount() > 0;
    }

    /** 그날 보너스·쓴 수 > 하루치 내역 (남은 수 = 기본 + 보너스 합 - 쓴 수, 0 미만은 0) */
    private static CreditHistoryDayResponse toDayResponse(LocalDate date, DailyFreeBonus bonus, int usedCredits) {
        int baseCredits = FeatureAccessPolicy.DAILY_FREE_LIMIT;
        int receivedCredits = baseCredits + bonus.totalBonusQuestionCount();
        return new CreditHistoryDayResponse(
            date,
            baseCredits,
            bonus.isDailySetCompletionEarned() ? bonus.bonusQuestionCount() : 0,
            bonus.isDailySetAccuracyEarned() ? bonus.bonusQuestionCount() : 0,
            bonus.adBonusUsedCount(),
            bonus.adBonusUsedCount() * bonus.bonusQuestionCount(),
            usedCredits,
            Math.max(receivedCredits - usedCredits, 0));
    }
}
