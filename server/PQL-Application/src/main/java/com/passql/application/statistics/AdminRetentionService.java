package com.passql.application.statistics;

import com.passql.application.statistics.AdminRetentionQueryRepository.RetentionCountRow;
import com.passql.application.statistics.AdminRetentionQueryRepository.WeekCohortRetentionRow;
import com.passql.application.statistics.AdminRetentionQueryRepository.WeekCohortSizeRow;
import com.passql.application.statistics.dto.RetentionResponse;
import com.passql.application.statistics.dto.RetentionResponse.DayRetention;
import com.passql.application.statistics.dto.RetentionResponse.FeatureUsage;
import com.passql.application.statistics.dto.RetentionResponse.WeekCohort;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 관리자 리텐션·코호트: D1·D7·D30 > 가입 주차 코호트(0~7주 뒤) > 기능별 이용률
 * 가입자 기준 구간은 StatisticsPeriod 공통
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminRetentionService {

    // 리텐션 측정 일수 (가입 후 N일째 활동)
    static final List<Integer> RETENTION_DAY_OFFSETS = List.of(1, 7, 30);
    // 코호트 최대 주차 오프셋 (0 = 가입 주 ~ 7 = 7주 뒤)
    static final int MAX_WEEK_OFFSET = 7;

    private final AdminRetentionQueryRepository retentionQueryRepository;

    public RetentionResponse getRetention(StatisticsPeriod period) {
        LocalDate today = LocalDate.now();
        long activeMemberCount = retentionQueryRepository.countActiveMembers(period.getStartInclusive(), period.getEndExclusive());
        return new RetentionResponse(
                period.fromDate(),
                period.toDate(),
                buildDayRetentions(period, today),
                buildWeekCohorts(period, today),
                activeMemberCount,
                buildFeatureUsages(period, activeMemberCount));
    }

    /** D1·D7·D30 > 대상·유지 회원 수와 비율 */
    private List<DayRetention> buildDayRetentions(StatisticsPeriod period, LocalDate today) {
        return RETENTION_DAY_OFFSETS.stream()
                .map(dayOffset -> {
                    RetentionCountRow row = retentionQueryRepository.countDayRetention(
                            dayOffset, period.getStartInclusive(), period.getEndExclusive(), today);
                    return new DayRetention(dayOffset, row.eligibleCount(), row.retainedCount(),
                            StatisticsNumbers.toPercent(row.retainedCount(), row.eligibleCount()));
                })
                .toList();
    }

    /** 코호트 크기 + 주차별 유지 회원 > 코호트 행 (오지 않은 주는 null) */
    private List<WeekCohort> buildWeekCohorts(StatisticsPeriod period, LocalDate today) {
        Map<LocalDate, Map<Integer, Long>> retainedCountByOffsetByWeek = new HashMap<>();
        for (WeekCohortRetentionRow row : retentionQueryRepository.countWeeklyCohortRetention(
                period.getStartInclusive(), period.getEndExclusive(), MAX_WEEK_OFFSET, today)) {
            retainedCountByOffsetByWeek.computeIfAbsent(row.weekStartDate(), weekStartDate -> new HashMap<>())
                    .put(row.weekOffset(), row.retainedCount());
        }
        List<WeekCohort> weekCohorts = new ArrayList<>();
        for (WeekCohortSizeRow cohortSizeRow : retentionQueryRepository
                .countCohortSizeByWeek(period.getStartInclusive(), period.getEndExclusive())) {
            Map<Integer, Long> retainedCountByOffset =
                    retainedCountByOffsetByWeek.getOrDefault(cohortSizeRow.weekStartDate(), Map.of());
            List<Long> retainedCounts = new ArrayList<>();
            List<Double> retentionRatePercents = new ArrayList<>();
            for (int weekOffset = 0; weekOffset <= MAX_WEEK_OFFSET; weekOffset++) {
                Long retainedCount = retainedCountByOffset.get(weekOffset);
                retainedCounts.add(retainedCount);
                retentionRatePercents.add(retainedCount == null
                        ? null : StatisticsNumbers.toPercent(retainedCount, cohortSizeRow.cohortSize()));
            }
            weekCohorts.add(new WeekCohort(cohortSizeRow.weekStartDate(), cohortSizeRow.cohortSize(),
                    retainedCounts, retentionRatePercents));
        }
        return weekCohorts;
    }

    /** 기능별 이용 회원 > 활동 회원 대비 비율 (100% 상한, 활동 기록 지연으로 넘는 경우 보정) */
    private List<FeatureUsage> buildFeatureUsages(StatisticsPeriod period, long activeMemberCount) {
        return retentionQueryRepository.countFeatureUsers(period.getStartInclusive(), period.getEndExclusive()).stream()
                .map(row -> new FeatureUsage(row.featureCode(), row.featureLabel(), row.userCount(),
                        Math.min(100.0, StatisticsNumbers.toPercent(row.userCount(), activeMemberCount))))
                .toList();
    }
}
