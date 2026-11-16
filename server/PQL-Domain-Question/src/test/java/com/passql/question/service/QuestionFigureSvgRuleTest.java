package com.passql.question.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 문제 그림 SVG 검사 (#1132): 내부 마커 참조는 통과, 스크립트·외부 참조·HTML 끼워 넣기는 거부
 */
class QuestionFigureSvgRuleTest {

    @Test
    void 내부_마커를_쓰는_그림과_빈_값은_통과() {
        String figureSvg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\">"
            + "<defs><marker id=\"m\"/></defs><line x1=\"0\" y1=\"0\" x2=\"5\" y2=\"5\" marker-end=\"url(#m)\"/></svg>";

        assertThat(QuestionFigureSvgRule.findRejectReason(figureSvg)).isNull();
        assertThat(QuestionFigureSvgRule.findRejectReason(" ")).isNull();
    }

    @Test
    void 스크립트_외부_링크_이벤트_HTML은_거부() {
        assertThat(QuestionFigureSvgRule.findRejectReason("<svg><script>x</script></svg>")).isNotNull();
        assertThat(QuestionFigureSvgRule.findRejectReason("<svg><a href=\"https://x\"/></svg>")).isNotNull();
        assertThat(QuestionFigureSvgRule.findRejectReason("<svg><rect onclick=\"x\"/></svg>")).isNotNull();
        assertThat(QuestionFigureSvgRule.findRejectReason("<svg><foreignObject/></svg>")).isNotNull();
        assertThat(QuestionFigureSvgRule.findRejectReason("<div></div>")).isNotNull();
    }
}
