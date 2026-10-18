package com.passql.question.service;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.question.dto.ExamTrendReportResponse;
import com.passql.question.dto.ExamTrendReportResponse.ExamTrendConcept;
import com.passql.question.dto.ExamTrendReportResponse.ExamTrendPattern;
import com.passql.question.dto.LatestTrendTopicCount;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 출제 경향 화면: 문구 원본(JSON 리소스) + 토픽별 최신 경향 문제 수 > 응답 (#523)
 * 문구는 버전 관리 (조사 원문 아님, 공개용 요약만), 기동 시 1회 읽기 (형식 오류면 기동 실패)
 */
@Service
@Transactional(readOnly = true)
public class ExamTrendService {

    // 문구 원본 경로 (PQL-Domain-Question/src/main/resources)
    static final String CONTENT_RESOURCE_PATH = "exam-trend/sqld-latest-trend.json";
    private static final ObjectMapper CONTENT_JSON_MAPPER = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, true);

    private final QuestionLatestTrendService latestTrendService;
    private final ExamTrendContent content;

    @Autowired
    public ExamTrendService(QuestionLatestTrendService latestTrendService) {
        this(latestTrendService, loadContent(CONTENT_RESOURCE_PATH));
    }

    ExamTrendService(QuestionLatestTrendService latestTrendService, ExamTrendContent content) {
        this.latestTrendService = latestTrendService;
        this.content = content;
    }

    /** 경향 화면 응답: 문구 + 항목별 관련 토픽 이름·최신 경향 문제 수 */
    public ExamTrendReportResponse getLatestReport() {
        List<LatestTrendTopicCount> topicCounts = latestTrendService.getLatestTrendTopicCounts();
        Map<String, LatestTrendTopicCount> topicCountByCode = topicCounts.stream()
                .collect(Collectors.toMap(LatestTrendTopicCount::topicCode, Function.identity()));
        int totalQuestionCount = topicCounts.stream().mapToInt(LatestTrendTopicCount::latestTrendQuestionCount).sum();

        List<ExamTrendPattern> risingPatterns = content.risingPatterns().stream()
                .map(pattern -> new ExamTrendPattern(pattern.title(), pattern.description(), pattern.examRoundsText(),
                        pattern.topicCode(),
                        topicNameOf(topicCountByCode, pattern.topicCode()),
                        questionCountOf(topicCountByCode, pattern.topicCode())))
                .toList();
        List<ExamTrendConcept> frequentConcepts = content.frequentConcepts().stream()
                .map(concept -> new ExamTrendConcept(concept.rank(), concept.name(), concept.description(),
                        concept.frequencyText(), concept.topicCode(),
                        topicNameOf(topicCountByCode, concept.topicCode()),
                        questionCountOf(topicCountByCode, concept.topicCode())))
                .toList();

        return new ExamTrendReportResponse(content.title(), content.basisDescription(), content.updatedDate(),
                content.summary(), totalQuestionCount, content.subjectShares(), risingPatterns, frequentConcepts,
                content.studyTips(), topicCounts);
    }

    /** 리소스 JSON > 문구 원본 */
    static ExamTrendContent loadContent(String resourcePath) {
        try (InputStream contentStream = new ClassPathResource(resourcePath).getInputStream()) {
            return CONTENT_JSON_MAPPER.readValue(contentStream, ExamTrendContent.class);
        } catch (IOException exception) {
            throw new UncheckedIOException("[exam trend] content load failed : " + resourcePath, exception);
        }
    }

    // 최신 경향 문제 없는 토픽은 이름 null (화면은 풀기 버튼 숨김)
    private static String topicNameOf(Map<String, LatestTrendTopicCount> topicCountByCode, String topicCode) {
        LatestTrendTopicCount topicCount = topicCountByCode.get(topicCode);
        return topicCount != null ? topicCount.topicName() : null;
    }

    private static int questionCountOf(Map<String, LatestTrendTopicCount> topicCountByCode, String topicCode) {
        LatestTrendTopicCount topicCount = topicCountByCode.get(topicCode);
        return topicCount != null ? topicCount.latestTrendQuestionCount() : 0;
    }
}
