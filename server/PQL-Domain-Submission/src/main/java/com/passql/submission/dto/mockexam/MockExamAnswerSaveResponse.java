package com.passql.submission.dto.mockexam;

/**
 * 답 저장 결과: 저장 문항 번호, 서버 기준 남은 시간 (앱 타이머 보정)
 */
public record MockExamAnswerSaveResponse(int questionNumber, long remainingSeconds) {
}
