package com.passql.question.dto;

import java.util.List;

/**
 * 관리자 저장 전 형식 검사 결과 (#905): 저장 가능 여부, 저장을 막는 위반, 저장본에 이미 있던 위반(경고, 형식 검사 화면에서 정리)
 */
public record AdminQuestionFormatCheckResponse(
        Boolean canSave,
        List<QuestionFormatViolation> blockingViolations,
        List<QuestionFormatViolation> existingViolations
) {
}
