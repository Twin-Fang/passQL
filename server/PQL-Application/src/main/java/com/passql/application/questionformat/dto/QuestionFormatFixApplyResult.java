package com.passql.application.questionformat.dto;

/**
 * 자동 정리 적용 결과 (#905): 고친 문제 수, 바꾼 필드 수, 고칠 것이 없던 문제 수
 */
public record QuestionFormatFixApplyResult(int fixedQuestionCount, int changedFieldCount, int unchangedQuestionCount) {
}
