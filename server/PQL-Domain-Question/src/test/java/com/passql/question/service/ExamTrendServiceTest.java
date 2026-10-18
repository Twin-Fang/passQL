package com.passql.question.service;

import com.passql.question.dto.ExamTrendReportResponse;
import com.passql.question.dto.LatestTrendTopicCount;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 출제 경향 화면 (#523): 문구 원본 JSON 형식·토픽 코드 유효성, 토픽별 최신 경향 문제 수 합치기
 */
class ExamTrendServiceTest {

    // 운영 토픽 코드 9개 (meta topic.code, 문구 원본 topicCode 는 이 안에서만)
    private static final Set<String> OPERATING_TOPIC_CODES = Set.of(
            "data_modeling", "sql_basic_select", "sql_function", "sql_join", "sql_subquery",
            "sql_group_aggregate", "sql_window", "sql_hierarchy_pivot", "sql_ddl_dml_tcl");

    private final QuestionLatestTrendService latestTrendService = mock(QuestionLatestTrendService.class);

    @Test
    void 문구_원본은_필수_항목을_모두_갖추고_운영_토픽_코드만_쓴다() {
        ExamTrendContent content = ExamTrendService.loadContent(ExamTrendService.CONTENT_RESOURCE_PATH);

        assertThat(content.title()).isNotBlank();
        assertThat(content.summary()).isNotBlank();
        assertThat(content.subjectShares()).hasSize(2);
        assertThat(content.subjectShares().stream().mapToInt(share -> share.percent()).sum()).isEqualTo(100);
        assertThat(content.risingPatterns()).isNotEmpty();
        assertThat(content.frequentConcepts()).isNotEmpty();
        assertThat(content.studyTips()).isNotEmpty();
        Stream.concat(
                        content.risingPatterns().stream().map(ExamTrendContent.PatternContent::topicCode),
                        content.frequentConcepts().stream().map(ExamTrendContent.ConceptContent::topicCode))
                .forEach(topicCode -> assertThat(OPERATING_TOPIC_CODES).contains(topicCode));
    }

    @Test
    void 항목마다_관련_토픽의_최신_경향_문제_수를_채우고_없으면_0이다() {
        when(latestTrendService.getLatestTrendTopicCounts()).thenReturn(List.of(
                new LatestTrendTopicCount("sql_join", "조인", 3),
                new LatestTrendTopicCount("sql_function", "SQL 함수", 6)));
        ExamTrendService service = new ExamTrendService(latestTrendService);

        ExamTrendReportResponse report = service.getLatestReport();

        assertThat(report.latestTrendQuestionCount()).isEqualTo(9);
        assertThat(report.latestTrendTopics()).hasSize(2);
        ExamTrendReportResponse.ExamTrendPattern joinPattern = report.risingPatterns().stream()
                .filter(pattern -> pattern.topicCode().equals("sql_join")).findFirst().orElseThrow();
        assertThat(joinPattern.topicName()).isEqualTo("조인");
        assertThat(joinPattern.latestTrendQuestionCount()).isEqualTo(3);
        ExamTrendReportResponse.ExamTrendConcept windowConcept = report.frequentConcepts().stream()
                .filter(concept -> concept.topicCode().equals("sql_window")).findFirst().orElseThrow();
        assertThat(windowConcept.topicName()).isNull();
        assertThat(windowConcept.latestTrendQuestionCount()).isZero();
    }
}
