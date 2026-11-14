package com.passql.meta.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * SQLD 알아보기 응답 (#1076, #1077): 시험 소개 + 연도별 공식 통계 + 회차 메모(비공식) + 인사이트
 * 원본: PQL-Domain-Meta resources exam-guide/sqld-exam-guide.json (인사이트만 서버 계산)
 */
public record SqldExamGuideResponse(
        String oneLineDefinition,
        String organizerName,
        String certificationNumber,
        List<String> recommendedFor,
        List<Subject> subjects,
        int examDurationMinutes,
        int passingTotalScore,
        @Schema(description = "과목별 과락 기준 (배점 대비 %, 미만이면 과락)") int failingSubjectPercent,
        int examFeeWon,
        String validityDescription,
        List<Faq> faqs,
        @Schema(description = "연도별 공식 통계 (연도 오름차순)") List<YearlyStatistic> yearlyStatistics,
        @Schema(description = "회차 메모 (체감 난이도, 비공식 합격률)") List<RoundNote> roundNotes,
        List<CertificationComparison> comparisons,
        @Schema(nullable = true, description = "연도 통계 2건 미만이면 null") Insights insights,
        List<Source> sources
) {
    public record Subject(String name, int questionCount, int points) {}

    public record Faq(String question, String answer) {}

    public record YearlyStatistic(int year, int applicantCount, int examineeCount, int passerCount,
                                  double passRatePercent) {}

    public record RoundNote(
            int round,
            String examDate,
            String difficultyNote,
            @Schema(nullable = true, description = "알려진 합격률 (없으면 null)") Double passRatePercent,
            @Schema(description = "공식 수치 여부 (false: 수험생 전언·후기)") boolean isOfficial
    ) {}

    public record CertificationComparison(String certificationName, int year, double passRatePercent) {}

    /** 통계에서 계산한 요약: 기준 연도 대비 응시자 배수, 직전 연도 대비 합격률 증감(%p) */
    public record Insights(int latestYear, int growthBaseYear, double examineeGrowthMultiple,
                           double passRateChangePoints) {}

    public record Source(String name, @Schema(nullable = true) String url, String checkedDate) {}
}
