package com.passql.application.service.explanation;

import com.passql.question.dto.explanation.ChoiceSetExplanation;

/**
 * 구조화 해설 생성 결과 (#521): 마지막 시도의 해설·원문 응답·검증 결과, 시도 횟수, 걸린 시간
 * explanation 은 검증 통과 시에만 저장 대상 (하네스는 실패한 원문도 리포트에 남김)
 */
public record ChoiceSetExplanationGenerationResult(
        ChoiceSetExplanation explanation,
        String rawResponse,
        ExplanationValidationResult validation,
        int attemptCount,
        long elapsedMilliseconds
) {

    public boolean isSuccessful() {
        return explanation != null && validation.isValid();
    }
}
