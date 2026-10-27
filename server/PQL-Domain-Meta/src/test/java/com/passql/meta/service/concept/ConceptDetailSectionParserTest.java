package com.passql.meta.service.concept;

import com.passql.meta.dto.concept.ConceptDetailSection;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ConceptDetailSectionParserTest {

    private final ConceptDetailSectionParser parser = new ConceptDetailSectionParser();

    @Test
    void parse_splitsByHeadingWithAnchor() {
        String detailMd = "## 왜 필요한가요 {#why}\n본문1\n\n## 자주 헷갈리는 점 {#confusing}\n본문2";

        List<ConceptDetailSection> sections = parser.parse(detailMd);

        assertThat(sections).hasSize(2);
        assertThat(sections.get(0).anchor()).isEqualTo("why");
        assertThat(sections.get(0).title()).isEqualTo("왜 필요한가요");
        assertThat(sections.get(0).bodyMd()).isEqualTo("본문1");
        assertThat(sections.get(1).anchor()).isEqualTo("confusing");
        assertThat(sections.get(1).bodyMd()).isEqualTo("본문2");
    }

    @Test
    void parse_keepsCodeBlockContainingHashes() {
        String detailMd = "## 예시 {#example}\n```sql\n## 이 줄은 코드\nSELECT 1 FROM DUAL;\n```\n끝";

        List<ConceptDetailSection> sections = parser.parse(detailMd);

        assertThat(sections).hasSize(1);
        assertThat(sections.get(0).bodyMd()).contains("## 이 줄은 코드").endsWith("끝");
    }

    @Test
    void parse_rejectsHeadingWithoutAnchor() {
        assertThatThrownBy(() -> parser.parse("## 왜 {#why}\n본문\n## 앵커 없는 제목\n본문"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("3");
    }

    @Test
    void parse_rejectsDuplicateAnchor() {
        assertThatThrownBy(() -> parser.parse("## 하나 {#same}\n가\n## 둘 {#same}\n나"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("same");
    }

    @Test
    void parse_rejectsTextBeforeFirstHeading() {
        assertThatThrownBy(() -> parser.parse("머리말\n## 왜 {#why}\n본문"))
            .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void findAnchors_returnsAllAnchorsInOrder() {
        assertThat(parser.findAnchors("## 왜 {#why}\n가\n## 시험 {#exam-point}\n나"))
            .containsExactly("why", "exam-point");
    }
}
