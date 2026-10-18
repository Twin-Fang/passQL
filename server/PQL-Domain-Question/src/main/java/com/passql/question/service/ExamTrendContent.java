package com.passql.question.service;

import com.passql.question.dto.ExamTrendReportResponse.ExamTrendSubjectShare;

import java.util.List;

/**
 * 출제 경향 문구 원본 (resources exam-trend/sqld-latest-trend.json) 모양
 * 문제 수·토픽 이름은 원본에 두지 않음 (ExamTrendService 가 조회해 채움)
 */
record ExamTrendContent(
    String title,
    String basisDescription,
    String updatedDate,
    String summary,
    List<ExamTrendSubjectShare> subjectShares,
    List<PatternContent> risingPatterns,
    List<ConceptContent> frequentConcepts,
    List<String> studyTips
) {
    record PatternContent(String title, String description, String examRoundsText, String topicCode) {}

    record ConceptContent(Integer rank, String name, String description, String frequencyText, String topicCode) {}
}
