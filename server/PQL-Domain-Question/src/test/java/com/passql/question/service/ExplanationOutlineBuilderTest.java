package com.passql.question.service;

import com.passql.question.constant.ExplanationOutlineSectionKind;
import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ExplanationOutline;
import com.passql.question.dto.explanation.ExplanationOutlineSection;
import com.passql.question.dto.explanation.KeyConcept;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/** 잠금 표시용 해설 구성 (#999): 본문이 새면 무료가 상세 해설을 그대로 봄, 모양이 틀리면 잠금 미리보기가 실제와 다름 */
class ExplanationOutlineBuilderTest {

    @Test
    @DisplayName("구조화 해설 > 비어 있지 않은 섹션만 화면 순서로, 글자 수는 10자 단위 올림, 본문 없음")
    void buildsOutlineFromExplanationWithoutText() {
        ChoiceExplanation explanation = new ChoiceExplanation("B", "A", false, "오답", "정답 근거 열한 글자다",
            List.of(new KeyConcept("HAVING", "그룹 조건")), List.of(), List.of(
                new ChoiceAnalysis("A", true, "가".repeat(25)),
                new ChoiceAnalysis("B", false, "나".repeat(30))), "  ");

        ExplanationOutline outline = ExplanationOutlineBuilder.buildOrDefault(explanation, 2);

        assertThat(outline.choiceCount()).isEqualTo(2);
        assertThat(outline.sections()).extracting(ExplanationOutlineSection::kind).containsExactly(
            ExplanationOutlineSectionKind.CORRECT_REASON, ExplanationOutlineSectionKind.KEY_CONCEPTS,
            ExplanationOutlineSectionKind.CHOICE_ANALYSES);
        assertThat(outline.sections().get(0).itemCharacterCounts()).containsExactly(20);
        assertThat(outline.sections().get(2).itemCharacterCounts()).containsExactly(30, 30);
    }

    @Test
    @DisplayName("해설 생성 전 > 기본 구성 (시험 팁, 핵심 개념, 보기 수만큼 보기별 판단)")
    void buildsDefaultOutlineWhenExplanationMissing() {
        ExplanationOutline outline = ExplanationOutlineBuilder.buildOrDefault(null, 4);

        assertThat(outline.sections()).extracting(ExplanationOutlineSection::kind).containsExactly(
            ExplanationOutlineSectionKind.EXAM_TIP, ExplanationOutlineSectionKind.KEY_CONCEPTS,
            ExplanationOutlineSectionKind.CHOICE_ANALYSES);
        assertThat(outline.sections().get(2).itemCharacterCounts()).hasSize(4);
    }
}
