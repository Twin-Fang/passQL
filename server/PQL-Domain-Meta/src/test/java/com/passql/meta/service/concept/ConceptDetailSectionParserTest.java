package com.passql.meta.service.concept;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

/**
 * 자세히 본문 형식 판정: 위반 사유에 줄 번호 포함 (관리자 화면 표시), 정상 본문은 empty
 */
class ConceptDetailSectionParserTest {

    private final ConceptDetailSectionParser parser = new ConceptDetailSectionParser();

    @Test
    void 앵커가_중복되면_줄_번호가_든_사유를_돌려준다() {
        String detailMd = "## 개요 {#intro}\n본문\n## 다시 {#intro}\n";

        assertThat(parser.findFormatViolation(detailMd)).contains("duplicate anchor 'intro' at line 3");
    }

    @Test
    void 형식이_맞으면_사유가_없다() {
        String detailMd = "## 개요 {#intro}\n```\n## 코드 안 제목\n```\n## 예시 {#example}\n본문\n";

        assertThat(parser.findFormatViolation(detailMd)).isEmpty();
    }
}
