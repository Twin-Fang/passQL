package com.passql.question.service;

import com.passql.question.dto.QuestionInternalTagFilter;
import com.passql.question.dto.QuestionInternalTagNormalizeResult;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/** 내부 태그 규칙 (#1117): 정규화·검증·필터 해석 (하네스 internal_tags.py 와 같은 판정이어야 가져오기가 통과) */
class QuestionInternalTagRuleTest {

    @Test
    @DisplayName("정규화: 앞뒤 공백 제거, 영문만 소문자, 한글 그대로, 중복 제거(입력 순서)")
    void normalizesTags() {
        QuestionInternalTagNormalizeResult result = QuestionInternalTagRule.normalizeTags(
                List.of("  Trend:T41 ", "concept:비등가조인", "trend:t41", "NEW-TYPE", "source:63-17"));
        assertThat(result.isValid()).isTrue();
        assertThat(result.tags()).containsExactly("trend:t41", "concept:비등가조인", "new-type", "source:63-17");
    }

    @Test
    @DisplayName("null 목록 > 빈 목록 통과 (태그 칸 없는 옛 가져오기 파일)")
    void acceptsNullList() {
        assertThat(QuestionInternalTagRule.normalizeTags(null).tags()).isEmpty();
    }

    @Test
    @DisplayName("거부: 빈 값, 안쪽 공백, 금지 문자(* 쉼표), 빈 네임스페이스·값, 64자 초과")
    void rejectsInvalidTags() {
        for (String invalidTag : List.of(" ", "concept:null 3값", "trend:t*", "a,b", ":t41", "trend:", "x".repeat(65))) {
            assertThat(QuestionInternalTagRule.normalizeTags(List.of(invalidTag)).isValid())
                    .as(invalidTag).isFalse();
        }
        assertThat(QuestionInternalTagRule.normalizeTags(List.of("가".repeat(64))).isValid()).isTrue();
    }

    @Test
    @DisplayName("문제당 최대 20개 (중복 제거 후 개수)")
    void limitsTagCount() {
        List<String> twentyTags = IntStream.rangeClosed(1, 20).mapToObj(number -> "round:" + number).toList();
        assertThat(QuestionInternalTagRule.normalizeTags(twentyTags).isValid()).isTrue();
        List<String> twentyOneTags = IntStream.rangeClosed(1, 21).mapToObj(number -> "round:" + number).toList();
        assertThat(QuestionInternalTagRule.normalizeTags(twentyOneTags).isValid()).isFalse();
        List<String> duplicatedTags = Collections.nCopies(30, "round:63");
        assertThat(QuestionInternalTagRule.normalizeTags(duplicatedTags).tags()).containsExactly("round:63");
    }

    @Test
    @DisplayName("필터: 정확 일치, 끝 * 앞부분 일치(source:63-*, source:*), 빈 값 무시, 잘못된 필터 거부")
    void parsesFilters() {
        assertThat(QuestionInternalTagRule.toFilterOrNull("Source:63-17"))
                .isEqualTo(new QuestionInternalTagFilter("source:63-17", false));
        assertThat(QuestionInternalTagRule.toFilterOrNull("source:63-*"))
                .isEqualTo(new QuestionInternalTagFilter("source:63-", true));
        assertThat(QuestionInternalTagRule.toFilterOrNull("source:*"))
                .isEqualTo(new QuestionInternalTagFilter("source:", true));
        assertThat(QuestionInternalTagRule.toFilterOrNull("  ")).isNull();
        assertThatThrownBy(() -> QuestionInternalTagRule.toFilterOrNull("*")).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> QuestionInternalTagRule.toFilterOrNull("so*urce:*")).isInstanceOf(IllegalArgumentException.class);
    }
}
