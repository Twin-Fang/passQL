package com.passql.web.support;

import com.passql.common.util.MarkdownTextStripper;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/** 미리보기용 마크다운 정리 (#566): 지문 속 표는 [표] 로, 파이프 원문 미노출 */
class MarkdownTextStripperTest {

    private static final String STEM_WITH_TABLE =
            "다음 중 실행 시 오류가 발생하는 SQL은?\n\n[SALES_Q]\n| YR | Q1 | Q2 |\n| --- | --- | --- |\n| 2025 | 10 | 20 |\n\n결과는?";

    @Test
    void 표_블록은_표_자리_표시로_바뀐다() {
        assertThat(MarkdownTextStripper.replaceTables(STEM_WITH_TABLE))
                .doesNotContain("|")
                .contains("[SALES_Q]\n[표]")
                .endsWith("결과는?");
    }

    @Test
    void 평문_변환도_표를_걷어_낸다() {
        assertThat(MarkdownTextStripper.toPlainText(STEM_WITH_TABLE))
                .isEqualTo("다음 중 실행 시 오류가 발생하는 SQL은? [SALES_Q] [표] 결과는?");
    }

    @Test
    void SQL_이름의_밑줄은_남기고_강조_밑줄만_걷어_낸다() {
        assertThat(MarkdownTextStripper.toPlainText("`EMP_ID` 는 _중요_ 하다")).isEqualTo("EMP_ID 는 중요 하다");
    }

    @Test
    void 한_줄짜리_파이프_글은_표로_보지_않는다() {
        assertThat(MarkdownTextStripper.replaceTables("A | B 중 옳은 것은?")).isEqualTo("A | B 중 옳은 것은?");
    }
}
