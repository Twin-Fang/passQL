package com.passql.application.statistics.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * 리텐션·코호트: 가입 기간 회원의 N일 뒤 재방문율, 가입 주차별 주간 유지율, 기능별 이용률
 * 가입 기준 구간 = fromDate ~ toDate, 기능 사용률 기준 = 같은 구간에 활동한 회원
 */
public record RetentionResponse(
        LocalDate fromDate,
        LocalDate toDate,
        List<DayRetention> dayRetentions,
        List<WeekCohort> weekCohorts,
        long activeMemberCount,
        List<FeatureUsage> featureUsages
) {

    /** N일 리텐션 (eligibleCount: 가입 후 N일이 지난 가입자, retainedCount: 가입 N일째 활동한 회원) */
    public record DayRetention(int dayOffset, long eligibleCount, long retainedCount, double ratePercent) {}

    /**
     * 가입 주차 코호트 (retainedCounts[n]: 가입 주 + n 주에 활동한 회원, 아직 오지 않은 주는 null)
     * retentionRatePercents 는 retainedCounts 와 같은 순서 (null 도 같은 위치)
     */
    public record WeekCohort(LocalDate weekStartDate, long cohortSize, List<Long> retainedCounts,
                             List<Double> retentionRatePercents) {}

    /** 기능 이용률 (userCount: 구간 이용 회원, ratePercent: 활동 회원 중 비율) */
    public record FeatureUsage(String featureCode, String featureLabel, long userCount, double ratePercent) {}
}
