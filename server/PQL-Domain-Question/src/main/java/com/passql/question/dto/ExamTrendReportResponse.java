package com.passql.question.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 출제 경향 화면 응답: 요약, 과목 비중, 늘어난 유형, 자주 나오는 개념, 공부 팁, 토픽별 최신 경향 문제 수 (#523)
 * 문구 원본: PQL-Domain-Question resources exam-trend/sqld-latest-trend.json
 */
public record ExamTrendReportResponse(
    String title,
    @Schema(description = "분석 근거 회차·기간 (예: 제58~62회)") String basisDescription,
    @Schema(description = "내용 갱신일 (yyyy-MM-dd)") String updatedDate,
    String summary,
    @Schema(description = "풀 수 있는 최신 경향 문제 총수") Integer latestTrendQuestionCount,
    List<ExamTrendSubjectShare> subjectShares,
    List<ExamTrendPattern> risingPatterns,
    List<ExamTrendConcept> frequentConcepts,
    List<String> studyTips,
    List<LatestTrendTopicCount> latestTrendTopics
) {
    /** 과목별 비중 (문항 수, 백분율) */
    public record ExamTrendSubjectShare(
        String subjectName,
        Integer questionCount,
        Integer percent,
        String description
    ) {}

    /** 최근 회차에서 늘어난 유형 1건 > 관련 토픽 최신 경향 문제 풀기 */
    public record ExamTrendPattern(
        String title,
        String description,
        @Schema(description = "근거 회차 표기 (예: 58회부터 증가)") String examRoundsText,
        String topicCode,
        @Schema(nullable = true) String topicName,
        Integer latestTrendQuestionCount
    ) {}

    /** 자주 나오는 개념 순위 1건 > 관련 토픽 최신 경향 문제 풀기 */
    public record ExamTrendConcept(
        Integer rank,
        String name,
        String description,
        @Schema(description = "최근 4회 출제 빈도 표기 (예: 15문항 이상)") String frequencyText,
        String topicCode,
        @Schema(nullable = true) String topicName,
        Integer latestTrendQuestionCount
    ) {}
}
