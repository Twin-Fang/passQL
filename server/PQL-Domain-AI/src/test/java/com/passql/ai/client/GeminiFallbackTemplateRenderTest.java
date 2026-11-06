package com.passql.ai.client;

import org.junit.jupiter.api.Test;

import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 대체 경로 프롬프트 변수 치환 (AI 서버 render_template 과 같은 규칙, #877)
 */
class GeminiFallbackTemplateRenderTest {

    @Test
    void 변수는_한_번만_치환되고_값_안의_변수_자리는_그대로_남는다() {
        Map<String, String> variables = new HashMap<>();
        variables.put("stem", "{answer_sql} $1");
        variables.put("answer_sql", null);

        String rendered = GeminiFallbackClient.renderTemplate("{stem} / {answer_sql} / {unknown}", variables);

        assertThat(rendered).isEqualTo("{answer_sql} $1 /  / {unknown}");
    }
}
