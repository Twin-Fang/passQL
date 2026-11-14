package com.passql.meta.service;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.meta.dto.SqldExamGuideResponse;
import com.passql.meta.dto.SqldExamGuideResponse.Insights;
import com.passql.meta.dto.SqldExamGuideResponse.YearlyStatistic;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * SQLD 알아보기 (#1076, #1077): 원본 JSON 로드(기동 시 1회, 형식 오류면 기동 실패) > 인사이트 계산 > 응답
 * 앱 화면과 소개 사이트 빌드가 같은 응답을 읽음
 */
@Service
public class SqldExamGuideService {

    // 원본 경로 (PQL-Domain-Meta/src/main/resources)
    static final String CONTENT_RESOURCE_PATH = "exam-guide/sqld-exam-guide.json";
    // 응시자 증가 배수 기준: 최신 연도 7년 전 (없으면 첫 연도)
    static final int GROWTH_BASE_YEARS_BEFORE_LATEST = 7;
    private static final ObjectMapper CONTENT_JSON_MAPPER = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);

    private final SqldExamGuideResponse guideResponse;

    public SqldExamGuideService() {
        this(loadContent(CONTENT_RESOURCE_PATH));
    }

    SqldExamGuideService(SqldExamGuideContent content) {
        this.guideResponse = toResponse(content);
    }

    public SqldExamGuideResponse getSqldExamGuide() {
        return guideResponse;
    }

    /** 연도 통계 > 인사이트 (2건 미만이면 null) */
    static Insights calculateInsights(List<YearlyStatistic> yearlyStatistics) {
        if (yearlyStatistics.size() < 2) {
            return null;
        }
        Map<Integer, YearlyStatistic> statisticByYear = yearlyStatistics.stream()
                .collect(Collectors.toMap(YearlyStatistic::year, Function.identity()));
        YearlyStatistic latest = yearlyStatistics.get(yearlyStatistics.size() - 1);
        YearlyStatistic previous = yearlyStatistics.get(yearlyStatistics.size() - 2);
        YearlyStatistic growthBase = statisticByYear.getOrDefault(
                latest.year() - GROWTH_BASE_YEARS_BEFORE_LATEST, yearlyStatistics.get(0));

        double examineeGrowthMultiple = roundTo(
                (double) latest.examineeCount() / growthBase.examineeCount(), 1);
        double passRateChangePoints = roundTo(latest.passRatePercent() - previous.passRatePercent(), 2);
        return new Insights(latest.year(), growthBase.year(), examineeGrowthMultiple, passRateChangePoints);
    }

    // 원본 > 응답 (연도 오름차순 정렬, 인사이트 계산)
    private static SqldExamGuideResponse toResponse(SqldExamGuideContent content) {
        List<YearlyStatistic> sortedStatistics = content.yearlyStatistics().stream()
                .sorted(Comparator.comparingInt(YearlyStatistic::year))
                .toList();
        return new SqldExamGuideResponse(content.oneLineDefinition(), content.organizerName(),
                content.certificationNumber(), content.recommendedFor(), content.subjects(),
                content.examDurationMinutes(), content.passingTotalScore(), content.failingSubjectPercent(),
                content.examFeeWon(), content.validityDescription(), content.faqs(), sortedStatistics,
                content.roundNotes(), content.comparisons(), calculateInsights(sortedStatistics),
                content.sources());
    }

    /** 리소스 JSON > 원본 */
    static SqldExamGuideContent loadContent(String resourcePath) {
        try (InputStream contentStream = new ClassPathResource(resourcePath).getInputStream()) {
            return CONTENT_JSON_MAPPER.readValue(contentStream, SqldExamGuideContent.class);
        } catch (IOException exception) {
            throw new UncheckedIOException("[exam guide] content load failed : " + resourcePath, exception);
        }
    }

    // 반올림 (HALF_UP, double 오차 회피)
    private static double roundTo(double value, int scale) {
        return BigDecimal.valueOf(value).setScale(scale, RoundingMode.HALF_UP).doubleValue();
    }
}
