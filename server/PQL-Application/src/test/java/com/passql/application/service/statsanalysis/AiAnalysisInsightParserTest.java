package com.passql.application.service.statsanalysis;

import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * LLM 출력 방어 해석 (#861): 코드 펜스, 모르는 토픽, 첫 문장, "요" 끝맺음
 */
class AiAnalysisInsightParserTest {

    private static final UUID JOIN_TOPIC_UUID = UUID.fromString("00000000-0000-0000-0000-000000000005");
    private static final UUID SUBQUERY_TOPIC_UUID = UUID.fromString("00000000-0000-0000-0000-000000000006");

    @Test
    void 코드_펜스를_벗기고_모르는_토픽은_무시한다() throws Exception {
        String rawOutput = """
                ```json
                {"insights":[
                  {"topicUuid":"00000000-0000-0000-0000-000000000005","text":"OUTER JOIN에서 NULL이 붙는 쪽을 헷갈려요."},
                  {"topicUuid":"00000000-0000-0000-0000-000000000099","text":"모르는 토픽이에요."}
                ]}
                ```""";

        Map<UUID, String> insights = AiAnalysisInsightParser.parse(rawOutput, Set.of(JOIN_TOPIC_UUID, SUBQUERY_TOPIC_UUID));

        assertThat(insights).containsOnlyKeys(JOIN_TOPIC_UUID);
        assertThat(insights.get(JOIN_TOPIC_UUID)).isEqualTo("OUTER JOIN에서 NULL이 붙는 쪽을 헷갈려요.");
    }

    @Test
    void 첫_문장만_남기고_요로_끝나지_않으면_버린다() throws Exception {
        String rawOutput = """
                {"insights":[
                  {"topicUuid":"00000000-0000-0000-0000-000000000005","text":"이행 함수 종속을 헷갈리는 것 같아요. 종속 단계를 기준으로 구분해 보세요."},
                  {"topicUuid":"00000000-0000-0000-0000-000000000006","text":"상관 서브쿼리 복습 필요."}
                ]}""";

        Map<UUID, String> insights = AiAnalysisInsightParser.parse(rawOutput, Set.of(JOIN_TOPIC_UUID, SUBQUERY_TOPIC_UUID));

        assertThat(insights.get(JOIN_TOPIC_UUID)).isEqualTo("이행 함수 종속을 헷갈리는 것 같아요.");
        assertThat(insights).doesNotContainKey(SUBQUERY_TOPIC_UUID);
    }

    @Test
    void 텍스트가_null이거나_70자를_넘으면_버린다() throws Exception {
        String longSentence = "가".repeat(80) + "요.";
        String rawOutput = "{\"insights\":[{\"topicUuid\":\"" + JOIN_TOPIC_UUID + "\",\"text\":null},"
                + "{\"topicUuid\":\"" + SUBQUERY_TOPIC_UUID + "\",\"text\":\"" + longSentence + "\"}]}";

        assertThat(AiAnalysisInsightParser.parse(rawOutput, Set.of(JOIN_TOPIC_UUID, SUBQUERY_TOPIC_UUID))).isEmpty();
    }
}
