package com.passql.application.entitlement;

import com.passql.question.constant.ChoiceExplanationStatus;
import com.passql.question.dto.ExecuteResult;
import com.passql.question.dto.SubmitResult;
import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import com.passql.question.dto.explanation.KeyConcept;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 무료 회원 응답 빼기: 제출 응답(실행 결과·전체 해설), 선택지 해설 응답(전체 해설), 프로는 그대로
 */
class ProResponseRedactorTest {

    private static final String VERDICT_TEXT = "정답이에요";

    private final FeatureAccessPolicy featureAccessPolicy = mock(FeatureAccessPolicy.class);
    private final ProResponseRedactor redactor = new ProResponseRedactor(featureAccessPolicy);
    private final UUID memberUuid = UUID.randomUUID();

    private void givenFreeMember() {
        when(featureAccessPolicy.canUse(any(), any())).thenReturn(false);
    }

    private void givenProMember() {
        when(featureAccessPolicy.canUse(any(), any())).thenReturn(true);
    }

    private ExecuteResult executeResult() {
        return new ExecuteResult("SUCCESS", List.of("ID"), List.of(List.of(1)), 1, 5L, null, null);
    }

    private ChoiceExplanation fullStructuredExplanation() {
        return new ChoiceExplanation("A", "B", false, VERDICT_TEXT, "정답 근거",
            List.of(new KeyConcept("DENSE_RANK", "순위 함수")), List.of("헷갈리는 점"),
            List.of(new ChoiceAnalysis("A", false, "이유")), "시험 팁");
    }

    private SubmitResult executableSubmitResult() {
        return new SubmitResult(false, "B", "보기 근거", executeResult(), executeResult(),
            "SELECT 2", "SELECT 1", UUID.randomUUID(), "전체 해설 마크다운", fullStructuredExplanation());
    }

    @Test
    void free_submitResult_dropsExecutionAndExplanation() {
        givenFreeMember();
        SubmitResult original = executableSubmitResult();

        SubmitResult redacted = redactor.redactSubmitResult(memberUuid, original);

        assertThat(redacted.selectedResult()).isNull();
        assertThat(redacted.correctResult()).isNull();
        assertThat(redacted.selectedSql()).isNull();
        assertThat(redacted.correctSql()).isNull();
        assertThat(redacted.explanation()).isNull();
        // 판정 한 줄만 남은 해설
        ChoiceExplanation verdictOnly = redacted.structuredExplanation();
        assertThat(verdictOnly.verdict()).isEqualTo(VERDICT_TEXT);
        assertThat(verdictOnly.correctReason()).isNull();
        assertThat(verdictOnly.examTip()).isNull();
        assertThat(verdictOnly.keyConcepts()).isEmpty();
        assertThat(verdictOnly.confusingPoints()).isEmpty();
        assertThat(verdictOnly.choiceAnalyses()).isEmpty();
        assertThat(redacted.lockedSections()).containsExactly("EXECUTION_RESULT", "FULL_EXPLANATION");
        // 정답 여부·정답 키·보기 근거·제출 UUID 유지
        assertThat(redacted.isCorrect()).isFalse();
        assertThat(redacted.correctKey()).isEqualTo("B");
        assertThat(redacted.rationale()).isEqualTo("보기 근거");
        assertThat(redacted.submissionUuid()).isEqualTo(original.submissionUuid());
    }

    @Test
    void free_conceptOnlyQuestion_locksOnlyExplanation() {
        givenFreeMember();
        SubmitResult conceptOnly = new SubmitResult(true, "A", "근거", null, null, null, null,
            UUID.randomUUID(), "해설", null);

        SubmitResult redacted = redactor.redactSubmitResult(memberUuid, conceptOnly);

        assertThat(redacted.lockedSections()).containsExactly("FULL_EXPLANATION");
        assertThat(redacted.explanation()).isNull();
        // 판정이 없으면 구조화 해설은 null (앱이 rationale 로 대신)
        assertThat(redacted.structuredExplanation()).isNull();
        assertThat(redacted.rationale()).isEqualTo("근거");
    }

    @Test
    void pro_submitResult_unchanged() {
        givenProMember();
        SubmitResult original = executableSubmitResult();

        SubmitResult redacted = redactor.redactSubmitResult(memberUuid, original);

        assertThat(redacted).isEqualTo(original);
        assertThat(redacted.lockedSections()).isEmpty();
    }

    @Test
    void free_choiceExplanation_keepsVerdictOnly() {
        givenFreeMember();
        ChoiceExplanationResponse original = new ChoiceExplanationResponse(ChoiceExplanationStatus.READY,
            UUID.randomUUID(), "A", fullStructuredExplanation(), "전체 해설 마크다운", 3, null);

        ChoiceExplanationResponse redacted = redactor.redactChoiceExplanation(memberUuid, original);

        assertThat(redacted.status()).isEqualTo(ChoiceExplanationStatus.READY);
        assertThat(redacted.choiceSetUuid()).isEqualTo(original.choiceSetUuid());
        assertThat(redacted.selectedChoiceKey()).isEqualTo("A");
        assertThat(redacted.explanation().verdict()).isEqualTo(VERDICT_TEXT);
        assertThat(redacted.explanation().correctReason()).isNull();
        assertThat(redacted.text()).isNull();
        assertThat(redacted.lockedSections()).containsExactly("FULL_EXPLANATION");
    }

    @Test
    void pro_choiceExplanation_unchanged() {
        givenProMember();
        ChoiceExplanationResponse original = new ChoiceExplanationResponse(ChoiceExplanationStatus.READY,
            UUID.randomUUID(), "A", fullStructuredExplanation(), "전체 해설 마크다운", 3, null);

        assertThat(redactor.redactChoiceExplanation(memberUuid, original)).isEqualTo(original);
    }
}
