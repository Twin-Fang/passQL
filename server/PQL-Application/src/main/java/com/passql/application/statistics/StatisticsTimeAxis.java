package com.passql.application.statistics;

import com.passql.application.constant.StatisticsRange;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.function.Function;

/**
 * 통계 그래프 날짜 축: 오늘이 속한 묶음까지 N개 묶음 시작일, 라벨, 조회 구간, 빈 묶음 채우기
 * 날짜 기준 서버 로컬 시각 (저장 시각도 서버 로컬 LocalDateTime)
 */
public final class StatisticsTimeAxis {

    private final StatisticsRange range;
    private final List<LocalDate> bucketStartDates;

    private StatisticsTimeAxis(StatisticsRange range, List<LocalDate> bucketStartDates) {
        this.range = range;
        this.bucketStartDates = Collections.unmodifiableList(bucketStartDates);
    }

    /** 범위 기본 개수 (일 30, 월 12) */
    public static StatisticsTimeAxis endingAt(StatisticsRange range, LocalDate today) {
        return endingAt(range, range.getDefaultBucketCount(), today);
    }

    /** 오늘이 속한 묶음을 마지막으로 bucketCount 개 */
    public static StatisticsTimeAxis endingAt(StatisticsRange range, int bucketCount, LocalDate today) {
        LocalDate lastBucketStartDate = range.toBucketStartDate(today);
        List<LocalDate> bucketStartDates = new ArrayList<>(bucketCount);
        for (int offset = bucketCount - 1; offset >= 0; offset--) {
            bucketStartDates.add(range.minusBuckets(lastBucketStartDate, offset));
        }
        return new StatisticsTimeAxis(range, bucketStartDates);
    }

    public StatisticsRange getRange() {
        return range;
    }

    public List<LocalDate> getBucketStartDates() {
        return bucketStartDates;
    }

    /** 조회 시작 (첫 묶음 00:00, 포함) */
    public LocalDateTime getStartInclusive() {
        return bucketStartDates.getFirst().atStartOfDay();
    }

    /** 조회 끝 (마지막 묶음 다음 시작 00:00, 제외) */
    public LocalDateTime getEndExclusive() {
        return range.toNextBucketStartDate(bucketStartDates.getLast()).atStartOfDay();
    }

    /** 라벨: 일 MM/dd, 월 yyyy.MM */
    public List<String> getLabels() {
        DateTimeFormatter labelFormatter = DateTimeFormatter.ofPattern(range.getLabelPattern());
        return bucketStartDates.stream().map(labelFormatter::format).toList();
    }

    /** 묶음별 값 > 축 순서 목록 (없는 묶음은 emptyValue) */
    public <T> List<T> fill(Map<LocalDate, T> valueByBucketStartDate, T emptyValue) {
        return bucketStartDates.stream()
                .map(bucketStartDate -> valueByBucketStartDate.getOrDefault(bucketStartDate, emptyValue))
                .toList();
    }

    /** 묶음별 원본 > 변환 값 축 순서 목록 (없는 묶음은 emptyValue) */
    public <S, T> List<T> fill(Map<LocalDate, S> sourceByBucketStartDate, Function<S, T> converter, T emptyValue) {
        return bucketStartDates.stream()
                .map(bucketStartDate -> {
                    S source = sourceByBucketStartDate.get(bucketStartDate);
                    return source == null ? emptyValue : converter.apply(source);
                })
                .toList();
    }
}
